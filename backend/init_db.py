"""
Script pour initialiser la base de données avec l'alphabet de la langue des signes
URLs YouTube de la chaîne Dicoplus LSF
"""
from database import SessionLocal, engine
import models
from video_urls import get_video_url, get_image_url, get_youtube_thumbnail_url

def init_signs():
    """Initialise les 26 lettres de l'alphabet"""
    db = SessionLocal()
    
    # Vérifier si les signes existent déjà
    existing_signs = db.query(models.Sign).count()
    if existing_signs > 0:
        print(f"La base de données contient déjà {existing_signs} signes.")
        db.close()
        return
    
    # Créer les 26 lettres de l'alphabet
    alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
    for i, letter in enumerate(alphabet):
        # Définir la difficulté
        if letter in "AEIO":
            difficulty = 1  # Facile
        elif letter in "BCDLMNPRSTV":
            difficulty = 2  # Moyen
        else:
            difficulty = 3  # Difficile
        
        video_url = get_video_url(letter)
        sign = models.Sign(
            letter=letter,
            video_path=video_url,  # URL YouTube
            image_path=get_image_url(letter),
            thumbnail_url=get_youtube_thumbnail_url(video_url),  # Miniature YouTube
            description=f"Signe de la lettre {letter} en LSF - Dicoplus LSF",
            difficulty=difficulty
        )
        db.add(sign)
    
    db.commit()
    print(f"✓ {len(alphabet)} signes créés avec succès!")
    print("✓ Crédit vidéos: Dicoplus LSF - https://www.youtube.com/@DicoplusLSF")
    db.close()


def create_tables():
    """Crée toutes les tables dans la base de données"""
    models.Base.metadata.create_all(bind=engine)
    print("✓ Tables créées avec succès!")


if __name__ == "__main__":
    print("Initialisation de la base de données...")
    create_tables()
    init_signs()
    print("✓ Base de données initialisée!")

