import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:isar/isar.dart';
import '../../features/user_preferences/data/models/user_preferences_model.dart';

class Database {
  static Isar? _isar;

  static Future<Isar> get instance async {
    if (_isar != null) {
      return _isar!;
    }

    _isar = await _init();
    return _isar!;
  }

  static Future<Isar> _init() async {
    if (kIsWeb) {
      // On web, pass an empty directory to satisfy required param; ignored by isar_web.
      return await Isar.open(
        [UserPreferencesModelSchema],
        directory: '',
      );
    }

    // For native platforms, we'll use a simple directory path for now
    // In a real implementation, you would use path_provider here
    return await Isar.open([UserPreferencesModelSchema], directory: './data');
  }

  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
