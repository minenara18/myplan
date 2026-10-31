import 'package:ai_study_planner/core/clock.dart';
import 'package:ai_study_planner/core/models/ai_plan_block.dart';
import 'package:ai_study_planner/core/models/ai_plan_input.dart';
import 'package:ai_study_planner/core/models/ai_plan_result.dart';
import 'package:ai_study_planner/core/models/ai_summary.dart';
import 'package:ai_study_planner/data/repositories/ai_repository.dart';

/// Implementasi in-memory dari AiRepository untuk mode demo.
class FakeAiRepository implements AiRepository {
  FakeAiRepository({required this.clock});

  final Clock clock;

  @override
  Future<AiPlanResult> buatRencana(AiPlanInput input) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final sesi = [
      AiPlanBlock(
        taskId: 'task-1',
        mulai: clock.now().add(const Duration(hours: 8)),
        selesai: clock.now().add(const Duration(hours: 9)),
        alasan: 'Tenggat terdekat, selesaikan bagian intinya dulu.',
      ),
      AiPlanBlock(
        taskId: 'task-2',
        mulai: clock.now().add(const Duration(days: 1, hours: 8)),
        selesai: clock.now().add(const Duration(days: 1, hours: 9, minutes: 30)),
        alasan: 'Slot waktu luang besok, setelah sesi yang sudah ada.',
      ),
      AiPlanBlock(
        taskId: 'task-2',
        mulai: clock.now().add(const Duration(days: 2, hours: 8)),
        selesai: clock.now().add(const Duration(days: 2, hours: 8, minutes: 30)),
        alasan: 'Lanjutan tugas besok dalam blok kecil.',
      ),
    ];

    return AiPlanResult(
      sumber: AiPlanSumber.ai,
      rentangMulai: input.mulai,
      rentangSampai: input.sampai,
      sesi: sesi,
      prioritas: ['task-1', 'task-2'],
    );
  }

  @override
  Future<AiSummary> ringkasMateri(String teks) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return const AiSummary(
      ringkasan:
          'Basis data menyimpan data terstruktur dalam tabel baris-kolom. '
          'Normalisasi memisahkan data untuk mengurangi redundansi, dan indeks '
          'B-tree mempercepat pencarian. Transaksi menjamin ACID agar data '
          'tetap konsisten sepanjang operasi konkuren.',
      poinKunci: [
        'Model relasional memakai tabel baris-kolom dengan kunci utama.',
        'Normalisasi 1NF-3NF mengurangi redundansi dan anomali data.',
        'Indeks B-tree mempercepat SELECT namun memperlambat tulis.',
        'ACID menjamin atomik, konsisten, isolasi, dan tahan gagal.',
      ],
      pertanyaanLatihan: [
        'Apa perbedaan kunci utama dan kunci asing?',
        'Jelaskan tujuan normalisasi hingga bentuk 3NF.',
        'Kapan indeks justru melemahkan kinerja aplikasi?',
        'Mengapa transaksi harus terisolasi satu sama lain?',
        'Beri contoh pelanggaran properti atomik dalam transaksi.',
      ],
    );
  }
}
