"""
Migration pour ajouter la table favorites
Permet aux utilisateurs de marquer des signes en favoris
"""

from database import SessionLocal, engine
from sqlalchemy import text, inspect
import models

def upgrade():
    """Ajoute la table favorites"""
    db = SessionLocal()
    try:
        print("🔄 Migration : Ajout de la table favorites...")
        
        # Vérifier si la table existe déjà
        inspector = inspect(engine)
        existing_tables = inspector.get_table_names()
        
        if 'favorites' in existing_tables:
            print("⚠️ La table 'favorites' existe déjà")
            print("✅ Migration terminée (déjà appliquée)")
            return
        
        # Créer la table favorites
        print("🔄 Création de la table favorites...")
        models.Favorite.__table__.create(bind=engine, checkfirst=True)
        print("✅ Table 'favorites' créée")
        
        db.commit()
        print("🎉 Migration réussie !")
        
    except Exception as e:
        print(f"❌ Erreur lors de la migration: {e}")
        db.rollback()
        raise
    finally:
        db.close()

def downgrade():
    """Supprime la table favorites (rollback)"""
    db = SessionLocal()
    try:
        print("🔄 Rollback : Suppression de la table favorites...")
        
        # Vérifier si la table existe
        inspector = inspect(engine)
        existing_tables = inspector.get_table_names()
        
        if 'favorites' not in existing_tables:
            print("⚠️ La table 'favorites' n'existe pas")
            return
        
        # Supprimer la table
        db.execute(text("DROP TABLE IF EXISTS favorites"))
        db.commit()
        print("✅ Table 'favorites' supprimée")
        
    except Exception as e:
        print(f"❌ Erreur lors du rollback: {e}")
        db.rollback()
        raise
    finally:
        db.close()

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "down":
        downgrade()
    else:
        upgrade()




