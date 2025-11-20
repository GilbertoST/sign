#!/bin/bash

# Script de build release pour l'application LSF
# Usage: ./build_release.sh [android|ios|both]

echo "🚀 Build Release - Application Langue des Signes"
echo "=================================================="
echo ""

# Vérifier Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé ou n'est pas dans le PATH"
    exit 1
fi

# Vérifier qu'on est dans le bon répertoire
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Lancez ce script depuis la racine du projet"
    exit 1
fi

# Sélectionner la plateforme
PLATFORM=${1:-android}

echo "📦 Préparation..."
flutter clean
flutter pub get

if [ "$PLATFORM" = "android" ] || [ "$PLATFORM" = "both" ]; then
    echo ""
    echo "🤖 Build Android APK..."
    flutter build apk --release --split-per-abi
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Build Android réussi !"
        echo "📱 APK générés dans :"
        ls -lh build/app/outputs/flutter-apk/*.apk 2>/dev/null | awk '{print "   - " $9 " (" $5 ")"}'
    else
        echo "❌ Erreur lors du build Android"
        exit 1
    fi
fi

if [ "$PLATFORM" = "ios" ] || [ "$PLATFORM" = "both" ]; then
    echo ""
    echo "🍎 Build iOS..."
    echo "   Ouvrez Xcode : open ios/Runner.xcworkspace"
    echo "   Puis : Product → Archive"
fi

echo ""
echo "✨ Build terminé !"
echo ""
echo "📋 Checklist finale :"
echo "   [ ] Tester l'APK sur un device physique"
echo "   [ ] Vérifier la connexion au backend Render"
echo "   [ ] Tester mode invité et création de compte"
echo "   [ ] Vérifier miniatures YouTube"
echo "   [ ] Tester quiz et défis"




