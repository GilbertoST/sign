"""
Script pour initialiser les défis dans la base de données
"""

from database import SessionLocal
import models
from datetime import datetime

def init_challenges():
    """Initialise les défis par défaut"""
    db = SessionLocal()
    try:
        # Vérifier si les défis existent déjà
        existing_challenges = db.query(models.Challenge).count()
        if existing_challenges > 0:
            print(f"⚠️ {existing_challenges} défis existent déjà. Rien à faire.")
            return
        
        print("🔄 Initialisation des défis...")
        
        # Défis par défaut
        challenges_data = [
            {
                "title": "Série de gestes",
                "description": "Fais une session 3 jours d'affilée",
                "icon": "🔄",
                "challenge_type": "streak",
                "requirement": 3,
                "xp_reward": 150,
                "color": "blue",
                "is_seasonal": False,
            },
            {
                "title": "Défi Halloween",
                "description": "Signe «citrouille» et «fantôme»",
                "icon": "👻",
                "challenge_type": "halloween",
                "requirement": 2,
                "xp_reward": 100,
                "color": "orange",
                "is_seasonal": True,
                "start_date": datetime(2025, 10, 1),
                "end_date": datetime(2025, 10, 31),
            },
            {
                "title": "Calendrier de l'avent",
                "description": "Débloque 1 signe par jour",
                "icon": "📅",
                "challenge_type": "advent",
                "requirement": 24,
                "xp_reward": 500,
                "color": "green",
                "is_seasonal": True,
                "start_date": datetime(2025, 12, 1),
                "end_date": datetime(2025, 12, 24),
            },
            {
                "title": "Alphabet complet",
                "description": "Apprendre les 26 lettres",
                "icon": "🏆",
                "challenge_type": "alphabet",
                "requirement": 26,
                "xp_reward": 500,
                "color": "purple",
                "is_seasonal": False,
            },
            {
                "title": "Quiz Master",
                "description": "Réussir 10 quiz parfaits (10/10)",
                "icon": "🎯",
                "challenge_type": "quiz_perfect",
                "requirement": 10,
                "xp_reward": 300,
                "color": "red",
                "is_seasonal": False,
            },
            {
                "title": "Premier pas",
                "description": "Compléter ton premier quiz",
                "icon": "🌟",
                "challenge_type": "first_quiz",
                "requirement": 1,
                "xp_reward": 50,
                "color": "yellow",
                "is_seasonal": False,
            },
        ]
        
        # Créer les défis
        for challenge_data in challenges_data:
            challenge = models.Challenge(**challenge_data)
            db.add(challenge)
        
        db.commit()
        print(f"✅ {len(challenges_data)} défis créés avec succès !")
        
        # Afficher la liste des défis créés
        print("\n📋 Défis créés:")
        for challenge_data in challenges_data:
            print(f"  • {challenge_data['icon']} {challenge_data['title']} - {challenge_data['xp_reward']} XP")
        
    except Exception as e:
        print(f"❌ Erreur lors de l'initialisation: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    init_challenges()




