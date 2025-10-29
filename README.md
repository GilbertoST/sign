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

Les vidéos utilisées proviennent de la chaîne YouTube Dicoplus LSF.