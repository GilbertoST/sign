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

## 🔐 Configuration sécurité & RGPD

1. Crée un fichier `backend/.env` avec :
   ```
   SECRET_KEY="change-me-with-a-64-bytes-secret"
   ALLOWED_ORIGINS=["http://localhost:5173","https://ton-domaine.com"]
   ```
2. Exécute les migrations RGPD :
   ```
   python backend/migrate_add_profile_fields.py
   python backend/migrate_update_consent_fields.py
   ```
3. Consulte les documents légaux :
   - `PRIVACY_POLICY.md`
   - `TERMS_OF_SERVICE.md`
   - `LEGAL_NOTICE.md`
4. Politique de mot de passe : longueur ≥ 8 + majuscule + minuscule + chiffre + caractère spécial.
5. Rate limiting : 5 tentatives de connexion / 15 minutes par IP/utilisateur (HTTP 429 en cas d'abus).
6. Headers de sécurité (HSTS, CSP, etc.) injectés côté API — activer HTTPS en production pour en profiter.
7. Stockage local : le token JWT est stocké avec `flutter_secure_storage` (Keychain / EncryptedSharedPrefs).

## 🎨 Fonctionnalités UI/UX

- ✅ **Thème unifié** avec constantes centralisées
- ✅ **Dark Mode** automatique (suit le système)
- ✅ **Animations fluides** (transitions, boutons, feedback)
- ✅ **Design moderne** avec gradients et shadows
- ✅ **HapticFeedback** sur toutes les interactions

## ⚠️ Note

Les vidéos utilisées proviennent de la chaîne YouTube Dicoplus LSF.