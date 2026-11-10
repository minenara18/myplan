import 'package:ai_study_planner/core/models/course.dart';
import 'package:ai_study_planner/core/models/study_session.dart';
import 'package:ai_study_planner/core/system_clock.dart';
import 'package:ai_study_planner/data/repositories/course_repository.dart';
import 'package:ai_study_planner/l10n/app_localizations.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';
import 'package:ai_study_planner/features/calendar/presentation/notifier/calendar_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom sheet untuk menambah sesi manual ke hari yang dipilih di kalender.
/// Dibungkus SingleChildScrollView agar aman pada skala teks 2.0 dan keyboard.
class SessionBottomSheet extends ConsumerStatefulWidget {
  const SessionBottomSheet({super.key});

  @override
  ConsumerState<SessionBottomSheet> createState() => _SessionBottomSheetState();
}

class _SessionBottomSheetState extends ConsumerState<SessionBottomSheet> {
  final _judulController = TextEditingController();
  String? _courseId;
  TimeOfDay _jam = const TimeOfDay(hour: 16, minute: 0);
  int _durasiMenit = 60;

  @override
  void dispose() {
    _judulController.dispose();
    super.dispose();
  }

  Future<void> _pilihJam() async {
    final jam = await showTimePicker(context: context, initialTime: _jam);
    if (jam != null) setState(() => _jam = jam);
  }

  Future<void> _simpan() async {
    final judul = _judulController.text.trim();
    final courseId = _courseId;
    if (judul.isEmpty || courseId == null) return;

    final clock = ref.read(clockProvider);
    final notifier = ref.read(calendarNotifierProvider.notifier);
    final hari = notifier.selectedDay;
    final mulai =
        DateTime(hari.year, hari.month, hari.day, _jam.hour, _jam.minute);
    final selesai = mulai.add(Duration(minutes: _durasiMenit));

    await notifier.tambahSesi(
      StudySession(
        id: 'session-${clock.now().millisecondsSinceEpoch}',
        courseId: courseId,
        mulai: mulai,
        selesai: selesai,
        sumber: SessionSource.manual,
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final courseRepo = ref.watch(courseRepositoryProvider);
    final courses = courseRepo.watchCourses().first;
    final paddingBawah = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: paddingBawah),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorTokens.moonstone.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n('ManualSession'),
              style: TextStyle(
                fontFamily: 'DM Serif Display',
                fontSize: 24,
                color: ColorTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _judulController,
              decoration: InputDecoration(
                labelText: l10n('SessionTitle'),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Course>>(
              future: courses,
              builder: (context, snapshot) {
                final daftar = snapshot.data ?? const <Course>[];
                return DropdownButtonFormField<String>(
                  initialValue: _courseId,
                  decoration: InputDecoration(
                    labelText: l10n('Subject'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: daftar
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.nama),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _courseId = value),
                );
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pilihJam,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n('StartTime'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '${_jam.hour.toString().padLeft(2, '0')}.${_jam.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: ColorTokens.textPrimary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final durasi in const [30, 45, 60, 90])
                  ChoiceChip(
                    label: Text('$durasi ${l10n('MinuteUnit')}'),
                    selected: _durasiMenit == durasi,
                    onSelected: (_) => setState(() => _durasiMenit = durasi),
                    backgroundColor:
                        ColorTokens.white.withValues(alpha: 0.8),
                    selectedColor: ColorTokens.moonstone,
                    labelStyle: TextStyle(
                      color: _durasiMenit == durasi
                          ? ColorTokens.textPrimary
                          : ColorTokens.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: ElevatedButton(
                onPressed: _simpan,
                child: Text(l10n('Save')),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
