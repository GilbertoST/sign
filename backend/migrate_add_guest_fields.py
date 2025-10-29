"""
Script de migration pour ajouter les colonnes du mode invité
"""
from sqlalchemy import create_engine, text, inspect
from config import settings

def main():
    engine = create_engine(settings.DATABASE_URL)
    
    # Vérifier si les colonnes existent déjà
    inspector = inspect(engine)
    columns = [col['name'] for col in inspector.get_columns('users')]
    
    with engine.connect() as conn:
        # Ajouter la colonne is_guest si elle n'existe pas
        if 'is_guest' not in columns:
            print("Ajout de la colonne is_guest...")
            conn.execute(text("ALTER TABLE users ADD COLUMN is_guest BOOLEAN DEFAULT FALSE"))
            conn.commit()
            print("✅ Colonne is_guest ajoutée")
        else:
            print("ℹ️  Colonne is_guest déjà présente")
        
        # Ajouter la colonne guest_lessons_count si elle n'existe pas
        if 'guest_lessons_count' not in columns:
            print("Ajout de la colonne guest_lessons_count...")
            conn.execute(text("ALTER TABLE users ADD COLUMN guest_lessons_count INTEGER DEFAULT 0"))
            conn.commit()
            print("✅ Colonne guest_lessons_count ajoutée")
        else:
            print("ℹ️  Colonne guest_lessons_count déjà présente")
        
        # Ajouter la colonne guest_quiz_count si elle n'existe pas
        if 'guest_quiz_count' not in columns:
            print("Ajout de la colonne guest_quiz_count...")
            conn.execute(text("ALTER TABLE users ADD COLUMN guest_quiz_count INTEGER DEFAULT 0"))
            conn.commit()
            print("✅ Colonne guest_quiz_count ajoutée")
        else:
            print("ℹ️  Colonne guest_quiz_count déjà présente")
    
    print("\n🎉 Migration terminée avec succès !")

if __name__ == "__main__":
    main()


