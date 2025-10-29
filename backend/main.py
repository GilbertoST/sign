from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from datetime import timedelta, datetime
from typing import List
import uuid
import models
import schemas
from database import engine, get_db
from auth import (
    get_password_hash,
    authenticate_user,
    create_access_token,
    get_current_user,
    get_user_by_username,
    get_user_by_email
)
from config import settings
from utils.xp_calculator import (
    calculate_level_from_xp,
    xp_progress_percentage,
    calculate_xp_reward
)

# Créer les tables
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Sign Language Learning API", version="1.0.0")

# Configuration CORS pour Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En production, spécifier les origines autorisées
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ==================== ENDPOINTS AUTHENTIFICATION ====================

@app.post("/api/auth/register", response_model=schemas.UserResponse, status_code=status.HTTP_201_CREATED)
def register(user: schemas.UserCreate, db: Session = Depends(get_db)):
    """Enregistre un nouvel utilisateur"""
    # Vérifier si l'utilisateur existe déjà
    db_user = get_user_by_username(db, username=user.username)
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already registered"
        )
    
    db_user = get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Créer le nouvel utilisateur
    hashed_password = get_password_hash(user.password)
    db_user = models.User(
        username=user.username,
        email=user.email,
        password_hash=hashed_password
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


@app.post("/api/auth/login", response_model=schemas.Token)
def login(user_credentials: schemas.UserLogin, db: Session = Depends(get_db)):
    """Authentifie un utilisateur et retourne un token"""
    user = authenticate_user(db, user_credentials.username, user_credentials.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}


@app.get("/api/auth/me", response_model=schemas.UserResponse)
async def get_current_user_info(current_user: models.User = Depends(get_current_user)):
    """Récupère les informations de l'utilisateur connecté"""
    return current_user


@app.post("/api/auth/guest", response_model=schemas.Token)
def create_guest_account(db: Session = Depends(get_db)):
    """Crée un compte invité temporaire"""
    # Générer un username unique pour l'invité
    guest_username = f"guest_{uuid.uuid4().hex[:8]}"
    guest_email = f"{guest_username}@example.com"
    
    # Créer un mot de passe aléatoire (non utilisé par l'invité)
    guest_password = uuid.uuid4().hex
    hashed_password = get_password_hash(guest_password)
    
    # Créer l'utilisateur invité
    db_user = models.User(
        username=guest_username,
        email=guest_email,
        password_hash=hashed_password,
        is_guest=True,
        guest_lessons_count=0,
        guest_quiz_count=0
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    # Créer un token pour l'invité
    access_token_expires = timedelta(days=30)  # Token plus long pour les invités
    access_token = create_access_token(
        data={"sub": db_user.username}, expires_delta=access_token_expires
    )
    
    return {"access_token": access_token, "token_type": "bearer"}


@app.post("/api/auth/increment-guest-lesson")
async def increment_guest_lesson(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Incrémente le compteur de leçons pour un invité"""
    if current_user.is_guest:
        current_user.guest_lessons_count += 1
        db.commit()
        db.refresh(current_user)
        
        # Vérifier si on doit afficher le prompt (5 leçons ET 2 quiz)
        should_prompt = (current_user.guest_lessons_count >= 5 and 
                        current_user.guest_quiz_count >= 2)
        
        return {
            "lessons": current_user.guest_lessons_count,
            "quizzes": current_user.guest_quiz_count,
            "should_prompt": should_prompt
        }
    return {"lessons": 0, "quizzes": 0, "should_prompt": False}


@app.post("/api/auth/increment-guest-quiz")
async def increment_guest_quiz(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Incrémente le compteur de quiz pour un invité"""
    if current_user.is_guest:
        current_user.guest_quiz_count += 1
        db.commit()
        db.refresh(current_user)
        
        # Vérifier si on doit afficher le prompt (5 leçons ET 2 quiz)
        should_prompt = (current_user.guest_lessons_count >= 5 and 
                        current_user.guest_quiz_count >= 2)
        
        return {
            "lessons": current_user.guest_lessons_count,
            "quizzes": current_user.guest_quiz_count,
            "should_prompt": should_prompt
        }
    return {"lessons": 0, "quizzes": 0, "should_prompt": False}


@app.post("/api/auth/convert-guest", response_model=schemas.UserResponse)
async def convert_guest_to_user(
    user_data: schemas.GuestConversion,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Convertit un compte invité en compte permanent"""
    if not current_user.is_guest:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User is not a guest account"
        )
    
    # Vérifier si le username existe déjà
    existing_user = get_user_by_username(db, username=user_data.username)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already taken"
        )
    
    # Vérifier si l'email existe déjà
    existing_email = get_user_by_email(db, email=user_data.email)
    if existing_email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Mettre à jour l'utilisateur
    current_user.username = user_data.username
    current_user.email = user_data.email
    current_user.password_hash = get_password_hash(user_data.password)
    current_user.is_guest = False
    
    db.commit()
    db.refresh(current_user)
    
    return current_user


# ==================== ENDPOINTS SIGNS ====================

@app.get("/api/signs", response_model=List[schemas.SignResponse])
def get_signs(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Récupère la liste de tous les signes"""
    signs = db.query(models.Sign).offset(skip).limit(limit).all()
    return signs


@app.get("/api/signs/{sign_id}", response_model=schemas.SignResponse)
def get_sign(sign_id: int, db: Session = Depends(get_db)):
    """Récupère un signe spécifique par son ID"""
    sign = db.query(models.Sign).filter(models.Sign.id == sign_id).first()
    if sign is None:
        raise HTTPException(status_code=404, detail="Sign not found")
    return sign


@app.post("/api/signs", response_model=schemas.SignResponse, status_code=status.HTTP_201_CREATED)
def create_sign(
    sign: schemas.SignCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Crée un nouveau signe (admin only)"""
    db_sign = models.Sign(**sign.dict())
    db.add(db_sign)
    db.commit()
    db.refresh(db_sign)
    return db_sign


# ==================== ENDPOINTS PROGRESS ====================

@app.get("/api/users/{user_id}/progress", response_model=List[schemas.ProgressResponse])
def get_user_progress(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Récupère la progression d'un utilisateur"""
    if current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    progress = db.query(models.Progress).filter(models.Progress.user_id == user_id).all()
    return progress


@app.post("/api/progress", response_model=schemas.ProgressResponse, status_code=status.HTTP_201_CREATED)
def create_progress(
    progress: schemas.ProgressCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Crée un nouveau suivi de progression"""
    if current_user.id != progress.user_id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    # Vérifier si la progression existe déjà
    existing = db.query(models.Progress).filter(
        models.Progress.user_id == progress.user_id,
        models.Progress.sign_id == progress.sign_id
    ).first()
    
    if existing:
        raise HTTPException(status_code=400, detail="Progress already exists")
    
    db_progress = models.Progress(**progress.dict())
    db.add(db_progress)
    db.commit()
    db.refresh(db_progress)
    return db_progress


@app.put("/api/progress/{progress_id}", response_model=schemas.ProgressResponse)
def update_progress(
    progress_id: int,
    progress_update: schemas.ProgressUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Met à jour la progression"""
    db_progress = db.query(models.Progress).filter(models.Progress.id == progress_id).first()
    if db_progress is None:
        raise HTTPException(status_code=404, detail="Progress not found")
    
    if db_progress.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    update_data = progress_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_progress, key, value)
    
    db.commit()
    db.refresh(db_progress)
    return db_progress


# ==================== ENDPOINTS SESSIONS ====================

@app.post("/api/sessions", response_model=schemas.LearningSessionResponse, status_code=status.HTTP_201_CREATED)
def create_session(
    session: schemas.LearningSessionCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Crée une nouvelle session d'apprentissage"""
    if current_user.id != session.user_id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    db_session = models.LearningSession(**session.model_dump())
    db.add(db_session)
    db.commit()
    db.refresh(db_session)
    return db_session


@app.put("/api/sessions/{session_id}", response_model=schemas.LearningSessionResponse)
def update_session(
    session_id: int,
    session_update: schemas.LearningSessionUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Met à jour une session d'apprentissage"""
    db_session = db.query(models.LearningSession).filter(models.LearningSession.id == session_id).first()
    if db_session is None:
        raise HTTPException(status_code=404, detail="Session not found")
    
    if db_session.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    update_data = session_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_session, key, value)
    
    db.commit()
    db.refresh(db_session)
    return db_session


# ==================== ENDPOINTS ATTEMPTS ====================

@app.post("/api/attempts", response_model=schemas.AttemptResponse, status_code=status.HTTP_201_CREATED)
def create_attempt(
    attempt: schemas.AttemptCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Enregistre une tentative"""
    # Vérifier que la session appartient à l'utilisateur
    session = db.query(models.LearningSession).filter(
        models.LearningSession.id == attempt.session_id
    ).first()
    
    if session is None:
        raise HTTPException(status_code=404, detail="Session not found")
    
    if session.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    db_attempt = models.Attempt(**attempt.model_dump())
    db.add(db_attempt)
    db.commit()
    db.refresh(db_attempt)
    return db_attempt


# ==================== ENDPOINTS STATISTIQUES ====================

@app.get("/api/users/{user_id}/stats", response_model=schemas.UserStats)
def get_user_stats(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Récupère les statistiques d'un utilisateur"""
    if current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    total_signs = db.query(models.Sign).count()
    
    progress_records = db.query(models.Progress).filter(
        models.Progress.user_id == user_id
    ).all()
    
    mastered_signs = sum(1 for p in progress_records if p.mastered)
    total_attempts = sum(p.attempts for p in progress_records)
    
    # Calculer le taux de succès
    all_attempts = db.query(models.Attempt).join(models.LearningSession).filter(
        models.LearningSession.user_id == user_id
    ).all()
    
    if all_attempts:
        successful_attempts = sum(1 for a in all_attempts if a.success)
        success_rate = (successful_attempts / len(all_attempts)) * 100
    else:
        success_rate = 0.0
    
    total_sessions = db.query(models.LearningSession).filter(
        models.LearningSession.user_id == user_id
    ).count()
    
    return {
        "total_signs": total_signs,
        "mastered_signs": mastered_signs,
        "total_attempts": total_attempts,
        "success_rate": round(success_rate, 2),
        "current_level": current_user.level,
        "total_sessions": total_sessions
    }


# ==================== ENDPOINTS PROFIL ====================

@app.put("/api/users/{user_id}", response_model=schemas.UserResponse)
async def update_user_profile(
    user_id: int,
    profile_update: schemas.UserProfileUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Met à jour le profil utilisateur"""
    if current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Non autorisé")
    
    # Vérifier unicité username si modifié
    if profile_update.username and profile_update.username != current_user.username:
        existing = get_user_by_username(db, profile_update.username)
        if existing:
            raise HTTPException(status_code=400, detail="Username déjà pris")
    
    # Vérifier unicité email si modifié
    if profile_update.email and profile_update.email != current_user.email:
        existing = get_user_by_email(db, profile_update.email)
        if existing:
            raise HTTPException(status_code=400, detail="Email déjà utilisé")
    
    # Mettre à jour les champs
    update_data = profile_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(current_user, key, value)
    
    db.commit()
    db.refresh(current_user)
    return current_user


@app.post("/api/users/{user_id}/change-password")
async def change_password(
    user_id: int,
    password_change: schemas.PasswordChange,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Change le mot de passe"""
    if current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Non autorisé")
    
    # Vérifier ancien mot de passe
    user = authenticate_user(db, current_user.username, password_change.current_password)
    if not user:
        raise HTTPException(status_code=400, detail="Mot de passe actuel incorrect")
    
    # Mettre à jour
    current_user.password_hash = get_password_hash(password_change.new_password)
    db.commit()
    
    return {"message": "Mot de passe changé avec succès"}


# ==================== ENDPOINTS RGPD ====================

@app.get("/api/users/{user_id}/export", response_model=schemas.UserDataExport)
async def export_user_data(
    user_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Export des données RGPD (droit d'accès)"""
    if current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Non autorisé")
    
    progress_count = db.query(models.Progress).filter(models.Progress.user_id == user_id).count()
    sessions_count = db.query(models.LearningSession).filter(models.LearningSession.user_id == user_id).count()
    total_attempts = db.query(models.Attempt).join(models.LearningSession).filter(
        models.LearningSession.user_id == user_id
    ).count()
    mastered = db.query(models.Progress).filter(
        models.Progress.user_id == user_id,
        models.Progress.mastered == True
    ).count()
    
    return {
        "user": current_user,
        "progress_count": progress_count,
        "sessions_count": sessions_count,
        "total_attempts": total_attempts,
        "mastered_signs": mastered
    }


@app.delete("/api/users/{user_id}")
async def delete_user_account(
    user_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Suppression du compte (droit à l'oubli RGPD)"""
    if current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Non autorisé")
    
    # La suppression en cascade s'occupe de progress, sessions, attempts
    db.delete(current_user)
    db.commit()
    
    return {"message": "Compte supprimé définitivement"}


@app.get("/")
def root():
    """Endpoint racine"""
    return {"message": "Sign Language Learning API", "version": "1.0.0"}


# ==================== ENDPOINTS DÉFIS ====================

@app.get("/api/challenges", response_model=List[schemas.ChallengeResponse])
def get_challenges(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Liste tous les défis avec progression de l'utilisateur"""
    try:
        challenges = db.query(models.Challenge).all()
        
        result = []
        for challenge in challenges:
            user_challenge = db.query(models.UserChallenge).filter(
                models.UserChallenge.user_id == current_user.id,
                models.UserChallenge.challenge_id == challenge.id
            ).first()
            
            if not user_challenge:
                # Créer une entrée vide si pas encore commencé
                user_challenge = models.UserChallenge(
                    user_id=current_user.id,
                    challenge_id=challenge.id,
                    progress=0,
                    completed=False
                )
                db.add(user_challenge)
                db.flush()  # Pour obtenir l'ID sans commit
            
            result.append(schemas.ChallengeResponse(
                id=challenge.id,
                title=challenge.title,
                description=challenge.description,
                icon=challenge.icon,
                challenge_type=challenge.challenge_type,
                requirement=challenge.requirement,
                xp_reward=challenge.xp_reward,
                is_seasonal=challenge.is_seasonal,
                start_date=challenge.start_date,
                end_date=challenge.end_date,
                color=challenge.color,
                progress=user_challenge.progress,
                completed=user_challenge.completed,
                completed_at=user_challenge.completed_at,
                xp_earned=user_challenge.xp_earned
            ))
        
        db.commit()
        return result
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Erreur serveur: {str(e)}")


@app.post("/api/challenges/{challenge_id}/complete", response_model=schemas.ChallengeCompletionResponse)
def complete_challenge(
    challenge_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Marque un défi comme complété et attribue l'XP"""
    challenge = db.query(models.Challenge).filter(
        models.Challenge.id == challenge_id
    ).first()
    
    if not challenge:
        raise HTTPException(status_code=404, detail="Challenge not found")
    
    user_challenge = db.query(models.UserChallenge).filter(
        models.UserChallenge.user_id == current_user.id,
        models.UserChallenge.challenge_id == challenge_id
    ).first()
    
    if not user_challenge:
        raise HTTPException(status_code=404, detail="User challenge not found")
    
    if user_challenge.completed:
        raise HTTPException(status_code=400, detail="Challenge already completed")
    
    # Marquer comme complété
    user_challenge.completed = True
    user_challenge.completed_at = datetime.utcnow()
    user_challenge.xp_earned = challenge.xp_reward
    
    # Ajouter l'XP à l'utilisateur
    old_level = current_user.level
    current_user.xp += challenge.xp_reward
    current_user.total_xp += challenge.xp_reward
    
    # Recalculer le niveau
    new_level = calculate_level_from_xp(current_user.xp)
    current_user.level = new_level
    
    level_up = new_level > old_level
    
    db.commit()
    
    message = f"Félicitations ! Vous avez gagné {challenge.xp_reward} XP"
    if level_up:
        message += f" et atteint le niveau {new_level} !"
    
    return schemas.ChallengeCompletionResponse(
        success=True,
        xp_earned=challenge.xp_reward,
        new_xp=current_user.xp,
        new_level=current_user.level,
        level_up=level_up,
        message=message
    )


@app.post("/api/challenges/{challenge_id}/progress", response_model=schemas.XPUpdateResponse)
def update_challenge_progress(
    challenge_id: int,
    increment: int = 1,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Met à jour la progression d'un défi"""
    user_challenge = db.query(models.UserChallenge).filter(
        models.UserChallenge.user_id == current_user.id,
        models.UserChallenge.challenge_id == challenge_id
    ).first()
    
    if not user_challenge:
        raise HTTPException(status_code=404, detail="User challenge not found")
    
    challenge = db.query(models.Challenge).filter(
        models.Challenge.id == challenge_id
    ).first()
    
    if user_challenge.completed:
        raise HTTPException(status_code=400, detail="Challenge already completed")
    
    # Mettre à jour la progression
    old_level = current_user.level
    user_challenge.progress += increment
    
    # Vérifier si le défi est maintenant complété
    if user_challenge.progress >= challenge.requirement:
        # Auto-complétion du défi
        user_challenge.completed = True
        user_challenge.completed_at = datetime.utcnow()
        user_challenge.xp_earned = challenge.xp_reward
        
        # Ajouter l'XP
        current_user.xp += challenge.xp_reward
        current_user.total_xp += challenge.xp_reward
        
        # Recalculer le niveau
        new_level = calculate_level_from_xp(current_user.xp)
        current_user.level = new_level
        
        level_up = new_level > old_level
        progress_to_next = xp_progress_percentage(current_user.xp, new_level)
        
        db.commit()
        
        return schemas.XPUpdateResponse(
            xp_added=challenge.xp_reward,
            new_xp=current_user.xp,
            new_level=current_user.level,
            level_up=level_up,
            progress_to_next=progress_to_next
        )
    
    db.commit()
    
    return schemas.XPUpdateResponse(
        xp_added=0,
        new_xp=current_user.xp,
        new_level=current_user.level,
        level_up=False,
        progress_to_next=xp_progress_percentage(current_user.xp, current_user.level)
    )


@app.post("/api/users/{user_id}/add-xp", response_model=schemas.XPUpdateResponse)
def add_xp_to_user(
    user_id: int,
    xp_amount: int,
    action_type: str = "general",
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Ajoute de l'XP à un utilisateur"""
    if current_user.id != user_id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    if xp_amount <= 0:
        raise HTTPException(status_code=400, detail="XP amount must be positive")
    
    old_level = current_user.level
    current_user.xp += xp_amount
    current_user.total_xp += xp_amount
    
    # Recalculer le niveau
    new_level = calculate_level_from_xp(current_user.xp)
    current_user.level = new_level
    
    level_up = new_level > old_level
    progress_to_next = xp_progress_percentage(current_user.xp, new_level)
    
    db.commit()
    
    return schemas.XPUpdateResponse(
        xp_added=xp_amount,
        new_xp=current_user.xp,
        new_level=current_user.level,
        level_up=level_up,
        progress_to_next=progress_to_next
    )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

