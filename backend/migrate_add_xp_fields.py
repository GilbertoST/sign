"""
Migration pour ajouter les champs XP et créer les tables de défis
"""

from database import SessionLocal, engine
from sqlalchemy import text
import models

def upgrade():
    """Ajoute les champs XP et crée les nouvelles tables"""
    db = SessionLocal()
    try:
        print("🔄 Migration des champs XP...")
        
        # Ajouter les champs XP à la table users
        try:
            db.execute(text("ALTER TABLE users ADD COLUMN xp INTEGER DEFAULT 0"))
            print("✅ Champ 'xp' ajouté")
        except Exception as e:
            print(f"⚠️ Champ 'xp' déjà existant ou erreur: {e}")
        
        try:
            db.execute(text("ALTER TABLE users ADD COLUMN total_xp INTEGER DEFAULT 0"))
            print("✅ Champ 'total_xp' ajouté")
        except Exception as e:
            print(f"⚠️ Champ 'total_xp' déjà existant ou erreur: {e}")
        
        # Créer les nouvelles tables
        print("🔄 Création des tables de défis...")
        models.Challenge.__table__.create(bind=engine, checkfirst=True)
        models.UserChallenge.__table__.create(bind=engine, checkfirst=True)
        print("✅ Tables de défis créées")
        
        db.commit()
        print("🎉 Migration réussie !")
        
    except Exception as e:
        print(f"❌ Erreur lors de la migration: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    upgrade()




