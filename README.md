# Application Langue des Signes

Application mobile d'apprentissage de l'alphabet en langue des signes française (LSF).

## 🚀 Démarrage rapide

### Backend (Terminal 1)
```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # Mac/Linux
pip install -r requirements.txt
python init_db.py
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Frontend (Terminal 2)
```bash
flutter pub get
flutter run
```

## 🔐 Compte de test

- **Username**: `testuser`
- **Password**: `testpassword123`

## 📁 Structure

```
sign/
├── backend/          # API FastAPI + SQLite
├── lib/              # Code Flutter
├── assets/           # Médias (images, vidéos)
└── README.md
```

## 🛠️ Technologies

- **Backend**: FastAPI, SQLAlchemy, SQLite
- **Frontend**: Flutter
- **Auth**: JWT

## 📚 API Documentation

http://localhost:8000/docs

## 🎨 Fonctionnalités UI/UX

- ✅ **Thème unifié** avec constantes centralisées
- ✅ **Dark Mode** automatique (suit le système)
- ✅ **Animations fluides** (transitions, boutons, feedback)
- ✅ **Design moderne** avec gradients et shadows
- ✅ **HapticFeedback** sur toutes les interactions

## ⚠️ Note

Les médias dans `assets/` sont des placeholders. Remplacez-les par de vraies vidéos LSF.

## 🚀 Déploiement Production (Render)

### Déploiement Express
1. Uploader sur GitHub
2. Créer un service sur [Render.com](https://render.com)
3. Connecter le repo → Render détecte `render.yaml` automatiquement
4. Attendre ~10 minutes
5. Récupérer l'URL Render

**Guide complet** : Voir [RENDER_QUICK_START.md](RENDER_QUICK_START.md)

### Configuration après déploiement
Modifier `lib/config/api_config.dart` :
```dart
static const bool isProduction = true;
static const String renderUrl = 'https://votre-service.onrender.com';
```
