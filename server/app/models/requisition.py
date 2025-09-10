from app.extensions import db
from datetime import datetime

class Requisition(db.Model):
    __tablename__ = 'requisitions'
    
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    department = db.Column(db.String(100))
    description = db.Column(db.Text)
    requirements = db.Column(db.Text)
    required_skills = db.Column(db.JSON)
    min_experience = db.Column(db.Integer)
    location = db.Column(db.String(100))
    seniority_level = db.Column(db.String(50))
    status = db.Column(db.String(20), default='draft')
    weightings = db.Column(db.JSON)
    knockout_rules = db.Column(db.JSON)
    assessment_pack_id = db.Column(db.Integer, db.ForeignKey('assessment_packs.id'))
    created_by = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    applications = db.relationship('Application', backref='requisition', lazy=True)
    
    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'department': self.department,
            'description': self.description,
            'requirements': self.requirements,
            'required_skills': self.required_skills,
            'min_experience': self.min_experience,
            'location': self.location,
            'seniority_level': self.seniority_level,
            'status': self.status,
            'weightings': self.weightings,
            'knockout_rules': self.knockout_rules,
            'assessment_pack_id': self.assessment_pack_id,
            'created_by': self.created_by,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
