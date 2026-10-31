import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart';

import 'package:ai_study_planner/data/api/token_storage.dart';

/// Klien API Dio terpusat:
/// - base URL dari --dart-define (emulator Android memakai 10.0.2.2);
/// - interceptor token Bearer;
/// - penanganan 401: token dihapus dan observer notifikasi agar keluar.
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
            _notifyUnauthorized();
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
  final List<VoidCallback> _unauthorizedListeners = [];

  /// Daftarkan callback saat sesi berakhir (401). Dipakai bootstrap
  /// untuk menandai pengguna keluar.
  void addUnauthorizedListener(VoidCallback listener) {
    _unauthorizedListeners.add(listener);
  }

  void _notifyUnauthorized() {
    for (final listener in _unauthorizedListeners) {
      listener();
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
}
