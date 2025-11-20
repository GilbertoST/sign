#!/bin/bash

# Script pour renommer les APK de "app-*" vers "sign-*"

APK_DIR="build/app/outputs/flutter-apk"

if [ -d "$APK_DIR" ]; then
    echo "🔄 Renommage des APK..."
    for apk in "$APK_DIR"/app-*.apk; do
        if [ -f "$apk" ]; then
            new_name=$(basename "$apk" | sed 's/^app-/sign-/')
            new_path="$APK_DIR/$new_name"
            mv "$apk" "$new_path"
            echo "✓ $(basename "$apk") -> $new_name"
        fi
    done
    echo "✅ Renommage terminé !"
else
    echo "❌ Répertoire $APK_DIR introuvable"
    exit 1
fi




