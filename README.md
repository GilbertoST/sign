# Application Langue des Signes

Application mobile d'apprentissage de l'alphabet en langue des signes française (LSF).

## Démarrage rapide

### Backend (Terminal 1)

```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
cp .env.example .env      # puis renseigne SECRET_KEY
pip install -r requirements.txt
python init_db.py
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Génère une clé secrète :

```bash
python -c "import secrets; print(secrets.token_urlsafe(64))"
```

### Frontend (Terminal 2)

```bash
flutter pub get
flutter run
```

Par défaut l'app pointe vers l'API de production. Pour le backend local, passe `ApiConfig.isProduction` à `false` dans `lib/config/api_config.dart`.

## Compte de test

- **Username**: `testuser`
- **Password**: `testpassword123`

## Tests

```bash
# Backend (à la racine du dépôt)
pip install -r backend/requirements.txt
pytest

# Flutter
flutter pub get
flutter analyze --no-fatal-infos
flutter test
```

Les tests E2E (`test/e2e/`) nécessitent Flutter Driver et ne sont pas lancés par `flutter test`.

## Structure

```
sign/
├── backend/          # API FastAPI + SQLite (PostgreSQL en production)
├── lib/              # Code Flutter
├── assets/           # Images de l'alphabet
└── README.md
```

## Technologies

- **Backend**: FastAPI, SQLAlchemy, SQLite / PostgreSQL
- **Frontend**: Flutter
- **Auth**: JWT

## Configuration sécurité & RGPD

1. Copie `backend/.env.example` vers `backend/.env` et renseigne `SECRET_KEY`.
2. Migrations (si tu pars d'une ancienne base locale) :
   ```
   python backend/migrate_add_profile_fields.py
   python backend/migrate_update_consent_fields.py
   ```
3. Documents légaux dans l'app : Politique de confidentialité, CGU, mentions légales (`lib/screens/legal/`).
4. Politique de mot de passe : longueur ≥ 8 + majuscule + minuscule + chiffre + caractère spécial.
5. Rate limiting : 5 tentatives de connexion / 15 minutes par IP/utilisateur (HTTP 429 en cas d'abus).
6. Headers de sécurité (HSTS, CSP, etc.) injectés côté API — activer HTTPS en production pour en profiter.
7. Stockage local : le token JWT est stocké avec `flutter_secure_storage` (Keychain / EncryptedSharedPrefs).

## Note

Les vidéos utilisées proviennent de la chaîne YouTube Dicoplus LSF.
