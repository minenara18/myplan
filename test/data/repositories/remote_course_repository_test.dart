import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_study_planner/core/failure.dart';
import 'package:ai_study_planner/core/models/course.dart';
import 'package:ai_study_planner/core/models/focus_record.dart';
import 'package:ai_study_planner/data/repositories/remote_course_repository.dart';
import 'package:ai_study_planner/data/repositories/remote_focus_repository.dart';
import 'package:ai_study_planner/data/repositories/remote_task_repository.dart';

import '../fakes/fake_dio_adapter.dart';

Dio dioWith(FakeDioAdapter adapter) {
  final dio = Dio();
  dio.httpClientAdapter = adapter;
  return dio;
}

void main() {
  group('RemoteCourseRepository', () {
    test('watchCourses memetakan JSON menjadi daftar Course', () async {
      final adapter = FakeDioAdapter(
        (options) async => fakeJsonResponse(200, {
          'data': [
            {
              'id': 'course-1',
              'nama': 'Pemrograman Mobile',
              'warna_index': 0,
              'ikon': 0xe800,
            },
            {
              'id': 'course-2',
              'nama': 'Basis Data',
              'warna_index': 1,
              'ikon': 0xe801,
            },
          ],
        }),
      );

      final repo = RemoteCourseRepository(dio: dioWith(adapter));
      final courses = await repo.watchCourses().first;

      expect(courses, hasLength(2));
      expect(courses[0].id, 'course-1');
      expect(courses[0].nama, 'Pemrograman Mobile');
      expect(courses[0].warnaIndex, 0);
      expect(adapter.capturedRequests.single.path, contains('/courses'));
    });

    test('PUT gagal 404 lalu POST buat baru saat simpan', () async {
      int call = 0;
      final adapter = FakeDioAdapter((options) async {
        call++;
        if (call == 1 && options.method == 'PUT') {
          return fakeJsonResponse(404, {
            'message': 'Tidak ditemukan',
            'code': 'TIDAK_ADA',
          });
        }
        return fakeJsonResponse(201, {
          'data': {'id': 'course-9', 'nama': 'Baru'},
        });
      });

      final repo = RemoteCourseRepository(dio: dioWith(adapter));
      await repo.saveCourse(
        const Course(
          id: 'course-9',
          nama: 'Baru',
          warnaIndex: 1,
          ikon: IconData(0xe800, fontFamily: 'MaterialIcons'),
        ),
      );

      expect(adapter.capturedRequests, hasLength(2));
      expect(adapter.capturedRequests[0].method, 'PUT');
      expect(adapter.capturedRequests[1].method, 'POST');
    });

    test('respons 401 dipetakan menjadi UnauthorizedFailure', () async {
      final adapter = FakeDioAdapter(
        (options) async => fakeJsonResponse(401, {
          'message': 'Sesi berakhir',
          'code': 'TIDAK_TERAUTENTIKASI',
        }),
      );

      final repo = RemoteCourseRepository(dio: dioWith(adapter));

      await expectLater(
        repo.watchCourses().first,
        throwsA(isA<UnauthorizedFailure>()),
      );
    });

    test('respons 403 dipetakan menjadi ForbiddenFailure', () async {
      final adapter = FakeDioAdapter(
        (options) async => fakeJsonResponse(403, {
          'message': 'Tidak berhak',
          'code': 'DILARANG',
        }),
      );

      final repo = RemoteCourseRepository(dio: dioWith(adapter));

      await expectLater(
        repo.watchCourses().first,
        throwsA(isA<ForbiddenFailure>()),
      );
    });

    test('respons 422 dipetakan menjadi ValidationFailure dengan errors',
        () async {
      final adapter = FakeDioAdapter(
        (options) async => fakeJsonResponse(422, {
          'message': 'Validasi gagal',
          'errors': {
            'nama': ['Nama wajib diisi.'],
          },
          'code': 'VALIDASI_GAGAL',
        }),
      );

      final repo = RemoteCourseRepository(dio: dioWith(adapter));

      await expectLater(
        repo.watchCourses().first,
        throwsA(
          isA<ValidationFailure>()
              .having((f) => f.message, 'message', 'Validasi gagal')
              .having(
                (f) => f.errors['nama']?.first,
                'error nama',
                'Nama wajib diisi.',
              ),
        ),
      );
    });

    test('kesalahan koneksi dipetakan menjadi NetworkFailure', () async {
      Future<ResponseBody> onFetch(RequestOptions options) {
        throw DioException.connectionError(
          requestOptions: options,
          reason: 'offline',
        );
      }

      final repo =
          RemoteCourseRepository(dio: dioWith(FakeDioAdapter(onFetch)));

      await expectLater(
        repo.watchCourses().first,
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('RemoteTaskRepository', () {
    test('watchTasks memetakan JSON menjadi daftar Task', () async {
      final adapter = FakeDioAdapter(
        (options) async => fakeJsonResponse(200, {
          'data': [
            {
              'id': 'task-1',
              'course_id': 'course-1',
              'judul': 'Tugas Flutter UI',
              'catatan': 'Buat layar onboarding',
              'tenggat': '2026-11-02T10:00:00.000',
              'estimasi_menit': 120,
              'prioritas': 'tinggi',
              'status': 'berjalan',
            },
          ],
        }),
      );

      final repo = RemoteTaskRepository(dio: dioWith(adapter));
      final tasks = await repo.watchTasks().first;

      expect(tasks.single.id, 'task-1');
      expect(tasks.single.courseId, 'course-1');
      expect(tasks.single.prioritas.name, 'tinggi');
      expect(tasks.single.status.name, 'berjalan');
      expect(tasks.single.estimasiMenit, 120);
    });
  });

  group('RemoteFocusRepository', () {
    test('saveFocusRecord mengirim POST ke /focus-records', () async {
      final adapter = FakeDioAdapter(
        (options) async => fakeJsonResponse(201, {
          'data': {'id': 'focus-1', 'durasi_menit': 25},
        }),
      );

      final dio = dioWith(adapter);
      final repo = RemoteFocusRepository(dio: dio);

      await repo.saveFocusRecord(
        FocusRecord(
          id: 'focus-1',
          mulai: DateTime(2026, 10, 30, 9),
          durasi: const Duration(minutes: 25),
          taskId: null,
        ),
      );

      expect(adapter.capturedRequests.single.method, 'POST');
      expect(adapter.capturedRequests.single.path, contains('/focus-records'));
    });

    test('saveFocusRecord mengirim task_id bila ada', () async {
      final adapter = FakeDioAdapter(
        (options) async => fakeJsonResponse(201, {
          'data': {'id': 'focus-2'},
        }),
      );

      final repo = RemoteFocusRepository(dio: dioWith(adapter));
      await repo.saveFocusRecord(
        FocusRecord(
          id: 'focus-2',
          mulai: DateTime(2026, 10, 30, 10),
          durasi: const Duration(minutes: 15),
          taskId: 'task-1',
        ),
      );

      final captured =
          adapter.capturedRequests.single.data as Map<String, dynamic>;
      expect(captured['task_id'], 'task-1');
    });
  });
}
