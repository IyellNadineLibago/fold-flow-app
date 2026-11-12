import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'data/firebase_laundry_repository.dart';
import 'data/laundry_repository.dart';
import 'firebase_options.dart';

/// True once `flutterfire configure` has replaced the placeholder options.
bool get _firebaseIsConfigured {
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    return options.projectId != 'YOUR-PROJECT-ID' &&
        !options.apiKey.startsWith('YOUR_');
  } catch (_) {
    return false;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final LaundryRepository repository;

  if (_firebaseIsConfigured) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      repository = FirebaseLaundryRepository();
    } on Exception catch (error) {
      debugPrint('FoldFlow: Firebase initialization failed: $error');
      runApp(FirebaseSetupErrorApp(
        message: 'Firebase could not be initialized: $error',
      ));
      return;
    }
  } else {
    // Firebase is not set up yet: run the local demo so the UI still works.
    repository = DemoLaundryRepository();
  }

  runApp(FoldFlowApp(repository: repository));
}

class FirebaseSetupErrorApp extends StatelessWidget {
  const FirebaseSetupErrorApp({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoldFlow setup error',
      theme: buildFoldFlowTheme(),
      home: Scaffold(
        appBar: AppBar(title: const Text('Connection setup')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SelectableText(message),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
