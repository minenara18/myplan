import 'package:dio/dio.dart';

import 'package:ai_study_planner/core/clock.dart';
import 'package:ai_study_planner/core/system_clock.dart';
import 'package:ai_study_planner/core/failure.dart';
import 'package:ai_study_planner/data/api/api_client.dart';
import 'package:ai_study_planner/data/api/failure_mapper.dart';
import 'package:ai_study_planner/data/repositories/auth_repository.dart';
import 'package:ai_study_planner/services/session_store.dart';

/// Implementasi remote dari AuthRepository melalui ApiClient.
/// Token disimpan di flutter_secure_storage lewat TokenStorage; email
/// terakhir dan keaktifan dicatat di SessionStore agar sesi 60 hari bisa
/// dievaluasi offline oleh policy saat aplikasi dibuka lagi.
class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository(
    this.apiClient, {
    SessionStore? sessionStore,
    Clock? clock,
  })  : sessionStore = sessionStore ?? InMemorySessionStore(),
        clock = clock ?? const SystemClock();

  final ApiClient apiClient;
  final SessionStore sessionStore;
  final Clock clock;
  static const _failureMapper = FailureMapper();

  @override
  Future<bool> isOnboardingCompleted() async {
    return apiClient.tokenStorage.hasToken();
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    // Onboarding ditandai lewat flow UI; token hanya dibuat saat login.
    if (!completed) {
      await apiClient.clearToken();
    }
  }

  @override
  Future<void> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post<Object?>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      await _extractAndSaveToken(response, email);
    } on DioException catch (e) {
      throw _failureMapper.fromDio(e);
    }
  }

  @override
  Future<void> register(String email, String password) async {
    try {
      final response = await apiClient.dio.post<Object?>(
        '/auth/register',
        data: {'email': email, 'password': password},
      );
      await _extractAndSaveToken(response, email);
    } on DioException catch (e) {
      throw _failureMapper.fromDio(e);
    }
  }

  @override
  Future<void> loginWithGoogle() async {
    throw const UnknownFailure('Login dengan Google belum tersedia.');
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.dio.post<Object?>('/auth/logout');
    } on DioException catch (e) {
      // Logout server gagal tetap keluar: token lokal dihapus.
      if (e.response?.statusCode == 401) {
        await apiClient.clearToken();
        return;
      }
      throw _failureMapper.fromDio(e);
    } finally {
      await apiClient.clearToken();
    }
  }

  @override
  Stream<AuthState> watchAuthState() async* {
    yield AuthState(
      isLoggedIn: await apiClient.tokenStorage.hasToken(),
      isLoading: false,
    );
  }

  /// Ambil token dari respons {token: ..., user: {...}} dan simpan,
  /// lalu catat email terakhir + keaktifan di SessionStore.
  Future<void> _extractAndSaveToken(
    Response<Object?> response,
    String email,
  ) async {
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw const UnknownFailure('Respons dari server tidak valid.');
    }
    final token = body['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const UnknownFailure('Token tidak diterima dari server.');
    }
    await apiClient.saveToken(token);
    final now = clock.now();
    await sessionStore.catatLogin(email: email, at: now);
    await sessionStore.simpanSesi(token: token, lastActiveAt: now);
  }
}
