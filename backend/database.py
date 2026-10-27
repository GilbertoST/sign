from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base
from sqlalchemy.orm import sessionmaker
from config import settings

# Détecter si on utilise SQLite ou PostgreSQL
is_sqlite = settings.DATABASE_URL.startswith("sqlite")

if is_sqlite:
    # Configuration pour SQLite (développement local)
    engine = create_engine(
        settings.DATABASE_URL,
        connect_args={"check_same_thread": False}  # Nécessaire pour SQLite
    )
else:
    # Configuration pour PostgreSQL (production Render)
    engine = create_engine(
        settings.DATABASE_URL,
        pool_pre_ping=True,  # Vérifie la connexion avant utilisation
        pool_size=10,
        max_overflow=20
    )

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


# Dependency pour obtenir la session DB
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

