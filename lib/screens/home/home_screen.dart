import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_provider.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/app_surface.dart';
import '../signs/signs_list_screen.dart';
import '../progress/progress_dashboard_screen.dart';
import '../profile/profile_screen.dart';
import '../quiz/quiz_screen.dart';
import '../challenges/challenges_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeContentScreen(onNavigateToTab: (index) {
        setState(() => _selectedIndex = index);
      }),
      const SignsListScreen(),
      const ProgressDashboardScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.line(context))),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            HapticFeedback.lightImpact();
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.sign_language_outlined),
              selectedIcon: Icon(Icons.sign_language),
              label: 'Signes',
            ),
            NavigationDestination(
              icon: Icon(Icons.trending_up_outlined),
              selectedIcon: Icon(Icons.trending_up),
              label: 'Progression',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContentScreen extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const HomeContentScreen({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Langue des Signes'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeCard(
              username: user?.username ?? 'Utilisateur',
              level: user?.level ?? 1,
              xp: user?.xp ?? 0,
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Builder(
              builder: (context) {
                final screenHeight = MediaQuery.of(context).size.height;
                final screenWidth = MediaQuery.of(context).size.width;
                final isSmallScreen = screenHeight < 700 || screenWidth < 360;
                final titleSize = isSmallScreen ? 16.0 : 20.0;

                return Text(
                  'Actions rapides',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: titleSize,
                      ),
                );
              },
            ),
            const SizedBox(height: AppTheme.spaceSm),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppTheme.spaceSm,
              crossAxisSpacing: AppTheme.spaceSm,
              childAspectRatio: 1.05,
              children: [
                _QuickActionCard(
                  icon: Icons.play_circle_outline,
                  title: 'Commencer',
                  subtitle: 'Apprendre',
                  gradient: AppTheme.primaryGradient,
                  onTap: () {
                    onNavigateToTab(1);
                  },
                ),
                _QuickActionCard(
                  icon: Icons.quiz_outlined,
                  title: 'Quiz',
                  subtitle: 'S\'entraîner',
                  gradient: AppTheme.orangeGradient,
                  onTap: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(page: const QuizScreen()),
                    );
                  },
                ),
                _QuickActionCard(
                  icon: Icons.trending_up,
                  title: 'Progression',
                  subtitle: 'Voir stats',
                  gradient: AppTheme.successGradient,
                  onTap: () {
                    onNavigateToTab(2);
                  },
                ),
                _QuickActionCard(
                  icon: Icons.emoji_events_outlined,
                  title: 'Défis',
                  subtitle: 'Gagner XP',
                  gradient: AppTheme.purpleGradient,
                  onTap: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(page: const ChallengesScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Builder(
              builder: (context) {
                final screenHeight = MediaQuery.of(context).size.height;
                final screenWidth = MediaQuery.of(context).size.width;
                final isSmallScreen = screenHeight < 700 || screenWidth < 360;
                final titleSize = isSmallScreen ? 16.0 : 20.0;

                return Text(
                  'Conseils d\'apprentissage',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: titleSize,
                      ),
                );
              },
            ),
            const SizedBox(height: AppTheme.spaceSm),
            const _TipCard(
              icon: Icons.lightbulb_outline,
              title: 'Pratiquez régulièrement',
              description: 'Consacrez 10-15 minutes par jour pour de meilleurs résultats.',
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: AppTheme.spaceXs),
            const _TipCard(
              icon: Icons.visibility_outlined,
              title: 'Observez attentivement',
              description: 'Faites attention aux détails de position des doigts et des mains.',
              color: AppTheme.secondaryColor,
            ),
            const SizedBox(height: AppTheme.spaceXs),
            const _TipCard(
              icon: Icons.repeat,
              title: 'Répétez les mouvements',
              description: 'La répétition est la clé pour mémoriser les signes.',
              color: AppTheme.successColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String username;
  final int level;
  final int xp;

  const _WelcomeCard({
    required this.username,
    required this.level,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700 || screenWidth < 360;

    final greetingSize = isSmallScreen ? 12.0 : 14.0;
    final usernameSize = isSmallScreen ? 18.0 : 24.0;
    final badgeTextSize = isSmallScreen ? 11.0 : 13.0;
    final messageSize = isSmallScreen ? 12.0 : 14.0;
    final iconSize = isSmallScreen ? 16.0 : 22.0;
    final badgeIconSize = isSmallScreen ? 14.0 : 16.0;
    final padding = isSmallScreen ? AppTheme.spaceMd : AppTheme.page;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: AppTheme.shadow(context),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spaceXs),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                    ),
                    child: Icon(
                      Icons.waving_hand,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour,',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: greetingSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          username,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: usernameSize,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            height: 1.15,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceMd),
              Row(
                children: [
                  Flexible(
                    child: _Badge(
                      icon: Icons.star_rounded,
                      iconSize: badgeIconSize,
                      label: 'Niveau $level',
                      fontSize: badgeTextSize,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceXs),
                  Flexible(
                    child: _Badge(
                      icon: Icons.bolt_rounded,
                      iconSize: badgeIconSize,
                      label: '$xp XP',
                      fontSize: badgeTextSize,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceMd),
              Text(
                'Continue ton apprentissage de l\'alphabet en langue des signes !',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: messageSize,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final String label;
  final double fontSize;

  const _Badge({
    required this.icon,
    required this.iconSize,
    required this.label,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceXs,
        vertical: AppTheme.space2xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFDE68A), size: iconSize),
          const SizedBox(width: AppTheme.space2xs),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
                letterSpacing: -0.1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700 || screenWidth < 360;

    final iconSize = isSmallScreen ? 24.0 : 28.0;
    final titleSize = isSmallScreen ? 14.0 : 16.0;
    final subtitleSize = isSmallScreen ? 11.0 : 13.0;
    final padding = isSmallScreen ? AppTheme.spaceSm : AppTheme.spaceMd;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return AppSurface(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, size: iconSize, color: Colors.white),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            title,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: subtitleSize,
              fontWeight: FontWeight.w500,
              color: muted,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _TipCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return AppSurface(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceXs),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusXs),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
