from flask import request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.extensions import db
from app.models import AssessmentPack, AssessmentResult, Application, Requisition
from app.utils.decorators import role_required
from datetime import datetime

def init_assessment_routes(app):
    @app.route('/api/assessment-packs', methods=['GET'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def get_assessment_packs():
        try:
            page = request.args.get('page', 1, type=int)
            per_page = request.args.get('per_page', 10, type=int)
            
            packs = AssessmentPack.query.paginate(
                page=page, per_page=per_page, error_out=False
            )
            
            return jsonify({
                'assessment_packs': [pack.to_dict() for pack in packs.items],
                'total': packs.total,
                'pages': packs.pages,
                'current_page': page
            }), 200
            
        except Exception as e:
            current_app.logger.error(f'Get assessment packs error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500

    @app.route('/api/assessment-packs', methods=['POST'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def create_assessment_pack():
        try:
            current_user_id = get_jwt_identity()
            data = request.get_json()
            
            required_fields = ['name', 'type', 'questions']
            if not all(field in data for field in required_fields):
                return jsonify({'error': 'Missing required fields'}), 400
            
            pack = AssessmentPack(
                name=data['name'],
                description=data.get('description'),
                type=data['type'],
                questions=data['questions'],
                time_limit=data.get('time_limit', 30),
                passing_score=data.get('passing_score', 70),
                created_by=current_user_id
            )
            
            db.session.add(pack)
            db.session.commit()
            
            return jsonify({
                'message': 'Assessment pack created successfully',
                'assessment_pack': pack.to_dict()
            }), 201
            
        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f'Create assessment pack error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500

    @app.route('/api/assessment-packs/<int:pack_id>', methods=['GET'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def get_assessment_pack(pack_id):
        try:
            pack = AssessmentPack.query.get_or_404(pack_id)
            return jsonify({'assessment_pack': pack.to_dict()}), 200
            
        except Exception as e:
            current_app.logger.error(f'Get assessment pack error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500

    @app.route('/api/assessment-packs/<int:pack_id>', methods=['PUT'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def update_assessment_pack(pack_id):
        try:
            pack = AssessmentPack.query.get_or_404(pack_id)
            data = request.get_json()
            
            if 'name' in data:
                pack.name = data['name']
            if 'description' in data:
                pack.description = data['description']
            if 'type' in data:
                pack.type = data['type']
            if 'questions' in data:
                pack.questions = data['questions']
            if 'time_limit' in data:
                pack.time_limit = data['time_limit']
            if 'passing_score' in data:
                pack.passing_score = data['passing_score']
            
            pack.updated_at = datetime.utcnow()
            db.session.commit()
            
            return jsonify({
                'message': 'Assessment pack updated successfully',
                'assessment_pack': pack.to_dict()
            }), 200
            
        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f'Update assessment pack error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500

    @app.route('/api/assessment-packs/<int:pack_id>', methods=['DELETE'])
    @jwt_required()
    @role_required('admin')
    def delete_assessment_pack(pack_id):
        try:
            pack = AssessmentPack.query.get_or_404(pack_id)
            
            # Check if pack is used in any requisitions
            if Requisition.query.filter_by(assessment_pack_id=pack_id).first():
                return jsonify({'error': 'Cannot delete assessment pack that is in use'}), 400
            
            db.session.delete(pack)
            db.session.commit()
            
            return jsonify({'message': 'Assessment pack deleted successfully'}), 200
            
        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f'Delete assessment pack error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500

    @app.route('/api/applications/<int:application_id>/assessment', methods=['POST'])
    @jwt_required()
    def submit_assessment(application_id):
        try:
            application = Application.query.get_or_404(application_id)
            
            if application.status != 'screened':
                return jsonify({'error': 'Application not ready for assessment'}), 400
            
            data = request.get_json()
            answers = data.get('answers', [])
            time_taken = data.get('time_taken', 0)
            
            # Get assessment pack from requisition
            requisition = application.requisition
            if not requisition.assessment_pack_id:
                return jsonify({'error': 'No assessment pack assigned to this requisition'}), 400
            
            assessment_pack = AssessmentPack.query.get(requisition.assessment_pack_id)
            
            # Calculate score
            from app.services.matching_service import MatchingService
            correct_answers = [q.get('correct_answer') for q in assessment_pack.questions if 'correct_answer' in q]
            assessment_score = MatchingService().calculate_assessment_score(answers, correct_answers)
            
            # Save assessment result
            result = AssessmentResult(
                application_id=application_id,
                score=assessment_score,
                answers=answers,
                time_taken=time_taken
            )
            
            db.session.add(result)
            
            # Update application
            application.assessment_score = assessment_score
            application.overall_score = MatchingService().calculate_overall_score(
                application.cv_match_score, 
                assessment_score, 
                requisition.weightings
            )
            application.recommendation = MatchingService().get_recommendation(application.overall_score)
            application.status = 'assessed'
            application.assessed_date = datetime.utcnow()
            
            db.session.commit()
            
            return jsonify({
                'message': 'Assessment submitted successfully',
                'score': assessment_score,
                'overall_score': application.overall_score,
                'recommendation': application.recommendation
            }), 200
            
        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f'Submit assessment error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500

    @app.route('/api/applications/<int:application_id>/assessment', methods=['GET'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def get_assessment_result(application_id):
        try:
            result = AssessmentResult.query.filter_by(application_id=application_id).first()
            
            if not result:
                return jsonify({'error': 'Assessment result not found'}), 404
            
            return jsonify({'assessment_result': result.to_dict()}), 200
            
        except Exception as e:
            current_app.logger.error(f'Get assessment result error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500