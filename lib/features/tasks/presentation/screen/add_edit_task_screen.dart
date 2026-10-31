import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_study_planner/core/models/task.dart';
import 'package:ai_study_planner/theme/components/ambient_background.dart';
import 'package:ai_study_planner/theme/components/glass_card.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';
import 'package:ai_study_planner/l10n/app_localizations.dart';

/// Layar form tambah atau ubah tugas dengan validasi.
class AddEditTaskScreen extends ConsumerStatefulWidget {
  const AddEditTaskScreen({super.key, this.task});

  final Task? task;

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulController;
  late final TextEditingController _catatanController;
  late final TextEditingController _estimasiController;
  late final TextEditingController _tenggatController;

  Priority _prioritas = Priority.sedang;
  TaskStatus _status = TaskStatus.belum;
  DateTime? _tenggat;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.task?.judul ?? '');
    _catatanController = TextEditingController(text: widget.task?.catatan ?? '');
    _estimasiController = TextEditingController(
      text: widget.task?.estimasiMenit.toString() ?? '',
    );
    _prioritas = widget.task?.prioritas ?? Priority.sedang;
    _status = widget.task?.status ?? TaskStatus.belum;
    _tenggat = widget.task?.tenggat;
    _tenggatController = TextEditingController(
      text: _tenggat != null ? '${_tenggat!.day}/${_tenggat!.month}/${_tenggat!.year}' : '',
    );
  }

  @override
  void dispose() {
    _judulController.dispose();
    _catatanController.dispose();
    _estimasiController.dispose();
    _tenggatController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tenggat ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _tenggat = picked;
        _tenggatController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(circleCount: 2),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                variant: GlassCardVariant.hero,
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.edit, size: 48, color: ColorTokens.moonstone),
                      const SizedBox(height: 24),
                      Text(
                        isEditing
                            ? AppLocalizations.messages['EditTaskTitle'] ?? 'Ubah Tugas'
                            : AppLocalizations.messages['AddTaskTitle'] ?? 'Tambah Tugas',
                        style: TextStyle(
                          fontFamily: 'DM Serif Display',
                          fontSize: 32,
                          color: ColorTokens.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _judulController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.messages['TaskTitle'] ?? 'Judul Tugas',
                          prefixIcon: const Icon(Icons.title, color: ColorTokens.moonstone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Judul tugas tidak boleh kosong.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: null,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.messages['TaskSubject'] ?? 'Mata Pelajaran',
                          prefixIcon: const Icon(Icons.book, color: ColorTokens.moonstone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'course-1', child: Text('Pemrograman Mobile')),
                          DropdownMenuItem(value: 'course-2', child: Text('Basis Data')),
                          DropdownMenuItem(value: 'course-3', child: Text('Jaringan Komputer')),
                          DropdownMenuItem(value: 'course-4', child: Text('Kecerdasan Buatan')),
                        ],
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _catatanController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.messages['TaskNotes'] ?? 'Catatan',
                          prefixIcon: const Icon(Icons.note, color: ColorTokens.moonstone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _tenggatController,
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.messages['TaskDueDate'] ?? 'Tenggat Waktu',
                          prefixIcon: const Icon(Icons.schedule, color: ColorTokens.moonstone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _estimasiController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.messages['TaskEstimate'] ?? 'Estimasi (menit)',
                          prefixIcon: const Icon(Icons.timer, color: ColorTokens.moonstone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Estimasi waktu tidak boleh kosong.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Priority>(
                        initialValue: _prioritas,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.messages['Priority'] ?? 'Prioritas',
                          prefixIcon: const Icon(Icons.flag, color: ColorTokens.moonstone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: Priority.values.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(_label(p)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _prioritas = value!),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate() && _tenggat != null) {
                              // TODO: kirim lewat TaskNotifier (update/add).
                              // ignore: unused_local_variable
                              final task = Task(
                                id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                courseId: 'course-1',
                                judul: _judulController.text,
                                catatan: _catatanController.text.isEmpty ? null : _catatanController.text,
                                tenggat: _tenggat!,
                                estimasiMenit: int.tryParse(_estimasiController.text) ?? 0,
                                prioritas: _prioritas,
                                status: _status,
                              );
                              if (isEditing) {
                                // TODO: update via notifier
                              } else {
                                // TODO: add via notifier
                              }
                              Navigator.pop(context);
                            }
                          },
                          child: Text(isEditing ? 'Simpan' : 'Tambah'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isEditing)
                        TextButton(
                          onPressed: () {},
                          child: const Text('Hapus', style: TextStyle(color: Color(0xFFBA1A1A))),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _label(Priority p) {
    switch (p) {
      case Priority.tinggi:
        return 'Tinggi';
      case Priority.sedang:
        return 'Sedang';
      case Priority.rendah:
        return 'Rendah';
    }
  }
}