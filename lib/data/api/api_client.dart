import 'package:dio/dio.dart';

import 'package:ai_study_planner/data/api/token_storage.dart';

/// Konteks 401 yang diteruskan ke listener: path endpoint yang menolak
/// dan `code` pada badan respons JSON bila ada (mis. session_expired).
final class UnauthorizedInfo {
  const UnauthorizedInfo({required this.path, this.code});

  /// Path URI request, mis. `/api/auth/login`.
  final String path;

  /// Isi kolom `code` badan respons, atau null bila bentuk bug lain.
  final String? code;
}

/// Callback 401. Dipanggil untuk SETIAP 401, termasuk dari /auth/login dan
/// /auth/register — pemanggil wajib memilah lewat [UnauthorizedInfo].
typedef UnauthorizedListener = void Function(UnauthorizedInfo info);

/// Klien API Dio terpusat:
/// - base URL dari --dart-define (emulator Android memakai 10.0.2.2);
/// - interceptor token Bearer;
/// - penanganan 401: token dihapus dan observer dinotifikasi beserta
///   konteksnya (path endpoint dan code badan respons) agar pemanggil
///   bisa membedakan kredensial salah, sesi kedaluwarsa, dan lainnya.
class ApiClient {
  ApiClient({TokenStorage? storageOverride, String? baseUrlOverride})
      : tokenStorage = storageOverride ?? TokenStorage() {
    final baseUrl = baseUrlOverride ?? defaultBaseUrl;
    assert(baseUrl.isNotEmpty, 'baseUrl tidak boleh kosong');

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _cachedToken ?? await tokenStorage.read();
          _cachedToken = token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            await tokenStorage.clear();
            _cachedToken = null;
            _notifyUnauthorized(
              UnauthorizedInfo(
                path: error.requestOptions.uri.path,
                code: _bacaCode(error.response),
              ),
            );
          }
          handler.next(error);
        },
      ),
    );
  }

  /// Base URL bawaan untuk emulator Android (host mesin = 10.0.2.2).
  /// Di-oper dari bootstrap melalui const dari environment.
  static const defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  /// Baca flag USE_FAKE dari --dart-define.
  static const useFake = bool.fromEnvironment('USE_FAKE', defaultValue: true);

  final TokenStorage tokenStorage;
  late final Dio dio;
  String? _cachedToken;
  final List<UnauthorizedListener> _unauthorizedListeners = [];

  /// Daftarkan callback saat sesi ditolak (401). Dipakai bootstrap
  /// untuk memilah kedaluwarsa vs keluar paksa.
  void addUnauthorizedListener(UnauthorizedListener listener) {
    _unauthorizedListeners.add(listener);
  }

  void _notifyUnauthorized(UnauthorizedInfo info) {
    for (final listener in _unauthorizedListeners) {
      listener(info);
    }
  }

  /// Simpan token setelah login/register; token langsung taxatif di cache.
  Future<void> saveToken(String token) async {
    _cachedToken = token;
    await tokenStorage.save(token);
  }

  /// Hapus token dan cache (logout).
  Future<void> clearToken() async {
    _cachedToken = null;
    await tokenStorage.clear();
  }

  /// Muat token dari penyimpanan saat aplikasi pertama kali jalan.
  Future<void> warmTokenCache() async {
    _cachedToken = await tokenStorage.read();
  }

  /// Baca kolom `code` pada badan respons JSON, atau null bila bentuknya
  /// bukan map (misal string HTML dari gateway).
  static String? _bacaCode(Response<Object?>? response) {
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final code = data['code'];
      return code is String ? code : null;
    }
    return null;
  }
}
