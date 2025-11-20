# Tests Flutter

Ce dossier contient tous les tests pour l'application Flutter.

## Structure

### Tests fonctionnels (`functional/`)
- `functional_test_auth.dart` : Tests fonctionnels pour l'authentification et les modèles
- `functional_test_user_model.dart` : Tests fonctionnels pour le modèle User

### Tests E2E (`e2e/`)
- `appium_test_login_flow.dart` : Tests end-to-end pour le flux de connexion/inscription
- `appium_test_rgpd_flow.dart` : Tests end-to-end pour les fonctionnalités RGPD

## Installation

```bash
flutter pub get
```

## Exécution des tests

### Tests fonctionnels
```bash
flutter test test/functional/
```

### Tests E2E avec Flutter Driver
```bash
# Démarrer l'application en mode driver
flutter drive --target=test/e2e/appium_test_login_flow.dart
flutter drive --target=test/e2e/appium_test_rgpd_flow.dart
```

### Tous les tests
```bash
flutter test
```

## Configuration Appium (optionnel)

Pour utiliser Appium au lieu de Flutter Driver :

1. Installer Appium :
```bash
npm install -g appium
npm install -g appium-doctor
```

2. Installer les drivers :
```bash
appium driver install uiautomator2  # Android
appium driver install xcuitest      # iOS
```

3. Démarrer Appium :
```bash
appium
```

## Notes

- Les tests E2E nécessitent que l'application soit compilée et lancée
- Les sélecteurs dans les tests E2E doivent correspondre aux `ValueKey` et textes de ton application
- Ajuste les sélecteurs selon la structure réelle de ton UI

