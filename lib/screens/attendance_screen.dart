import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/api_constants.dart';
import '../config/theme.dart';
import '../providers/attendance_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/gps_switch_card.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  void _showEditStaticGpsDialog(BuildContext context, AttendanceProvider attendance) {
    final latController = TextEditingController(text: attendance.staticLatitude);
    final lngController = TextEditingController(text: attendance.staticLongitude);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.pin_drop_rounded, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
              'Atur Koordinat Static GPS',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Koordinat ini otomatis disisipkan ke payload query "latitude" saat Absen Masuk maupun Absen Pulang.',
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            Text('Latitude', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: latController,
              decoration: const InputDecoration(hintText: '-7.157700'),
            ),
            const SizedBox(height: 12),
            Text('Longitude', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: lngController,
              decoration: const InputDecoration(hintText: '112.642500'),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {
                latController.text = AttendanceProvider.kDefaultStaticLatitude;
                lngController.text = AttendanceProvider.kDefaultStaticLongitude;
              },
              icon: const Icon(Icons.restore_rounded, size: 16),
              label: const Text('Reset ke Kantor Pusat K3PG'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              attendance.setStaticCoordinates(latController.text, lngController.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Koordinat Static GPS berhasil disimpan'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Screen Header
          Text(
            'Presensi Kehadiran',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ambil foto selfie dan pastikan lokasi koordinat presensi Anda valid',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 18),

          // Camera Selfie Box
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (attendance.capturedImageBytes != null)
                  Image.memory(
                    attendance.capturedImageBytes!,
                    fit: BoxFit.cover,
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_enhance_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Kamera Depan Diperlukan',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ketuk tombol di bawah untuk mengambil selfie',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),

                // Top camera badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(120),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: attendance.capturedImageBytes != null ? AppTheme.success : AppTheme.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          attendance.capturedImageBytes != null ? 'Foto Siap' : 'Belum Ada Foto',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),

                // Retake button if captured
                if (attendance.capturedImageBytes != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: InkWell(
                      onTap: attendance.clearSelfie,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(140),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Capture selfie trigger button
          OutlinedButton.icon(
            onPressed: attendance.takeSelfie,
            icon: const Icon(Icons.camera_alt_outlined, size: 20),
            label: Text(
              attendance.capturedImageBytes != null ? 'Ambil Ulang Foto Selfie' : 'Ambil Foto Selfie',
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              side: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
          ),

          const SizedBox(height: 20),

          // Static GPS Feature Card with ON/OFF Switch
          GpsSwitchCard(
            compact: false,
            onSettingsTap: () => _showEditStaticGpsDialog(context, attendance),
          ),

          const SizedBox(height: 18),

          // Shift and Building Selectors
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shift Dropdown
                Text(
                  'Pilih Jam Kerja / Shift',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: attendance.selectedShiftId,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.access_time_rounded, color: Color(0xFF94A3B8)),
                  ),
                  items: ApiConstants.availableShifts.map((s) {
                    return DropdownMenuItem<String>(
                      value: s['id'],
                      child: Text(
                        '${s['name']} (${s['time']})',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) attendance.setShift(val);
                  },
                ),

                const SizedBox(height: 16),

                // Building Dropdown
                Text(
                  'Lokasi Gedung / Kantor',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: attendance.selectedBuildingId,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.apartment_rounded, color: Color(0xFF94A3B8)),
                  ),
                  items: ApiConstants.availableBuildings.map((b) {
                    return DropdownMenuItem<String>(
                      value: b['id'],
                      child: Text(
                        b['name']!,
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) attendance.setBuilding(val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Submit Attendance Button
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: attendance.isSubmitting
                  ? null
                  : () async {
                      final success = await attendance.submitAttendance();
                      if (context.mounted) {
                        if (success) {
                          // Immediately reload real history from server to sync data everywhere
                          context.read<HistoryProvider>().loadAllData();
                        }
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: Row(
                              children: [
                                Icon(
                                  success ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                                  color: success ? AppTheme.success : AppTheme.danger,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  success ? 'Presensi Berhasil!' : 'Perhatian',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  attendance.lastSubmitMessage ?? (success ? 'Kehadiran Anda berhasil tercatat.' : 'Gagal mengirim data presensi.'),
                                  style: GoogleFonts.inter(fontSize: 14),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Payload Koordinat Terkirim:',
                                        style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        attendance.effectiveCoordinates,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        attendance.isStaticGps ? 'Mode: Static GPS (Kantor Pusat K3PG)' : 'Mode: Sensor GPS Perangkat',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: attendance.isStaticGps ? AppTheme.success : AppTheme.accent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: success ? AppTheme.success : AppTheme.primary,
                                ),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: attendance.hasClockedOut
                    ? AppTheme.success
                    : (attendance.hasClockedIn ? const Color(0xFFDC2626) : AppTheme.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: attendance.isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          attendance.hasClockedOut
                              ? Icons.check_circle_rounded
                              : (attendance.hasClockedIn ? Icons.logout_rounded : Icons.login_rounded),
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          !attendance.hasClockedIn
                              ? 'Absen Masuk Sekarang'
                              : (!attendance.hasClockedOut ? 'Absen Pulang Sekarang' : 'Sudah Absen Masuk & Pulang'),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
