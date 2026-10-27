import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conditions d\'utilisation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Derniere mise a jour : 09/11/2025',
              style: theme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              '1. Objet',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ces conditions regissent l\'utilisation de l\'application Sign LSF. '
              'En creant un compte, tu acceptes integralement ces conditions.',
            ),
            const SizedBox(height: 16),
            Text(
              '2. Creation de compte',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tu dois fournir un identifiant et une adresse e-mail valides. '
              'Tu t\'engages a ne pas usurper l\'identite d\'autrui et a securiser ton mot de passe.',
            ),
            const SizedBox(height: 16),
            Text(
              '3. Utilisation autorisee',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'L\'application est reservee a un usage personnel et pedagogique. '
              'Toute tentative de reverse engineering, d\'extraction massive ou de redistribution du contenu est interdite.',
            ),
            const SizedBox(height: 16),
            Text(
              '4. Contenus tiers',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Certaines videos sont hebergees sur YouTube (Dicoplus LSF). '
              'Leur utilisation est soumise aux conditions de YouTube.',
            ),
            const SizedBox(height: 16),
            Text(
              '5. Responsabilites',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Nous nous efforcons de fournir un service disponible et securise. '
              'Toutefois, aucune garantie de disponibilite permanente n\'est offerte. '
              'En cas de perte de donnee, contacte-nous rapidement.',
            ),
            const SizedBox(height: 16),
            Text(
              '6. Suspension et suppression',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Nous nous reservons le droit de suspendre ou supprimer un compte en cas :\n'
              '- de non-respect des presentes conditions\n'
              '- d\'usage frauduleux\n'
              '- de demande expresse de l\'utilisateur (droit a l\'oubli)',
            ),
            const SizedBox(height: 16),
            Text(
              '7. Propriete intellectuelle',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Les contenus pedagogiques, design et code sont proteges. '
              'Toute reproduction sans autorisation est prohibee.',
            ),
            const SizedBox(height: 16),
            Text(
              '8. Evolution des conditions',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Nous pouvons modifier ces conditions. Un avertissement sera affiche au sein de l\'application. '
              'La poursuite de l\'usage vaut acceptation.',
            ),
            const SizedBox(height: 16),
            Text(
              '9. Contact',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Pour toute question, ecris-nous : contact@sign-lsf.app',
            ),
          ],
        ),
      ),
    );
  }
}

