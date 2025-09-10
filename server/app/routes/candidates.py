from flask import request, jsonify, current_app
from flask_jwt_extended import jwt_required
from app.extensions import db
from app.models import Candidate, Application, CandidateSkill, Requisition
from app.services.cv_parser import CVParser
from app.utils.decorators import role_required
from datetime import datetime
import os
import cloudinary.uploader

def init_candidate_routes(app):

    # ---------- GET all candidates ----------
    @app.route('/api/candidates', methods=['GET'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def get_candidates():
        try:
            page = request.args.get('page', 1, type=int)
            per_page = request.args.get('per_page', 10, type=int)
            search = request.args.get('search', '')

            query = Candidate.query
            if search:
                query = query.filter(
                    (Candidate.first_name.ilike(f'%{search}%')) |
                    (Candidate.last_name.ilike(f'%{search}%')) |
                    (Candidate.email.ilike(f'%{search}%')) |
                    (Candidate.current_company.ilike(f'%{search}%'))
                )

            candidates = query.paginate(page=page, per_page=per_page, error_out=False)

            return jsonify({
                'candidates': [c.to_dict() for c in candidates.items],
                'total': candidates.total,
                'pages': candidates.pages,
                'current_page': page
            }), 200

        except Exception as e:
            current_app.logger.error(f'Get candidates error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500

    # ---------- CREATE candidate ----------
    @app.route('/api/candidates', methods=['POST'])
    def create_candidate():
        try:
            data = request.form.to_dict()
            files = request.files

            # Required fields check
            required_fields = ['first_name', 'last_name', 'email']
            missing = [f for f in required_fields if not data.get(f)]
            if missing:
                return jsonify({'error': f'Missing required fields: {", ".join(missing)}'}), 400

            # Duplicate email check
            if Candidate.query.filter_by(email=data['email']).first():
                return jsonify({'error': 'Candidate with this email already exists'}), 409

            # ---------- Handle CV ----------
            cv_path = None
            cv_text = None
            parsed_data = {}
            cv_file = files.get('cv')

            if cv_file:
                if cv_file.filename == "":
                    return jsonify({"error": "CV file is empty"}), 400

                # Cloudinary upload
                upload_result = cloudinary.uploader.upload(
                    cv_file,
                    folder="recruitment/cvs",
                    resource_type="auto"
                )
                cv_path = upload_result['secure_url']

                # Temporary save for parsing
                temp_path = os.path.join(current_app.config['CV_UPLOAD_FOLDER'], cv_file.filename)
                os.makedirs(os.path.dirname(temp_path), exist_ok=True)
                cv_file.save(temp_path)

                file_ext = os.path.splitext(cv_file.filename)[1].lower()
                file_type = 'pdf' if file_ext == '.pdf' else 'docx' if file_ext == '.docx' else 'txt'

                # Parse CV safely
                try:
                    parser = CVParser()
                    cv_text = parser.extract_text_from_file(temp_path, file_type)
                    parsed_data = parser.parse_cv(cv_text)
                except Exception as e:
                    current_app.logger.warning(f"CV parsing failed: {str(e)}")
                    cv_text = None
                    parsed_data = {}

                # Clean up temp file
                if os.path.exists(temp_path):
                    os.remove(temp_path)

            # Merge parsed data
            candidate_data = {
                'first_name': data['first_name'],
                'last_name': data['last_name'],
                'email': data['email'],
                'phone': parsed_data.get('phone') or data.get('phone'),
                'location': data.get('location'),
                'current_company': parsed_data.get('experience', {}).get('details', [{}])[0].split(' at ')[-1] 
                                   if parsed_data.get('experience', {}).get('details') else data.get('current_company'),
                'current_title': parsed_data.get('experience', {}).get('details', [{}])[0].split(' at ')[0] 
                                 if parsed_data.get('experience', {}).get('details') else data.get('current_title'),
                'total_experience': float(parsed_data.get('experience', {}).get('total_years', 0)),
                'summary': ' '.join(parsed_data.get('education', []))[:500] if parsed_data.get('education') else data.get('summary', ''),
                'cv_path': cv_path,
                'cv_text': cv_text,
                'consent_given': data.get('consent_given', 'false').lower() == 'true',
                'consent_date': datetime.utcnow() if data.get('consent_given', 'false').lower() == 'true' else None
            }

            candidate = Candidate(**candidate_data)
            db.session.add(candidate)
            db.session.commit()

            # ---------- Add skills ----------
            if 'skills' in data:
                try:
                    skills = eval(data['skills']) if isinstance(data['skills'], str) else data['skills']
                    for s in skills:
                        skill = CandidateSkill(
                            candidate_id=candidate.id,
                            skill=s.get('skill'),
                            years_experience=s.get('years_experience'),
                            proficiency_level=s.get('proficiency_level')
                        )
                        db.session.add(skill)
                    db.session.commit()
                except Exception as e:
                    db.session.rollback()
                    current_app.logger.error(f'Error adding candidate skills: {str(e)}')

            return jsonify({'message': 'Candidate created successfully', 'candidate': candidate.to_dict()}), 201

        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f'Create candidate error: {str(e)}')
            return jsonify({'error': str(e)}), 500

    # ---------- GET candidate by ID ----------
    @app.route('/api/candidates/<int:candidate_id>', methods=['GET'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def get_candidate(candidate_id):
        try:
            candidate = Candidate.query.get_or_404(candidate_id)
            data = candidate.to_dict()
            # Skills
            data['skills'] = [s.to_dict() for s in CandidateSkill.query.filter_by(candidate_id=candidate_id).all()]
            # Applications
            data['applications'] = [a.to_dict() for a in Application.query.filter_by(candidate_id=candidate_id).all()]
            return jsonify({'candidate': data}), 200
        except Exception as e:
            current_app.logger.error(f'Get candidate error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500

    # ---------- UPDATE candidate ----------
    @app.route('/api/candidates/<int:candidate_id>', methods=['PUT'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def update_candidate(candidate_id):
        try:
            candidate = Candidate.query.get_or_404(candidate_id)
            data = request.get_json()
            for field in ['first_name', 'last_name', 'email', 'phone', 'location',
                          'current_company', 'current_title', 'total_experience', 'summary']:
                if field in data:
                    setattr(candidate, field, data[field])
            candidate.updated_at = datetime.utcnow()
            db.session.commit()
            return jsonify({'message': 'Candidate updated successfully', 'candidate': candidate.to_dict()}), 200
        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f'Update candidate error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500

    # ---------- ADD candidate skill ----------
    @app.route('/api/candidates/<int:candidate_id>/skills', methods=['POST'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def add_candidate_skill(candidate_id):
        try:
            candidate = Candidate.query.get_or_404(candidate_id)
            data = request.get_json()
            skill = CandidateSkill(
                candidate_id=candidate_id,
                skill=data['skill'],
                years_experience=data.get('years_experience'),
                proficiency_level=data.get('proficiency_level')
            )
            db.session.add(skill)
            db.session.commit()
            return jsonify({'message': 'Skill added successfully', 'skill': skill.to_dict()}), 201
        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f'Add candidate skill error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500

    # ---------- DELETE candidate skill ----------
    @app.route('/api/candidates/<int:candidate_id>/skills/<int:skill_id>', methods=['DELETE'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def delete_candidate_skill(candidate_id, skill_id):
        try:
            skill = CandidateSkill.query.filter_by(id=skill_id, candidate_id=candidate_id).first_or_404()
            db.session.delete(skill)
            db.session.commit()
            return jsonify({'message': 'Skill deleted successfully'}), 200
        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f'Delete candidate skill error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500

    # ---------- GET candidates for requisition ----------
    @app.route('/api/requisitions/<int:requisition_id>/candidates', methods=['GET'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def get_candidates_for_requisition(requisition_id):
        try:
            requisition = Requisition.query.get_or_404(requisition_id)
            applications = Application.query.filter_by(requisition_id=requisition_id).all()
            candidates = []
            for app in applications:
                c = app.candidate
                c_data = c.to_dict()
                c_data['application'] = app.to_dict()
                c_data['skills'] = [s.to_dict() for s in CandidateSkill.query.filter_by(candidate_id=c.id).all()]
                candidates.append(c_data)
            return jsonify({'candidates': candidates}), 200
        except Exception as e:
            current_app.logger.error(f'Get candidates for requisition error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500
