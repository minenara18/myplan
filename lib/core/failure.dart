/// Kegagalan bernilai (sealed) — semua kegagalan jaringan, validasi,
/// dan otorisasi dipetakan ke subkelas ini oleh lapisan data.
sealed class Failure {
  const Failure([
    this.message = 'Terjadi kesalahan.',
    this.code,
  ]);

  /// Pesan siap tampilkan ke pengguna.
  final String message;

  /// Kode kegagalan dari API (misalnya 'VALIDASI_GAGAL').
  final String? code;
}

/// Tidak ada koneksi atau koneksi putus.
final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Koneksi tidak tersedia. Periksa internet Anda.',
    super.code,
  ]);
}

/// Payload tidak lolos validasi (HTTP 422).
final class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'Data yang dikirim tidak valid.',
    super.code,
    this.errors = const {},
  ]);

  /// Kesalahan per field dari server: {field: [pesan]}.
  final Map<String, List<String>> errors;
}

/// Tidak terautentikasi atau sesi berakhir (HTTP 401).
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Sesi berakhir. Silakan masuk kembali.',
    super.code,
  ]);
}

/// Terus tetapi tidak berhak (HTTP 403).
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure([
    super.message = 'Anda tidak memiliki akses ke data ini.',
    super.code,
  ]);
}

/// Data tidak ditemukan (HTTP 404).
final class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'Data tidak ditemukan.',
    super.code,
  ]);
}

/// Kesalahan server (HTTP 5xx).
final class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Terjadi kesalahan pada server. Coba lagi nanti.',
    super.code,
  ]);
}

/// Kegagalan yang tidak terklasifikasi.
final class UnknownFailure extends Failure {
  const UnknownFailure(
      [super.message = 'Terjadi kesalahan yang tidak diketahui.']);
}
