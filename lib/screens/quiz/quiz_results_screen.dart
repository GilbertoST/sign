import 'package:flutter/material.dart';

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
      color = Colors.amber;
    } else if (percentage >= 60) {
      message = 'Bon travail !';
      icon = Icons.thumb_up;
      color = Colors.green;
    } else if (percentage >= 40) {
      message = 'Pas mal, continue !';
      icon = Icons.sentiment_satisfied;
      color = Colors.orange;
    } else {
      message = 'Continue à pratiquer !';
      icon = Icons.refresh;
      color = Colors.blue;
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icône de résultat
              Icon(
                icon,
                size: 100,
                color: color,
              ),
              const SizedBox(height: 24),

              // Message
              Text(
                message,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Score
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        '$score / $total',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Statistiques détaillées
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatCard(
                    icon: Icons.check_circle,
                    label: 'Bonnes\nréponses',
                    value: score.toString(),
                    color: Colors.green,
                  ),
                  _StatCard(
                    icon: Icons.cancel,
                    label: 'Mauvaises\nréponses',
                    value: (total - score).toString(),
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Boutons d'action
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/quiz');
                },
                icon: const Icon(Icons.replay),
                label: const Text('Recommencer'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Retour à l\'accueil'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
