import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/challenge.dart';
import '../../services/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_surface.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  List<Challenge> _challenges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _challenges = await authProvider.apiService.getChallenges();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Défis'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadChallenges,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppTheme.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('Défis en cours', _getOngoingChallenges()),
                    const SizedBox(height: AppTheme.spaceLg),
                    _buildSection('Défis à venir', _getUpcomingChallenges()),
                    const SizedBox(height: AppTheme.spaceLg),
                    _buildSection('Défis terminés', _getCompletedChallenges()),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSection(String title, List<Challenge> challenges) {
    if (challenges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.spaceSm),
        ...challenges.map((challenge) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
              child: _ChallengeCard(challenge: challenge),
            )),
      ],
    );
  }

  List<Challenge> _getOngoingChallenges() {
    return _challenges.where((c) => !c.completed && c.isActive && c.progress > 0).toList();
  }

  List<Challenge> _getUpcomingChallenges() {
    return _challenges.where((c) => !c.completed && c.isActive && c.progress == 0).toList();
  }

  List<Challenge> _getCompletedChallenges() {
    return _challenges.where((c) => c.completed).toList();
  }
}

class _ChallengeCard extends StatelessWidget {
  final Challenge challenge;

  const _ChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.namedColor(challenge.color);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return AppSurface(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Center(
                  child: Text(
                    challenge.icon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      challenge.description,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spaceXs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                ),
                child: Text(
                  '+${challenge.xpReward} XP',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.amber,
                  ),
                ),
              ),
            ],
          ),
          if (!challenge.completed) ...[
            const SizedBox(height: AppTheme.spaceMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progression',
                  style: TextStyle(fontSize: 12, color: muted),
                ),
                Text(
                  '${challenge.progress}/${challenge.requirement}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              child: LinearProgressIndicator(
                value: challenge.progressPercentage,
                minHeight: 8,
                color: accent,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkTrack
                    : AppTheme.track,
              ),
            ),
          ],
          if (challenge.completed) ...[
            const SizedBox(height: AppTheme.spaceMd),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 16, color: AppTheme.successColor),
                  const SizedBox(width: 4),
                  Text(
                    'Terminé ! +${challenge.xpEarned} XP',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (challenge.isSeasonal) ...[
            const SizedBox(height: AppTheme.spaceXs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusXs),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event, size: 12, color: AppTheme.secondaryColor),
                  SizedBox(width: 4),
                  Text(
                    'Défi saisonnier',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
