# 🚀 Démarrage rapide

## Backend (5 min)

```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python init_db.py
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

✅ Backend prêt sur http://localhost:8000

## Frontend (2 min)

```bash
cd /Users/gil/Desktop/sign
flutter pub get
flutter run
```

## Connexion

- Username: `testuser`
- Password: `testpassword123`

## API Docs

http://localhost:8000/docs
