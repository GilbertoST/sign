"""
Script de test simple pour vérifier que l'API fonctionne correctement
Usage: python test_api.py
"""
import requests
import json

BASE_URL = "http://localhost:8000"

def test_root():
    """Test l'endpoint racine"""
    print("🔍 Test de l'endpoint racine...")
    try:
        response = requests.get(f"{BASE_URL}/")
        print(f"✅ Status: {response.status_code}")
        print(f"   Response: {response.json()}")
        return True
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return False

def test_register():
    """Test l'inscription d'un utilisateur"""
    print("\n🔍 Test d'inscription...")
    try:
        data = {
            "username": "testuser",
            "email": "test@example.com",
            "password": "testpassword123"
        }
        response = requests.post(f"{BASE_URL}/api/auth/register", json=data)
        
        if response.status_code == 201:
            print(f"✅ Utilisateur créé: {response.json()['username']}")
            return True
        elif response.status_code == 400:
            print("⚠️  Utilisateur existe déjà (normal si déjà testé)")
            return True
        else:
            print(f"❌ Erreur {response.status_code}: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return False

def test_login():
    """Test la connexion"""
    print("\n🔍 Test de connexion...")
    try:
        data = {
            "username": "testuser",
            "password": "testpassword123"
        }
        response = requests.post(f"{BASE_URL}/api/auth/login", json=data)
        
        if response.status_code == 200:
            token = response.json()['access_token']
            print(f"✅ Connexion réussie!")
            print(f"   Token: {token[:20]}...")
            return token
        else:
            print(f"❌ Erreur {response.status_code}: {response.text}")
            return None
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return None

def test_get_signs():
    """Test la récupération des signes"""
    print("\n🔍 Test de récupération des signes...")
    try:
        response = requests.get(f"{BASE_URL}/api/signs")
        
        if response.status_code == 200:
            signs = response.json()
            print(f"✅ {len(signs)} signes récupérés")
            if signs:
                print(f"   Premier signe: {signs[0]['letter']} (difficulté: {signs[0]['difficulty']})")
            return True
        else:
            print(f"❌ Erreur {response.status_code}: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return False

def test_user_stats(token):
    """Test la récupération des statistiques utilisateur"""
    print("\n🔍 Test de récupération des stats...")
    try:
        headers = {"Authorization": f"Bearer {token}"}
        
        # D'abord, récupérer l'utilisateur actuel
        response = requests.get(f"{BASE_URL}/api/auth/me", headers=headers)
        if response.status_code != 200:
            print(f"❌ Erreur de récupération du profil: {response.status_code}")
            return False
        
        user_id = response.json()['id']
        
        # Maintenant récupérer les stats
        response = requests.get(f"{BASE_URL}/api/users/{user_id}/stats", headers=headers)
        
        if response.status_code == 200:
            stats = response.json()
            print(f"✅ Statistiques récupérées:")
            print(f"   Total signes: {stats['total_signs']}")
            print(f"   Signes maîtrisés: {stats['mastered_signs']}")
            print(f"   Taux de réussite: {stats['success_rate']}%")
            return True
        else:
            print(f"❌ Erreur {response.status_code}: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Erreur: {e}")
        return False

def main():
    print("=" * 60)
    print("🧪 Test de l'API Langue des Signes")
    print("=" * 60)
    
    # Vérifier que le serveur est démarré
    try:
        requests.get(BASE_URL, timeout=2)
    except requests.exceptions.ConnectionError:
        print("\n❌ ERREUR: Le serveur n'est pas démarré!")
        print("   Lancez d'abord: uvicorn main:app --reload")
        return
    
    # Exécuter les tests
    results = []
    
    results.append(("Endpoint racine", test_root()))
    results.append(("Inscription", test_register()))
    
    token = test_login()
    results.append(("Connexion", token is not None))
    
    results.append(("Récupération des signes", test_get_signs()))
    
    if token:
        results.append(("Statistiques utilisateur", test_user_stats(token)))
    
    # Résumé
    print("\n" + "=" * 60)
    print("📊 RÉSUMÉ DES TESTS")
    print("=" * 60)
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status} - {test_name}")
    
    print(f"\n🎯 Résultat: {passed}/{total} tests passés")
    
    if passed == total:
        print("🎉 Tous les tests ont réussi!")
    else:
        print("⚠️  Certains tests ont échoué, vérifiez les logs ci-dessus")

if __name__ == "__main__":
    main()
