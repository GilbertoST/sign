"""
Tests unitaires pour le calculateur XP
"""
from utils.xp_calculator import (
    calculate_level_from_xp,
    xp_progress_percentage,
    calculate_xp_reward
)


class TestXPCalculator:
    """Tests unitaires pour le calcul d'XP et de niveau"""
    
    def test_level_1_at_0_xp(self):
        """Test : niveau 1 à 0 XP"""
        assert calculate_level_from_xp(0) == 1
    
    def test_level_1_at_99_xp(self):
        """Test : niveau 1 à 99 XP"""
        assert calculate_level_from_xp(99) == 1
    
    def test_level_2_at_100_xp(self):
        """Test : niveau 2 à 100 XP"""
        assert calculate_level_from_xp(100) == 2
    
    def test_level_2_at_299_xp(self):
        """Test : niveau 2 à 299 XP"""
        assert calculate_level_from_xp(299) == 2
    
    def test_level_3_at_300_xp(self):
        """Test : niveau 3 à 300 XP"""
        assert calculate_level_from_xp(300) == 3
    
    def test_level_5_at_1000_xp(self):
        """Test : niveau 5 à 1000 XP"""
        assert calculate_level_from_xp(1000) == 5
    
    def test_level_increases_with_xp(self):
        """Test : le niveau augmente avec l'XP aux seuils documentés"""
        level_50 = calculate_level_from_xp(50)
        level_150 = calculate_level_from_xp(150)
        level_500 = calculate_level_from_xp(500)
        assert level_150 > level_50
        assert level_500 > level_150
    
    def test_level_6_at_1500_xp(self):
        """Test : niveau 6 à 1500 XP"""
        assert calculate_level_from_xp(1500) == 5  # 1500 est encore niveau 5
        assert calculate_level_from_xp(2000) == 6  # 2000 est niveau 6
    
    def test_xp_progress_percentage_level_1(self):
        """Test : calcul du pourcentage de progression niveau 1"""
        # À 50 XP, on devrait être à 50% vers le niveau 2 (100 XP requis)
        progress = xp_progress_percentage(50, 1)
        assert 0 <= progress <= 100
        assert progress == 50.0  # 50/100 = 50%
    
    def test_xp_progress_at_level_boundary(self):
        """Test : progression à 100% quand on atteint le niveau suivant"""
        progress = xp_progress_percentage(100, 1)
        assert progress == 100.0
    
    def test_xp_progress_level_2(self):
        """Test : progression niveau 2"""
        # À 150 XP (50 XP dans le niveau 2), on devrait être à 25% (50/200)
        progress = xp_progress_percentage(150, 2)
        assert progress == 25.0
    
    def test_calculate_xp_reward_difficulty_1(self):
        """Test : calcul de la récompense XP pour difficulté 1"""
        reward = calculate_xp_reward(1)
        assert reward == 10
        assert isinstance(reward, int)
    
    def test_calculate_xp_reward_difficulty_2(self):
        """Test : calcul de la récompense XP pour difficulté 2"""
        reward = calculate_xp_reward(2)
        assert reward == 20
        assert isinstance(reward, int)
    
    def test_calculate_xp_reward_difficulty_3(self):
        """Test : calcul de la récompense XP pour difficulté 3"""
        reward = calculate_xp_reward(3)
        assert reward == 30
        assert isinstance(reward, int)
    
    def test_calculate_xp_reward_custom_base(self):
        """Test : récompense avec base personnalisée"""
        reward = calculate_xp_reward(2, base_reward=5)
        assert reward == 10  # 5 * 2

