import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/sign.dart';
import '../../services/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_surface.dart';

class SignDetailScreen extends StatefulWidget {
  final Sign sign;

  const SignDetailScreen({super.key, required this.sign});

  @override
  State<SignDetailScreen> createState() => _SignDetailScreenState();
}

class _SignDetailScreenState extends State<SignDetailScreen> {
  bool _isFavorite = false;
  bool _isLoadingFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isGuest) {
      setState(() => _isFavorite = false);
      return;
    }

    try {
      final isFav = await authProvider.apiService.isFavorite(widget.sign.id);
      if (mounted) {
        setState(() => _isFavorite = isFav);
      }
    } catch (e) {
      debugPrint('Erreur vérification favori: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isGuest) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connectez-vous pour ajouter aux favoris'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
      return;
    }

    setState(() => _isLoadingFavorite = true);

    try {
      if (_isFavorite) {
        await authProvider.apiService.removeFavorite(widget.sign.id);
        if (mounted) {
          setState(() => _isFavorite = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.sign.letter} retiré des favoris'),
              backgroundColor: AppTheme.muted,
            ),
          );
        }
      } else {
        await authProvider.apiService.addFavorite(widget.sign.id);
        if (mounted) {
          setState(() => _isFavorite = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.sign.letter} ajouté aux favoris !'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingFavorite = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final difficultyColor = AppTheme.difficultyColor(widget.sign.difficulty);
    final hasVideo =
        widget.sign.videoPath != null && widget.sign.videoPath!.isNotEmpty;
    final videoHeight =
        (MediaQuery.sizeOf(context).height * 0.40).clamp(240.0, 420.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Lettre ${widget.sign.letter}'),
        actions: [
          if (_isLoadingFavorite)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: Icon(_isFavorite ? Icons.bookmark : Icons.bookmark_border),
              color: _isFavorite ? AppTheme.amber : null,
              onPressed: _toggleFavorite,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.page,
                AppTheme.spaceXs,
                AppTheme.page,
                AppTheme.spaceLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (hasVideo) ...[
                    _VideoHero(
                      height: videoHeight,
                      thumbnailUrl: widget.sign.thumbnailUrl,
                      onTap: () => _openYouTubeVideo(context),
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                  ],
                  AppSurface(
                    padding: const EdgeInsets.all(AppTheme.page),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              widget.sign.letter,
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(width: AppTheme.spaceSm),
                            Expanded(
                              child: Text(
                                'Lettre ${widget.sign.letter}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Chip(
                              label: Text(widget.sign.difficultyLabel),
                              backgroundColor: difficultyColor.withValues(alpha: 0.12),
                              side: BorderSide(
                                color: difficultyColor.withValues(alpha: 0.28),
                              ),
                              labelStyle: TextStyle(
                                color: difficultyColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (widget.sign.description != null) ...[
                          const SizedBox(height: AppTheme.spaceMd),
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppTheme.spaceXs),
                          Text(
                            widget.sign.description!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                        const SizedBox(height: AppTheme.spaceMd),
                        Text(
                          'Conseils pratiques',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppTheme.spaceXs),
                        const _TipItem(
                          icon: Icons.visibility_outlined,
                          text: 'Regardez attentivement la position des doigts',
                        ),
                        const _TipItem(
                          icon: Icons.repeat,
                          text: 'Pratiquez plusieurs fois le mouvement',
                        ),
                        const _TipItem(
                          icon: Icons.videocam_outlined,
                          text: 'Enregistrez-vous pour comparer',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: AppTheme.line(context))),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.page,
                  AppTheme.spaceSm,
                  AppTheme.page,
                  AppTheme.spaceSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/quiz',
                          arguments: widget.sign,
                        );
                      },
                      icon: const Icon(Icons.quiz_outlined),
                      label: const Text('Pratiquer'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        _markAsLearned(context, authProvider);
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Appris'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openYouTubeVideo(BuildContext context) async {
    try {
      final raw = widget.sign.videoPath!.trim();
      final url = Uri.parse(raw.startsWith('http') ? raw : 'https://$raw');
      if (await canLaunchUrl(url) &&
          await launchUrl(url, mode: LaunchMode.externalApplication)) {
        return;
      }
      if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir la vidéo'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _markAsLearned(
      BuildContext context, AuthProvider authProvider) async {
    try {
      final userId = authProvider.currentUser!.id;

      await authProvider.apiService.createProgress(
        userId,
        widget.sign.id,
        true,
        1,
      );

      if (!authProvider.isGuest) {
        try {
          final challengeResult = await authProvider.apiService
              .updateChallengeProgressByType('alphabet', increment: 1);
          if (challengeResult['xp_added'] != null &&
              challengeResult['xp_added'] > 0) {
            debugPrint(
                '✅ Défi "alphabet" complété ! +${challengeResult['xp_added']} XP');
            await authProvider.loadCurrentUser();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '🎉 Défi Alphabet complété ! +${challengeResult['xp_added']} XP !'),
                backgroundColor: AppTheme.purple,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          debugPrint('⚠️ Erreur mise à jour défi alphabet: $e');
        }
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.sign.letter} marqué comme appris !'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}

class _VideoHero extends StatelessWidget {
  final double height;
  final String? thumbnailUrl;
  final VoidCallback onTap;

  const _VideoHero({
    required this.height,
    required this.thumbnailUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasThumb = thumbnailUrl != null && thumbnailUrl!.isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: AppTheme.shadow(context),
      ),
      child: Material(
        color: const Color(0xFF1E3A8A),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        ),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasThumb)
                  Image.network(
                    thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const _VideoFallback();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  )
                else
                  const _VideoFallback(),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 42,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoFallback extends StatelessWidget {
  const _VideoFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
      child: SizedBox.expand(),
    );
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: AppTheme.spaceSm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
