"""
Tests unitaires pour l'authentification
"""
import pytest
from fastapi import HTTPException
from auth import (
    validate_password_strength,
    get_password_hash,
    verify_password,
    create_access_token
)


class TestPasswordValidation:
    """Tests unitaires pour la validation de mot de passe"""
    
    def test_password_valid(self):
        """Test : mot de passe valide doit passer"""
        password = "Test123!@#"
        # Ne doit pas lever d'exception
        validate_password_strength(password)
    
    def test_password_too_short(self):
        """Test : mot de passe trop court doit échouer"""
        password = "Test1!"
        with pytest.raises(HTTPException) as exc_info:
            validate_password_strength(password)
        assert exc_info.value.status_code == 400
        assert "8 caractères" in exc_info.value.detail
    
    def test_password_no_uppercase(self):
        """Test : mot de passe sans majuscule doit échouer"""
        password = "test123!@#"
        with pytest.raises(HTTPException) as exc_info:
            validate_password_strength(password)
        assert exc_info.value.status_code == 400
    
    def test_password_no_lowercase(self):
        """Test : mot de passe sans minuscule doit échouer"""
        password = "TEST123!@#"
        with pytest.raises(HTTPException) as exc_info:
            validate_password_strength(password)
        assert exc_info.value.status_code == 400
    
    def test_password_no_digit(self):
        """Test : mot de passe sans chiffre doit échouer"""
        password = "TestABC!@#"
        with pytest.raises(HTTPException) as exc_info:
            validate_password_strength(password)
        assert exc_info.value.status_code == 400
    
    def test_password_no_special_char(self):
        """Test : mot de passe sans caractère spécial doit échouer"""
        password = "Test12345"
        with pytest.raises(HTTPException) as exc_info:
            validate_password_strength(password)
        assert exc_info.value.status_code == 400
    
    def test_password_with_space(self):
        """Test : mot de passe avec espace doit échouer"""
        password = "Test123! @#"
        with pytest.raises(HTTPException) as exc_info:
            validate_password_strength(password)
        assert exc_info.value.status_code == 400
        assert "espace" in exc_info.value.detail


class TestPasswordHashing:
    """Tests unitaires pour le hachage de mot de passe"""
    
    def test_hash_password(self):
        """Test : hash d'un mot de passe doit être différent du mot de passe original"""
        password = "Test123!@#"
        hashed = get_password_hash(password)
        assert hashed != password
        assert len(hashed) > 0
    
    def test_verify_password_correct(self):
        """Test : vérification d'un mot de passe correct"""
        password = "Test123!@#"
        hashed = get_password_hash(password)
        assert verify_password(password, hashed) is True
    
    def test_verify_password_incorrect(self):
        """Test : vérification d'un mot de passe incorrect"""
        password = "Test123!@#"
        wrong_password = "WrongPass123!"
        hashed = get_password_hash(password)
        assert verify_password(wrong_password, hashed) is False
    
    def test_hash_different_for_same_password(self):
        """Test : deux hash du même mot de passe doivent être différents (salage)"""
        password = "Test123!@#"
        hash1 = get_password_hash(password)
        hash2 = get_password_hash(password)
        # Les hash doivent être différents à cause du salage
        assert hash1 != hash2
        # Mais la vérification doit fonctionner pour les deux
        assert verify_password(password, hash1) is True
        assert verify_password(password, hash2) is True


class TestJWTToken:
    """Tests unitaires pour la création de tokens JWT"""
    
    def test_create_token(self):
        """Test : création d'un token JWT"""
        data = {"sub": "testuser"}
        token = create_access_token(data)
        assert token is not None
        assert isinstance(token, str)
        assert len(token) > 0
    
    def test_token_is_string(self):
        """Test : le token doit être une chaîne de caractères"""
        data = {"sub": "testuser"}
        token = create_access_token(data)
        assert isinstance(token, str)
        assert len(token) > 20  # Un token JWT est généralement assez long

