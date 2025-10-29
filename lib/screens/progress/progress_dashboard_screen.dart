import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_stats.dart';
import '../../services/auth_provider.dart';

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
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Encouragements en tête de page
                        if (_stats != null) ...[
                          _EncouragementCard(stats: _stats!),
                          const SizedBox(height: 24),
                        ],
                        // Carte de niveau
                        Card(
                          color: Colors.blue[700],
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.military_tech,
                                  size: 60,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Niveau',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  '${user?.level ?? 1}',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Progression globale
                        Text(
                          'Progression globale',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_stats!.masteredSigns} / ${_stats!.totalSigns}',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${_stats!.progressPercentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                LinearProgressIndicator(
                                  value: _stats!.progressPercentage / 100,
                                  minHeight: 10,
                                  borderRadius: BorderRadius.circular(5),
                                  backgroundColor: Colors.grey[300],
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Signes maîtrisés',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Statistiques détaillées
                        Text(
                          'Statistiques',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmall = constraints.maxWidth < 360;
                            return GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: isSmall ? 1.1 : 1.3,
                              children: [
                                _StatCard(
                                  icon: Icons.school,
                                  title: 'Tentatives',
                                  value: _stats!.totalAttempts.toString(),
                                  color: Colors.blue,
                                ),
                                _StatCard(
                                  icon: Icons.check_circle,
                                  title: 'Taux de réussite',
                                  value: '${_stats!.successRate.toStringAsFixed(1)}%',
                                  color: Colors.green,
                                ),
                                _StatCard(
                                  icon: Icons.event,
                                  title: 'Sessions',
                                  value: _stats!.totalSessions.toString(),
                                  color: Colors.orange,
                                ),
                                _StatCard(
                                  icon: Icons.emoji_events,
                                  title: 'Signes appris',
                                  value: _stats!.masteredSigns.toString(),
                                  color: Colors.purple,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Bouton d'action
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signs');
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Continuer à apprendre'),
                          style: ElevatedButton.styleFrom(
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 12),
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
              title,
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
      color = Colors.amber;
    } else if (stats.progressPercentage >= 75) {
      message = '🌟 Excellent ! Vous êtes presque au bout !';
      icon = Icons.star;
      color = Colors.orange;
    } else if (stats.progressPercentage >= 50) {
      message = '💪 Super travail ! Continuez comme ça !';
      icon = Icons.trending_up;
      color = Colors.green;
    } else if (stats.progressPercentage >= 25) {
      message = '🚀 Bon début ! Continuez à pratiquer !';
      icon = Icons.rocket_launch;
      color = Colors.blue;
    } else {
      message = '✨ Bienvenue ! Commencez votre aventure !';
      icon = Icons.auto_awesome;
      color = Colors.purple;
    }

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
