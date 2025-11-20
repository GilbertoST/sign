import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politique de confidentialite'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Derniere mise a jour : 09/11/2025',
              style: theme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              '1. Responsable de traitement',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign LSF est editee par l\'equipe projet (contact : contact@sign-lsf.app). '
              'Nous agissons en qualite de responsable de traitement au sens du RGPD.',
            ),
            const SizedBox(height: 16),
            Text(
              '2. Donnees collectees',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              '- Identifiants : nom d\'utilisateur, adresse e-mail\n'
              '- Donnees de progression : signes appris, sessions, tentatives\n'
              '- Metriques d\'usage : recompenses, defis completes\n'
              '- Donnees de consentement : date et statut des autorisations RGPD',
            ),
            const SizedBox(height: 16),
            Text(
              '3. Finalites et base legale',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Les donnees sont traitees pour :\n'
              '- authentifier les utilisateurs (base legale : execution du contrat)\n'
              '- fournir le suivi pedagogique et personnaliser le contenu (base legale : consentement)\n'
              '- gerer le compte et la progression (base legale : execution du contrat)\n'
              '- assurer la securite et prevenir la fraude (base legale : interet legitime)',
            ),
            const SizedBox(height: 16),
            Text(
              '4. Destinataires et sous-traitants',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Les donnees sont hebergees sur Render (backend) et sur PostgreSQL. '
              'Aucun transfert en dehors de l\'Union europeenne n\'est realise sans garanties adequates.',
            ),
            const SizedBox(height: 16),
            Text(
              '5. Duree de conservation',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              '- Compte actif : conservation tant que le compte est utilise\n'
              '- Compte inactif : suppression apres 24 mois sans connexion\n'
              '- Donnees de consentement : 3 ans a compter du dernier consentement\n'
              '- Logs techniques : 12 mois maximum',
            ),
            const SizedBox(height: 16),
            Text(
              '6. Tes droits',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tu disposes des droits d\'acces, de rectification, d\'opposition, de portabilite, '
              'de limitation et de suppression. Tu peux exercer ces droits depuis l\'application '
              'ou en ecrivant a contact@sign-lsf.app. Une reponse sera envoyee sous 30 jours.',
            ),
            const SizedBox(height: 16),
            Text(
              '7. Retrait du consentement',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tu peux a tout moment retirer ton consentement depuis la page Profil > Donnees personnelles (RGPD). '
              'Cette action peut limiter certaines fonctionnalites (progression, sauvegarde).',
            ),
            const SizedBox(height: 16),
            Text(
              '8. Securite',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Les mots de passe sont haches (PBKDF2-SHA256) et les communications securisees via HTTPS. '
              'L\'acces a l\'API est protege par un jeton JWT. Les suppressions de compte sont definitives.',
            ),
            const SizedBox(height: 16),
            Text(
              '9. Contact CNIL',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'En cas de litige, tu peux saisir la CNIL (www.cnil.fr) ou toute autorite de controle competente.',
            ),
          ],
        ),
      ),
    );
  }
}

