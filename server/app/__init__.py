from flask import Flask
from flask_cors import CORS
from app.config import config
from app.extensions import db, jwt, mail, migrate, cors, socketio, redis_client, mongo_db

def create_app(config_name='default'):
    app = Flask(__name__)
    app.config.from_object(config[config_name])
    
    # Initialize extensions
    db.init_app(app)
    jwt.init_app(app)
    mail.init_app(app)
    migrate.init_app(app, db)
    cors.init_app(app)
    socketio.init_app(app, cors_allowed_origins="*", message_queue=app.config['REDIS_URL'])
    
    # Register routes
    from app.routes.auth import init_auth_routes
    from app.routes.assessments import init_assessment_routes
    from app.routes.candidates import init_candidate_routes
    from app.routes.requisitions import init_requisition_routes
    from app.routes.scheduling import init_scheduling_routes
    
    init_auth_routes(app)
    init_assessment_routes(app)
    init_candidate_routes(app)
    init_requisition_routes(app)
    init_scheduling_routes(app)
    
    # Register error handlers
    @app.errorhandler(404)
    def not_found(error):
        return {'error': 'Not found'}, 404
    
    @app.errorhandler(500)
    def internal_error(error):
        return {'error': 'Internal server error'}, 500
    
    # Health check endpoint
    @app.route('/api/health')
    def health_check():
        return {'status': 'healthy', 'timestamp': datetime.utcnow().isoformat()}
    
    return app