import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_study_planner/data/api/token_storage.dart';

/// Kunci penyimpanan waktu keaktifan terakhir (milidetik sejak epoch).
const String kSessionLastActiveKey = 'session_last_active_at_millis';

/// Kunci penyimpanan email terakhir yang berhasil login.
const String kSessionLastEmailKey = 'session_last_email';

/// Threshold tulis [SessionStore.touch]: maksimal sekali per jam.
const Duration kTouchThrottle = Duration(hours: 1);

/// Penyimpanan sesi: token, waktu keaktifan terakhir, dan email terakhir.
///
/// Sumber token TUNGGAL adalah [TokenStorage] yang sama dengan [ApiClient],
/// jadi token yang belum kedaluwarsa tidak pernah terpisah dari request.
/// [SharedPreferences] menyimpan lastActiveAt dan email terakhir.
///
/// Password TIDAK PERNAH disimpan di sini.
abstract class SessionStore {
  /// Baca token tersimpan, atau null bila belum ada.
  Future<String?> bacaToken();

  /// Baca waktu keaktifan terakhir, atau null bila belum pernah.
  Future<DateTime?> bacaLastActiveAt();

  /// Baca email terakhir yang berhasil login, atau null bila belum ada.
  Future<String?> bacaEmailTerakhir();

  /// Simpan sesi lengkap setelah login/register: token + keaktifan.
  Future<void> simpanSesi({
    required String token,
    required DateTime lastActiveAt,
  });

  /// Perpanjang sesi dari [now].
  /// Throttle: tulis maksimal sekali per jam; jika `now` lebih awal dari
  /// lastActiveAt tersimpan (jam mundur), lewati — jangan menurunkan.
  Future<void> touch(DateTime now);

  /// Hapus token dan lastActiveAt. Email terakhir DIPERTAHANKAN agar
  /// login berikutnya (mis. setelah sesi kedaluwarsa) bisa mengisinya.
  Future<void> hapusSesi();

  /// Catat login sukses: simpan email dan reset keaktifan ke [at].
  Future<void> catatLogin({required String email, required DateTime at});

  /// Simpan email terakhir tanpa mengubah keaktifan.
  Future<void> simpanEmailTerakhir(String email);
}

/// Implementasi nyata: [TokenStorage] untuk token,
/// [SharedPreferences] untuk lastActiveAt dan email terakhir.
class SharedPreferencesSessionStore implements SessionStore {
  SharedPreferencesSessionStore({
    required SharedPreferences prefs,
    required TokenStorage tokenStorage,
  })  : _prefs = prefs,
        _tokenStorage = tokenStorage;

  final SharedPreferences _prefs;
  final TokenStorage _tokenStorage;

  @override
  Future<String?> bacaToken() => _tokenStorage.read();

  @override
  Future<DateTime?> bacaLastActiveAt() async {
    final millis = _prefs.getInt(kSessionLastActiveKey);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  @override
  Future<String?> bacaEmailTerakhir() => Future.value(
        _prefs.getString(kSessionLastEmailKey),
      );

  @override
  Future<void> simpanSesi({
    required String token,
    required DateTime lastActiveAt,
  }) async {
    await _tokenStorage.save(token);
    await _tulisLastActive(lastActiveAt);
  }

  @override
  Future<void> touch(DateTime now) async {
    final current = await bacaLastActiveAt();
    if (current != null && now.isBefore(current)) return; // jam mundur.
    final sejakTulis = current == null ? null : now.difference(current);
    if (sejakTulis != null && sejakTulis < kTouchThrottle) return; // throttle.
    await _tulisLastActive(now);
  }

  @override
  Future<void> hapusSesi() async {
    await _tokenStorage.clear();
    await _prefs.remove(kSessionLastActiveKey);
  }

  @override
  Future<void> catatLogin({required String email, required DateTime at}) async {
    await _prefs.setString(kSessionLastEmailKey, email);
    await _tulisLastActive(at);
  }

  @override
  Future<void> simpanEmailTerakhir(String email) {
    return _prefs.setString(kSessionLastEmailKey, email);
  }

  Future<void> _tulisLastActive(DateTime at) {
    return _prefs.setInt(kSessionLastActiveKey, at.millisecondsSinceEpoch);
  }
}

/// Implementasi in-memory untuk test: tidak menyentuh platform channel.
class InMemorySessionStore implements SessionStore {
  InMemorySessionStore({this.emailTerakhir});

  String? _token;
  DateTime? _lastActiveAt;

  String? emailTerakhir;

  @override
  Future<String?> bacaToken() => Future.value(_token);

  @override
  Future<DateTime?> bacaLastActiveAt() => Future.value(_lastActiveAt);

  @override
  Future<String?> bacaEmailTerakhir() => Future.value(emailTerakhir);

  @override
  Future<void> simpanSesi({
    required String token,
    required DateTime lastActiveAt,
  }) async {
    _token = token;
    _lastActiveAt = lastActiveAt;
  }

  @override
  Future<void> touch(DateTime now) async {
    final current = _lastActiveAt;
    if (current != null && now.isBefore(current)) return;
    if (current != null && now.difference(current) < kTouchThrottle) return;
    _lastActiveAt = now;
  }

  @override
  Future<void> hapusSesi() async {
    _token = null;
    _lastActiveAt = null;
  }

  @override
  Future<void> catatLogin({required String email, required DateTime at}) async {
    emailTerakhir = email;
    _lastActiveAt = at;
  }

  @override
  Future<void> simpanEmailTerakhir(String email) async {
    emailTerakhir = email;
  }
}

/// Provider SessionStore — melempar UnimplementedError sampai di-override
/// di bootstrap.
final sessionStoreProvider = Provider<SessionStore>((ref) {
  throw UnimplementedError(
    'SessionStore belum di-override di bootstrap. '
    'Gunakan SharedPreferencesSessionStore atau InMemorySessionStore.',
  );
});
