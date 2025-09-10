import bcrypt
import jwt
from datetime import datetime, timedelta
from app.extensions import db, redis_client
from app.models import User
from flask import current_app

class AuthService:

    @staticmethod
    def hash_password(password: str) -> str:
        """Hash a plain-text password."""
        salt = bcrypt.gensalt()
        hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
        return hashed.decode('utf-8')

    @staticmethod
    def verify_password(password: str, hashed_password: str) -> bool:
        """Verify a plain-text password against a hash."""
        return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))

    @staticmethod
    def create_user(email: str, password: str, first_name: str, last_name: str, role: str = 'recruiter') -> User:
        """
        Create a new user, hash their password, add to DB, and commit immediately.
        Returns the User instance.
        """
        hashed_password = AuthService.hash_password(password)
        user = User(
            email=email.strip().lower(),
            password_hash=hashed_password,
            first_name=first_name,
            last_name=last_name,
            role=role
        )
        try:
            db.session.add(user)
            db.session.commit()  # ✅ ensures user is saved immediately
        except Exception as e:
            db.session.rollback()
            current_app.logger.error(f'Failed to create user: {str(e)}', exc_info=True)
            raise e
        return user

    @staticmethod
    def generate_password_reset_token(user_id: int) -> str:
        """Generate a JWT password reset token and store it in Redis."""
        payload = {
            'user_id': user_id,
            'exp': datetime.utcnow() + timedelta(hours=1),
            'type': 'password_reset'
        }
        token = jwt.encode(payload, current_app.config['JWT_SECRET_KEY'], algorithm='HS256')
        if isinstance(token, bytes):
            token = token.decode('utf-8')  # ✅ always store as str

        redis_client.setex(f'password_reset:{token}', 3600, user_id)
        return token

    @staticmethod
    def verify_password_reset_token(token: str):
        """Verify password reset token from Redis and JWT."""
        try:
            user_id = redis_client.get(f'password_reset:{token}')
            if not user_id:
                return None

            payload = jwt.decode(token, current_app.config['JWT_SECRET_KEY'], algorithms=['HS256'])
            if payload.get('type') != 'password_reset':
                return None

            redis_client.delete(f'password_reset:{token}')
            return int(user_id)

        except jwt.ExpiredSignatureError:
            redis_client.delete(f'password_reset:{token}')
            return None
        except jwt.InvalidTokenError:
            return None

    @staticmethod
    def validate_user_credentials(email: str, password: str):
        """Validate user credentials and return User instance if valid."""
        user = User.query.filter(db.func.lower(User.email) == email.strip().lower()).first()
        if user and AuthService.verify_password(password, user.password_hash):
            return user
        return None
