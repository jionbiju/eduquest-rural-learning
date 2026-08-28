import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/sync/data/repositories/sync_queue_repository.dart';
import 'features/sync/providers/sync_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Hive.
  await Hive.initFlutter();

  // Open all required boxes before app starts.
  await Future.wait([
    Hive.openBox<String>(AppConstants.hiveUserBox),
    Hive.openBox<String>(AppConstants.hiveSyncQueueBox),
    Hive.openBox<String>(AppConstants.hiveSettingsBox),
  ]);

  final syncRepo = SyncQueueRepository();
  await syncRepo.init();

  runApp(
    ProviderScope(
      overrides: [
        syncQueueRepositoryProvider.overrideWithValue(syncRepo),
      ],
      child: const EduQuestApp(),
    ),
  );
}

/// Root application widget.
class EduQuestApp extends ConsumerWidget {
  const EduQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Boot the sync service in the background.
    ref.watch(syncServiceProvider);

    return MaterialApp.router(
      title: 'EduQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
