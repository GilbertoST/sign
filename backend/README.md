# Backend API

API REST pour l'apprentissage de la langue des signes.

## Installation

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python init_db.py
```

## Lancement

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## Documentation

http://localhost:8000/docs

## Tests

```bash
python test_api.py
```

## Stack

- FastAPI
- SQLAlchemy + SQLite
- JWT (python-jose)
- Bcrypt
