import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/sign.dart';
import '../../services/auth_provider.dart';

class SignDetailScreen extends StatefulWidget {
  final Sign sign;

  const SignDetailScreen({super.key, required this.sign});

  @override
  State<SignDetailScreen> createState() => _SignDetailScreenState();
}

class _SignDetailScreenState extends State<SignDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Lettre ${widget.sign.letter}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // TODO: Ajouter aux favoris
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité à venir !'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section vidéo YouTube avec miniature réelle
            if (widget.sign.videoPath != null && widget.sign.videoPath!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () => _openYouTubeVideo(context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 220,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Miniature YouTube
                          widget.sign.thumbnailUrl != null && widget.sign.thumbnailUrl!.isNotEmpty
                              ? Image.network(
                                  widget.sign.thumbnailUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback si l'image ne charge pas
                                    return Container(
                                      color: Colors.red[800],
                                      child: Icon(
                                        Icons.play_circle_filled,
                                        size: 80,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: Colors.red[800],
                                  child: Icon(
                                    Icons.play_circle_filled,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                ),
                          // Icône play centrale
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.play_arrow,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Informations sur le signe
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lettre et difficulté
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lettre ${widget.sign.letter}',
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Chip(
                        label: Text(widget.sign.difficultyLabel),
                        backgroundColor: _getDifficultyColor().withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _getDifficultyColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  if (widget.sign.description != null) ...[
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.sign.description!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Conseils pratiques
                  Text(
                    'Conseils pratiques',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const _TipItem(
                    icon: Icons.visibility,
                    text: 'Regardez attentivement la position des doigts',
                  ),
                  const _TipItem(
                    icon: Icons.repeat,
                    text: 'Pratiquez plusieurs fois le mouvement',
                  ),
                  const _TipItem(
                    icon: Icons.videocam,
                    text: 'Enregistrez-vous pour comparer',
                  ),
                  const SizedBox(height: 24),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/quiz',
                              arguments: widget.sign,
                            );
                          },
                          icon: const Icon(Icons.quiz),
                          label: const Text('Pratiquer'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _markAsLearned(context, authProvider);
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Appris'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openYouTubeVideo(BuildContext context) async {
    try {
      final raw = widget.sign.videoPath!.trim();
      final url = Uri.parse(raw.startsWith('http') ? raw : 'https://$raw');
      // Essaye d'abord avec l'application/ navigateur externe
      if (await canLaunchUrl(url) &&
          await launchUrl(url, mode: LaunchMode.externalApplication)) {
        return;
      }
      // Fallback WebView interne
      if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossible d\'ouvrir la vidéo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getDifficultyColor() {
    switch (widget.sign.difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _markAsLearned(
      BuildContext context, AuthProvider authProvider) async {
    try {
      final userId = authProvider.currentUser!.id;
      
      // Essayer de créer ou mettre à jour la progression
      await authProvider.apiService.createProgress(
        userId,
        widget.sign.id,
        true,
        1,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.sign.letter} marqué comme appris !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _TipItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
