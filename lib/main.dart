import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Hive for local storage.
  await Hive.initFlutter();
  // Type adapters and box opens will be registered here as models are added.

  runApp(
    // Riverpod scope wraps the entire widget tree.
    const ProviderScope(
      child: EduQuestApp(),
    ),
  );
}

/// Root application widget.
class EduQuestApp extends StatelessWidget {
  const EduQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EduQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      // Localisation delegates will be added when l10n is scaffolded.
    );
  }
}
