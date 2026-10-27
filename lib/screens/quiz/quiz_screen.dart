import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sign.dart';
import '../../models/learning_session.dart';
import '../../services/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_surface.dart';
import '../../widgets/guest_conversion_dialog.dart';

enum QuizMode { libre, intermediaire, expert }

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Sign> _signs = [];
  List<Sign> _quizSigns = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  LearningSession? _session;
  final Random _random = Random();
  String? _selectedAnswer;
  bool _hasAnswered = false;
  
  // Timer variables
  QuizMode _selectedMode = QuizMode.libre;
  Timer? _timer;
  int _timeLeft = 0;
  bool _showModeSelector = true;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    
    if (_selectedMode == QuizMode.libre) {
      return; // Pas de timer en mode libre
    }

    // Définir le temps selon le mode
    switch (_selectedMode) {
      case QuizMode.intermediaire:
        _timeLeft = 5;
        break;
      case QuizMode.expert:
        _timeLeft = 3;
        break;
      case QuizMode.libre:
        return;
    }

    setState(() {});

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() => _timeLeft--);

      if (_timeLeft <= 0) {
        timer.cancel();
        if (!_hasAnswered && mounted) {
          // Temps écoulé, soumettre une mauvaise réponse
          _submitAnswer('');
        }
      }
    });
  }

  void _startQuiz() {
    setState(() {
      _showModeSelector = false;
      _currentIndex = 0;
      _score = 0;
      _hasAnswered = false;
    });
    if (_selectedMode != QuizMode.libre) {
      _startTimer();
    }
  }

  Future<void> _loadQuiz() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Créer une session d'apprentissage
      _session = await authProvider.apiService
          .createSession(authProvider.currentUser!.id);

      // Charger tous les signes
      _signs = await authProvider.apiService.getSigns();

      // Sélectionner 10 signes aléatoires
      _signs.shuffle();
      _quizSigns = _signs.take(10).toList();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  List<String> _getAnswerOptions(Sign correctSign) {
    final options = <String>[correctSign.letter];
    final otherSigns = _signs.where((s) => s.id != correctSign.id).toList();
    otherSigns.shuffle(_random);

    // Ajouter 3 autres options
    for (var i = 0; i < 3 && i < otherSigns.length; i++) {
      options.add(otherSigns[i].letter);
    }

    options.shuffle(_random);
    return options;
  }

  Future<void> _submitAnswer(String answer) async {
    if (_hasAnswered) return;

    // Arrêter le timer
    _timer?.cancel();

    setState(() => _hasAnswered = true);

    final currentSign = _quizSigns[_currentIndex];
    final isCorrect = answer == currentSign.letter && answer.isNotEmpty;

    if (isCorrect) {
      setState(() => _score++);
      
      // Attribuer de l'XP pour une bonne réponse
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.apiService.addXP(
          authProvider.currentUser!.id,
          10, // +10 XP par bonne réponse
          actionType: 'quiz_correct',
        );
        
        // Mettre à jour l'utilisateur pour refléter le nouveau XP
        await authProvider.loadCurrentUser();
      } catch (e) {
        debugPrint('Erreur lors de l\'attribution XP: $e');
      }
    }
    else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Mauvaise réponse. La bonne lettre était: ${currentSign.letter}'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(milliseconds: 900),
          ),
        );
      }
    }

    // Enregistrer la tentative
    if (!mounted) return;
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.apiService.createAttempt(
        _session!.id,
        currentSign.id,
        isCorrect,
      );
    } catch (e) {
      debugPrint('Erreur lors de l\'enregistrement de la tentative: $e');
    }

    // Attendre 1.5 secondes avant de passer à la question suivante
    await Future.delayed(const Duration(milliseconds: 1500));

    if (_currentIndex < _quizSigns.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _hasAnswered = false;
      });
      // Redémarrer le timer pour la prochaine question
      if (_selectedMode != QuizMode.libre) {
        _startTimer();
      }
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final finalScore = (_score / _quizSigns.length) * 100;

      await authProvider.apiService.updateSession(
        _session!.id,
        endTime: DateTime.now(),
        score: finalScore,
      );

      // Mettre à jour le défi "premier quiz" si utilisateur connecté
      if (!authProvider.isGuest) {
        try {
          final challengeResult = await authProvider.apiService.updateChallengeProgressByType('first_quiz', increment: 1);
          // Si le défi est complété, les XP sont automatiquement ajoutés par le backend
          if (challengeResult['xp_added'] != null && challengeResult['xp_added'] > 0) {
            debugPrint('✅ Défi "first_quiz" complété ! +${challengeResult['xp_added']} XP');
            await authProvider.loadCurrentUser();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🎉 Défi Premier pas complété ! +${challengeResult['xp_added']} XP !'),
                  backgroundColor: AppTheme.amber,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        } catch (e) {
          debugPrint('⚠️ Erreur mise à jour défi first_quiz: $e');
        }
      }

      // Bonus XP pour un quiz parfait (10/10)
      if (_score == _quizSigns.length && !authProvider.isGuest) {
        try {
          await authProvider.apiService.addXP(
            authProvider.currentUser!.id,
            50, // +50 XP bonus pour quiz parfait
            actionType: 'quiz_perfect',
          );
          
          // Mettre à jour le défi "Quiz Master" (10 quiz parfaits)
          try {
            final challengeResult = await authProvider.apiService.updateChallengeProgressByType('quiz_perfect', increment: 1);
            // Si le défi est complété, les XP sont déjà ajoutés automatiquement par le backend
            if (challengeResult['xp_added'] != null && challengeResult['xp_added'] > 0) {
              debugPrint('✅ Défi "quiz_perfect" complété ! +${challengeResult['xp_added']} XP');
              // Recharger l'utilisateur pour avoir les derniers XP
              await authProvider.loadCurrentUser();
            }
          } catch (e) {
            debugPrint('⚠️ Erreur mise à jour défi quiz_perfect: $e');
          }
          
          // Mettre à jour l'utilisateur
          await authProvider.loadCurrentUser();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 Quiz parfait ! +50 XP bonus !'),
                backgroundColor: AppTheme.amber,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          debugPrint('Erreur lors du bonus XP: $e');
        }
      }

      // Si c'est un invité, incrémenter le compteur de quiz
      if (authProvider.isGuest) {
        final shouldPrompt = await authProvider.incrementGuestQuiz();
        if (shouldPrompt && mounted) {
          // Attendre un peu pour ne pas interrompre l'UX
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              showGuestConversionDialog(context);
            }
          });
        }
      }

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/quiz-results',
          arguments: {
            'score': _score,
            'total': _quizSigns.length,
            'percentage': finalScore,
          },
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de la fin du quiz: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_quizSigns.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(
          child: Text('Aucun signe disponible pour le quiz'),
        ),
      );
    }

    // Afficher le sélecteur de mode si le quiz n'a pas commencé
    if (_showModeSelector) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Choisir le mode de quiz'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.page),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Builder(
                builder: (context) {
                  final screenHeight = MediaQuery.of(context).size.height;
                  final screenWidth = MediaQuery.of(context).size.width;
                  final isSmallScreen = screenHeight < 700 || screenWidth < 360;
                  final iconSize = isSmallScreen ? 44.0 : 56.0;
                  final titleSize = isSmallScreen ? 18.0 : 22.0;

                  return Column(
                    children: [
                      Container(
                        width: iconSize + 28,
                        height: iconSize + 28,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                        ),
                        child: Icon(
                          Icons.quiz_outlined,
                          size: iconSize,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      Text(
                        'Sélectionnez votre niveau de défi',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: titleSize,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppTheme.spaceXl),
              _buildModeCard(
                mode: QuizMode.libre,
                icon: Icons.all_inclusive,
                title: 'Mode Libre',
                description: 'Pas de limite de temps\nParfait pour apprendre',
                color: AppTheme.successColor,
              ),
              const SizedBox(height: AppTheme.spaceSm),
              _buildModeCard(
                mode: QuizMode.intermediaire,
                icon: Icons.timer_outlined,
                title: 'Mode Intermédiaire',
                description: '5 secondes par question\nÉquilibre défi/confiance',
                color: AppTheme.secondaryColor,
              ),
              const SizedBox(height: AppTheme.spaceSm),
              _buildModeCard(
                mode: QuizMode.expert,
                icon: Icons.flash_on,
                title: 'Mode Expert',
                description: '3 secondes par question\nPour les pros !',
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: AppTheme.spaceLg),
              FilledButton(
                onPressed: _startQuiz,
                child: const Text('Commencer le Quiz'),
              ),
            ],
          ),
        ),
      );
    }

    final currentSign = _quizSigns[_currentIndex];
    final options = _getAnswerOptions(currentSign);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '${_currentIndex + 1}/${_quizSigns.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / _quizSigns.length,
                minHeight: 8,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            if (_selectedMode != QuizMode.libre && !_hasAnswered)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    child: LinearProgressIndicator(
                      value: _timeLeft / (_selectedMode == QuizMode.expert ? 3 : 5),
                      minHeight: 6,
                      color: _timeLeft <= 1 ? AppTheme.errorColor : AppTheme.primaryColor,
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.darkTrack
                          : AppTheme.track,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: _timeLeft <= 1 ? AppTheme.errorColor : AppTheme.primaryColor,
                      ),
                      const SizedBox(width: AppTheme.spaceXs),
                      Text(
                        '$_timeLeft s',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: _timeLeft <= 1 ? AppTheme.errorColor : AppTheme.primaryColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              'Score: $_score/${_currentIndex + (_hasAnswered ? 1 : 0)}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Builder(
              builder: (context) {
                final screenHeight = MediaQuery.of(context).size.height;
                final screenWidth = MediaQuery.of(context).size.width;
                final isSmallScreen = screenHeight < 700 || screenWidth < 360;

                return Text(
                  'Quelle lettre représente ce signe ?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: isSmallScreen ? 16.0 : 20.0,
                      ),
                  textAlign: TextAlign.center,
                );
              },
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Expanded(
              flex: 2,
              child: AppSurface(
                child: Center(
                  child: Builder(
                    builder: (context) {
                      final screenHeight = MediaQuery.of(context).size.height;
                      final screenWidth = MediaQuery.of(context).size.width;
                      final isSmallScreen = screenHeight < 700 || screenWidth < 360;

                      return Text(
                        currentSign.letter,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 80.0 : 112.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -2,
                          height: 1,
                          color: AppTheme.primaryColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Expanded(
              flex: 3,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.45,
                ),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = _selectedAnswer == option;
                  final isCorrect = option == currentSign.letter;

                  Color? backgroundColor;
                  if (_hasAnswered) {
                    if (isCorrect) {
                      backgroundColor = AppTheme.successColor;
                    } else if (isSelected) {
                      backgroundColor = AppTheme.errorColor;
                    }
                  } else if (isSelected) {
                    backgroundColor = AppTheme.primaryColor.withValues(alpha: 0.16);
                  }

                  return ElevatedButton(
                    onPressed: _hasAnswered
                        ? null
                        : () {
                            setState(() => _selectedAnswer = option);
                            _submitAnswer(option);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundColor,
                      elevation: 0,
                      side: backgroundColor == null
                          ? null
                          : BorderSide(
                              color: backgroundColor == AppTheme.successColor ||
                                      backgroundColor == AppTheme.errorColor
                                  ? Colors.transparent
                                  : AppTheme.primaryColor.withValues(alpha: 0.35),
                            ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                      ),
                      padding: const EdgeInsets.all(8),
                    ),
                    child: Image.asset(
                      'assets/images/${option.toLowerCase()}.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 36,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              option,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required QuizMode mode,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final isSelected = _selectedMode == mode;
    final ink = Theme.of(context).colorScheme.onSurface;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700 || screenWidth < 360;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: AppTheme.shadow(context),
      ),
      child: Material(
        color: isSelected
            ? color.withValues(alpha: 0.08)
            : AppTheme.cardColor(context),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          side: BorderSide(
            color: isSelected ? color : AppTheme.line(context),
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: () {
            setState(() => _selectedMode = mode);
          },
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(
                    icon,
                    size: isSmallScreen ? 22.0 : 28.0,
                    color: color,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14.0 : 16.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: isSelected ? color : ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12.0 : 13.0,
                          height: 1.35,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: color,
                    size: isSmallScreen ? 22.0 : 26.0,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
