from app.extensions import db
from datetime import datetime

class Application(db.Model):
    __tablename__ = 'applications'
    
    id = db.Column(db.Integer, primary_key=True)
    candidate_id = db.Column(db.Integer, db.ForeignKey('candidates.id'), nullable=False)
    requisition_id = db.Column(db.Integer, db.ForeignKey('requisitions.id'), nullable=False)
    cv_match_score = db.Column(db.Float)
    assessment_score = db.Column(db.Float)
    overall_score = db.Column(db.Float)
    status = db.Column(db.String(20), default='applied')
    recommendation = db.Column(db.String(20))
    applied_date = db.Column(db.DateTime, default=datetime.utcnow)
    screened_date = db.Column(db.DateTime)
    assessed_date = db.Column(db.DateTime)
    shortlisted_date = db.Column(db.DateTime)
    
    # Relationships
    assessment_results = db.relationship('AssessmentResult', backref='application', lazy=True)
    interviews = db.relationship('Interview', backref='application', lazy=True)
    audit_logs = db.relationship('AuditLog', backref='application', lazy=True)
    
    def to_dict(self):
        return {
            'id': self.id,
            'candidate_id': self.candidate_id,
            'requisition_id': self.requisition_id,
            'cv_match_score': self.cv_match_score,
            'assessment_score': self.assessment_score,
            'overall_score': self.overall_score,
            'status': self.status,
            'recommendation': self.recommendation,
            'applied_date': self.applied_date.isoformat() if self.applied_date else None,
            'screened_date': self.screened_date.isoformat() if self.screened_date else None,
            'assessed_date': self.assessed_date.isoformat() if self.assessed_date else None,
            'shortlisted_date': self.shortlisted_date.isoformat() if self.shortlisted_date else None
        }

class AssessmentResult(db.Model):
    __tablename__ = 'assessment_results'
    
    id = db.Column(db.Integer, primary_key=True)
    application_id = db.Column(db.Integer, db.ForeignKey('applications.id'), nullable=False)
    score = db.Column(db.Float)
    answers = db.Column(db.JSON)
    time_taken = db.Column(db.Integer)
    completed_at = db.Column(db.DateTime, default=datetime.utcnow)
    evaluator_notes = db.Column(db.Text)
    
    def to_dict(self):
        return {
            'id': self.id,
            'application_id': self.application_id,
            'score': self.score,
            'answers': self.answers,
            'time_taken': self.time_taken,
            'completed_at': self.completed_at.isoformat() if self.completed_at else None,
            'evaluator_notes': self.evaluator_notes
        }

class Interview(db.Model):
    __tablename__ = 'interviews'
    
    id = db.Column(db.Integer, primary_key=True)
    application_id = db.Column(db.Integer, db.ForeignKey('applications.id'), nullable=False)
    type = db.Column(db.String(50))
    scheduled_date = db.Column(db.DateTime)
    duration = db.Column(db.Integer)
    interviewers = db.Column(db.JSON)
    status = db.Column(db.String(20), default='scheduled')
    feedback = db.Column(db.JSON)
    rating = db.Column(db.Float)
    
    def to_dict(self):
        return {
            'id': self.id,
            'application_id': self.application_id,
            'type': self.type,
            'scheduled_date': self.scheduled_date.isoformat() if self.scheduled_date else None,
            'duration': self.duration,
            'interviewers': self.interviewers,
            'status': self.status,
            'feedback': self.feedback,
            'rating': self.rating
        }

class AuditLog(db.Model):
    __tablename__ = 'audit_logs'
    
    id = db.Column(db.Integer, primary_key=True)
    application_id = db.Column(db.Integer, db.ForeignKey('applications.id'), nullable=False)
    action = db.Column(db.String(100), nullable=False)
    changed_by = db.Column(db.Integer, db.ForeignKey('users.id'))
    changed_at = db.Column(db.DateTime, default=datetime.utcnow)
    old_values = db.Column(db.JSON)
    new_values = db.Column(db.JSON)
    
    def to_dict(self):
        return {
            'id': self.id,
            'application_id': self.application_id,
            'action': self.action,
            'changed_by': self.changed_by,
            'changed_at': self.changed_at.isoformat(),
            'old_values': self.old_values,
            'new_values': self.new_values
        }
