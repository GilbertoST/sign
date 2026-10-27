"""
Tests d'intégration pour les fonctionnalités RGPD
"""


class TestRGPDIntegration:
    """Tests d'intégration pour les fonctionnalités RGPD"""
    
    def test_export_user_data(self, client):
        """Test : export des données utilisateur (droit d'accès RGPD)"""
        # 1. Créer un utilisateur
        register_response = client.post(
            "/api/auth/register",
            json={
                "username": "testuser_export",
                "email": "test_export@example.com",
                "password": "Test123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        user_id = register_response.json()["id"]
        
        # 2. Se connecter
        login_response = client.post(
            "/api/auth/login",
            json={
                "username": "testuser_export",
                "password": "Test123!@#"
            }
        )
        token = login_response.json()["access_token"]
        
        # 3. Exporter les données
        export_response = client.get(
            f"/api/users/{user_id}/export",
            headers={"Authorization": f"Bearer {token}"}
        )
        assert export_response.status_code == 200
        export_data = export_response.json()
        
        # Vérifier que toutes les données sont présentes
        assert "user" in export_data
        assert export_data["user"]["id"] == user_id
        assert "progress_count" in export_data
        assert "sessions_count" in export_data
        assert "total_attempts" in export_data
        assert "mastered_signs" in export_data
    
    def test_delete_user_account_cascade(self, client):
        """Test : suppression de compte avec cascade (droit à l'oubli RGPD)"""
        # 1. Créer un utilisateur
        register_response = client.post(
            "/api/auth/register",
            json={
                "username": "testuser_delete",
                "email": "test_delete@example.com",
                "password": "Test123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        user_id = register_response.json()["id"]
        
        # 2. Se connecter
        login_response = client.post(
            "/api/auth/login",
            json={
                "username": "testuser_delete",
                "password": "Test123!@#"
            }
        )
        token = login_response.json()["access_token"]
        
        # 3. Supprimer le compte
        delete_response = client.delete(
            f"/api/users/{user_id}",
            headers={"Authorization": f"Bearer {token}"}
        )
        assert delete_response.status_code == 200
        assert "supprimé" in delete_response.json()["message"].lower()
        
        # 4. Vérifier que le token n'est plus valide
        profile_response = client.get(
            "/api/auth/me",
            headers={"Authorization": f"Bearer {token}"}
        )
        assert profile_response.status_code == 401  # Token invalide car utilisateur supprimé
    
    def test_export_unauthorized_user(self, client):
        """Test : export des données d'un autre utilisateur doit échouer"""
        # Créer deux utilisateurs
        user1_response = client.post(
            "/api/auth/register",
            json={
                "username": "user1_export",
                "email": "user1_export@example.com",
                "password": "Test123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        user1_id = user1_response.json()["id"]
        
        user2_response = client.post(
            "/api/auth/register",
            json={
                "username": "user2_export",
                "email": "user2_export@example.com",
                "password": "Test123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        user2_id = user2_response.json()["id"]
        
        # Se connecter avec user2
        login_response = client.post(
            "/api/auth/login",
            json={
                "username": "user2_export",
                "password": "Test123!@#"
            }
        )
        token = login_response.json()["access_token"]
        
        # Essayer d'exporter les données de user1 avec le token de user2
        export_response = client.get(
            f"/api/users/{user1_id}/export",
            headers={"Authorization": f"Bearer {token}"}
        )
        assert export_response.status_code == 403
        assert "autorisé" in export_response.json()["detail"].lower()
    
    def test_update_gdpr_consent(self, client):
        """Test : mise à jour du consentement RGPD"""
        # 1. Créer un utilisateur
        register_response = client.post(
            "/api/auth/register",
            json={
                "username": "testuser_consent_update",
                "email": "test_consent_update@example.com",
                "password": "Test123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        user_id = register_response.json()["id"]
        
        # 2. Se connecter
        login_response = client.post(
            "/api/auth/login",
            json={
                "username": "testuser_consent_update",
                "password": "Test123!@#"
            }
        )
        token = login_response.json()["access_token"]
        
        # 3. Mettre à jour le consentement
        update_response = client.put(
            f"/api/users/{user_id}",
            headers={"Authorization": f"Bearer {token}"},
            json={
                "gdpr_consent": False,
                "data_processing_consent": False
            }
        )
        assert update_response.status_code == 200
        updated_user = update_response.json()
        assert updated_user["gdpr_consent"] is False
        assert updated_user["data_processing_consent"] is False

