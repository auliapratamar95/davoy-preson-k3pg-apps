import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.pin_drop_rounded, color: Color(0xFF16A34A), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Atur Static GPS',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Koordinat ini otomatis disisipkan ke payload query "latitude" saat Absen Masuk maupun Absen Pulang.',
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),
              Text(
                'Pilih Titik Spot (Radius <100m Geofence):',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: attendance.selectedCoordinateIndex < AttendanceProvider.kGeofenceCoordinates.length
                        ? attendance.selectedCoordinateIndex
                        : 0,
                    items: List.generate(
                      AttendanceProvider.kGeofenceCoordinates.length,
                      (i) {
                        final spot = AttendanceProvider.kGeofenceCoordinates[i];
                        return DropdownMenuItem<int>(
                          value: i,
                          child: Text(
                            '${spot['name']} (${spot['distance']})',
                            style: GoogleFonts.inter(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                    onChanged: (idx) {
                      if (idx != null) {
                        attendance.selectStaticPointByIndex(idx);
                        latController.text = attendance.staticLatitude;
                        lngController.text = attendance.staticLongitude;
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  attendance.randomizeStaticCoordinate();
                  latController.text = attendance.staticLatitude;
                  lngController.text = attendance.staticLongitude;
                },
                icon: const Icon(Icons.shuffle_rounded, size: 16),
                label: const Text('Acak Titik Koordinat (<100m)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 38),
                  textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),
              Text('Latitude', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: latController,
                style: GoogleFonts.sourceCodePro(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: '-7.157700',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              Text('Longitude', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: lngController,
                style: GoogleFonts.sourceCodePro(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: '112.642500',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF16A34A)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Koordinat otomatis selalu berganti saat Absen Masuk & Pulang agar variatif & valid.',
                        style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF166534)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Screen Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Presensi Kehadiran',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ambil foto selfie & pastikan koordinat valid',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: AppTheme.primary),
                    const SizedBox(width: 5),
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Daily Attendance Status Strip Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(6),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Masuk Status
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: attendance.hasClockedIn ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.login_rounded,
                          size: 16,
                          color: attendance.hasClockedIn ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Absen Masuk',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              attendance.hasClockedIn ? attendance.todayTimeIn : 'Belum Absen',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: attendance.hasClockedIn ? const Color(0xFF15803D) : const Color(0xFF94A3B8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                const SizedBox(width: 12),
                // Pulang Status
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: attendance.hasClockedOut ? const Color(0xFFE0E7FF) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.logout_rounded,
                          size: 16,
                          color: attendance.hasClockedOut ? const Color(0xFF4338CA) : const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Absen Pulang',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              attendance.hasClockedOut ? attendance.todayTimeOut : 'Belum Absen',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: attendance.hasClockedOut ? const Color(0xFF3730A3) : const Color(0xFF94A3B8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Interactive Camera Viewfinder
          GestureDetector(
            onTap: attendance.takeSelfie,
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: attendance.capturedImageBytes == null
                    ? const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: attendance.capturedImageBytes != null
                      ? const Color(0xFF16A34A).withAlpha(120)
                      : const Color(0xFF334155),
                  width: attendance.capturedImageBytes != null ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 16,
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
                        // Viewfinder center focus icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(15),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withAlpha(30), width: 1.5),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Ketuk untuk Ambil Foto Selfie',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pastikan wajah berada di area terang & jelas',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),

                  // Top Status Badge Overlay
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(140),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withAlpha(30)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: attendance.capturedImageBytes != null
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFF59E0B),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            attendance.capturedImageBytes != null ? 'Foto Siap Digunakan' : 'Kamera Depan',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Bar when photo is captured
                  if (attendance.capturedImageBytes != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withAlpha(180),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: attendance.takeSelfie,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(40),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withAlpha(50)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.refresh_rounded, size: 14, color: Colors.white),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Ambil Ulang',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: attendance.clearSelfie,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(140),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Static GPS Feature Card with Clean Dual Segmented Tab
          GpsSwitchCard(
            compact: false,
            onSettingsTap: () => _showEditStaticGpsDialog(context, attendance),
          ),

          const SizedBox(height: 16),

          // Shift and Building Selectors Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(6),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.tune_rounded, size: 16, color: AppTheme.accent),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Konfigurasi Presensi',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Shift Dropdown
                Text(
                  'Jam Kerja / Shift',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: attendance.selectedShiftId,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF64748B)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                  items: ApiConstants.availableShifts.map((s) {
                    return DropdownMenuItem<String>(
                      value: s['id'],
                      child: Text(
                        '${s['name']} (${s['time']})',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) attendance.setShift(val);
                  },
                ),

                const SizedBox(height: 14),

                // Building Dropdown
                Text(
                  'Lokasi Gedung / Kantor',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: attendance.selectedBuildingId,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.apartment_rounded, size: 18, color: Color(0xFF64748B)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                  items: ApiConstants.availableBuildings.map((b) {
                    return DropdownMenuItem<String>(
                      value: b['id'],
                      child: Text(
                        b['name']!,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 12),
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

          const SizedBox(height: 16),

          // Payload Verification Summary Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.my_location_rounded, size: 15, color: Color(0xFF475569)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payload Terkirim: ${attendance.effectiveCoordinates}',
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        attendance.isStaticGps ? 'Mode Static: Geofence Kantor K3PG (<100m)' : 'Mode: Sensor GPS Realtime',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: attendance.isStaticGps ? const Color(0xFF15803D) : AppTheme.accent,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, size: 12, color: Color(0xFF16A34A)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Submit Attendance Button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: attendance.isSubmitting
                  ? null
                  : () async {
                      if (attendance.capturedImageBytes == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Silakan ambil foto selfie terlebih dahulu sebelum presensi'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppTheme.warning,
                          ),
                        );
                        return;
                      }

                      final success = await attendance.submitAttendance();
                      if (context.mounted) {
                        if (success) {
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
                                Expanded(
                                  child: Text(
                                    success ? 'Presensi Berhasil!' : 'Perhatian',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  attendance.lastSubmitMessage ??
                                      (success ? 'Kehadiran Anda berhasil tercatat.' : 'Gagal mengirim data presensi.'),
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
                                        style: GoogleFonts.sourceCodePro(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        attendance.isStaticGps
                                            ? 'Mode: Static GPS (Kantor Pusat K3PG)'
                                            : 'Mode: Sensor GPS Perangkat',
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
                    ? const Color(0xFF64748B)
                    : (attendance.hasClockedIn ? const Color(0xFFDC2626) : const Color(0xFF16A34A)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
              child: attendance.isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          attendance.hasClockedOut
                              ? Icons.check_circle_rounded
                              : (attendance.hasClockedIn ? Icons.logout_rounded : Icons.login_rounded),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            !attendance.hasClockedIn
                                ? 'Kirim Presensi Masuk'
                                : (!attendance.hasClockedOut
                                    ? 'Kirim Presensi Pulang'
                                    : 'Presensi Hari Ini Selesai'),
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
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
