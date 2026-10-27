import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_provider.dart';
import '../../services/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Utilisateur non connecté')),
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/edit-profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête du profil
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Text(
                      user.username[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.military_tech,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Niveau ${user.level}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Informations du compte
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations du compte',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _InfoCard(
                    icon: Icons.person,
                    title: 'Nom d\'utilisateur',
                    value: user.username,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    icon: Icons.email,
                    title: 'Email',
                    value: user.email,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    icon: Icons.calendar_today,
                    title: 'Membre depuis',
                    value: dateFormat.format(user.createdAt),
                  ),
                  const SizedBox(height: 24),

                  // Paramètres
                  Text(
                    'Paramètres',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _SettingsTile(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Gère tes notifications',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité à venir !'),
                        ),
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.language,
                    title: 'Langue',
                    subtitle: 'Français',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité à venir !'),
                        ),
                      );
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.dark_mode,
                    title: 'Thème',
                    subtitle: _getThemeSubtitle(context),
                    trailing: _buildThemeSwitch(context),
                    onTap: () {
                      _showThemeDialog(context);
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.help,
                    title: 'Aide et support',
                    subtitle: 'Besoin d\'aide ?',
                    onTap: () {
                      _showHelpDialog(context);
                    },
                  ),
                  _SettingsTile(
                    icon: Icons.info,
                    title: 'À propos',
                    subtitle: 'Version 1.0.0',
                    onTap: () {
                      _showAboutDialog(context);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Section RGPD
                  Text(
                    'Données personnelles (RGPD)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    value: user.gdprConsent,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Consentement RGPD'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.gdprConsent
                              ? 'Actif depuis le ${_formatConsentDate(user.gdprConsentAt)}'
                              : 'Consentement non donné',
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => Navigator.of(context).pushNamed('/privacy-policy'),
                          child: const Text('Lire la politique de confidentialité'),
                        ),
                      ],
                    ),
                    onChanged: (value) async {
                      if (!value) {
                        final confirm = await _confirmConsentWithdrawal(
                          context,
                          title: 'Retirer le consentement RGPD',
                          message:
                              'Sans consentement, certaines fonctionnalités seront désactivées. Continuer ?',
                        );
                        if (confirm != true) return;
                      }
                      await _updateConsent(
                        context,
                        authProvider,
                        gdprConsent: value,
                      );
                    },
                  ),
                  SwitchListTile.adaptive(
                    value: user.dataProcessingConsent,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Traitement des données'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.dataProcessingConsent
                              ? 'Autorisé depuis le ${_formatConsentDate(user.dataProcessingConsentAt)}'
                              : 'Non autorisé',
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => Navigator.of(context).pushNamed('/terms-of-service'),
                          child: const Text('Lire les conditions d\'utilisation'),
                        ),
                      ],
                    ),
                    onChanged: (value) async {
                      if (!value) {
                        final confirm = await _confirmConsentWithdrawal(
                          context,
                          title: 'Refuser le traitement des données',
                          message:
                              'Refuser le traitement des données peut empêcher la sauvegarde de ta progression. Continuer ?',
                        );
                        if (confirm != true) return;
                      }
                      await _updateConsent(
                        context,
                        authProvider,
                        dataProcessingConsent: value,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _SettingsTile(
                    icon: Icons.privacy_tip,
                    title: 'Politique de confidentialité',
                    subtitle: 'Quelles données sont collectées et pourquoi',
                    onTap: () => Navigator.of(context).pushNamed('/privacy-policy'),
                  ),
                  _SettingsTile(
                    icon: Icons.description,
                    title: 'Conditions d\'utilisation',
                    subtitle: 'Règles du service et obligations',
                    onTap: () => Navigator.of(context).pushNamed('/terms-of-service'),
                  ),
                  _SettingsTile(
                    icon: Icons.gavel,
                    title: 'Mentions légales',
                    subtitle: 'Responsable de traitement et contact',
                    onTap: () => Navigator.of(context).pushNamed('/legal-notice'),
                  ),
                  const SizedBox(height: 16),
                  _SettingsTile(
                    icon: Icons.download,
                    title: 'Télécharger mes données',
                    subtitle: 'Export RGPD',
                    onTap: () => _exportUserData(context, authProvider),
                  ),
                  _SettingsTile(
                    icon: Icons.delete_forever,
                    title: 'Supprimer mon compte',
                    subtitle: 'Action irréversible',
                    onTap: () => _deleteAccount(context, authProvider),
                  ),
                  const SizedBox(height: 24),

                  // Bouton de déconnexion
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final shouldLogout = await _showLogoutDialog(context);
                        if (shouldLogout == true) {
                          await authProvider.logout();
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Se déconnecter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatConsentDate(DateTime? timestamp) {
    if (timestamp == null) {
      return 'date non renseignée';
    }
    final formatter = DateFormat('dd/MM/yyyy à HH:mm');
    return formatter.format(timestamp.toLocal());
  }

  Future<void> _updateConsent(
    BuildContext context,
    AuthProvider authProvider, {
    bool? gdprConsent,
    bool? dataProcessingConsent,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await authProvider.apiService.updateUserProfile(
        authProvider.currentUser!.id,
        gdprConsent: gdprConsent,
        dataProcessingConsent: dataProcessingConsent,
      );
      await authProvider.loadCurrentUser();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('✅ Préférences RGPD mises à jour'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool?> _confirmConsentWithdrawal(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Es-tu sûr de vouloir te déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aide et support'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Comment utiliser l\'application :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Parcourez l\'alphabet des signes'),
              Text('2. Regardez les vidéos de démonstration'),
              Text('3. Pratiquez avec le mode quiz'),
              Text('4. Suis ta progression'),
              SizedBox(height: 16),
              Text(
                'Besoin d\'aide ?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Contactez-nous à : support@signlanguage.com'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Langue des Signes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Version 1.0.0'),
              SizedBox(height: 16),
              Text(
                'Application d\'apprentissage de la langue des signes française.',
              ),
              SizedBox(height: 16),
              Text(
                '© 2025 Sign Language Learning',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  String _getThemeSubtitle(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    if (themeProvider.isDarkMode) return 'Sombre';
    if (themeProvider.isLightMode) return 'Clair';
    return 'Système';
  }

  Widget _buildThemeSwitch(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Switch(
      value: themeProvider.isDarkMode,
      onChanged: (value) {
        themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
      },
    );
  }

  void _showThemeDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir le thème'),
        content: RadioGroup<ThemeMode>(
          groupValue: themeProvider.themeMode,
          onChanged: (value) {
            if (value == null) return;
            themeProvider.setThemeMode(value);
            Navigator.pop(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              RadioListTile<ThemeMode>(
                title: Text('Clair'),
                value: ThemeMode.light,
              ),
              RadioListTile<ThemeMode>(
                title: Text('Sombre'),
                value: ThemeMode.dark,
              ),
              RadioListTile<ThemeMode>(
                title: Text('Système'),
                value: ThemeMode.system,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportUserData(BuildContext context, AuthProvider authProvider) async {
    try {
      final data = await authProvider.apiService.exportUserData(authProvider.currentUser!.id);
      
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('📊 Vos données RGPD'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Utilisateur: ${data['user']['username']}'),
                  Text('Email: ${data['user']['email']}'),
                  const SizedBox(height: 16),
                  Text('Progression: ${data['progress_count']} signes'),
                  Text('Sessions: ${data['sessions_count']}'),
                  Text('Tentatives: ${data['total_attempts']}'),
                  Text('Signes maîtrisés: ${data['mastered_signs']}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Ces données peuvent être téléchargées au format JSON.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAccount(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Supprimer le compte'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer définitivement votre compte ?\n\n'
          'Cette action est IRRÉVERSIBLE. Toutes vos données seront perdues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer définitivement'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await authProvider.apiService.deleteUserAccount(authProvider.currentUser!.id);
      await authProvider.logout();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Compte supprimé'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
