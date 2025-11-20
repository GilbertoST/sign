import 'package:flutter/material.dart';

class LegalNoticeScreen extends StatelessWidget {
  const LegalNoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentions legales'),
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
              'Editeur',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Projet etudiant Sign LSF\n'
              'Responsable publication : Equipe projet\n'
              'Contact : contact@sign-lsf.app',
            ),
            const SizedBox(height: 16),
            Text(
              'Hebergement',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Render (render.com)\n'
              '40 Islington High St, London N1 8EQ, Royaume-Uni',
            ),
            const SizedBox(height: 16),
            Text(
              'Propriete intellectuelle',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Toute reproduction du contenu (textes, visuels, code) est interdite sans autorisation. '
              'Les illustrations des signes proviennent de sources citees dans l\'application.',
            ),
            const SizedBox(height: 16),
            Text(
              'Donnees personnelles',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Les traitements sont decrits dans la Politique de confidentialite. '
              'Tu peux exercer tes droits via l\'application ou par e-mail.',
            ),
            const SizedBox(height: 16),
            Text(
              'Responsabilite',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'L\'editeur ne saurait etre tenu responsable en cas de dommages resultant de l\'utilisation du service, '
              'sauf faute prouvee de sa part.',
            ),
            const SizedBox(height: 16),
            Text(
              'Contact',
              style: theme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('contact@sign-lsf.app'),
          ],
        ),
      ),
    );
  }
}

