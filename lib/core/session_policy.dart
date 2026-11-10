/// Kebijakan sesi: keputusan rute berdasarkan onboarding, token,
/// dan keaktifan terakhir pengguna.
///
/// Dart murni (tanpa Flutter). Waktu hanya lewat [Clock] yang disuntik.
library;

/// Alasan pengguna diminta login lagi.
enum LoginReason {
  /// Belum pernah login (belum ada token).
  pertamaKali,

  /// Sesi kedaluwarsa karena melewati batas idle maksimum.
  kedaluwarsa,
}

/// Nama query parameter alasan login pada rute /login.
const String kLoginReasonParam = 'reason';

/// Nilai query parameter untuk login karena sesi kedaluwarsa.
const String kLoginReasonKedaluwarsa = 'kedaluwarsa';

/// Keputusan sesi. Sealed agar switch wajib exhaustif.
sealed class SessionDecision {
  const SessionDecision();
}

/// Pengguna belum menyelesaikan onboarding.
final class NeedsOnboarding extends SessionDecision {
  const NeedsOnboarding();
}

/// Pengguna harus login dengan alasan tertentu.
final class NeedsLogin extends SessionDecision {
  const NeedsLogin(this.reason);

  final LoginReason reason;
}

/// Pengguna terautentikasi dan sesi masih hidup.
final class Authenticated extends SessionDecision {
  const Authenticated();
}

/// Evaluasi keputusan sesi.
///
/// Batas idle dihitung dari [Clock yang disuntik], bukan DateTime.now().
class SessionPolicy {
  const SessionPolicy();

  /// Batas idle maksimum sesi: aplikasi minimal dibuka sekali dalam 60
  /// hari agar sesi tetap hidup. Sumber tunggal angka ini.
  static const Duration maxIdle = Duration(days: 60);

  /// Urutan aturan:
  /// 1. belum onboarding -> [NeedsOnboarding];
  /// 2. tanpa token -> [NeedsLogin]([LoginReason.pertamaKali]);
  /// 3. [lastActiveAt] kosong atau selisih melebihi [maxIdle]
  ///    -> [NeedsLogin]([LoginReason.kedaluwarsa]);
  /// 4. selain itu -> [Authenticated].
  ///
  /// Jam mundur (now lebih awal dari lastActiveAt) tidak menggugurkan
  /// sesi: selisih bisa negatif dan dianggap masih dalam batas.
  SessionDecision evaluate({
    required DateTime now,
    required DateTime? lastActiveAt,
    required bool hasToken,
    required bool onboardingDone,
  }) {
    if (!onboardingDone) return const NeedsOnboarding();
    if (!hasToken) return const NeedsLogin(LoginReason.pertamaKali);
    final last = lastActiveAt;
    if (last == null) return const NeedsLogin(LoginReason.kedaluwarsa);
    if (now.isBefore(last)) return const Authenticated();
    if (now.difference(last) > maxIdle) {
      return const NeedsLogin(LoginReason.kedaluwarsa);
    }
    return const Authenticated();
  }
}
