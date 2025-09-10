from app.extensions import db
from datetime import datetime

class AssessmentPack(db.Model):
    __tablename__ = 'assessment_packs'
    
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    type = db.Column(db.String(50))
    questions = db.Column(db.JSON)
    time_limit = db.Column(db.Integer)
    passing_score = db.Column(db.Float)
    created_by = db.Column(db.Integer, db.ForeignKey('users.id'))
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=True)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    
    # Relationships
    requisitions = db.relationship('Requisition', backref='assessment_pack', lazy=True)
    
    def to_dict(self):
        return {
        'id': self.id,
        'name': self.name,
        'description': self.description,
        'type': self.type,
        'questions': self.questions,
        'time_limit': self.time_limit,
        'passing_score': self.passing_score,
        'created_by': self.created_by,
        'created_at': self.created_at.isoformat() if self.created_at else None,
        'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
