# ⚡ Déploiement Rapide Render - Guide Express

## 🎯 5 Étapes pour déployer votre backend

### 1️⃣ Uploader votre code sur GitHub

```bash
# Si pas déjà fait
git init
git add .
git commit -m "Initial commit - LSF App Backend"

# Créer un repo sur GitHub.com puis :
git remote add origin https://github.com/VOTRE_USERNAME/sign.git
git push -u origin main
```

### 2️⃣ Créer un service Render

1. Allez sur https://dashboard.render.com
2. **New +** → **Web Service**
3. Connectez GitHub (si pas déjà fait)
4. Sélectionnez votre dépôt `sign`
5. Le fichier `render.yaml` sera automatiquement détecté ✅
6. Cliquez sur **Create Web Service**

### 3️⃣ Attendre le déploiement

- Build : ~5 minutes
- Premier déploiement : ~10 minutes
- Status : "Live" = ✅ prêt !

### 4️⃣ Récupérer votre URL

Render vous donne une URL comme :
```
https://sign-lsf-api.onrender.com
```

### 5️⃣ Modifier Flutter pour utiliser l'API de production

**Option A : Modification rapide (ApiService)**

Dans `lib/services/api_service.dart` ligne 16 :
```dart
// Remplacez par :
static const String baseUrl = 'https://votre-service.onrender.com';
```

**Option B : Configuration propre (recommandé)**

Dans `lib/config/api_config.dart` :
```dart
// Ligne 5 : Passer à true
static const bool isProduction = true;

// Ligne 9 : Mettre votre URL Render
static const String renderUrl = 'https://votre-service.onrender.com';
```

Puis dans `lib/services/api_service.dart` ligne 16 :
```dart
static const String baseUrl = ApiConfig.baseUrl;
```

## ✅ Tester

```bash
# Test de l'API
curl https://votre-service.onrender.com/

# Test des signes
curl https://votre-service.onrender.com/api/signs

# Documentation
# Ouvrez : https://votre-service.onrender.com/docs
```

## 🎉 C'est fait !

Votre backend est en production sur Render ! 🚀

## 📝 Notes importantes

### Sleep Mode (plan gratuit)
- Après 15 min d'inactivité : l'app "s'endort"
- Premier appel : ~30 secondes de démarrage
- Solution : Service de ping (UptimeRobot gratuit) ou plan payant

### Évolution future
Quand vous avez terminé le prototype :
- Connecter l'app Flutter à l'URL Render
- Compiler l'APK/IPA
- Partager votre application !

## 🔗 Ressources

- [Guide complet](RENDER_DEPLOY.md)
- [Documentation Render](https://render.com/docs)
- [Dashboard Render](https://dashboard.render.com)

