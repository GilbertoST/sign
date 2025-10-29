@echo off
echo.
echo 🚀 Démarrage du serveur API Langue des Signes
echo ==============================================
echo.

REM Vérifier si l'environnement virtuel existe
if not exist "venv" (
    echo 📦 Création de l'environnement virtuel...
    python -m venv venv
)

REM Activer l'environnement virtuel
echo 🔧 Activation de l'environnement virtuel...
call venv\Scripts\activate

REM Installer les dépendances
echo 📥 Installation des dépendances...
pip install -q -r requirements.txt

REM Vérifier si la base de données existe
if not exist "sign_language.db" (
    echo 🗄️  Initialisation de la base de données...
    python init_db.py
)

REM Lancer le serveur
echo ✅ Démarrage du serveur sur http://localhost:8000
echo 📖 Documentation API : http://localhost:8000/docs
echo.
uvicorn main:app --reload --host 0.0.0.0 --port 8000
