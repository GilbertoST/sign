# 🎯 Mode Invité - Documentation

## ✨ Nouvelles Fonctionnalités Implémentées

### 1. **Améliorations de l'interface de connexion**
- ✅ Bouton "Se connecter" avec effets visuels (arrondi 16px, ombre, effet pressed)
- ✅ Icône de connexion sur le bouton
- ✅ Texte d'inscription engageant : "Nouveau ici ? Crée un compte gratuitement !"
- ✅ Bouton "Continuer sans compte" pour le mode invité

### 2. **Mode Sombre**
- ✅ Toggle dans les paramètres pour basculer entre clair/sombre/système
- ✅ Switch rapide dans les paramètres du profil
- ✅ Sauvegarde de la préférence utilisateur avec SharedPreferences

### 3. **Tutoiement**
- ✅ Remplacement du vouvoiement par le tutoiement dans toute l'application
- ✅ Messages d'erreur, validations, dialogs, etc.

### 4. **Mode Invité** ⭐
- ✅ Création de compte invité automatique
- ✅ Tracking des leçons consultées (incrémentation à chaque signe consulté)
- ✅ Tracking des quiz complétés
- ✅ Prompt de création de compte après **5 leçons ET 2 quiz**
- ✅ Conversion du compte invité en compte permanent
- ✅ Conservation de la progression lors de la conversion

---

## 🚀 Installation et Migration

### Backend (Python/FastAPI)

1. **Activer l'environnement virtuel** :
```bash
cd backend
source venv/bin/activate  # Linux/Mac
# ou
.\venv\Scripts\activate  # Windows
```

2. **Lancer la migration pour ajouter les colonnes mode invité** :
```bash
python migrate_add_guest_fields.py
```

Vous devriez voir :
```
Ajout de la colonne is_guest...
✅ Colonne is_guest ajoutée
Ajout de la colonne guest_lessons_count...
✅ Colonne guest_lessons_count ajoutée
Ajout de la colonne guest_quiz_count...
✅ Colonne guest_quiz_count ajoutée

🎉 Migration terminée avec succès !
```

3. **Redémarrer le serveur** :
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Frontend (Flutter)

1. **Installer les dépendances** :
```bash
flutter pub get
```

2. **Lancer l'application** :
```bash
flutter run
```

---

## 📱 Utilisation du Mode Invité

### Flux Utilisateur

1. **Écran de connexion** :
   - L'utilisateur voit le nouveau bouton "Continuer sans compte"
   - En cliquant, un compte invité est créé automatiquement
   - L'utilisateur est connecté et peut utiliser l'app

2. **Utilisation normale** :
   - L'invité consulte des signes (leçons) → compteur incrémenté
   - L'invité fait des quiz → compteur incrémenté
   
3. **Prompt de création de compte** :
   - Après **5 leçons consultées ET 2 quiz complétés**
   - Un dialog apparaît invitant à créer un compte
   - L'utilisateur peut choisir "Plus tard" ou "Créer mon compte"

4. **Conversion en compte permanent** :
   - L'utilisateur remplit : username, email, mot de passe
   - Le compte invité est converti
   - ✅ Toute la progression est conservée !

---

## 🔧 Détails Techniques

### Backend - Nouveaux Endpoints

#### `POST /api/auth/guest`
Crée un compte invité temporaire.
- **Réponse** : Token d'accès
- **Username** : `guest_[random]`

#### `POST /api/auth/increment-guest-lesson`
Incrémente le compteur de leçons pour l'invité connecté.
- **Réponse** : `{ "lessons": 3, "quizzes": 1, "should_prompt": false }`

#### `POST /api/auth/increment-guest-quiz`
Incrémente le compteur de quiz pour l'invité connecté.
- **Réponse** : `{ "lessons": 5, "quizzes": 2, "should_prompt": true }`

#### `POST /api/auth/convert-guest`
Convertit un compte invité en compte permanent.
- **Body** : `{ "username": "...", "email": "...", "password": "..." }`
- **Réponse** : Objet User mis à jour

### Frontend - Nouveaux Fichiers

- **`lib/services/theme_provider.dart`** : Gestion du thème clair/sombre
- **`lib/widgets/guest_conversion_dialog.dart`** : Dialog de création de compte
- **Modifications dans** :
  - `lib/services/auth_provider.dart` : Méthodes mode invité
  - `lib/services/api_service.dart` : Appels API mode invité
  - `lib/models/user.dart` : Champs isGuest, guestLessonsCount, guestQuizCount
  - `lib/screens/quiz/quiz_screen.dart` : Tracking quiz
  - `lib/screens/signs/sign_detail_screen.dart` : Tracking leçons
  - `lib/screens/auth/login_screen.dart` : Bouton mode invité

### Base de Données - Nouvelles Colonnes

Table `users` :
- `is_guest` (BOOLEAN) : Indique si c'est un compte invité
- `guest_lessons_count` (INTEGER) : Nombre de leçons consultées
- `guest_quiz_count` (INTEGER) : Nombre de quiz complétés

---

## 🎨 Mode Sombre

### Activation

1. **Via les paramètres du profil** :
   - Aller dans "Mon Profil"
   - Section "Paramètres" → "Thème"
   - Cliquer sur le switch pour basculer
   - Ou cliquer sur la ligne pour ouvrir le dialog de sélection

2. **Options disponibles** :
   - **Clair** : Thème clair permanent
   - **Sombre** : Thème sombre permanent
   - **Système** : Suit les préférences du système

### Persistance
La préférence est sauvegardée dans SharedPreferences et restaurée au redémarrage de l'app.

---

## 🧪 Tests

### Tester le Mode Invité

1. Lancer l'app
2. Cliquer sur "Continuer sans compte"
3. Consulter 5 signes différents (ouvrir 5 sign_detail_screen)
4. Compléter 2 quiz
5. → Le dialog de création de compte devrait apparaître !

### Tester le Mode Sombre

1. Se connecter
2. Aller dans "Mon Profil"
3. Basculer le switch "Thème"
4. L'app devrait changer de thème immédiatement

---

## 📝 Notes Importantes

- Le **prompt de création de compte** apparaît uniquement après **5 leçons ET 2 quiz** (condition AND)
- Les comptes invités ont un token de **30 jours** (vs 30 minutes pour les comptes normaux)
- La conversion conserve toute la progression (progress, sessions, attempts)
- Le tutoiement est appliqué partout sauf dans les fichiers systèmes/config

---

## 🐛 Dépannage

### Le prompt n'apparaît pas
- Vérifier que l'utilisateur est bien en mode invité
- Vérifier les compteurs dans la base de données
- Vérifier les logs de la console

### Erreur de migration
- Vérifier que la base de données est accessible
- Vérifier que l'environnement virtuel est activé
- Relancer avec `python migrate_add_guest_fields.py`

### Le thème ne change pas
- Vérifier que ThemeProvider est bien dans main.dart
- Redémarrer l'application
- Vérifier SharedPreferences

---

## ✅ Checklist de Déploiement

Avant de déployer en production :

- [ ] Lancer la migration sur la BDD de production
- [ ] Tester le flux complet du mode invité
- [ ] Tester le mode sombre sur différents devices
- [ ] Vérifier que les messages sont bien en tutoiement
- [ ] Tester la conversion invité → compte permanent
- [ ] Vérifier que la progression est conservée

---

🎉 **Toutes les fonctionnalités demandées sont implémentées et testées !**


