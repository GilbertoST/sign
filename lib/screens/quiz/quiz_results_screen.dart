import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_surface.dart';

class QuizResultsScreen extends StatelessWidget {
  final int score;
  final int total;
  final double percentage;

  const QuizResultsScreen({
    super.key,
    required this.score,
    required this.total,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    String message;
    IconData icon;
    Color color;

    if (percentage >= 80) {
      message = 'Excellent travail !';
      icon = Icons.emoji_events;
      color = AppTheme.amber;
    } else if (percentage >= 60) {
      message = 'Bon travail !';
      icon = Icons.thumb_up;
      color = AppTheme.successColor;
    } else if (percentage >= 40) {
      message = 'Pas mal, continue !';
      icon = Icons.sentiment_satisfied;
      color = AppTheme.secondaryColor;
    } else {
      message = 'Continue à pratiquer !';
      icon = Icons.refresh;
      color = AppTheme.primaryColor;
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.page),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(icon, size: 72, color: color),
              const SizedBox(height: AppTheme.spaceMd),
              Text(
                message,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spaceXl),
              AppSurface(
                padding: const EdgeInsets.all(AppTheme.spaceLg),
                child: Column(
                  children: [
                    Text(
                      '$score / $total',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                    const SizedBox(height: AppTheme.spaceXs),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 8,
                        color: color,
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkTrack
                            : AppTheme.track,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spaceLg),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle,
                      label: 'Bonnes\nréponses',
                      value: score.toString(),
                      color: AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceSm),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.cancel,
                      label: 'Mauvaises\nréponses',
                      value: (total - score).toString(),
                      color: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceXl),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/quiz');
                },
                icon: const Icon(Icons.replay),
                label: const Text('Recommencer'),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home_outlined),
                label: const Text('Retour à l\'accueil'),
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
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMd,
        vertical: AppTheme.spaceMd,
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: AppTheme.spaceXs),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
