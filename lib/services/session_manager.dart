import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

// Kelas ini berfungsi sebagai jembatan antara aplikasi dan penyimpanan lokal perangkat.
// Kita menggunakan static method agar bisa dipanggil dari mana saja tanpa membuat instance baru.
class SessionManager {
  // Kunci-kunci untuk menyimpan data di SharedPreferences
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userPositionKey = 'user_position';
  static const String _userImageUrlKey = 'user_image_url';
  static const String _isOnRestKey = 'is_on_rest';
  static const String _restInTimeKey = 'rest_in_time';


  /// Menyimpan data sesi pengguna setelah login berhasil.
  static Future<void> saveSession(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
    await prefs.setString(_userIdKey, user.id);
    await prefs.setString(_userNameKey, user.name);
    await prefs.setString(_userPositionKey, user.position);
    if (user.imageUrl != null) {
      await prefs.setString(_userImageUrlKey, user.imageUrl!);
    }
  }

  /// Mengambil data sesi pengguna dari penyimpanan.
  /// Mengembalikan Map berisi token dan User jika ada, atau null jika tidak ada sesi.
  static Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_authTokenKey);
    final userId = prefs.getString(_userIdKey);

    // Jika token atau userId tidak ada, berarti tidak ada sesi yang aktif.
    if (token == null || userId == null) {
      return null;
    }

    // Rekonstruksi objek User dari data yang tersimpan
    final user = User(
      id: userId,
      name: prefs.getString(_userNameKey) ?? '',
      position: prefs.getString(_userPositionKey) ?? '',
      imageUrl: prefs.getString(_userImageUrlKey), username: '',
    );

    return {'token': token, 'user': user};
  }

  /// Menghapus semua data sesi saat pengguna logout.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userPositionKey);
    await prefs.remove(_userImageUrlKey);
    // Atau cara cepat: await prefs.clear();
  }

  // --- STATUS ISTIRAHAT ---
  static Future<bool> getIsOnRest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isOnRestKey) ?? false;
  }

  static Future<void> setIsOnRest(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isOnRestKey, value);
  }

  static Future<String?> getRestInTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_restInTimeKey);
  }

  static Future<void> setRestInTime(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_restInTimeKey);
    } else {
      await prefs.setString(_restInTimeKey, value);
    }
  }
}

