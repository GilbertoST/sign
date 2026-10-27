import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_provider.dart';
import '../../utils/page_transitions.dart';
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
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
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section de bienvenue avec gradient
            _WelcomeCard(
              username: user?.username ?? 'Utilisateur', 
              level: user?.level ?? 1,
              xp: user?.xp ?? 0,
            ),
            const SizedBox(height: AppTheme.paddingLarge),

            // Actions rapides
            Builder(
              builder: (context) {
                final screenHeight = MediaQuery.of(context).size.height;
                final screenWidth = MediaQuery.of(context).size.width;
                final isSmallScreen = screenHeight < 700 || screenWidth < 360;
                final titleSize = isSmallScreen ? 16.0 : 20.0;
                
                return Text(
                  'Actions rapides',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: titleSize,
                      ),
                );
              },
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppTheme.paddingMedium,
              crossAxisSpacing: AppTheme.paddingMedium,
              children: [
                _QuickActionCard(
                  icon: Icons.play_circle_outline,
                  title: 'Commencer',
                  subtitle: 'Apprendre',
                  gradient: AppTheme.primaryGradient,
                  onTap: () {
                    onNavigateToTab(1); // Onglet Signes
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
                    onNavigateToTab(2); // Onglet Progression
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
            const SizedBox(height: AppTheme.paddingLarge),

            // Conseils d'apprentissage
            Builder(
              builder: (context) {
                final screenHeight = MediaQuery.of(context).size.height;
                final screenWidth = MediaQuery.of(context).size.width;
                final isSmallScreen = screenHeight < 700 || screenWidth < 360;
                final titleSize = isSmallScreen ? 16.0 : 20.0;
                
                return Text(
                  'Conseils d\'apprentissage',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: titleSize,
                      ),
                );
              },
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            const _TipCard(
              icon: Icons.lightbulb_outline,
              title: 'Pratiquez régulièrement',
              description: 'Consacrez 10-15 minutes par jour pour de meilleurs résultats.',
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            const _TipCard(
              icon: Icons.visibility_outlined,
              title: 'Observez attentivement',
              description: 'Faites attention aux détails de position des doigts et des mains.',
              color: AppTheme.secondaryColor,
            ),
            const SizedBox(height: AppTheme.paddingSmall),
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
    final iconSize = isSmallScreen ? 16.0 : 24.0;
    final badgeIconSize = isSmallScreen ? 14.0 : 18.0;
    final padding = isSmallScreen ? AppTheme.paddingMedium : AppTheme.paddingLarge;

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppTheme.paddingSmall),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: Icon(
                    Icons.waving_hand,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
                SizedBox(width: AppTheme.paddingSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour,',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: greetingSize,
                        ),
                      ),
                      Text(
                        username,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: usernameSize,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.paddingMedium),
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingSmall,
                      vertical: AppTheme.paddingSmall / 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: badgeIconSize,
                        ),
                        SizedBox(width: AppTheme.paddingSmall / 2),
                        Flexible(
                          child: Text(
                            'Niveau $level',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: badgeTextSize,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingSmall,
                      vertical: AppTheme.paddingSmall / 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt,
                          color: Colors.amber,
                          size: badgeIconSize,
                        ),
                        SizedBox(width: AppTheme.paddingSmall / 2),
                        Flexible(
                          child: Text(
                            '$xp XP',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: badgeTextSize,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.paddingMedium),
            Text(
              'Continue ton apprentissage de l\'alphabet en langue des signes !',
              style: TextStyle(
                color: Colors.white,
                fontSize: messageSize,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatefulWidget {
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
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700 || screenWidth < 360;
    
    final iconSize = isSmallScreen ? 28.0 : 40.0;
    final titleSize = isSmallScreen ? 13.0 : 16.0;
    final subtitleSize = isSmallScreen ? 10.0 : 12.0;
    final padding = isSmallScreen ? AppTheme.paddingSmall : AppTheme.paddingMedium;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      child: Container(
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                child: Icon(
                  widget.icon,
                  size: iconSize,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: AppTheme.paddingSmall),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: TextStyle(
                  fontSize: subtitleSize,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingSmall),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(width: AppTheme.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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
