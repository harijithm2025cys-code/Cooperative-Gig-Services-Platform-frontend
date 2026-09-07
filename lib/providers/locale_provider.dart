import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleProvider with ChangeNotifier {
  static const String _storageKey = 'cooperative_app_locale_lang';
  final FlutterSecureStorage _storage;

  Locale _currentLocale = const Locale('en');

  LocaleProvider({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage() {
    _loadPersistedLocale();
  }

  Locale get currentLocale => _currentLocale;
  bool get isTamil => _currentLocale.languageCode == 'ta';
  String get languageCode => _currentLocale.languageCode;

  Future<void> _loadPersistedLocale() async {
    try {
      final savedCode = await _storage.read(key: _storageKey);
      if (savedCode != null && (savedCode == 'ta' || savedCode == 'en')) {
        _currentLocale = Locale(savedCode);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved locale: $e');
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_currentLocale == newLocale) return;
    if (newLocale.languageCode != 'en' && newLocale.languageCode != 'ta') return;

    _currentLocale = newLocale;
    notifyListeners();

    try {
      await _storage.write(key: _storageKey, value: newLocale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale preference: $e');
    }
  }

  Future<void> toggleLanguage() async {
    if (_currentLocale.languageCode == 'ta') {
      await setLocale(const Locale('en'));
    } else {
      await setLocale(const Locale('ta'));
    }
  }
}
