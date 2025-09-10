from app.extensions import db
from datetime import datetime

class Candidate(db.Model):
    __tablename__ = 'candidates'
    
    id = db.Column(db.Integer, primary_key=True)
    first_name = db.Column(db.String(50), nullable=False)
    last_name = db.Column(db.String(50), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    phone = db.Column(db.String(20))
    location = db.Column(db.String(100))
    current_company = db.Column(db.String(100))
    current_title = db.Column(db.String(100))
    total_experience = db.Column(db.Float)
    summary = db.Column(db.Text)
    cv_path = db.Column(db.String(500))
    cv_text = db.Column(db.Text)
    consent_given = db.Column(db.Boolean, default=False)
    consent_date = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    applications = db.relationship('Application', backref='candidate', lazy=True)
    skills = db.relationship('CandidateSkill', backref='candidate', lazy=True)
    
    def to_dict(self):
        return {
            'id': self.id,
            'first_name': self.first_name,
            'last_name': self.last_name,
            'email': self.email,
            'phone': self.phone,
            'location': self.location,
            'current_company': self.current_company,
            'current_title': self.current_title,
            'total_experience': self.total_experience,
            'summary': self.summary,
            'cv_path': self.cv_path,
            'consent_given': self.consent_given,
            'consent_date': self.consent_date.isoformat() if self.consent_date else None,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }

class CandidateSkill(db.Model):
    __tablename__ = 'candidate_skills'
    
    id = db.Column(db.Integer, primary_key=True)
    candidate_id = db.Column(db.Integer, db.ForeignKey('candidates.id'), nullable=False)
    skill = db.Column(db.String(100), nullable=False)
    years_experience = db.Column(db.Float)
    proficiency_level = db.Column(db.String(50))  # beginner, intermediate, advanced, expert
    
    def to_dict(self):
        return {
            'id': self.id,
            'candidate_id': self.candidate_id,
            'skill': self.skill,
            'years_experience': self.years_experience,
            'proficiency_level': self.proficiency_level
        }
