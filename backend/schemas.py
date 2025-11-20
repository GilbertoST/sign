from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional, List


# Schémas User
class UserBase(BaseModel):
    username: str
    email: EmailStr


class UserCreate(UserBase):
    password: str
    gdpr_consent: bool
    data_processing_consent: bool


class UserLogin(BaseModel):
    username: str
    password: str


class UserResponse(UserBase):
    id: int
    created_at: datetime
    level: int
    is_guest: bool = False
    guest_lessons_count: int = 0
    guest_quiz_count: int = 0
    profile_picture_url: Optional[str] = None
    bio: Optional[str] = None
    gdpr_consent: bool = False
    gdpr_consent_at: Optional[datetime] = None
    data_processing_consent: bool = False
    data_processing_consent_at: Optional[datetime] = None
    xp: int = 0
    total_xp: int = 0
    
    class Config:
        from_attributes = True


class Token(BaseModel):
    access_token: str
    token_type: str


class TokenData(BaseModel):
    username: Optional[str] = None


# Schémas Sign
class SignBase(BaseModel):
    letter: str
    video_path: Optional[str] = None
    image_path: Optional[str] = None
    thumbnail_url: Optional[str] = None  # URL miniature YouTube
    description: Optional[str] = None
    difficulty: int = 1


class SignCreate(SignBase):
    pass


class SignResponse(SignBase):
    id: int
    
    class Config:
        from_attributes = True


# Schémas Progress
class ProgressBase(BaseModel):
    user_id: int
    sign_id: int
    mastered: bool = False
    attempts: int = 0


class ProgressCreate(ProgressBase):
    pass


class ProgressUpdate(BaseModel):
    mastered: Optional[bool] = None
    attempts: Optional[int] = None
    last_practice_date: Optional[datetime] = None


class ProgressResponse(ProgressBase):
    id: int
    last_practice_date: Optional[datetime] = None
    
    class Config:
        from_attributes = True


# Schémas LearningSession
class LearningSessionBase(BaseModel):
    user_id: int


class LearningSessionCreate(LearningSessionBase):
    pass


class LearningSessionUpdate(BaseModel):
    end_time: Optional[datetime] = None
    score: Optional[float] = None


class LearningSessionResponse(LearningSessionBase):
    id: int
    start_time: datetime
    end_time: Optional[datetime] = None
    score: float
    
    class Config:
        from_attributes = True


# Schémas Attempt
class AttemptBase(BaseModel):
    session_id: int
    sign_id: int
    success: bool


class AttemptCreate(AttemptBase):
    pass


class AttemptResponse(AttemptBase):
    id: int
    timestamp: datetime
    
    class Config:
        from_attributes = True


# Schémas de statistiques
class UserStats(BaseModel):
    total_signs: int
    mastered_signs: int
    total_attempts: int
    success_rate: float
    current_level: int
    total_sessions: int


# Schéma pour conversion d'invité
class GuestConversion(BaseModel):
    username: str
    email: EmailStr
    password: str
    gdpr_consent: bool
    data_processing_consent: bool


# Schéma pour mise à jour du profil
class UserProfileUpdate(BaseModel):
    username: Optional[str] = None
    email: Optional[EmailStr] = None
    bio: Optional[str] = None
    profile_picture_url: Optional[str] = None
    gdpr_consent: Optional[bool] = None
    data_processing_consent: Optional[bool] = None


# Schéma pour changement de mot de passe
class PasswordChange(BaseModel):
    current_password: str
    new_password: str


# Schéma pour export RGPD
class UserDataExport(BaseModel):
    user: UserResponse
    progress_count: int
    sessions_count: int
    total_attempts: int
    mastered_signs: int


# ==================== SCHÉMAS DÉFIS ====================

class ChallengeBase(BaseModel):
    title: str
    description: str
    icon: str
    challenge_type: str
    requirement: int
    xp_reward: int = 100
    is_seasonal: bool = False
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    color: str = 'blue'


class ChallengeCreate(ChallengeBase):
    pass


class ChallengeResponse(ChallengeBase):
    id: int
    progress: int = 0
    completed: bool = False
    completed_at: Optional[datetime] = None
    xp_earned: int = 0
    
    class Config:
        from_attributes = True


class UserChallengeUpdate(BaseModel):
    progress: Optional[int] = None
    completed: Optional[bool] = None


class ChallengeCompletionResponse(BaseModel):
    success: bool
    xp_earned: int
    new_xp: int
    new_level: int
    level_up: bool
    message: str


class XPUpdateResponse(BaseModel):
    xp_added: int
    new_xp: int
    new_level: int
    level_up: bool
    progress_to_next: float


# ==================== SCHÉMAS FAVORIS ====================

class FavoriteBase(BaseModel):
    user_id: int
    sign_id: int


class FavoriteCreate(FavoriteBase):
    pass


class FavoriteResponse(FavoriteBase):
    id: int
    created_at: datetime
    
    class Config:
        from_attributes = True

