# Tests Backend

Ce dossier contient tous les tests pour le backend Python.

## Structure

### Tests unitaires
- `test_auth.py` : Tests unitaires pour l'authentification (validation de mot de passe, hachage, JWT)
- `test_xp_calculator.py` : Tests unitaires pour le calculateur d'XP

### Tests d'intégration
- `test_integration_auth.py` : Tests d'intégration pour les flux d'authentification
- `test_integration_rgpd.py` : Tests d'intégration pour les fonctionnalités RGPD

### Tests de cybersécurité (OWASP)
- `test_security_rate_limiting.py` : Tests de sécurité OWASP A07:2021 - Rate limiting contre les attaques par force brute
- `test_security_access_control.py` : Tests de sécurité OWASP A01:2021 - Contrôle d'accès et autorisation
- `test_security_injection.py` : Tests de sécurité OWASP A03:2021 - Protection contre les injections (SQL, XSS, commandes)

### Configuration
- `conftest.py` : Configuration pytest (fixtures, base de données de test)

## Installation

```bash
cd backend
pip install -r requirements.txt
```

## Exécution des tests

### Tous les tests
```bash
pytest backend/tests/ -v
```

### Tests unitaires uniquement
```bash
pytest backend/tests/test_auth.py backend/tests/test_xp_calculator.py -v
```

### Tests d'intégration uniquement
```bash
pytest backend/tests/test_integration_*.py -v
```

### Tests de cybersécurité uniquement
```bash
pytest backend/tests/test_security_*.py -v
```

### Tests avec couverture
```bash
pytest backend/tests/ --cov=backend --cov-report=html
```

## Notes

- Les tests utilisent une base de données SQLite en mémoire (`test.db`)
- Chaque test crée et nettoie sa propre base de données
- Les tests d'intégration nécessitent que le backend soit configuré correctement

