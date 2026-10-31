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
    'CobaLagi': 'Coba Lagi',
    'LoadFailed': 'Terjadi kesalahan saat memuat data',

    // Onboarding & Auth
    'Onboarding': 'Onboarding',
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
    'Source': 'Sumber',
    'SourceManual': 'Manual',
    'SourceAI': 'AI',

    // Home
    'Greeting': 'Halo, {nama}',
    'TodayProgress': 'Progres Hari Ini',
    'FocusToday': 'Fokus Hari Ini',
    'NextSession': 'Sesi berikutnya',
    'StartSession': 'Mulai Sesi',
    'Subjects': 'Mata Pelajaran',
    'QuickActions': 'Aksi Cepat',
    'AddTaskQuick': 'Tambah Tugas',
    'AIPlanQuick': 'Rencana AI',
    'TimerQuick': 'Timer',
    'NotesQuick': 'Catatan',
    'NotesComingSoon': 'Segera hadir',
    'Streak': 'Streak',
    'StreakDays': 'hari',
    'EmptyHome': 'Mulai dengan menambahkan tugas atau sesi belajar.',
  };

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
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