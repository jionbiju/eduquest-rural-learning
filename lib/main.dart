import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/sync/data/repositories/sync_queue_repository.dart';
import 'features/sync/providers/sync_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Hive for local storage.
  await Hive.initFlutter();

  // Open sync queue box before app starts.
  final syncRepo = SyncQueueRepository();
  await syncRepo.init();

  runApp(
    ProviderScope(
      overrides: [
        // Inject the already-initialised repo.
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
    // Boot the sync service — it listens to connectivity in the background.
    ref.watch(syncServiceProvider);

    return MaterialApp.router(
      title: 'EduQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
