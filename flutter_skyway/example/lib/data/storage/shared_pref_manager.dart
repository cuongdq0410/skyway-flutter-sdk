import 'package:shared_preferences/shared_preferences.dart';

enum SharedPreferenceKey {
  keyAccessToken,
  keyRefreshToken,
  keyUser,
}

extension SharedPreferenceKeyExt on SharedPreferenceKey {
  String get name => _mapFromPreviousKeyValues[this] ?? toString();

  Map<SharedPreferenceKey, String> get _mapFromPreviousKeyValues => {
        SharedPreferenceKey.keyAccessToken: 'key_accessToken',
        SharedPreferenceKey.keyRefreshToken: 'key_refreshToken',
        SharedPreferenceKey.keyUser: 'key_user',
      };
}

class SharedPreferencesManager {
  final SharedPreferences _sharedPreferences;

  SharedPreferencesManager(this._sharedPreferences);

  Future<bool> putBool(SharedPreferenceKey key, bool value) =>
      _sharedPreferences.setBool(key.name, value);

  bool? getBool(SharedPreferenceKey key) =>
      _sharedPreferences.getBool(key.name);

  Future<bool> putString(SharedPreferenceKey key, String value) =>
      _sharedPreferences.setString(key.name, value);

  String? getString(SharedPreferenceKey key) =>
      _sharedPreferences.getString(key.name);

  Future<bool> putStringList(SharedPreferenceKey key, List<String> value) =>
      _sharedPreferences.setStringList(key.name, value);

  List<String>? getStringList(SharedPreferenceKey key) =>
      _sharedPreferences.getStringList(key.name);

  Future<void> removeByKey(SharedPreferenceKey key) =>
      _sharedPreferences.remove(key.name);

  /// Clear is now will set the value of each keys to [Null] excluding
  /// the values from excluded keys.
  Future<void> clear([List<SharedPreferenceKey>? exclude]) async {
    final list = [...SharedPreferenceKey.values]
      ..removeWhere((element) => exclude!.contains(element));
    for (var element in list) {
      if (element == SharedPreferenceKey.keyAccessToken) {
        putString(element, '');
      }
    }
  }
}
