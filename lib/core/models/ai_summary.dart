import 'package:equatable/equatable.dart';

/// Hasil ringkasan materi dari backend AI:
/// ringkasan paragraf, poin kunci, dan pertanyaan latihan.
class AiSummary extends Equatable {
  const AiSummary({
    required this.ringkasan,
    required this.poinKunci,
    required this.pertanyaanLatihan,
  });

  final String ringkasan;
  final List<String> poinKunci;
  final List<String> pertanyaanLatihan;

  @override
  List<Object?> get props => [ringkasan, poinKunci, pertanyaanLatihan];
}
