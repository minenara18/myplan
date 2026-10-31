import 'package:flutter/material.dart';

import 'package:ai_study_planner/theme/app_theme.dart';
import 'package:ai_study_planner/theme/color_tokens.dart';

/// Sheet penyuntingan masukan rencana: tanggal mulai, tanggal sampai,
/// dan jendela jam waktu luang harian.
/// Kembali dengan record `(mulai, sampai, jamMulai, jamSelesai)`.
class AiSheetEditMasukan extends StatefulWidget {
  const AiSheetEditMasukan({
    super.key,
    required this.mulaiAwal,
    required this.sampaiAwal,
    required this.jamMulaiAwal,
    required this.jamSelesaiAwal,
  });

  final DateTime mulaiAwal;
  final DateTime sampaiAwal;
  final int jamMulaiAwal;
  final int jamSelesaiAwal;

  @override
  State<AiSheetEditMasukan> createState() => _AiSheetEditMasukanState();
}

class _AiSheetEditMasukanState extends State<AiSheetEditMasukan> {
  late DateTime _mulai;
  late DateTime _sampai;
  late TimeOfDay _jamMulai;
  late TimeOfDay _jamSelesai;

  @override
  void initState() {
    super.initState();
    _mulai = widget.mulaiAwal;
    _sampai = widget.sampaiAwal;
    _jamMulai = TimeOfDay(hour: widget.jamMulaiAwal, minute: 0);
    _jamSelesai = TimeOfDay(hour: widget.jamSelesaiAwal, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Ubah Masukan',
            style: TextStyle(
              fontFamily: AppTheme.dmSerifDisplay,
              fontSize: 20,
              color: ColorTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PemilihTile(
                  label: 'Mulai',
                  nilai: _showDate(_mulai),
                  ikon: Icons.today_outlined,
                  onTap: () => _pilihTanggal(pilihMulai: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PemilihTile(
                  label: 'Sampai',
                  nilai: _showDate(_sampai),
                  ikon: Icons.event_outlined,
                  onTap: () => _pilihTanggal(pilihMulai: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PemilihTile(
                  label: 'Jam luang mulai',
                  nilai: _jamMulai.format(context),
                  ikon: Icons.schedule_outlined,
                  onTap: () => _pilihJam(pilihMulai: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PemilihTile(
                  label: 'Jam luang selesai',
                  nilai: _jamSelesai.format(context),
                  ikon: Icons.nightlight_outlined,
                  onTap: () => _pilihJam(pilihMulai: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    foregroundColor: ColorTokens.textSecondary,
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    // Record hasil: (mulai, sampai, jamMulai, jamSelesai).
                    Navigator.of(context).pop((
                      DateTime(_mulai.year, _mulai.month, _mulai.day),
                      DateTime(_sampai.year, _sampai.month, _sampai.day),
                      _jamMulai.hour,
                      _jamSelesai.hour,
                    ));
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    backgroundColor: ColorTokens.moonstone,
                  ),
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _showDate(DateTime hari) =>
      '${hari.day} ${_namaBulan(hari.month)} ${hari.year}';

  static String _namaBulan(int bulan) => const [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ][bulan - 1];

  Future<void> _pilihTanggal({required bool pilihMulai}) async {
    final dipilih = await showDatePicker(
      context: context,
      initialDate: pilihMulai ? _mulai : _sampai,
      // Batas pilihan diturunkan dari tanggal yang sudah dipilih, tanpa waktu
      // sistem langsung — Clock milik notifier, bukan sheet.
      firstDate: widget.mulaiAwal.subtract(const Duration(days: 1)),
      lastDate: widget.mulaiAwal.add(const Duration(days: 60)),
    );
    if (dipilih == null) return;

    setState(() {
      if (pilihMulai) {
        _mulai = dipilih;
        if (_sampai.isBefore(dipilih)) _sampai = dipilih;
      } else {
        _sampai = dipilih;
      }
    });
  }

  Future<void> _pilihJam({required bool pilihMulai}) async {
    final dipilih = await showTimePicker(
      context: context,
      initialTime: pilihMulai ? _jamMulai : _jamSelesai,
    );
    if (dipilih == null) return;

    setState(() {
      if (pilihMulai) {
        _jamMulai = dipilih;
      } else {
        _jamSelesai = dipilih;
      }
    });
  }
}

/// Satu baris pemilih (tanggal / jam) bentuk tile tumpuk.
class _PemilihTile extends StatelessWidget {
  const _PemilihTile({
    required this.label,
    required this.nilai,
    required this.ikon,
    required this.onTap,
  });

  final String label;
  final String nilai;
  final IconData ikon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorTokens.moonstone.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(ikon, size: 18, color: ColorTokens.moonstone),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: AppTheme.inter,
                        fontSize: 10,
                        color: ColorTokens.textSecondary,
                      ),
                    ),
                    Text(
                      nilai,
                      style: const TextStyle(
                        fontFamily: AppTheme.inter,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ColorTokens.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
