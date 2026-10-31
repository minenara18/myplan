import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/core/clock.dart';
import 'package:ai_study_planner/core/failure.dart';
import 'package:ai_study_planner/core/models/ai_plan_block.dart';
import 'package:ai_study_planner/core/models/ai_plan_input.dart';
import 'package:ai_study_planner/core/models/ai_plan_result.dart';
import 'package:ai_study_planner/core/models/course.dart';
import 'package:ai_study_planner/core/models/study_session.dart';
import 'package:ai_study_planner/core/models/task.dart';
import 'package:ai_study_planner/data/repositories/ai_repository.dart';
import 'package:ai_study_planner/data/repositories/course_repository.dart';
import 'package:ai_study_planner/data/repositories/session_repository.dart';
import 'package:ai_study_planner/data/repositories/task_repository.dart';
import 'package:ai_study_planner/core/system_clock.dart';

/// State untuk AiPlannerNotifier.
sealed class AiPlannerState {}

/// Belum ada rencana; masukan siap diedit.
final class AiPlannerIdle extends AiPlannerState {
  AiPlannerIdle({this.catatan = ''});

  /// Catatan bebas pengguna sebagai konteks AI.
  final String catatan;
}

/// Menunggu jawaban backend; skeleton tampil.
final class AiPlannerLoading extends AiPlannerState {
  AiPlannerLoading(this.masukanLalu);

  final AiPlanInput masukanLalu;
}

/// Rencana tersedia dan menunggu diterapkan.
final class AiPlannerReady extends AiPlannerState {
  AiPlannerReady({
    required this.hasil,
    required this.tugas,
    required this.mataKuliah,
    this.catatan = '',
  });

  final AiPlanResult hasil;

  /// task_id -> Task; untuk judul, tenggat, dan prioritas.
  final Map<String, Task> tugas;

  /// course_id -> Course; untuk ikon dan nama mata kuliah.
  final Map<String, Course> mataKuliah;

  final String catatan;

  int get jumlahSesi => hasil.sesi.length;
}

/// Menyimpan semua sesi ke kalender.
final class AiPlannerMenyimpan extends AiPlannerReady {
  AiPlannerMenyimpan({required super.hasil, required super.tugas, required super.mataKuliah, super.catatan});
}

/// Semua sesi tersimpan lewat satu operasi bulk.
final class AiPlannerTersimpan extends AiPlannerReady {
  AiPlannerTersimpan({required super.hasil, required super.tugas, required super.mataKuliah, super.catatan});
}

/// Gagal: penyebab dijelaskan; tombol Coba lagi tersedia.
final class AiPlannerError extends AiPlannerState {
  AiPlannerError(this.failure, {this.terakhir, this.readySebelumnya});

  final Failure failure;

  /// Masukan terakhir; Coba lagi mengulang panggilan susun yang sama.
  final AiPlanInput? terakhir;

  /// Hasil yang sudah tampak sebelum gagal menyimpan; bila ada,
  /// Coba lagi kembali menawarkan Terapkan, bukan menyusun dari nol.
  final AiPlannerReady? readySebelumnya;

  /// Retry tersedia bila ada masukan atau hasil sebelumnya untuk diulang.
  bool get bisaCobaLagi => terakhir != null || readySebelumnya != null;
}

/// Notifier untuk fitur penyusun rencana AI (tab tengah).
class AiPlannerNotifier extends ChangeNotifier {
  AiPlannerNotifier({
    required AiRepository aiRepository,
    required SessionRepository sessionRepository,
    required TaskRepository taskRepository,
    required CourseRepository courseRepository,
    required Clock clock,
  })  : _aiRepository = aiRepository,
        _sessionRepository = sessionRepository,
        _taskRepository = taskRepository,
        _courseRepository = courseRepository,
        _clock = clock;

  final AiRepository _aiRepository;
  final SessionRepository _sessionRepository;
  final TaskRepository _taskRepository;
  final CourseRepository _courseRepository;
  final Clock _clock;

  AiPlannerState _state = AiPlannerIdle();
  AiPlannerState get state => _state;

  /// Masukan bawaan untuk tampilan awal: hari ini s.d. +6 hari,
  /// jendela waktu luang 16.00–21.00 (semua lewat Clock yang disuntik).
  AiPlanInput get masukanDefault => _bangunMasukan();

  /// Muat konteks (tugas + mata kuliah) tanpa memanggil AI.
  Future<void> muatKonteks() async {
    final tugas = await _tugasMap();
    final mataKuliah = await _mataKuliahMap();
    _state = AiPlannerReady(
      hasil: AiPlanResult(
        sumber: AiPlanSumber.fallback,
        rentangMulai: DateTime(_clock.now().year, _clock.now().month, _clock.now().day),
        rentangSampai: DateTime(_clock.now().year, _clock.now().month, _clock.now().day),
        sesi: const [],
        prioritas: const [],
      ),
      tugas: tugas,
      mataKuliah: mataKuliah,
    );
    notifyListeners();
  }

  /// Susun jadwal untuk satu rentang. Rentang kosong berarti 7 hari ke depan;
  /// jam jendela waktu luang diambil dari jam pada mulai/sampai bila diberi.
  Future<void> susun({
    DateTime? mulai,
    DateTime? sampai,
    int? jamMulai,
    int? jamSelesai,
    String? catatan,
  }) async {
    final masukan = _bangunMasukan(
      mulai: mulai,
      sampai: sampai,
      jamMulai: jamMulai,
      jamSelesai: jamSelesai,
      catatan: catatan,
    );

    _state = AiPlannerLoading(masukan);
    notifyListeners();

    try {
      final hasil = await _aiRepository.buatRencana(masukan);
      final tugas = await _tugasMap();
      final mataKuliah = await _mataKuliahMap();

      _state = AiPlannerReady(
        hasil: hasil,
        tugas: tugas,
        mataKuliah: mataKuliah,
        catatan: masukan.catatan ?? '',
      );
    } on Failure catch (failure) {
      _state = AiPlannerError(failure, terakhir: masukan);
    }
    notifyListeners();
  }

  /// Edit satu blok hasil AI sebelum diterapkan (tombol Ubah).
  void perbaruiBlok(AiPlanBlock lama, DateTime mulai, DateTime selesai) {
    final state = _state;
    if (state is! AiPlannerReady) return;

    final sesiBaru = state.hasil.sesi.map((b) {
      return identical(b, lama)
          ? b.copyWith(mulai: mulai, selesai: selesai)
          : b;
    }).toList();

    _state = AiPlannerReady(
      hasil: AiPlanResult(
        sumber: state.hasil.sumber,
        rentangMulai: state.hasil.rentangMulai,
        rentangSampai: state.hasil.rentangSampai,
        sesi: sesiBaru,
        prioritas: state.hasil.prioritas,
      ),
      tugas: state.tugas,
      mataKuliah: state.mataKuliah,
      catatan: state.catatan,
    );
    notifyListeners();
  }

  /// Simpan semua sesi lewat satu operasi repository (bulk).
  Future<void> terapkan() async {
    final state = _state;
    if (state is! AiPlannerReady || state.hasil.sesi.isEmpty) return;

    _state = AiPlannerMenyimpan(
      hasil: state.hasil,
      tugas: state.tugas,
      mataKuliah: state.mataKuliah,
      catatan: state.catatan,
    );
    notifyListeners();

    try {
      final sekarang = _clock.now();
      final sesiBaru = [
        for (var i = 0; i < state.hasil.sesi.length; i++)
          () {
            final blok = state.hasil.sesi[i];
            final tugas = state.tugas[blok.taskId];
            return StudySession(
              id: 'ai-${blok.taskId}-$i-${sekarang.millisecondsSinceEpoch}',
              taskId: blok.taskId,
              courseId: tugas?.courseId ?? '',
              mulai: blok.mulai,
              selesai: blok.selesai,
              sumber: SessionSource.ai,
            );
          }(),
      ];

      await _sessionRepository.saveManySessions(sesiBaru);
      _state = AiPlannerTersimpan(
        hasil: state.hasil,
        tugas: state.tugas,
        mataKuliah: state.mataKuliah,
        catatan: state.catatan,
      );
    } on Failure catch (failure) {
      // Hasil yang sudah ditolak masih bisa diulang: tampilkan error
      // dengan hasil lama agar tombol Coba lagi memicu Terapkan ulang,
      // tanpa memanggil AI lagi.
      _state = AiPlannerError(failure, readySebelumnya: state);
    }
    notifyListeners();
  }

  /// Panggil ulang masukan terakhir (tombol Coba lagi).
  Future<void> cobaUlang() async {
    final state = _state;
    if (state is! AiPlannerError || !state.bisaCobaLagi) return;

    // Gagal saat menyimpan → kembalikan kondisi ready agar bisa Terapkan ulang.
    if (state.readySebelumnya != null) {
      _state = state.readySebelumnya!;
      notifyListeners();

      await terapkan();

      return;
    }

    final masukan = state.terakhir!;
    await susun(
      mulai: masukan.mulai,
      sampai: masukan.sampai,
      jamMulai: masukan.jamMulai,
      jamSelesai: masukan.jamSelesai,
      catatan: masukan.catatan,
    );
  }

  /// Reset ke kondisi idle.
  void reset() {
    _state = AiPlannerIdle();
    notifyListeners();
  }

  AiPlanInput _bangunMasukan({
    DateTime? mulai,
    DateTime? sampai,
    int? jamMulai,
    int? jamSelesai,
    String? catatan,
  }) {
    final hariIni = _clock.now();
    final mulaiFix = mulai ?? DateTime(hariIni.year, hariIni.month, hariIni.day);
    final sampaiFix =
        sampai ?? mulaiFix.add(const Duration(days: 6));

    return AiPlanInput(
      mulai: mulaiFix,
      sampai: sampaiFix,
      // Jam jendela diambil dari jam di tanggal yang dipilih, bila ada.
      jamMulai: jamMulai ?? (mulai != null ? mulai.hour : AiPlanInput.defaultJamMulai),
      jamSelesai:
          jamSelesai ?? (sampai != null ? sampai.hour : AiPlanInput.defaultJamSelesai),
      catatan: catatan,
    );
  }

  Future<Map<String, Task>> _tugasMap() async {
    final tasks = await _taskRepository.watchTasks().first;

    return {for (final task in tasks) task.id: task};
  }

  Future<Map<String, Course>> _mataKuliahMap() async {
    final courses = await _courseRepository.watchCourses().first;

    return {for (final course in courses) course.id: course};
  }
}

/// Provider AiPlannerNotifier.
final aiPlannerNotifierProvider = ChangeNotifierProvider<AiPlannerNotifier>((
  ref,
) {
  return AiPlannerNotifier(
    aiRepository: ref.watch(aiRepositoryProvider),
    sessionRepository: ref.watch(sessionRepositoryProvider),
    taskRepository: ref.watch(taskRepositoryProvider),
    courseRepository: ref.watch(courseRepositoryProvider),
    clock: SystemClock(),
  );
});
