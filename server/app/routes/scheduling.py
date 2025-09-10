from flask import request, jsonify, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.extensions import db, socketio
from app.models import Interview, Application, User
from app.utils.decorators import role_required
from datetime import datetime, timedelta
import json

def init_scheduling_routes(app):
    @app.route('/api/interviews', methods=['GET'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def get_interviews():
        try:
            page = request.args.get('page', 1, type=int)
            per_page = request.args.get('per_page', 10, type=int)
            status = request.args.get('status', '')
            start_date = request.args.get('start_date', '')
            end_date = request.args.get('end_date', '')
            
            query = Interview.query
            
            if status:
                query = query.filter_by(status=status)
            
            if start_date:
                start_datetime = datetime.fromisoformat(start_date)
                query = query.filter(Interview.scheduled_date >= start_datetime)
            
            if end_date:
                end_datetime = datetime.fromisoformat(end_date) + timedelta(days=1)
                query = query.filter(Interview.scheduled_date < end_datetime)
            
            interviews = query.order_by(Interview.scheduled_date.asc()).paginate(
                page=page, per_page=per_page, error_out=False
            )
            
            interviews_data = []
            for interview in interviews.items:
                interview_data = interview.to_dict()
                interview_data['application'] = interview.application.to_dict()
                interview_data['application']['candidate'] = interview.application.candidate.to_dict()
                
                # Get interviewer details
                if interview.interviewers:
                    interviewers = User.query.filter(User.id.in_(interview.interviewers)).all()
                    interview_data['interviewer_details'] = [user.to_dict() for user in interviewers]
                
                interviews_data.append(interview_data)
            
            return jsonify({
                'interviews': interviews_data,
                'total': interviews.total,
                'pages': interviews.pages,
                'current_page': page
            }), 200
            
        except Exception as e:
            current_app.logger.error(f'Get interviews error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500

    @app.route('/api/interviews', methods=['POST'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def create_interview():
        try:
            current_user_id = get_jwt_identity()
            data = request.get_json()
            
            required_fields = ['application_id', 'scheduled_date', 'duration', 'interviewers']
            if not all(field in data for field in required_fields):
                return jsonify({'error': 'Missing required fields'}), 400
            
            application = Application.query.get_or_404(data['application_id'])
            
            # Check if interview already exists for this application
            existing_interview = Interview.query.filter_by(application_id=data['application_id']).first()
            if existing_interview:
                return jsonify({'error': 'Interview already scheduled for this application'}), 409
            
            # Parse scheduled date
            scheduled_date = datetime.fromisoformat(data['scheduled_date'].replace('Z', '+00:00'))
            
            interview = Interview(
                application_id=data['application_id'],
                type=data.get('type', 'video'),
                scheduled_date=scheduled_date,
                duration=data['duration'],
                interviewers=data['interviewers'],
                status='scheduled'
            )
            
            db.session.add(interview)
            
            # Update application status
            application.status = 'interview'
            
            db.session.commit()
            
            # Emit socket event for real-time update
            socketio.emit('interview_scheduled', {
                'interview': interview.to_dict(),
                'application': application.to_dict(),
                'candidate': application.candidate.to_dict()
            })
            
            return jsonify({
                'message': 'Interview scheduled successfully',
                'interview': interview.to_dict()
            }), 201
            
        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f'Create interview error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500

    @app.route('/api/interviews/<int:interview_id>', methods=['GET'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def get_interview(interview_id):
        try:
            interview = Interview.query.get_or_404(interview_id)
            interview_data = interview.to_dict()
            
            interview_data['application'] = interview.application.to_dict()
            interview_data['application']['candidate'] = interview.application.candidate.to_dict()
            
            # Get interviewer details
            if interview.interviewers:
                interviewers = User.query.filter(User.id.in_(interview.interviewers)).all()
                interview_data['interviewer_details'] = [user.to_dict() for user in interviewers]
            
            return jsonify({'interview': interview_data}), 200
            
        except Exception as e:
            current_app.logger.error(f'Get interview error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500

    @app.route('/api/interviews/<int:interview_id>', methods=['PUT'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def update_interview(interview_id):
        try:
            interview = Interview.query.get_or_404(interview_id)
            data = request.get_json()
            
            if 'type' in data:
                interview.type = data['type']
            if 'scheduled_date' in data:
                interview.scheduled_date = datetime.fromisoformat(data['scheduled_date'].replace('Z', '+00:00'))
            if 'duration' in data:
                interview.duration = data['duration']
            if 'interviewers' in data:
                interview.interviewers = data['interviewers']
            if 'status' in data:
                interview.status = data['status']
            if 'feedback' in data:
                interview.feedback = data['feedback']
            if 'rating' in data:
                interview.rating = data['rating']
            
            db.session.commit()
            
            # Emit socket event for real-time update
            socketio.emit('interview_updated', {
                'interview': interview.to_dict(),
                'application': interview.application.to_dict(),
                'candidate': interview.application.candidate.to_dict()
            })
            
            return jsonify({
                'message': 'Interview updated successfully',
                'interview': interview.to_dict()
            }), 200
            
        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f'Update interview error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500

    @app.route('/api/interviews/<int:interview_id>', methods=['DELETE'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def cancel_interview(interview_id):
        try:
            interview = Interview.query.get_or_404(interview_id)
            
            # Update application status back to previous state
            application = interview.application
            application.status = 'recommended'
            
            db.session.delete(interview)
            db.session.commit()
            
            # Emit socket event for real-time update
            socketio.emit('interview_cancelled', {
                'interview_id': interview_id,
                'application': application.to_dict(),
                'candidate': application.candidate.to_dict()
            })
            
            return jsonify({'message': 'Interview cancelled successfully'}), 200
            
        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f'Cancel interview error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500

    @app.route('/api/interviews/<int:interview_id>/feedback', methods=['POST'])
    @jwt_required()
    def submit_interview_feedback(interview_id):
        try:
            current_user_id = get_jwt_identity()
            interview = Interview.query.get_or_404(interview_id)
            
            # Check if user is an interviewer
            if current_user_id not in interview.interviewers:
                return jsonify({'error': 'Not authorized to provide feedback for this interview'}), 403
            
            data = request.get_json()
            feedback = data.get('feedback', '')
            rating = data.get('rating', 0)
            
            # Initialize feedback array if not exists
            if not interview.feedback:
                interview.feedback = []
            
            # Add new feedback
            interview.feedback.append({
                'interviewer_id': current_user_id,
                'feedback': feedback,
                'rating': rating,
                'submitted_at': datetime.utcnow().isoformat()
            })
            
            # Calculate average rating
            ratings = [f['rating'] for f in interview.feedback if f['rating']]
            if ratings:
                interview.rating = sum(ratings) / len(ratings)
            
            db.session.commit()
            
            return jsonify({
                'message': 'Feedback submitted successfully',
                'interview': interview.to_dict()
            }), 200
            
        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f'Submit interview feedback error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500

    @app.route('/api/users/<int:user_id>/availability', methods=['GET'])
    @jwt_required()
    def get_user_availability(user_id):
        try:
            current_user_id = get_jwt_identity()
            
            # Users can only view their own availability unless they're admin/recruiter
            from app.models.postgres_models import User
            current_user = User.query.get(current_user_id)
            if user_id != current_user_id and current_user.role not in ['admin', 'recruiter']:
                return jsonify({'error': 'Not authorized to view this user\'s availability'}), 403
            
            # Get availability from user preferences or database
            user = User.query.get_or_404(user_id)
            preferences = user.preferences or {}
            availability = preferences.get('availability', {})
            
            return jsonify({'availability': availability}), 200
            
        except Exception as e:
            current_app.logger.error(f'Get user availability error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500

    @app.route('/api/users/<int:user_id>/availability', methods=['PUT'])
    @jwt_required()
    def update_user_availability(user_id):
        try:
            current_user_id = get_jwt_identity()
            
            # Users can only update their own availability
            if user_id != current_user_id:
                return jsonify({'error': 'Not authorized to update this user\'s availability'}), 403
            
            user = User.query.get_or_404(user_id)
            data = request.get_json()
            availability = data.get('availability', {})
            
            # Initialize preferences if not exists
            if not user.preferences:
                user.preferences = {}
            
            user.preferences['availability'] = availability
            db.session.commit()
            
            return jsonify({
                'message': 'Availability updated successfully',
                'availability': availability
            }), 200
            
        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f'Update user availability error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500

    @app.route('/api/scheduling/suggest-slots', methods=['POST'])
    @jwt_required()
    @role_required('recruiter', 'hiring_manager', 'admin')
    def suggest_interview_slots():
        try:
            data = request.get_json()
            interviewer_ids = data.get('interviewer_ids', [])
            duration = data.get('duration', 60)
            date_range = data.get('date_range', {})
            
            if not interviewer_ids:
                return jsonify({'error': 'At least one interviewer is required'}), 400
            
            # Get availability for all interviewers
            available_slots = []
            for interviewer_id in interviewer_ids:
                user = User.query.get(interviewer_id)
                if user and user.preferences and 'availability' in user.preferences:
                    available_slots.append(user.preferences['availability'])
            
            # Find common available slots (simplified logic)
            # In a real implementation, this would use a more sophisticated algorithm
            common_slots = self.find_common_slots(available_slots, duration, date_range)
            
            return jsonify({
                'suggested_slots': common_slots
            }), 200
            
        except Exception as e:
            current_app.logger.error(f'Suggest interview slots error: {str(e)}')
            return jsonify({'error': 'Internal server error'}), 500

    def find_common_slots(self, available_slots, duration, date_range):
        # Simplified implementation - in production, this would use a proper scheduling algorithm
        # that considers time zones, working hours, existing appointments, etc.
        
        # For now, return some mock slots
        import random
        from datetime import datetime, timedelta
        
        slots = []
        start_date = datetime.fromisoformat(date_range.get('start', datetime.now().isoformat()))
        end_date = datetime.fromisoformat(date_range.get('end', (datetime.now() + timedelta(days=7)).isoformat()))
        
        current_date = start_date
        while current_date <= end_date:
            # Only suggest slots on weekdays
            if current_date.weekday() < 5:
                for hour in [9, 11, 14, 16]:  # 9am, 11am, 2pm, 4pm
                    slot_time = current_date.replace(hour=hour, minute=0, second=0, microsecond=0)
                    if slot_time > datetime.now():  # Only future slots
                        slots.append({
                            'start_time': slot_time.isoformat(),
                            'end_time': (slot_time + timedelta(minutes=duration)).isoformat(),
                            'available': random.choice([True, False])  # Mock availability
                        })
            current_date += timedelta(days=1)
        
        return slots