# Guide des Tests

Ce guide explique comment exécuter tous les tests du projet.

## 📋 Résumé des tests créés

### Backend (Python)
- ✅ **2 tests unitaires** : `test_auth.py`, `test_xp_calculator.py`
- ✅ **2 tests d'intégration** : `test_integration_auth.py`, `test_integration_rgpd.py`

### Frontend (Flutter)
- ✅ **2 tests fonctionnels** : `functional_test_auth.dart`, `functional_test_user_model.dart`
- ✅ **2 tests E2E** : `appium_test_login_flow.dart`, `appium_test_rgpd_flow.dart`

---

## 🐍 Tests Backend

### Installation des dépendances

```bash
cd backend
pip install -r requirements.txt
```

### Exécution

```bash
# Tous les tests backend
pytest backend/tests/ -v

# Tests unitaires uniquement
pytest backend/tests/test_auth.py backend/tests/test_xp_calculator.py -v

# Tests d'intégration uniquement
pytest backend/tests/test_integration_*.py -v

# Avec couverture de code
pytest backend/tests/ --cov=backend --cov-report=html
```

### Tests unitaires créés

#### `test_auth.py`
- Validation de mot de passe (longueur, complexité, caractères spéciaux)
- Hachage et vérification de mot de passe
- Création de tokens JWT

#### `test_xp_calculator.py`
- Calcul du niveau à partir de l'XP
- Calcul du pourcentage de progression
- Calcul des récompenses XP

### Tests d'intégration créés

#### `test_integration_auth.py`
- Flux complet d'inscription puis connexion
- Validation du consentement RGPD lors de l'inscription
- Gestion des erreurs (mauvais mot de passe, username dupliqué)

#### `test_integration_rgpd.py`
- Export des données utilisateur (droit d'accès RGPD)
- Suppression de compte avec cascade (droit à l'oubli)
- Vérification des autorisations (un utilisateur ne peut pas exporter les données d'un autre)

---

## 📱 Tests Flutter

### Installation des dépendances

```bash
flutter pub get
```

### Tests fonctionnels

```bash
# Tous les tests fonctionnels
flutter test test/functional/

# Test spécifique
flutter test test/functional/functional_test_auth.dart
```

### Tests E2E avec Flutter Driver

```bash
# Test de connexion/inscription
flutter drive --target=test/e2e/appium_test_login_flow.dart

# Test des fonctionnalités RGPD
flutter drive --target=test/e2e/appium_test_rgpd_flow.dart
```

### Tests fonctionnels créés

#### `functional_test_auth.dart`
- Désérialisation/sérialisation du modèle User
- Gestion des tokens dans ApiService
- User avec valeurs par défaut et utilisateur invité

#### `functional_test_user_model.dart`
- Tests complets du modèle User (JSON complet, minimal, valeurs par défaut)
- Gestion des dates de consentement RGPD

### Tests E2E créés

#### `appium_test_login_flow.dart`
- Inscription complète avec consentement RGPD
- Connexion avec credentials valides

#### `appium_test_rgpd_flow.dart`
- Export des données RGPD
- Mise à jour du consentement RGPD

---

## ⚙️ Configuration Appium (optionnel)

Si tu veux utiliser Appium au lieu de Flutter Driver :

### Installation

```bash
npm install -g appium
npm install -g appium-doctor
appium driver install uiautomator2  # Android
appium driver install xcuitest      # iOS
```

### Utilisation

1. Démarrer Appium :
```bash
appium
```

2. Lancer les tests avec Appium (nécessite une configuration supplémentaire)

---

## 📝 Notes importantes

### Pour les tests E2E

Les tests E2E utilisent des sélecteurs qui doivent correspondre à ton application :

- `ValueKey` : Assure-toi que tes widgets ont les bons `key: ValueKey('username_field')`
- Textes : Les textes doivent correspondre exactement à ceux de ton UI
- Navigation : Les routes et écrans doivent correspondre

### Ajustements nécessaires

Tu devras peut-être ajuster :
- Les sélecteurs dans les tests E2E selon ta structure UI
- Les noms d'écrans ("Accueil", "Profil", etc.)
- Les `ValueKey` de tes widgets

### Base de données de test

Les tests backend utilisent une base SQLite en mémoire qui est créée et supprimée pour chaque test. Aucune configuration supplémentaire n'est nécessaire.

---

## 🚀 Exécution rapide

### Backend
```bash
cd backend && pytest tests/ -v
```

### Frontend
```bash
flutter test
```

### Tous les tests
```bash
# Terminal 1 : Backend
cd backend && pytest tests/ -v

# Terminal 2 : Frontend
flutter test
```

---

## 📊 Résultats attendus

### Tests unitaires backend
- ✅ ~15 tests unitaires devraient passer
- ✅ Couverture : validation, hachage, JWT, calcul XP

### Tests d'intégration backend
- ✅ ~6 tests d'intégration devraient passer
- ✅ Couverture : flux complets d'authentification et RGPD

### Tests fonctionnels Flutter
- ✅ ~8 tests fonctionnels devraient passer
- ✅ Couverture : modèles et services

### Tests E2E
- ⚠️ Nécessitent que l'application soit compilée et lancée
- ⚠️ Nécessitent des ajustements selon ta structure UI

---

## 🐛 Dépannage

### Erreur : Module not found (Python)
```bash
cd backend
pip install -r requirements.txt
```

### Erreur : Package not found (Flutter)
```bash
flutter pub get
```

### Erreur : Tests E2E ne trouvent pas les éléments
- Vérifie que les `ValueKey` correspondent
- Vérifie que les textes correspondent exactement
- Ajuste les sélecteurs dans les fichiers de test

---

## 📚 Documentation supplémentaire

- [README des tests backend](backend/tests/README.md)
- [README des tests Flutter](test/README.md)

