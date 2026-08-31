import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages app-wide settings like locale. Defaults to Hindi ('hi').
final selectedLanguageProvider = StateProvider<String>((ref) => 'hi');
