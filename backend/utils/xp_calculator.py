"""
Calculateur XP pour le système de gamification
"""


def calculate_level_from_xp(xp: int) -> int:
    """
    Calcule le niveau d'un utilisateur à partir de son XP.
    Niveau 1 : 0-99 XP
    Niveau 2 : 100-299 XP
    Niveau 3 : 300-599 XP
    Niveau 4 : 600-999 XP
    Niveau 5 : 1000-1499 XP
    etc. (chaque niveau nécessite 500 XP de plus)
    """
    if xp < 100:
        return 1
    elif xp < 300:
        return 2
    elif xp < 600:
        return 3
    elif xp < 1000:
        return 4
    elif xp < 1500:
        return 5
    else:
        # Formule : niveau = base + (XP - 1500) // 500
        return 5 + ((xp - 1500) // 500)


def xp_progress_percentage(xp: int, level: int) -> float:
    """
    Calcule le pourcentage de progression vers le prochain niveau.
    """
    if level == 1:
        # 0 à 99 XP
        current_xp_in_level = xp
        total_xp_for_level = 100
    elif level == 2:
        # 100 à 299 XP
        current_xp_in_level = xp - 100
        total_xp_for_level = 200
    elif level == 3:
        # 300 à 599 XP
        current_xp_in_level = xp - 300
        total_xp_for_level = 300
    elif level == 4:
        # 600 à 999 XP
        current_xp_in_level = xp - 600
        total_xp_for_level = 400
    elif level == 5:
        # 1000 à 1499 XP
        current_xp_in_level = xp - 1000
        total_xp_for_level = 500
    else:
        # Niveau 6+ : 500 XP par niveau
        base_xp = 1500 + (level - 6) * 500
        current_xp_in_level = xp - base_xp
        total_xp_for_level = 500
    
    if total_xp_for_level == 0:
        return 0.0
    
    percentage = (current_xp_in_level / total_xp_for_level) * 100
    return min(percentage, 100.0)  # Max 100%


def calculate_xp_reward(difficulty: int, base_reward: int = 10) -> int:
    """
    Calcule la récompense XP en fonction de la difficulté.
    """
    if difficulty == 1:
        return base_reward  # Facile : 10 XP
    elif difficulty == 2:
        return base_reward * 2  # Moyen : 20 XP
    else:
        return base_reward * 3  # Difficile : 30 XP


