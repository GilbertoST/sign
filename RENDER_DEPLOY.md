# 🚀 Guide de déploiement sur Render

Ce guide vous explique comment déployer le backend de votre application LSF sur Render.

## 📋 Prérequis

- Compte Render créé (gratuit)
- Code prêt à être déployé

## 🎯 Étapes de déploiement

### 1. Connecter votre dépôt GitHub à Render

**Option A : Via l'interface Render**
1. Allez sur [dashboard.render.com](https://dashboard.render.com)
2. Cliquez sur **"New +"** → **"Web Service"**
3. Connectez votre compte GitHub si pas déjà fait
4. Sélectionnez votre dépôt `sign`

**Option B : Via le fichier `render.yaml`**
- Render détectera automatiquement le fichier `render.yaml` à la racine
- Cliquez sur **"Apply"** dans l'interface Render

### 2. Configuration automatique (via render.yaml)

Le fichier `render.yaml` configure automatiquement :
- ✅ **Build Command** : Installation des dépendances + initialisation DB
- ✅ **Start Command** : Lancement de FastAPI avec uvicorn
- ✅ **Variables d'environnement** : SECRET_KEY, DATABASE_URL, etc.
- ✅ **Port** : Utilise automatiquement `$PORT` pour Render

### 3. Variables d'environnement (automatiques via render.yaml)

Render définit automatiquement :
- `SECRET_KEY` : Généré automatiquement
- `DATABASE_URL` : `sqlite:///./sign_language.db`
- `ACCESS_TOKEN_EXPIRE_MINUTES` : `10080` (7 jours)
- `PYTHON_VERSION` : `3.12.0`

### 4. Premier déploiement

Render va automatiquement :
1. Installer les dépendances Python
2. Créer la base de données avec `init_db.py`
3. Initialiser les défis avec `init_challenges.py`
4. Lancer le serveur FastAPI

### 5. Attendre le déploiement

- Le déploiement prend ~5-10 minutes la première fois
- Vous verrez les logs en temps réel dans l'interface Render
- Le statut passera de **"Building"** → **"Deploying"** → **"Live"**

### 6. Récupérer votre URL

Une fois déployé, Render vous donne une URL :
```
https://sign-lsf-api.onrender.com
```

## 🔧 Configuration dans Flutter

### Modifier l'URL API

Dans `lib/services/api_service.dart`, modifier la ligne 16 :

```dart
// Avant (développement local)
static const String baseUrl = 'http://localhost:8000';

// Après (production Render)
static const String baseUrl = 'https://votre-service.onrender.com';
```

### Option : Utiliser une configuration conditionnelle

Créez un fichier `lib/config/api_config.dart` :

```dart
class ApiConfig {
  static const bool isProduction = true; // Changez à true en production
  static const String baseUrl = isProduction
      ? 'https://votre-service.onrender.com'
      : 'http://localhost:8000';
}
```

Puis dans `api_service.dart` :
```dart
import '../config/api_config.dart';

class ApiService {
  static const String baseUrl = ApiConfig.baseUrl;
  // ...
}
```

## ✅ Tester le déploiement

Une fois déployé, testez votre API :

```bash
# Test de l'API racine
curl https://votre-service.onrender.com/

# Test des signes
curl https://votre-service.onrender.com/api/signs

# Documentation interactive
# Ouvrez dans votre navigateur :
# https://votre-service.onrender.com/docs
```

## 📊 Limitations du plan gratuit Render

**Important à savoir :**
- ⚠️ Après **15 minutes d'inactivité**, l'app entre en "sleep mode"
- ⚠️ Le premier appel après le sleep prend ~30 secondes (cold start)
- ⚠️ Limite de **512 MB RAM** et **0.1 CPU**
- ⚠️ **750 heures gratuites/mois** de runtime

**Pour éviter le sleep mode :**
1. Payez un plan (7$/mois = toujours actif)
2. Utilisez un service de ping (UptimeRobot gratuit)
3. Acceptez le délai de démarrage (~30s)

## 🔄 Mises à jour automatiques

Une fois connecté à GitHub :
- Chaque `git push` déclenche un redéploiement automatique
- Render rebuild et redémarre votre application
- Logs disponibles dans l'interface Render

## 🐛 Dépannage

### L'app ne démarre pas

**Vérifier les logs :**
- Interface Render → Logs
- Cherchez les erreurs de build ou de démarrage

**Problèmes courants :**
1. **Erreur "No module named"** → Vérifier `requirements.txt`
2. **Erreur de base de données** → Vérifier `init_db.py` s'exécute
3. **Port binding** → Vérifier utilise bien `$PORT`

### L'API ne répond pas

1. Attendre ~30 secondes après le sleep
2. Vérifier que l'URL est correcte
3. Vérifier les logs pour erreurs 500

## 📱 Modifier l'application Flutter

Après avoir déployé :

```bash
# 1. Modifier api_service.dart avec la nouvelle URL
# 2. Tester localement avec l'URL Render
# 3. Lancer l'app
flutter run

# 4. Compiler pour production
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 🎉 Félicitations !

Votre backend est maintenant en production sur Render !

**URL de production** : `https://votre-service.onrender.com`

**Documentation** : `https://votre-service.onrender.com/docs`

**Next steps :**
1. Tester toutes les fonctionnalités avec l'URL de production
2. Compiler l'APK/IPA Flutter
3. Partager votre app ! 🚀

