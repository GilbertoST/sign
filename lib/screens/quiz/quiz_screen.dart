import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sign.dart';
import '../../models/learning_session.dart';
import '../../services/auth_provider.dart';
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
            backgroundColor: Colors.red,
            duration: const Duration(milliseconds: 900),
          ),
        );
      }
    }

    // Enregistrer la tentative
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

      // Bonus XP pour un quiz parfait (10/10)
      if (_score == _quizSigns.length && !authProvider.isGuest) {
        try {
          await authProvider.apiService.addXP(
            authProvider.currentUser!.id,
            50, // +50 XP bonus pour quiz parfait
            actionType: 'quiz_perfect',
          );
          
          // Mettre à jour l'utilisateur
          await authProvider.loadCurrentUser();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 Quiz parfait ! +50 XP bonus !'),
                backgroundColor: Colors.amber,
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
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.quiz,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Sélectionnez votre niveau de défi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              _buildModeCard(
                mode: QuizMode.libre,
                icon: Icons.all_inclusive,
                title: 'Mode Libre',
                description: 'Pas de limite de temps\nParfait pour apprendre',
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              
              _buildModeCard(
                mode: QuizMode.intermediaire,
                icon: Icons.timer,
                title: 'Mode Intermédiaire',
                description: '5 secondes par question\nÉquilibre défi/confiance',
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              
              _buildModeCard(
                mode: QuizMode.expert,
                icon: Icons.flash_on,
                title: 'Mode Expert',
                description: '3 secondes par question\nPour les pros !',
                color: Colors.red,
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Commencer le Quiz',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barre de progression du quiz
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _quizSigns.length,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            
            // Indicateur de temps (si mode avec timer)
            if (_selectedMode != QuizMode.libre && !_hasAnswered)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _timeLeft / (_selectedMode == QuizMode.expert ? 3 : 5),
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _timeLeft <= 1 ? Colors.red : Colors.blue,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer,
                        size: 20,
                        color: _timeLeft <= 1 ? Colors.red : Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_timeLeft s',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _timeLeft <= 1 ? Colors.red : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Score actuel
            Text(
              'Score: $_score/${_currentIndex + (_hasAnswered ? 1 : 0)}',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Question
            const Text(
              'Quelle lettre représente ce signe ?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Lettre à identifier
            Expanded(
              flex: 2,
              child: Card(
                child: Center(
                  child: Text(
                    currentSign.letter,
                    style: const TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Options de réponse
            Expanded(
              flex: 3,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = _selectedAnswer == option;
                  final isCorrect = option == currentSign.letter;
                  
                  Color? backgroundColor;
                  if (_hasAnswered) {
                    if (isCorrect) {
                      backgroundColor = Colors.green;
                    } else if (isSelected) {
                      backgroundColor = Colors.red;
                    }
                  } else if (isSelected) {
                    backgroundColor = Colors.blue.withOpacity(0.3);
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                              size: 40,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              option,
                              style: const TextStyle(fontSize: 12),
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
    
    return GestureDetector(
      onTap: () {
        setState(() => _selectedMode = mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
