"""
Test OWASP A01:2021 - Broken Access Control
Teste que les utilisateurs ne peuvent pas accéder aux ressources d'autres utilisateurs
"""


class TestAccessControlSecurity:
    """Tests de sécurité : Contrôle d'accès et autorisation"""
    
    def test_user_cannot_access_other_user_data(self, client):
        """Test : Un utilisateur ne peut pas accéder aux données d'un autre utilisateur"""
        # Créer deux utilisateurs
        user1_response = client.post(
            "/api/auth/register",
            json={
                "username": "user1_access",
                "email": "user1_access@example.com",
                "password": "Pass123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        user1_id = user1_response.json()["id"]
        
        user2_response = client.post(
            "/api/auth/register",
            json={
                "username": "user2_access",
                "email": "user2_access@example.com",
                "password": "Pass123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        user2_id = user2_response.json()["id"]
        
        # user2 se connecte
        login_response = client.post(
            "/api/auth/login",
            json={
                "username": "user2_access",
                "password": "Pass123!@#"
            }
        )
        token2 = login_response.json()["access_token"]
        
        # user2 essaie d'accéder aux données de user1
        response = client.get(
            f"/api/users/{user1_id}/export",
            headers={"Authorization": f"Bearer {token2}"}
        )
        assert response.status_code == 403  # Forbidden
        assert "autorisé" in response.json()["detail"].lower()
    
    def test_user_cannot_delete_other_user_account(self, client):
        """Test : Un utilisateur ne peut pas supprimer le compte d'un autre"""
        # Créer deux utilisateurs
        user1_response = client.post(
            "/api/auth/register",
            json={
                "username": "user1_delete",
                "email": "user1_delete@example.com",
                "password": "Pass123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        user1_id = user1_response.json()["id"]
        
        user2_response = client.post(
            "/api/auth/register",
            json={
                "username": "user2_delete",
                "email": "user2_delete@example.com",
                "password": "Pass123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        user2_id = user2_response.json()["id"]
        
        # user2 se connecte
        login_response = client.post(
            "/api/auth/login",
            json={
                "username": "user2_delete",
                "password": "Pass123!@#"
            }
        )
        token2 = login_response.json()["access_token"]
        
        # user2 essaie de supprimer le compte de user1
        response = client.delete(
            f"/api/users/{user1_id}",
            headers={"Authorization": f"Bearer {token2}"}
        )
        assert response.status_code == 403  # Forbidden
        
        # Vérifier que user1 existe toujours
        login_user1 = client.post(
            "/api/auth/login",
            json={
                "username": "user1_delete",
                "password": "Pass123!@#"
            }
        )
        assert login_user1.status_code == 200
    
    def test_user_cannot_modify_other_user_profile(self, client):
        """Test : Un utilisateur ne peut pas modifier le profil d'un autre"""
        # Créer deux utilisateurs
        user1_response = client.post(
            "/api/auth/register",
            json={
                "username": "user1_modify",
                "email": "user1_modify@example.com",
                "password": "Pass123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        user1_id = user1_response.json()["id"]
        
        user2_response = client.post(
            "/api/auth/register",
            json={
                "username": "user2_modify",
                "email": "user2_modify@example.com",
                "password": "Pass123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        
        # user2 se connecte
        login_response = client.post(
            "/api/auth/login",
            json={
                "username": "user2_modify",
                "password": "Pass123!@#"
            }
        )
        token2 = login_response.json()["access_token"]
        
        # user2 essaie de modifier le profil de user1
        response = client.put(
            f"/api/users/{user1_id}",
            headers={"Authorization": f"Bearer {token2}"},
            json={
                "bio": "Modifié par user2 - ATTaque !"
            }
        )
        assert response.status_code == 403  # Forbidden
    
    def test_progress_isolation_between_users(self, client):
        """Test : Un utilisateur ne peut pas créer/modifier la progression d'un autre"""
        # Créer deux utilisateurs
        user1_response = client.post(
            "/api/auth/register",
            json={
                "username": "user1_progress",
                "email": "user1_progress@example.com",
                "password": "Pass123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        user1_id = user1_response.json()["id"]
        
        user2_response = client.post(
            "/api/auth/register",
            json={
                "username": "user2_progress",
                "email": "user2_progress@example.com",
                "password": "Pass123!@#",
                "gdpr_consent": True,
                "data_processing_consent": True
            }
        )
        user2_id = user2_response.json()["id"]
        
        # user2 se connecte
        login_response = client.post(
            "/api/auth/login",
            json={
                "username": "user2_progress",
                "password": "Pass123!@#"
            }
        )
        token2 = login_response.json()["access_token"]
        
        # user2 essaie de créer une progression pour user1
        response = client.post(
            "/api/progress",
            headers={"Authorization": f"Bearer {token2}"},
            json={
                "user_id": user1_id,  # Tentative d'accès non autorisé
                "sign_id": 1,
                "attempts": 5,
                "mastered": True
            }
        )
        assert response.status_code == 403  # Forbidden

