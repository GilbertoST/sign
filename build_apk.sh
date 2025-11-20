#!/bin/bash

# Script wrapper pour build APK et renommage automatique

echo "🚀 Build APK Release..."
flutter build apk --release --split-per-abi

if [ $? -eq 0 ]; then
    echo ""
    echo "🔄 Renommage des APK..."
    ./rename_apk.sh
    echo ""
    echo "✅ Build et renommage terminés !"
    echo "📱 APK disponibles dans: build/app/outputs/flutter-apk/"
    ls -lh build/app/outputs/flutter-apk/sign-*.apk 2>/dev/null | awk '{print "   - " $9 " (" $5 ")"}'
else
    echo "❌ Erreur lors du build"
    exit 1
fi




