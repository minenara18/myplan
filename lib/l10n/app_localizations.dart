import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  AppLocalizations(this._key, this._args);

  final String _key;
  final List<Object> _args;

  String get localized => Intl.message(_key, args: _args);

  static List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('id', ''),
  ];

  static Map<String, String> messages = {
    // Umum
    'Welcome': 'Selamat Datang',
    'Home': 'Beranda',
    'Calendar': 'Kalender',
    'AI': 'AI',
    'Graphics': 'Grafik',
    'Profile': 'Profil',
    'Priority': 'Prioritas',
    'Subject': 'Mata Pelajaran',
    'Status': 'Status',
    'Login': 'Masuk',
    'Register': 'Daftar',
    'Logout': 'Keluar',
    'StudyPlan': 'Rencana Belajar',
    'AddTask': 'Tambah Tugas',
    'Settings': 'Pengaturan',
    'Email': 'Email',
    'Sandi': 'Sandi',
    'BuatAkunBaru': 'Buat akun baru untuk memulai',
    'KonfirmasiSandi': 'Konfirmasi Sandi',
    'EmailKosong': 'Email tidak boleh kosong.',
    'EmailTidakValid': 'Masukkan email yang valid.',
    'SandiKosong': 'Sandi tidak boleh kosong.',
    'SandiMinimalEnam': 'Sandi minimal 6 karakter.',
    'KonfirmasiKosong': 'Konfirmasi sandi tidak boleh kosong.',
    'SandiTidakCocok': 'Sandi tidak cocok.',
    'SudahPunyaAkun': 'Sudah punya akun? Masuk',
    'BelumPunyaAkun': 'Belum punya akun? Daftar',
    'LanjutDenganGoogle': 'Lanjut dengan Google',
    'Keluar': 'Keluar',
    'KeluarAkun': 'Keluar Akun',
    'YakinKeluar': 'Yakin ingin keluar dari akun ini?',
    'Pengguna': 'Pengguna',
    'CobaLagi': 'Coba Lagi',
    'LoadFailed': 'Terjadi kesalahan saat memuat data',

    // Onboarding & Auth
    'OnboardingDeskripsi1': 'Rencanakan jadwal belajarmu dengan mudah dan terstruktur.',
    'OnboardingDeskripsi2': 'Dapatkan rekomendasi waktu belajar yang disesuaikan kebutuhanmu.',
    'OnboardingDeskripsi3': 'Siapkan rencana belajarmu dan raih prestasi akademik yang lebih baik.',
    'Lanjut': 'Lanjut',
    'Aplikasi': 'AI Study Planner',
    'Skip': 'Lewati',
    'GetStarted': 'Mulai',

    // Tasks
    'Tasks': 'Tugas',
    'AllTasks': 'Semua',
    'TodayTasks': 'Hari Ini',
    'WeekTasks': 'Minggu Ini',
    'CompletedTasks': 'Selesai',
    'NoTasks': 'Belum ada tugas',
    'NoTasksDescription': 'Tambah tugas baru untuk memulai rencana belajarmu.',
    'AddTaskTitle': 'Tambah Tugas',
    'EditTaskTitle': 'Ubah Tugas',
    'TaskDetail': 'Detail Tugas',
    'TaskTitle': 'Judul Tugas',
    'TaskSubject': 'Mata Pelajaran',
    'TaskNotes': 'Catatan',
    'TaskDueDate': 'Tenggat Waktu',
    'TaskEstimate': 'Estimasi (menit)',
    'TaskPriority': 'Prioritas',
    'TaskStatus': 'Status',
    'Save': 'Simpan',
    'Cancel': 'Batal',
    'Delete': 'Hapus',
    'Deleted': 'Tugas dihapus',
    'Undo': 'Batalkan',
    'EstimasiKosong': 'Estimasi waktu tidak boleh kosong.',
    'Tinggi': 'Tinggi',
    'Sedang': 'Sedang',
    'Rendah': 'Rendah',
    'JudulKosong': 'Judul tugas tidak boleh kosong.',
    'PilihMataPelajaran': 'Pilih mata pelajaran.',
    'Tambah': 'Tambah',
    'Tenggat': 'Tenggat',
    'Selesai': 'Selesai',
    'Belum': 'Belum',
    'MarkComplete': 'Tandai selesai',
    'MarkIncomplete': 'Tandai belum selesai',

    // Calendar
    'CalendarTitle': 'Kalender Belajar',
    'AddSession': 'Tambah Sesi',
    'ManualSession': 'Sesi Manual',
    'NoSessions': 'Belum ada sesi',
    'NoSessionsDescription': 'Tambah sesi belajar untuk menjadwalkan waktu mu.',
    'SessionDetail': 'Detail Sesi',
    'Duration': 'Durasi',
    'StartTime': 'Waktu Mulai',
    'EndTime': 'Waktu Selesai',
    'SessionTitle': 'Judul Sesi',
    'SessionCardTitle': 'Sesi Belajar',
    'StudySession': 'Sesi Belajar',
    'MinuteUnit': 'menit',
    'PreviousWeek': 'Minggu sebelumnya',
    'NextWeek': 'Minggu berikutnya',
    'SelectedDayNoSessions': 'Tidak ada sesi pada hari ini',
    'SelectedDayNoSessionsDescription': 'Tambah sesi baru untuk hari ini.',
    'TetapFokus': 'Tetap fokus selama',
    'Fokus': 'Fokus Hari Ini',
    'Berjalan': 'Berjalan',
    'Siap': 'Siap',
    'RingkasMateri': 'Ringkas Materi',
    'Ringkasan': 'Ringkasan',
    'PoinKunci': 'Poin kunci',
    'Latihan': 'Pertanyaan latihan',
    'SimpanSebagaiCatatan': 'Simpan sebagai catatan:',
    'SimpanSebagaiCatatanTugas': 'Simpan ringkasan sebagai catatan tugas ini',
    'BelumAdaTugasBuatDulu': 'Belum ada tugas. Buat tugas dulu di menu Tugas.',
    'GagalSimpanCatatan': 'Gagal menyimpan catatan',
    'TempelTeksKuliah': 'Tempel teks kuliah di sini',
    'MinimalKarakter': 'Minimal 50 karakter…',
    'Ringkas': 'Ringkas',
    'Kembali': 'Kembali',
    'RencanaDiterapkan': 'Rencana diterapkan ke kalender',
    'FallbackAktif': 'AI tidak merespons — pakai penjadwalan fallback dasar.',
    'SusunJadwalMingguIni': 'Susun jadwal minggu ini',
    'SusunSlotOtomatis': 'Susun slot belajar otomatis',
    'TerapkanKeKalender': 'Terapkan ke Kalender',
    'GenerateUlang': 'Generate ulang rencana',
    'TerapkanRencana': 'Terapkan rencana ke kalender',
    'KonteksAI': 'Konteks untuk AI, mis.: ujian akhir minggu depan…',
    'RekamSuara': 'Rekam suara (segera hadir)',
    'SuaraSegera': 'Suara segera hadir',
    'UbahMasukanRencana': 'Ubah masukan rencana',
    'UbahJamSesi': 'Ubah jam sesi',
    'TanggalKe': '–',
    'Source': 'Sumber',
    'SourceManual': 'Manual',
    'SourceAI': 'AI',

    // Home
    'Greeting': 'Halo, Pengguna',
    'Greeting_nama': 'Halo, Pengguna',
    'HomeSubtitle': 'Selamat belajar hari ini!',
    'Pengingat': 'Pengingat',
    'DurasiPomodoro': 'Durasi Pomodoro Bawaan',
    'WaktuLuang': 'Waktu Luang Harian',
    'Pengaturan': 'Pengaturan',
    'TodayProgress': 'Progres Hari Ini',
    'FocusToday': 'Fokus Hari Ini',
    'NextSession': 'Sesi berikutnya',
    'StartSession': 'Mulai Sesi',
    'Subjects': 'Mata Pelajaran',
    'QuickActions': 'Aksi Cepat',
    'AddTaskQuick': 'Tambah Tugas',
    'AIPlanQuick': 'Rencana AI',
    'TimerQuick': 'Timer',
    'RingkasQuick': 'Ringkas Materi',
    'NotesQuick': 'Catatan',
    'NotesComingSoon': 'Segera hadir',
    'Streak': 'Streak',
    'JamBelajar': 'Jam Belajar',
    'HourUnit': 'jam',
    'TugasSelesai': 'Tugas Selesai',
    'BelumAdaDistribusi': 'Belum ada data distribusi',
    'ProgressBelajar': 'Progress Belajar',
    'AktivitasMingguIni': 'Aktivitas Minggu Ini',
    'DistribusiMataPelajaran': 'Distribusi Waktu per Mata Pelajaran',
    'StreakDays': 'hari',
    'EmptyHome': 'Mulai dengan menambahkan tugas atau sesi belajar.',
  };

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.contains(locale);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations('', []);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Helper untuk mengambil pesan dengan parameter.
String l10n(String key, {Map<String, String>? params}) {
  final message = AppLocalizations.messages[key] ?? key;
  if (params == null) return message;
  var result = message;
  params.forEach((k, v) => result = result.replaceAll('{$k}', v));
  return result;
}
