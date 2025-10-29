"""
Script de migration pour ajouter les champs de profil et RGPD
"""
from database import SessionLocal, engine
from sqlalchemy import text

def upgrade():
    """Ajoute les nouveaux champs à la table users"""
    db = SessionLocal()
    try:
        print("🔄 Migration en cours...")
        
        # Ajouter les champs de profil
        db.execute(text("ALTER TABLE users ADD COLUMN profile_picture_url VARCHAR"))
        print("✓ Champ profile_picture_url ajouté")
        
        db.execute(text("ALTER TABLE users ADD COLUMN bio VARCHAR"))
        print("✓ Champ bio ajouté")
        
        # Ajouter les champs RGPD
        db.execute(text("ALTER TABLE users ADD COLUMN gdpr_consent BOOLEAN DEFAULT TRUE"))
        print("✓ Champ gdpr_consent ajouté")
        
        db.execute(text("ALTER TABLE users ADD COLUMN data_processing_consent BOOLEAN DEFAULT TRUE"))
        print("✓ Champ data_processing_consent ajouté")
        
        db.commit()
        print("✅ Migration réussie !")
        
    except Exception as e:
        print(f"❌ Erreur: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    print("📊 Migration : Ajout des champs de profil et RGPD")
    print("=" * 50)
    upgrade()




