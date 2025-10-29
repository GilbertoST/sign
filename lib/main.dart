import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/auth_provider.dart';
import 'services/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/signs/sign_detail_screen.dart';
import 'screens/quiz/quiz_screen.dart';
import 'screens/quiz/quiz_results_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/challenges/challenges_screen.dart';
import 'models/sign.dart';

void main() {
  // Configuration de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Langue des Signes',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/login':
                  return MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  );
                case '/register':
                  return MaterialPageRoute(
                    builder: (_) => const RegisterScreen(),
                  );
                case '/home':
                  return MaterialPageRoute(
                    builder: (_) => const HomeScreen(),
                  );
                case '/sign-detail':
                  final sign = settings.arguments as Sign;
                  return MaterialPageRoute(
                    builder: (_) => SignDetailScreen(sign: sign),
                  );
                case '/quiz':
                  return MaterialPageRoute(
                    builder: (_) => const QuizScreen(),
                  );
                case '/quiz-results':
                  final args = settings.arguments as Map<String, dynamic>;
                  return MaterialPageRoute(
                    builder: (_) => QuizResultsScreen(
                      score: args['score'],
                      total: args['total'],
                      percentage: args['percentage'],
                    ),
                  );
                case '/edit-profile':
                  return MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  );
                case '/challenges':
                  return MaterialPageRoute(
                    builder: (_) => const ChallengesScreen(),
                  );
                default:
                  return null;
              }
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
