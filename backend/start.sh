#!/bin/bash

echo "🚀 Démarrage du serveur API Langue des Signes"
echo "=============================================="

# Vérifier si l'environnement virtuel existe
if [ ! -d "venv" ]; then
    echo "📦 Création de l'environnement virtuel..."
    python3 -m venv venv
fi

# Activer l'environnement virtuel
echo "🔧 Activation de l'environnement virtuel..."
source venv/bin/activate

# Installer les dépendances
echo "📥 Installation des dépendances..."
pip install -q -r requirements.txt

# Vérifier si la base de données existe
if [ ! -f "sign_language.db" ]; then
    echo "🗄️  Initialisation de la base de données..."
    python init_db.py
fi

# Lancer le serveur
echo "✅ Démarrage du serveur sur http://localhost:8000"
echo "📖 Documentation API : http://localhost:8000/docs"
echo ""
uvicorn main:app --reload --host 0.0.0.0 --port 8000
