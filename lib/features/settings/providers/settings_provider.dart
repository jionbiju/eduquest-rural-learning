import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages app-wide settings like locale.
final selectedLanguageProvider = StateProvider<String>((ref) => 'en');
