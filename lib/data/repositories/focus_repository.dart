import 'package:ai_study_planner/core/models/focus_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Interface repositori rekaman fokus.
/// Stream untuk pembacaan, satu jalur penulisan.
abstract class FocusRepository {
  /// Stream semua rekaman fokus.
  Stream<List<FocusRecord>> watchFocusRecords();

  /// Simpan atau perbarui satu rekaman fokus.
  Future<void> saveFocusRecord(FocusRecord record);

  /// Hapus rekaman fokus berdasarkan id.
  Future<void> deleteFocusRecord(String id);
}

/// Provider FocusRepository — melempar UnimplementedError sampai di-override di bootstrap.
final focusRepositoryProvider = Provider<FocusRepository>((ref) {
  throw UnimplementedError(
    'FocusRepository belum di-override di bootstrap. '
    'Gunakan FakeFocusRepository atau RemoteFocusRepository.',
  );
});
