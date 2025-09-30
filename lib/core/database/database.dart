import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
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

    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open([UserPreferencesModelSchema], directory: dir.path);
  }

  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
