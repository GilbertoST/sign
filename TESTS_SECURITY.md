# Tests de Cybersécurité OWASP

Ce document décrit les tests de cybersécurité basés sur l'OWASP Top 10 pour le projet.

## 📋 Vue d'ensemble

Trois fichiers de tests de sécurité ont été créés pour valider la protection contre les risques OWASP les plus critiques :

### 1. 🔒 `test_security_rate_limiting.py` - OWASP A07:2021
**Identification and Authentication Failures**

Protection contre les attaques par force brute sur les authentifications.

**Tests inclus :**
- ✅ Blocage après 5 tentatives échouées de connexion
- ✅ Réinitialisation du rate limiting après une connexion réussie
- ✅ Isolation du rate limiting par IP + username (un utilisateur bloqué n'affecte pas les autres)

**Risque couvert :** Attaques par force brute visant à compromettre les comptes utilisateurs.

---

### 2. 🛡️ `test_security_access_control.py` - OWASP A01:2021
**Broken Access Control**

Vérification que les utilisateurs ne peuvent accéder qu'à leurs propres données.

**Tests inclus :**
- ✅ Un utilisateur ne peut pas exporter les données d'un autre utilisateur
- ✅ Un utilisateur ne peut pas supprimer le compte d'un autre utilisateur
- ✅ Un utilisateur ne peut pas modifier le profil d'un autre utilisateur
- ✅ Isolation de la progression entre utilisateurs

**Risque couvert :** Accès non autorisé aux données d'autres utilisateurs (escalade de privilèges, violation de confidentialité).

---

### 3. 🚨 `test_security_injection.py` - OWASP A03:2021
**Injection**

Protection contre les différentes formes d'injection malveillante.

**Tests inclus :**
- ✅ Protection contre injection SQL dans le champ username
- ✅ Protection contre injection SQL dans le champ password
- ✅ Protection contre injection XSS dans les champs de profil
- ✅ Protection contre injection de commandes système
- ✅ Protection contre injection SQL dans les paramètres de requête

**Risques couverts :**
- SQL Injection : compromission de la base de données
- XSS (Cross-Site Scripting) : exécution de code malveillant côté client
- Command Injection : exécution de commandes système non autorisées

---

## 🚀 Exécution des tests

### Tous les tests de sécurité
```bash
cd backend
pytest tests/test_security_*.py -v
```

### Test spécifique
```bash
# Rate limiting
pytest tests/test_security_rate_limiting.py -v

# Access control
pytest tests/test_security_access_control.py -v

# Injection protection
pytest tests/test_security_injection.py -v
```

### Avec rapport détaillé
```bash
pytest tests/test_security_*.py -v --tb=short
```

---

## 📊 Résultats attendus

### Test 1 : Rate Limiting
- ✅ 3 tests doivent passer
- ✅ Vérifie que 6 tentatives échouées → 429 Too Many Requests
- ✅ Vérifie que le rate limiting se réinitialise après succès

### Test 2 : Access Control
- ✅ 4 tests doivent passer
- ✅ Toutes les tentatives d'accès non autorisé → 403 Forbidden

### Test 3 : Injection Protection
- ✅ 5 tests doivent passer
- ✅ Toutes les tentatives d'injection → 401/422 (pas 500 = pas d'erreur serveur)

**Total : 12 tests de sécurité**

---

## 🔍 Détails techniques

### Rate Limiting
- **Seuil :** 5 tentatives échouées
- **Fenêtre :** 15 minutes
- **Clé :** IP + username (isolation)

### Access Control
- Vérification systématique : `current_user.id == resource.user_id`
- Retourne 403 si non autorisé
- Protection sur tous les endpoints sensibles

### Injection Protection
- Utilisation de SQLAlchemy ORM (protection SQL native)
- Validation des entrées avec Pydantic
- Pas d'exécution directe de requêtes SQL brutes

---

## 📚 Références OWASP

- [OWASP Top 10:2021](https://owasp.org/Top10/)
- [A01:2021 - Broken Access Control](https://owasp.org/Top10/A01_2021-Broken_Access_Control/)
- [A03:2021 - Injection](https://owasp.org/Top10/A03_2021-Injection/)
- [A07:2021 - Identification and Authentication Failures](https://owasp.org/Top10/A07_2021-Identification_and_Authentication_Failures/)

---

## ✅ Checklist de sécurité

Avant de déployer en production, vérifier que tous les tests passent :

- [ ] Rate limiting fonctionne correctement
- [ ] Les utilisateurs ne peuvent accéder qu'à leurs propres données
- [ ] Aucune injection SQL possible
- [ ] Protection contre XSS en place
- [ ] Aucune injection de commandes possible

---

## 🐛 Dépannage

### Erreur : Rate limiting ne fonctionne pas
- Vérifier que `MAX_LOGIN_ATTEMPTS = 5` dans `main.py`
- Vérifier que le rate limiting est activé

### Erreur : 403 au lieu de 403
- Vérifier que les endpoints vérifient `current_user.id`
- Vérifier la logique d'autorisation dans chaque endpoint

### Erreur : Injection SQL réussit
- Vérifier que SQLAlchemy ORM est utilisé (pas de requêtes SQL brutes)
- Vérifier la validation des entrées avec Pydantic

---

## 📝 Notes importantes

1. **Ces tests sont des tests de sécurité**, pas des tests fonctionnels
2. **Tous les tests doivent passer en vert** avant de déployer
3. **En cas d'échec**, corriger immédiatement la vulnérabilité
4. **Exécuter ces tests régulièrement** dans le CI/CD

---

**Créé le :** 2024-11-20  
**Version :** 1.0.0

