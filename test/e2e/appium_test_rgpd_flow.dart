import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Tests E2E Appium - Flux RGPD', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    setUp(() async {
      // Se connecter avant chaque test
      // Note: Ajuste selon ton application
      try {
        final loginButton = find.text('Se connecter');
        await driver.tap(loginButton);
        
        final usernameField = find.byValueKey('login_username_field');
        final passwordField = find.byValueKey('login_password_field');
        
        await driver.tap(usernameField);
        await driver.enterText('testuser');
        
        await driver.tap(passwordField);
        await driver.enterText('Test123!@#');
        
        final loginSubmitButton = find.text('Se connecter');
        await driver.tap(loginSubmitButton);
        
        // Attendre la connexion
        await driver.waitFor(find.text('Accueil'), timeout: Duration(seconds: 10));
      } catch (e) {
        // Si déjà connecté, continuer
        print('Utilisateur peut-être déjà connecté: $e');
      }
    });

    test('Test E2E : Export des données RGPD', () async {
      // 1. Aller dans le profil
      final profileTab = find.text('Profil');
      await driver.tap(profileTab);
      await driver.waitFor(find.text('Mon Profil'), timeout: Duration(seconds: 5));

      // 2. Scroller jusqu'à la section RGPD
      final rgpdSection = find.text('Données personnelles (RGPD)');
      await driver.scrollUntilVisible(
        find.byType('ListView'),
        rgpdSection,
        dyScroll: -300,
      );

      // 3. Cliquer sur "Télécharger mes données"
      final exportButton = find.text('Télécharger mes données');
      await driver.tap(exportButton);

      // 4. Vérifier que les données sont affichées
      final exportDialog = find.text('Vos données RGPD');
      await driver.waitFor(exportDialog, timeout: Duration(seconds: 5));

      // 5. Vérifier la présence des données
      final userData = find.text('testuser');
      await driver.waitFor(userData, timeout: Duration(seconds: 5));

      // 6. Fermer le dialog
      final closeButton = find.text('Fermer');
      await driver.tap(closeButton);
    });

    test('Test E2E : Mise à jour du consentement RGPD', () async {
      // 1. Aller dans le profil
      final profileTab = find.text('Profil');
      await driver.tap(profileTab);
      await driver.waitFor(find.text('Mon Profil'), timeout: Duration(seconds: 5));

      // 2. Scroller jusqu'à la section RGPD
      final rgpdSection = find.text('Données personnelles (RGPD)');
      await driver.scrollUntilVisible(
        find.byType('ListView'),
        rgpdSection,
        dyScroll: -300,
      );

      // 3. Trouver le switch du consentement RGPD
      final gdprSwitch = find.byValueKey('gdpr_consent_switch');
      
      // 4. Vérifier l'état initial (doit être activé)
      // Note: On ne peut pas directement lire la valeur d'un switch avec flutter_driver
      // On vérifie plutôt la présence du texte associé
      await driver.waitFor(find.text('Consentement RGPD'), timeout: Duration(seconds: 5));

      // 5. Désactiver le consentement (simuler un retrait)
      await driver.tap(gdprSwitch);
      
      // 6. Confirmer le retrait dans le dialog
      final confirmButton = find.text('Continuer');
      await driver.waitFor(confirmButton, timeout: Duration(seconds: 5));
      await driver.tap(confirmButton);

      // 7. Vérifier que le switch est désactivé
      await driver.waitFor(find.text('Consentement non donné'), timeout: Duration(seconds: 5));

      // 8. Réactiver le consentement
      await driver.tap(gdprSwitch);
      await driver.waitFor(find.text('Actif depuis le'), timeout: Duration(seconds: 5));
    });
  });
}

