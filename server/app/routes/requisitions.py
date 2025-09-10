from flask import request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.extensions import db
from app.models import Requisition, Application, Candidate, AuditLog, CandidateSkill, AssessmentPack
from app.services.matching_service import MatchingService
from app.utils.decorators import role_required
from app.utils.helpers import create_requisition_helper, get_or_create_default_assessment_pack
from datetime import datetime

def init_requisition_routes(app):

    # ------------------- GET ALL REQUISITIONS -------------------
    @app.route('/api/requisitions', methods=['GET'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def get_requisitions():
        try:
            page = request.args.get('page', 1, type=int)
            per_page = request.args.get('per_page', 10, type=int)
            status = request.args.get('status', '')

            query = Requisition.query
            if status:
                query = query.filter_by(status=status)

            requisitions = query.order_by(Requisition.created_at.desc()).paginate(
                page=page, per_page=per_page, error_out=False
            )

            return jsonify({
                'requisitions': [req.to_dict() for req in requisitions.items],
                'total': requisitions.total,
                'pages': requisitions.pages,
                'current_page': page
            }), 200

        except Exception as e:
            current_app.logger.error(f'Get requisitions error: {str(e)}', exc_info=True)
            return jsonify({'error': 'Internal server error'}), 500

    # ------------------- CREATE REQUISITION -------------------
    @app.route('/api/requisitions', methods=['POST'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def create_requisition():
        try:
            current_user_id = get_jwt_identity()
            data = request.get_json()

            if not data:
                return jsonify({'error': 'No input data provided'}), 400

            # Validate required fields
            required_fields = ['title', 'required_skills']
            if not all(field in data for field in required_fields):
                return jsonify({'error': 'Missing required fields'}), 400

            # Validate required_skills
            if not isinstance(data['required_skills'], list) or \
               not all(isinstance(skill, dict) and 'name' in skill for skill in data['required_skills']):
                return jsonify({'error': 'required_skills must be a list of dicts with "name"'}), 400

            # Optional: validate knockout_rules and weightings
            # ...

            # Handle optional assessment_pack_id
            assessment_pack_id = data.get('assessment_pack_id')
            if assessment_pack_id:
                pack = AssessmentPack.query.get(assessment_pack_id)
                if not pack:
                    return jsonify({'error': f'Assessment pack {assessment_pack_id} does not exist'}), 400
            else:
                pack = get_or_create_default_assessment_pack(user_id=current_user_id)

            # Create requisition
            requisition = create_requisition_helper({**data, 'assessment_pack_id': pack.id}, created_by=current_user_id)

            return jsonify({
                'message': 'Requisition created successfully',
                'requisition': requisition.to_dict()
            }), 201

        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f'Create requisition error: {str(e)}', exc_info=True)
            return jsonify({'error': 'Internal server error'}), 500

    # ------------------- GET SINGLE REQUISITION -------------------
    @app.route('/api/requisitions/<int:requisition_id>', methods=['GET'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def get_requisition(requisition_id):
        try:
            requisition = Requisition.query.get_or_404(requisition_id)
            return jsonify({'requisition': requisition.to_dict()}), 200

        except Exception as e:
            current_app.logger.error(f'Get requisition error: {str(e)}', exc_info=True)
            return jsonify({'error': 'Internal server error'}), 500

    # ------------------- UPDATE REQUISITION -------------------
    @app.route('/api/requisitions/<int:requisition_id>', methods=['PUT'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def update_requisition(requisition_id):
        try:
            requisition = Requisition.query.get_or_404(requisition_id)
            data = request.get_json()
            if not data:
                return jsonify({'error': 'Invalid JSON body'}), 422

            # Update allowed fields
            for field in ['title', 'department', 'description', 'requirements', 'required_skills',
                          'min_experience', 'location', 'seniority_level', 'weightings', 'knockout_rules',
                          'assessment_pack_id', 'status']:
                if field in data:
                    if field == 'assessment_pack_id':
                        pack = AssessmentPack.query.get(data[field])
                        if not pack:
                            return jsonify({'error': f'Assessment pack {data[field]} does not exist'}), 400
                        setattr(requisition, field, pack.id)
                    else:
                        setattr(requisition, field, data[field])

            requisition.updated_at = datetime.utcnow()
            db.session.commit()

            return jsonify({'message': 'Requisition updated successfully', 'requisition': requisition.to_dict()}), 200

        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f'Update requisition error: {str(e)}', exc_info=True)
            return jsonify({'error': 'Internal server error'}), 500

    # ------------------- DELETE REQUISITION -------------------
    @app.route('/api/requisitions/<int:requisition_id>', methods=['DELETE'])
    @jwt_required()
    @role_required('admin')
    def delete_requisition(requisition_id):
        try:
            requisition = Requisition.query.get_or_404(requisition_id)
            if Application.query.filter_by(requisition_id=requisition_id).first():
                return jsonify({'error': 'Cannot delete requisition with applications'}), 400

            db.session.delete(requisition)
            db.session.commit()

            return jsonify({'message': 'Requisition deleted successfully'}), 200

        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f'Delete requisition error: {str(e)}', exc_info=True)
            return jsonify({'error': 'Internal server error'}), 500

    # ------------------- APPLY TO REQUISITION -------------------
    @app.route('/api/requisitions/<int:requisition_id>/apply', methods=['POST'])
    def apply_to_requisition(requisition_id):
        try:
            requisition = Requisition.query.get_or_404(requisition_id)
            if requisition.status != 'open':
                return jsonify({'error': 'Requisition is not open for applications'}), 400

            data = request.get_json()
            if not data or 'candidate_id' not in data:
                return jsonify({'error': 'Candidate ID is required'}), 422

            candidate = Candidate.query.get_or_404(data['candidate_id'])

            # Prevent duplicate applications
            if Application.query.filter_by(candidate_id=candidate.id, requisition_id=requisition_id).first():
                return jsonify({'error': 'Already applied to this requisition'}), 409

            match_service = MatchingService()
            cv_match_score = match_service.calculate_cv_match_score(
                [skill.skill for skill in candidate.skills],
                candidate.total_experience,
                requisition.to_dict()
            )

            application = Application(
                candidate_id=candidate.id,
                requisition_id=requisition_id,
                cv_match_score=cv_match_score,
                status='applied' if cv_match_score > 0 else 'rejected',
                recommendation='hold' if cv_match_score > 0 else 'reject'
            )

            db.session.add(application)
            db.session.flush()  # Ensure application.id exists for audit log

            audit_log = AuditLog(
                application_id=application.id,
                action='Applied to requisition',
                changed_by=candidate.id,
                old_values=None,
                new_values={'status': application.status, 'cv_match_score': cv_match_score}
            )
            db.session.add(audit_log)
            db.session.commit()

            return jsonify({'message': 'Application submitted successfully', 'application': application.to_dict()}), 201

        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f'Apply to requisition error: {str(e)}', exc_info=True)
            return jsonify({'error': 'Internal server error'}), 500

    # ------------------- GET REQUISITION APPLICATIONS -------------------
    @app.route('/api/requisitions/<int:requisition_id>/applications', methods=['GET'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def get_requisition_applications(requisition_id):
        try:
            requisition = Requisition.query.get_or_404(requisition_id)

            page = request.args.get('page', 1, type=int)
            per_page = request.args.get('per_page', 10, type=int)
            status = request.args.get('status', '')
            recommendation = request.args.get('recommendation', '')

            query = Application.query.filter_by(requisition_id=requisition_id)
            if status:
                query = query.filter_by(status=status)
            if recommendation:
                query = query.filter_by(recommendation=recommendation)

            applications = query.order_by(Application.overall_score.desc()).paginate(
                page=page, per_page=per_page, error_out=False
            )

            applications_data = []
            for app in applications.items:
                app_data = app.to_dict()
                app_data['candidate'] = app.candidate.to_dict()
                applications_data.append(app_data)

            return jsonify({
                'applications': applications_data,
                'total': applications.total,
                'pages': applications.pages,
                'current_page': page
            }), 200

        except Exception as e:
            current_app.logger.error(f'Get requisition applications error: {str(e)}', exc_info=True)
            return jsonify({'error': 'Internal server error'}), 500

    # ------------------- SHORTLIST -------------------
    @app.route('/api/requisitions/<int:requisition_id>/shortlist', methods=['GET'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def get_requisition_shortlist(requisition_id):
        try:
            requisition = Requisition.query.get_or_404(requisition_id)

            applications = Application.query.filter_by(
                requisition_id=requisition_id,
                recommendation='proceed'
            ).order_by(Application.overall_score.desc()).all()

            shortlist = []
            for app in applications:
                app_data = app.to_dict()
                app_data['candidate'] = app.candidate.to_dict()
                skills = CandidateSkill.query.filter_by(candidate_id=app.candidate_id).all()
                app_data['candidate']['skills'] = [skill.to_dict() for skill in skills]
                shortlist.append(app_data)

            return jsonify({'shortlist': shortlist}), 200

        except Exception as e:
            current_app.logger.error(f'Get requisition shortlist error: {str(e)}', exc_info=True)
            return jsonify({'error': 'Internal server error'}), 500

    # ------------------- UPDATE APPLICATION STATUS -------------------
    @app.route('/api/applications/<int:application_id>', methods=['PUT'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def update_application_status(application_id):
        try:
            current_user_id = get_jwt_identity()
            data = request.get_json()
            if not data:
                return jsonify({'error': 'Invalid JSON body'}), 422

            application = Application.query.get_or_404(application_id)
            old_status = application.status
            old_recommendation = application.recommendation

            for field in ['status', 'recommendation']:
                if field in data:
                    setattr(application, field, data[field])

            # Update timestamps based on status changes
            if application.status == 'screened' and old_status != 'screened':
                application.screened_date = datetime.utcnow()
            elif application.status == 'assessed' and old_status != 'assessed':
                application.assessed_date = datetime.utcnow()
            elif application.status == 'recommended' and old_status != 'recommended':
                application.shortlisted_date = datetime.utcnow()

            audit_log = AuditLog(
                application_id=application.id,
                action='Status updated',
                changed_by=current_user_id,
                old_values={'status': old_status, 'recommendation': old_recommendation},
                new_values={'status': application.status, 'recommendation': application.recommendation}
            )
            db.session.add(audit_log)
            db.session.commit()

            return jsonify({'message': 'Application updated successfully', 'application': application.to_dict()}), 200

        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f'Update application status error: {str(e)}', exc_info=True)
            return jsonify({'error': 'Internal server error'}), 500

    # ------------------- GET APPLICATION AUDIT LOGS -------------------
    @app.route('/api/applications/<int:application_id>/audit-logs', methods=['GET'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def get_application_audit_logs(application_id):
        try:
            logs = AuditLog.query.filter_by(application_id=application_id)\
                .order_by(AuditLog.changed_at.desc()).all()
            return jsonify({'audit_logs': [log.to_dict() for log in logs]}), 200

        except Exception as e:
            current_app.logger.error(f'Get application audit logs error: {str(e)}', exc_info=True)
            return jsonify({'error': 'Internal server error'}), 500
