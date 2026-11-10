import 'dart:convert';
import 'dart:typed_data';

import 'package:ai_study_planner/bootstrap.dart';
import 'package:ai_study_planner/core/session_policy.dart';
import 'package:ai_study_planner/data/api/api_client.dart';
import 'package:ai_study_planner/data/api/token_storage.dart';
import 'package:ai_study_planner/routing/session_keeper.dart';
import 'package:ai_study_planner/services/session_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Adapter Dio palsu: SELALU membalas 401 dengan [body].
class _Adapter401 implements HttpClientAdapter {
  _Adapter401(this.body);

  final Map<String, dynamic> body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(body),
      401,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// TokenStorage palsu: tidak menyentuh platform channel.
class _TokenStoragePalsu implements TokenStorage {
  String? _token;

  @override
  Future<void> clear() async => _token = null;

  @override
  Future<bool> hasToken() async => _token != null;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> save(String token) async => _token = token;
}

void main() {
  /// ApiClient dengan adapter 401 tersambung lewat wiring bootstrap;
  /// store berstatus "sudah login" (token + email terakhir tersimpan).
  Future<(SessionKeeper, InMemorySessionStore, Dio)> siapkan(
    Map<String, dynamic> body,
  ) async {
    final apiClient = ApiClient(
      storageOverride: _TokenStoragePalsu(),
      baseUrlOverride: 'http://localhost/api',
    )..dio.httpClientAdapter = _Adapter401(body);

    final keeper = SessionKeeper();
    final store = InMemorySessionStore();
    await store.catatLogin(email: 'bocil@kampus.ac.id', at: DateTime(2026));
    await store.simpanSesi(token: 'token-masak', lastActiveAt: DateTime(2026));

    sambungkanPengecualian401(
      apiClient: apiClient,
      sessionStore: store,
      keeper: keeper,
    );
    return (keeper, store, apiClient.dio);
  }

  /// Panggil endpoint di env yang memang dijamin 401; yang diuji adalah
  /// efek listener, bukan pembuangan DioException.
  Future<void> panggil(
    Dio dio, {
    required String path,
    bool post = false,
  }) async {
    try {
      if (post) {
        await dio.post<Object?>(path);
      } else {
        await dio.get<Object?>(path);
      }
    } on DioException {
      // 401 memang dibuang Dio; yang diuji efek listener.
    }
  }

  test('401 dari /auth/login TIDAK menggugurkan sesi (kredensial salah)',
      () async {
    final (keeper, store, dio) = await siapkan({'code': 'KREDENSIAL'});
    await panggil(dio, path: '/auth/login', post: true);

    expect(keeper.decision, isNull);
    expect(await store.bacaToken(), isNotNull);
    expect(await store.bacaEmailTerakhir(), 'bocil@kampus.ac.id');
  });

  test('401 session_expired -> kedaluwarsakan (banner) dan sesi dihapus',
      () async {
    final (keeper, store, dio) = await siapkan({'code': 'session_expired'});
    await panggil(dio, path: '/me');

    final decision = keeper.decision!;
    expect(decision, isA<NeedsLogin>());
    expect((decision as NeedsLogin).reason, LoginReason.kedaluwarsa);
    expect(await store.bacaToken(), isNull);
    // Surel terjaga untuk isi otomatis pada halaman login kedaluwarsa.
    expect(await store.bacaEmailTerakhir(), 'bocil@kampus.ac.id');
  });

  test('401 lain pada endpoint terproteksi -> login polos tanpa banner',
      () async {
    final (keeper, store, dio) = await siapkan({'message': 'Token dicabut.'});
    await panggil(dio, path: '/me');

    final decision = keeper.decision!;
    expect(decision, isA<NeedsLogin>());
    expect((decision as NeedsLogin).reason, LoginReason.pertamaKali);
    expect(await store.bacaToken(), isNull);
  });
}
