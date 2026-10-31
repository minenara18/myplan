import 'package:equatable/equatable.dart';

/// Masukan penyusunan rencana yang dikirim ke backend:
/// rentang tanggal dan jendela waktu luang harian.
class AiPlanInput extends Equatable {
  // Default jendela waktu luang harian (jam ke-16 s.d. ke-21).
  static const int defaultJamMulai = 16;
  static const int defaultJamSelesai = 21;

  const AiPlanInput({
    required this.mulai,
    required this.sampai,
    this.jamMulai = defaultJamMulai,
    this.jamSelesai = defaultJamSelesai,
    this.catatan,
  });

  /// Rentang tanggal (bagian tanggal yang dipakai).
  final DateTime mulai;
  final DateTime sampai;
  final int jamMulai;
  final int jamSelesai;

  /// Catatan bebas dari pengguna untuk konteks AI (opsional).
  final String? catatan;

  @override
  List<Object?> get props => [mulai, sampai, jamMulai, jamSelesai, catatan];
}
