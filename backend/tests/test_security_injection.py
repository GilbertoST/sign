"""
Test OWASP A03:2021 - Injection
Teste la protection contre les injections SQL et autres injections
"""
import pytest
from backend.tests.conftest import client


class TestInjectionSecurity:
    """Tests de sécurité : Protection contre les injections"""
    
    def test_sql_injection_in_username_field(self, client):
        """Test : Protection contre injection SQL dans le champ username"""
        # Tentative d'injection SQL classique
        sql_injection_attempts = [
            "' OR '1'='1",
            "admin'--",
            "'; DROP TABLE users;--",
            "' UNION SELECT * FROM users--",
            "admin' OR '1'='1'--",
        ]
        
        for injection in sql_injection_attempts:
            response = client.post(
                "/api/auth/login",
                json={
                    "username": injection,
                    "password": "anything"
                }
            )
            # Doit retourner 401 (utilisateur non trouvé) et non une erreur SQL
            # Si c'était une injection SQL réussie, on aurait une erreur 500
            assert response.status_code in [401, 422]  # 422 = validation error
            assert response.status_code != 500  # Pas d'erreur serveur = injection bloquée
    
    def test_sql_injection_in_password_field(self, client):
        """Test : Protection contre injection SQL dans le champ password"""
        # Créer un utilisateur normal
        client.post(
            "/api/auth/register",
            json={
                "username": "normal_user",
                "email": "normal@example.com",
                "password": "NormalPass123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        
        sql_injection_attempts = [
            "' OR '1'='1",
            "'; DROP TABLE users;--",
            "' UNION SELECT password FROM users--",
        ]
        
        for injection in sql_injection_attempts:
            response = client.post(
                "/api/auth/login",
                json={
                    "username": "normal_user",
                    "password": injection
                }
            )
            # Doit retourner 401 (mauvais mot de passe) et non une erreur SQL
            assert response.status_code == 401
            assert response.status_code != 500
    
    def test_xss_injection_in_profile_fields(self, client):
        """Test : Protection contre injection XSS dans les champs de profil"""
        # Créer un utilisateur
        register_response = client.post(
            "/api/auth/register",
            json={
                "username": "xss_user",
                "email": "xss@example.com",
                "password": "XssPass123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        user_id = register_response.json()["id"]
        
        # Se connecter
        login_response = client.post(
            "/api/auth/login",
            json={
                "username": "xss_user",
                "password": "XssPass123!@#"
            }
        )
        token = login_response.json()["access_token"]
        
        # Tentatives d'injection XSS
        xss_attempts = [
            "<script>alert('XSS')</script>",
            "<img src=x onerror=alert('XSS')>",
            "javascript:alert('XSS')",
            "<svg/onload=alert('XSS')>",
        ]
        
        for xss in xss_attempts:
            response = client.put(
                f"/api/users/{user_id}",
                headers={"Authorization": f"Bearer {token}"},
                json={
                    "bio": xss
                }
            )
            # Doit accepter la requête (le contenu sera échappé côté frontend)
            # Mais ne doit pas causer d'erreur serveur
            assert response.status_code in [200, 400]
            assert response.status_code != 500
    
    def test_command_injection_protection(self, client):
        """Test : Protection contre injection de commandes"""
        # Tentatives d'injection de commandes
        command_injections = [
            "; ls",
            "| cat /etc/passwd",
            "&& rm -rf /",
            "`whoami`",
            "$(cat /etc/passwd)",
        ]
        
        for injection in command_injections:
            # Tester dans différents champs
            response = client.post(
                "/api/auth/register",
                json={
                    "username": injection,
                    "email": "test@example.com",
                    "password": "Test123!@#",
                    "gdpr_consent": True,
                    "data_processing_consent": True
                }
            )
            # Doit valider le format (peut rejeter mais pas exécuter)
            assert response.status_code != 500
    
    def test_no_sql_injection_in_query_parameters(self, client):
        """Test : Protection contre injection SQL dans les paramètres de requête"""
        # Créer un utilisateur
        register_response = client.post(
            "/api/auth/register",
            json={
                "username": "query_user",
                "email": "query@example.com",
                "password": "QueryPass123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        user_id = register_response.json()["id"]
        
        # Se connecter
        login_response = client.post(
            "/api/auth/login",
            json={
                "username": "query_user",
                "password": "QueryPass123!@#"
            }
        )
        token = login_response.json()["access_token"]
        
        # Tentatives d'injection dans les paramètres de requête
        sql_attempts = [
            "1 OR 1=1",
            "1; DROP TABLE users;--",
            "1' UNION SELECT * FROM users--",
        ]
        
        # Tester dans l'URL (si le endpoint accepte des paramètres)
        for sql in sql_attempts:
            # Test sur un endpoint qui pourrait être vulnérable
            response = client.get(
                f"/api/progress?user_id={sql}",
                headers={"Authorization": f"Bearer {token}"}
            )
            # Ne doit pas causer d'erreur serveur ou d'exécution SQL
            assert response.status_code != 500

