from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_mail import Mail
from flask_migrate import Migrate
from flask_cors import CORS
from flask_socketio import SocketIO
from redis import Redis
from pymongo import MongoClient

db = SQLAlchemy()
jwt = JWTManager()
mail = Mail()
migrate = Migrate()
cors = CORS()
socketio = SocketIO()
redis_client = Redis.from_url('redis://localhost:6379/0')

# MongoDB client
mongo_client = MongoClient('mongodb://localhost:27017/')
mongo_db = mongo_client['recruitment_cv']