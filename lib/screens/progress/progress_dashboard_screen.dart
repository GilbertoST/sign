import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_stats.dart';
import '../../services/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_surface.dart';

class ProgressDashboardScreen extends StatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  State<ProgressDashboardScreen> createState() =>
      _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen> {
  UserStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final stats = await authProvider.apiService
          .getUserStats(authProvider.currentUser!.id);

      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma Progression'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? const Center(child: Text('Erreur de chargement'))
              : RefreshIndicator(
                  onRefresh: _loadStats,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppTheme.page),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_stats != null) ...[
                          _EncouragementCard(stats: _stats!),
                          const SizedBox(height: AppTheme.spaceLg),
                        ],
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                            boxShadow: AppTheme.shadow(context),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.page,
                              vertical: AppTheme.spaceLg,
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.military_tech,
                                  size: 44,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: AppTheme.spaceXs),
                                Text(
                                  'Niveau',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.82),
                                  ),
                                ),
                                Text(
                                  '${user?.level ?? 1}',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -1.2,
                                    height: 1.05,
                                    color: Colors.white,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceLg),
                        Text(
                          'Progression globale',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppTheme.spaceSm),
                        AppSurface(
                          padding: const EdgeInsets.all(AppTheme.page),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_stats!.masteredSigns} / ${_stats!.totalSigns}',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontFeatures: const [FontFeature.tabularFigures()],
                                        ),
                                  ),
                                  Text(
                                    '${_stats!.progressPercentage.toStringAsFixed(1)}%',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: AppTheme.successColor,
                                          fontFeatures: const [FontFeature.tabularFigures()],
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spaceMd),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                                child: LinearProgressIndicator(
                                  value: _stats!.progressPercentage / 100,
                                  minHeight: 8,
                                  color: AppTheme.successColor,
                                  backgroundColor: AppTheme.track,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spaceXs),
                              Text(
                                'Signes maîtrisés',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceLg),
                        Text(
                          'Statistiques',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppTheme.spaceSm),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmall = constraints.maxWidth < 360;
                            return GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: AppTheme.spaceSm,
                              crossAxisSpacing: AppTheme.spaceSm,
                              childAspectRatio: isSmall ? 1.05 : 1.25,
                              children: [
                                _StatCard(
                                  icon: Icons.school_outlined,
                                  title: 'Tentatives',
                                  value: _stats!.totalAttempts.toString(),
                                  color: AppTheme.primaryColor,
                                ),
                                _StatCard(
                                  icon: Icons.check_circle_outline,
                                  title: 'Taux de réussite',
                                  value: '${_stats!.successRate.toStringAsFixed(1)}%',
                                  color: AppTheme.successColor,
                                ),
                                _StatCard(
                                  icon: Icons.event_outlined,
                                  title: 'Sessions',
                                  value: _stats!.totalSessions.toString(),
                                  color: AppTheme.secondaryColor,
                                ),
                                _StatCard(
                                  icon: Icons.emoji_events_outlined,
                                  title: 'Signes appris',
                                  value: _stats!.masteredSigns.toString(),
                                  color: AppTheme.purple,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: AppTheme.spaceLg),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signs');
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Continuer à apprendre'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusXs),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: AppTheme.spaceXs),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EncouragementCard extends StatelessWidget {
  final UserStats stats;

  const _EncouragementCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    String message;
    IconData icon;
    Color color;

    if (stats.progressPercentage >= 100) {
      message = '🎉 Félicitations ! Vous avez maîtrisé tout l\'alphabet !';
      icon = Icons.emoji_events;
      color = AppTheme.amber;
    } else if (stats.progressPercentage >= 75) {
      message = '🌟 Excellent ! Vous êtes presque au bout !';
      icon = Icons.star;
      color = AppTheme.secondaryColor;
    } else if (stats.progressPercentage >= 50) {
      message = '💪 Super travail ! Continuez comme ça !';
      icon = Icons.trending_up;
      color = AppTheme.successColor;
    } else if (stats.progressPercentage >= 25) {
      message = '🚀 Bon début ! Continuez à pratiquer !';
      icon = Icons.rocket_launch;
      color = AppTheme.primaryColor;
    } else {
      message = '✨ Bienvenue ! Commencez votre aventure !';
      icon = Icons.auto_awesome;
      color = AppTheme.purple;
    }

    return AppSurface(
      color: color.withValues(alpha: 0.08),
      borderColor: color.withValues(alpha: 0.22),
      padding: const EdgeInsets.all(AppTheme.page),
      child: Row(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 15,
                height: 1.35,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
