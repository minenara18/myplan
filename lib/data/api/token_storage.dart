import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Penyimpanan token akses di flutter_secure_storage.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'auth_token';

  final FlutterSecureStorage _storage;

  /// Baca token tersimpan, atau null bila belum ada.
  Future<String?> read() async {
    return _storage.read(key: _key);
  }

  /// Simpan atau ganti token.
  Future<void> save(String token) async {
    await _storage.write(key: _key, value: token);
  }

  /// Hapus token (dipakai saat logout atau sesi berakhir).
  Future<void> clear() async {
    await _storage.delete(key: _key);
  }

  /// Benar bila token masih ada.
  Future<bool> hasToken() async {
    return await _storage.read(key: _key) != null;
  }
}
