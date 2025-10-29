from sqlalchemy import Column, Integer, String, DateTime, Boolean, ForeignKey, Float
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base


class User(Base):
    __tablename__ = 'users'
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    level = Column(Integer, default=1)
    is_guest = Column(Boolean, default=False)
    guest_lessons_count = Column(Integer, default=0)
    guest_quiz_count = Column(Integer, default=0)
    
    # Champs de profil
    profile_picture_url = Column(String, nullable=True)
    bio = Column(String, nullable=True)
    
    # Champs RGPD
    gdpr_consent = Column(Boolean, default=True)
    data_processing_consent = Column(Boolean, default=True)
    
    # Champs XP et défis
    xp = Column(Integer, default=0)
    total_xp = Column(Integer, default=0)
    
    # Relations
    progress = relationship('Progress', back_populates='user', cascade='all, delete-orphan')
    learning_sessions = relationship('LearningSession', back_populates='user', cascade='all, delete-orphan')
    user_challenges = relationship('UserChallenge', back_populates='user', cascade='all, delete-orphan')
    favorites = relationship('Favorite', back_populates='user', cascade='all, delete-orphan')


class Sign(Base):
    __tablename__ = 'signs'
    
    id = Column(Integer, primary_key=True, index=True)
    letter = Column(String(1), unique=True, nullable=False, index=True)
    video_path = Column(String, nullable=True)
    image_path = Column(String, nullable=True)
    thumbnail_url = Column(String, nullable=True)  # URL de la miniature YouTube
    description = Column(String, nullable=True)
    difficulty = Column(Integer, default=1)  # 1=facile, 2=moyen, 3=difficile
    
    # Relations
    progress = relationship('Progress', back_populates='sign', cascade='all, delete-orphan')
    attempts = relationship('Attempt', back_populates='sign', cascade='all, delete-orphan')
    favorites = relationship('Favorite', back_populates='sign', cascade='all, delete-orphan')


class Progress(Base):
    __tablename__ = 'progress'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    sign_id = Column(Integer, ForeignKey('signs.id'), nullable=False)
    mastered = Column(Boolean, default=False)
    attempts = Column(Integer, default=0)
    last_practice_date = Column(DateTime, nullable=True)
    
    # Relations
    user = relationship('User', back_populates='progress')
    sign = relationship('Sign', back_populates='progress')


class LearningSession(Base):
    __tablename__ = 'learning_sessions'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    start_time = Column(DateTime, default=datetime.utcnow)
    end_time = Column(DateTime, nullable=True)
    score = Column(Float, default=0.0)
    
    # Relations
    user = relationship('User', back_populates='learning_sessions')
    attempts = relationship('Attempt', back_populates='session', cascade='all, delete-orphan')


class Attempt(Base):
    __tablename__ = 'attempts'
    
    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey('learning_sessions.id'), nullable=False)
    sign_id = Column(Integer, ForeignKey('signs.id'), nullable=False)
    success = Column(Boolean, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)
    
    # Relations
    session = relationship('LearningSession', back_populates='attempts')
    sign = relationship('Sign', back_populates='attempts')


class Challenge(Base):
    __tablename__ = 'challenges'
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(String, nullable=False)
    icon = Column(String, nullable=False)  # emoji ou nom d'icône
    challenge_type = Column(String, nullable=False)  # 'streak', 'halloween', 'advent', 'alphabet'
    requirement = Column(Integer, nullable=False)  # ex: 3 jours, 2 signes, 26 lettres
    xp_reward = Column(Integer, default=100)
    is_seasonal = Column(Boolean, default=False)  # Si c'est un défi temporaire
    start_date = Column(DateTime, nullable=True)
    end_date = Column(DateTime, nullable=True)
    color = Column(String, default='blue')  # Couleur du badge
    
    # Relations
    user_challenges = relationship('UserChallenge', back_populates='challenge')


class UserChallenge(Base):
    __tablename__ = 'user_challenges'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    challenge_id = Column(Integer, ForeignKey('challenges.id'), nullable=False)
    progress = Column(Integer, default=0)  # ex: 1/3 jours, 1/2 signes
    completed = Column(Boolean, default=False)
    completed_at = Column(DateTime, nullable=True)
    xp_earned = Column(Integer, default=0)
    
    # Relations
    user = relationship('User', back_populates='user_challenges')
    challenge = relationship('Challenge', back_populates='user_challenges')


class Favorite(Base):
    __tablename__ = 'favorites'
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    sign_id = Column(Integer, ForeignKey('signs.id'), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relations
    user = relationship('User', back_populates='favorites')
    sign = relationship('Sign', back_populates='favorites')

