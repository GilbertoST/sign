"""
Tests d'intégration pour l'authentification
"""


class TestAuthIntegration:
    """Tests d'intégration pour l'authentification"""
    
    def test_register_and_login_flow(self, client):
        """Test : flux complet d'inscription puis connexion"""
        # 1. Inscription
        register_response = client.post(
            "/api/auth/register",
            json={
                "username": "testuser_integration",
                "email": "test_integration@example.com",
                "password": "Test123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        assert register_response.status_code == 201
        user_data = register_response.json()
        assert user_data["username"] == "testuser_integration"
        assert user_data["gdpr_consent"] is True
        assert user_data["gdpr_consent_at"] is not None
        
        # 2. Connexion
        login_response = client.post(
            "/api/auth/login",
            json={
                "username": "testuser_integration",
                "password": "Test123!@#"
            }
        )
        assert login_response.status_code == 200
        token_data = login_response.json()
        assert "access_token" in token_data
        assert token_data["token_type"] == "bearer"
        
        # 3. Récupération du profil avec le token
        token = token_data["access_token"]
        profile_response = client.get(
            "/api/auth/me",
            headers={"Authorization": f"Bearer {token}"}
        )
        assert profile_response.status_code == 200
        profile_data = profile_response.json()
        assert profile_data["username"] == "testuser_integration"
        assert profile_data["id"] == user_data["id"]
    
    def test_register_without_gdpr_consent_fails(self, client):
        """Test : inscription sans consentement RGPD doit échouer"""
        response = client.post(
            "/api/auth/register",
            json={
                "username": "testuser_no_consent",
                "email": "test_no_consent@example.com",
                "password": "Test123!@#",
                "gdpr_consent": False,
                "data_processing_consent": False
            }
        )
        assert response.status_code == 400
        assert "RGPD consent" in response.json()["detail"]
    
    def test_login_with_wrong_password_fails(self, client):
        """Test : connexion avec mauvais mot de passe doit échouer"""
        # D'abord créer un utilisateur
        client.post(
            "/api/auth/register",
            json={
                "username": "testuser_wrong_pass",
                "email": "test_wrong_pass@example.com",
                "password": "Test123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        
        # Ensuite essayer de se connecter avec un mauvais mot de passe
        response = client.post(
            "/api/auth/login",
            json={
                "username": "testuser_wrong_pass",
                "password": "WrongPassword123!"
            }
        )
        assert response.status_code == 401
        assert "Incorrect" in response.json()["detail"]
    
    def test_register_duplicate_username_fails(self, client):
        """Test : inscription avec un username déjà utilisé doit échouer"""
        # Créer un premier utilisateur
        client.post(
            "/api/auth/register",
            json={
                "username": "duplicate_user",
                "email": "duplicate1@example.com",
                "password": "Test123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        
        # Essayer de créer un deuxième utilisateur avec le même username
        response = client.post(
            "/api/auth/register",
            json={
                "username": "duplicate_user",
                "email": "duplicate2@example.com",
                "password": "Test123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        assert response.status_code == 400
        assert "already registered" in response.json()["detail"].lower()

