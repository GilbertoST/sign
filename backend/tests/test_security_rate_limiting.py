"""
Test OWASP A07:2021 - Identification and Authentication Failures
Teste le rate limiting pour prévenir les attaques par force brute
"""
import pytest
from backend.tests.conftest import client


class TestRateLimitingSecurity:
    """Tests de sécurité : Rate limiting contre les attaques par force brute"""
    
    def test_brute_force_attack_blocked(self, client):
        """Test : Une attaque par force brute doit être bloquée après 5 tentatives"""
        # Créer un utilisateur cible
        client.post(
            "/api/auth/register",
            json={
                "username": "target_user",
                "email": "target@example.com",
                "password": "TargetPass123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        
        # Tenter 5 connexions avec mauvais mot de passe
        for i in range(5):
            response = client.post(
                "/api/auth/login",
                json={
                    "username": "target_user",
                    "password": f"WrongPassword{i}123!"
                }
            )
            assert response.status_code == 401
        
        # La 6e tentative doit être bloquée (rate limiting)
        response = client.post(
            "/api/auth/login",
            json={
                "username": "target_user",
                "password": "WrongPassword123!"
            }
        )
        assert response.status_code == 429  # Too Many Requests
        assert "tentatives" in response.json()["detail"].lower()
    
    def test_rate_limiting_reset_after_success(self, client):
        """Test : Le rate limiting doit être réinitialisé après une connexion réussie"""
        # Créer un utilisateur
        client.post(
            "/api/auth/register",
            json={
                "username": "reset_user",
                "email": "reset@example.com",
                "password": "ResetPass123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        
        # Faire 4 tentatives échouées
        for i in range(4):
            response = client.post(
                "/api/auth/login",
                json={
                    "username": "reset_user",
                    "password": f"WrongPass{i}"
                }
            )
            assert response.status_code == 401
        
        # Connexion réussie - doit réinitialiser le compteur
        response = client.post(
            "/api/auth/login",
            json={
                "username": "reset_user",
                "password": "ResetPass123!@#"
            }
        )
        assert response.status_code == 200
        
        # Après succès, on peut refaire des tentatives
        response = client.post(
            "/api/auth/login",
            json={
                "username": "reset_user",
                "password": "WrongPassword"
            }
        )
        assert response.status_code == 401  # Pas encore bloqué
    
    def test_rate_limiting_per_ip_and_username(self, client):
        """Test : Le rate limiting doit être basé sur IP + username"""
        # Créer deux utilisateurs différents
        client.post(
            "/api/auth/register",
            json={
                "username": "user1_rate",
                "email": "user1_rate@example.com",
                "password": "Pass123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        
        client.post(
            "/api/auth/register",
            json={
                "username": "user2_rate",
                "email": "user2_rate@example.com",
                "password": "Pass123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        
        # Bloquer user1
        for i in range(5):
            client.post(
                "/api/auth/login",
                json={
                    "username": "user1_rate",
                    "password": "WrongPass"
                }
            )
        
        # user2 ne doit pas être affecté (même IP mais username différent)
        response = client.post(
            "/api/auth/login",
            json={
                "username": "user2_rate",
                "password": "Pass123!@#"
            }
        )
        assert response.status_code == 200  # user2 peut toujours se connecter

