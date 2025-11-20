import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Tests E2E Appium - Flux de connexion', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    test('Test E2E : Inscription complète avec consentement RGPD', () async {
      // 1. Attendre que l'écran de login soit chargé
      // Note: Ajuste les sélecteurs selon ton application
      final loginScreen = find.text('Connexion');
      await driver.waitFor(loginScreen, timeout: Duration(seconds: 10));

      // 2. Cliquer sur le bouton d'inscription
      final registerButton = find.text('Créer un compte');
      await driver.tap(registerButton);
      await driver.waitFor(find.text('Inscription'), timeout: Duration(seconds: 5));

      // 3. Remplir le formulaire d'inscription
      final usernameField = find.byValueKey('username_field');
      final emailField = find.byValueKey('email_field');
      final passwordField = find.byValueKey('password_field');
      final confirmPasswordField = find.byValueKey('confirm_password_field');

      final uniqueUsername = 'e2e_user_${DateTime.now().millisecondsSinceEpoch}';
      final uniqueEmail = 'e2e_${DateTime.now().millisecondsSinceEpoch}@example.com';

      await driver.tap(usernameField);
      await driver.enterText(uniqueUsername);

      await driver.tap(emailField);
      await driver.enterText(uniqueEmail);

      await driver.tap(passwordField);
      await driver.enterText('Test123!@#');

      await driver.tap(confirmPasswordField);
      await driver.enterText('Test123!@#');

      // 4. Accepter les consentements RGPD
      final privacyCheckbox = find.byValueKey('gdpr_consent_checkbox');
      final dataProcessingCheckbox = find.byValueKey('data_processing_consent_checkbox');
      
      await driver.tap(privacyCheckbox);
      await driver.tap(dataProcessingCheckbox);

      // 5. Soumettre le formulaire
      final submitButton = find.text('S\'inscrire');
      await driver.tap(submitButton);

      // 6. Vérifier que l'utilisateur est connecté (redirection vers l'écran d'accueil)
      // Note: Ajuste selon ton application
      final homeScreen = find.text('Accueil');
      await driver.waitFor(homeScreen, timeout: Duration(seconds: 10));

      // 7. Vérifier que le profil affiche le bon username
      final profileTab = find.text('Profil');
      await driver.tap(profileTab);
      
      final usernameDisplay = find.text(uniqueUsername);
      await driver.waitFor(usernameDisplay, timeout: Duration(seconds: 5));
    });

    test('Test E2E : Connexion avec credentials valides', () async {
      // 1. Aller à l'écran de connexion
      final loginButton = find.text('Se connecter');
      await driver.tap(loginButton);
      await driver.waitFor(find.text('Connexion'), timeout: Duration(seconds: 5));

      // 2. Remplir les champs de connexion
      final usernameField = find.byValueKey('login_username_field');
      final passwordField = find.byValueKey('login_password_field');

      await driver.tap(usernameField);
      await driver.enterText('testuser'); // Utilisateur existant

      await driver.tap(passwordField);
      await driver.enterText('Test123!@#');

      // 3. Cliquer sur le bouton de connexion
      final loginSubmitButton = find.text('Se connecter');
      await driver.tap(loginSubmitButton);

      // 4. Vérifier la redirection vers l'écran d'accueil
      final homeScreen = find.text('Accueil');
      await driver.waitFor(homeScreen, timeout: Duration(seconds: 10));

      // 5. Vérifier que l'utilisateur est bien connecté
      final profileTab = find.text('Profil');
      await driver.tap(profileTab);
      
      final userInfo = find.text('testuser');
      await driver.waitFor(userInfo, timeout: Duration(seconds: 5));
    });
  });
}

