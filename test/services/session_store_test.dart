import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_study_planner/data/api/token_storage.dart';
import 'package:ai_study_planner/services/session_store.dart';

void main() {
  group('InMemorySessionStore', () {
    late InMemorySessionStore store;

    setUp(() {
      store = InMemorySessionStore();
    });

    test('touch: tulis pertama langsung tersimpan', () async {
      final t0 = DateTime(2026, 1, 1, 8);
      await store.touch(t0);
      expect(await store.bacaLastActiveAt(), t0);
    });

    test('touch: throttle, tulis maksimal sekali per jam', () async {
      final t0 = DateTime(2026, 1, 1, 8);
      await store.touch(t0);

      // 45 menit kemudian: tidak menulis ulang.
      final t1 = t0.add(const Duration(minutes: 45));
      await store.touch(t1);
      expect(await store.bacaLastActiveAt(), t0);

      // 61 menit dari t0: menulis ulang.
      final t2 = t0.add(const Duration(minutes: 61));
      await store.touch(t2);
      expect(await store.bacaLastActiveAt(), t2);
    });

    test('touch: jam mundur tidak menurunkan lastActiveAt', () async {
      final t0 = DateTime(2026, 1, 1, 8);
      await store.touch(t0);
      final mundur = t0.subtract(const Duration(days: 5));
      await store.touch(mundur);
      expect(await store.bacaLastActiveAt(), t0);
    });

    test('hapusSesi menghapus token & lastActiveAt, email terjaga', () async {
      final t0 = DateTime(2026, 1, 1, 8);
      await store.catatLogin(email: 'bocil@kampus.ac.id', at: t0);
      await store.simpanSesi(token: 'token-abc', lastActiveAt: t0);

      await store.hapusSesi();

      expect(await store.bacaToken(), isNull);
      expect(await store.bacaLastActiveAt(), isNull);
      expect(await store.bacaEmailTerakhir(), 'bocil@kampus.ac.id');
    });

    test('catatLogin menyimpan email dan mengatur keaktifan', () async {
      final t0 = DateTime(2026, 1, 1, 8);
      await store.catatLogin(email: 'bocil@kampus.ac.id', at: t0);
      expect(await store.bacaEmailTerakhir(), 'bocil@kampus.ac.id');
      expect(await store.bacaLastActiveAt(), t0);
    });

    test('simpanEmailTerakhir tidak mengubah keaktifan', () async {
      await store.simpanEmailTerakhir('baru@kampus.ac.id');
      expect(await store.bacaLastActiveAt(), isNull);
      expect(await store.bacaEmailTerakhir(), 'baru@kampus.ac.id');
    });
  });

  group('SharedPreferencesSessionStore', () {
    // flutter_secure_storage tidak tersedia di lingkungan test (tanpa
    // platform channel), jadi jalur token diuji lewat InMemorySessionStore;
    // bagian SharedPreferences (lastActiveAt & email) diuji di sini.
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<SharedPreferencesSessionStore> buatStore() async {
      final prefs = await SharedPreferences.getInstance();
      return SharedPreferencesSessionStore(
        prefs: prefs,
        tokenStorage: _TokenStoragePalsu(),
      );
    }

    test('roundtrip catatLogin: email dan lastActiveAt tersimpan', () async {
      final store = await buatStore();
      final t0 = DateTime(2026, 5, 5, 9, 30);
      await store.catatLogin(email: 'bocil@kampus.ac.id', at: t0);

      expect(await store.bacaEmailTerakhir(), 'bocil@kampus.ac.id');
      expect(await store.bacaLastActiveAt(), t0);
    });

    test('touch di SharedPreferences juga throttle dan anti-mundur', () async {
      final store = await buatStore();
      final t0 = DateTime(2026, 5, 5, 9, 30);
      await store.touch(t0);
      await store.touch(t0.add(const Duration(minutes: 10)));
      await store.touch(t0.subtract(const Duration(days: 1)));
      expect(await store.bacaLastActiveAt(), t0);
    });

    test('hapusSesi menyingkirkan lastActiveAt dan mempertahankan email',
        () async {
      final store = await buatStore();
      await store.catatLogin(
        email: 'bocil@kampus.ac.id',
        at: DateTime(2026, 5, 5),
      );
      await store.hapusSesi();
      expect(await store.bacaLastActiveAt(), isNull);
      expect(await store.bacaEmailTerakhir(), 'bocil@kampus.ac.id');
    });
  });
}

/// TokenStorage palsu: tidak menyentuh platform channel.
class _TokenStoragePalsu implements TokenStorage {
  String? _token;

  @override
  Future<bool> hasToken() async => _token != null;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> save(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}
