#!/bin/bash

# Script de déploiement sur Render
# Usage: ./deploy_render.sh

echo "🚀 Préparation du déploiement sur Render..."

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "render.yaml" ]; then
    echo "❌ Erreur: render.yaml introuvable"
    echo "   Lancez ce script depuis la racine du projet"
    exit 1
fi

# Vérifier que git est initialisé
if [ ! -d ".git" ]; then
    echo "📦 Initialisation du dépôt Git..."
    git init
    git add .
    git commit -m "Initial commit for Render deployment"
fi

echo "✅ Vérification des fichiers..."
echo "   ✓ render.yaml"
echo "   ✓ backend/requirements.txt"
echo "   ✓ backend/init_db.py"
echo "   ✓ backend/init_challenges.py"

echo ""
echo "📋 Étapes suivantes :"
echo ""
echo "1. Pushez votre code sur GitHub :"
echo "   git remote add origin <URL_DE_VOTRE_REPO>"
echo "   git push -u origin main"
echo ""
echo "2. Allez sur Render.com et :"
echo "   - Cliquez sur 'New +' → 'Web Service'"
echo "   - Connectez GitHub et sélectionnez votre repo"
echo "   - Render détectera automatiquement render.yaml"
echo "   - Cliquez sur 'Apply'"
echo ""
echo "3. Attendez ~5-10 minutes le déploiement"
echo ""
echo "4. Récupérez votre URL Render (ex: https://sign-lsf-api.onrender.com)"
echo ""
echo "5. Modifiez lib/config/api_config.dart :"
echo "   - Changez 'isProduction = true'"
echo "   - Changez 'renderUrl' avec votre URL Render"
echo ""
echo "📖 Guide complet : Voir RENDER_DEPLOY.md"
echo ""
echo "✨ Bon déploiement !"

