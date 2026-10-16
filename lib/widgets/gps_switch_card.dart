import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/attendance_provider.dart';

class GpsSwitchCard extends StatelessWidget {
  final bool compact;
  final VoidCallback? onSettingsTap;

  const GpsSwitchCard({
    super.key,
    this.compact = false,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();

    if (compact) {
      return _buildCompactCard(context, attendance);
    }
    return _buildFullCard(context, attendance);
  }

  Widget _buildCompactCard(BuildContext context, AttendanceProvider attendance) {
    final isStatic = attendance.isStaticGps;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isStatic ? const Color(0xFF16A34A).withAlpha(80) : const Color(0xFFCBD5E1),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isStatic ? const Color(0xFF16A34A).withAlpha(15) : Colors.black.withAlpha(6),
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
                  color: isStatic ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isStatic ? Icons.location_pin : Icons.my_location_rounded,
                  color: isStatic ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Static GPS',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      isStatic ? 'Payload Kunci K3PG' : 'Sensor GPS Realtime',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Clean toggle switch without duplicate pill
              Transform.scale(
                scale: 0.85,
                child: Switch.adaptive(
                  value: isStatic,
                  activeTrackColor: const Color(0xFF16A34A),
                  onChanged: (val) => attendance.toggleStaticGps(val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isStatic ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isStatic ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isStatic ? Icons.check_circle_rounded : Icons.sensors_rounded,
                  size: 14,
                  color: isStatic ? const Color(0xFF16A34A) : AppTheme.accent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isStatic
                        ? 'ON: ${attendance.currentLocationLabel} (${attendance.staticCoordinates})'
                        : 'OFF: GPS Perangkat (${attendance.coordinates})',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isStatic ? const Color(0xFF15803D) : const Color(0xFF334155),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isStatic)
                  InkWell(
                    onTap: attendance.randomizeStaticCoordinate,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shuffle_rounded, size: 14, color: Color(0xFF16A34A)),
                          const SizedBox(width: 3),
                          Text(
                            'Acak',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  InkWell(
                    onTap: attendance.isLoadingLocation ? null : attendance.refreshLocation,
                    child: attendance.isLoadingLocation
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 1.5),
                          )
                        : const Icon(Icons.refresh_rounded, size: 16, color: AppTheme.accent),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullCard(BuildContext context, AttendanceProvider attendance) {
    final isStatic = attendance.isStaticGps;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isStatic ? const Color(0xFF16A34A).withAlpha(80) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isStatic ? const Color(0xFF16A34A).withAlpha(15) : Colors.black.withAlpha(6),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Clean, overlapping switch removed)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isStatic ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isStatic ? Icons.location_on_rounded : Icons.sensors_rounded,
                  color: isStatic ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Mode Lokasi GPS',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isStatic ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isStatic ? const Color(0xFF86EFAC) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Text(
                            isStatic ? 'Static Aktif' : 'GPS Sensor',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isStatic ? const Color(0xFF15803D) : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pilih sumber koordinat yang dikirim saat presensi',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Dual Segmented Selector Tab (Primary toggle)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // TAB 1: ON (Static K3PG)
                Expanded(
                  child: InkWell(
                    onTap: () => attendance.toggleStaticGps(true),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isStatic ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isStatic
                            ? [
                                BoxShadow(
                                  color: Colors.black.withAlpha(12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isStatic ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 16,
                            color: isStatic ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              'ON (Static K3PG)',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: isStatic ? FontWeight.w700 : FontWeight.w600,
                                color: isStatic ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // TAB 2: OFF (Sensor GPS)
                Expanded(
                  child: InkWell(
                    onTap: () => attendance.toggleStaticGps(false),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !isStatic ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: !isStatic
                            ? [
                                BoxShadow(
                                  color: Colors.black.withAlpha(12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            !isStatic ? Icons.sensors_rounded : Icons.radio_button_unchecked_rounded,
                            size: 16,
                            color: !isStatic ? AppTheme.accent : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              'OFF (GPS Sensor)',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: !isStatic ? FontWeight.w700 : FontWeight.w600,
                                color: !isStatic ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Detail Section based on active mode
          if (isStatic) ...[
            // Mode ON: Static GPS
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.business_rounded, size: 16, color: Color(0xFF16A34A)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${AttendanceProvider.kStaticLocationName} — ${attendance.currentLocationLabel}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onSettingsTap != null) ...[
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: onSettingsTap,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF86EFAC)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.tune_rounded, size: 13, color: Color(0xFF16A34A)),
                                const SizedBox(width: 4),
                                Text(
                                  'Pilih Spot',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF15803D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Koordinat: ${attendance.staticCoordinates}',
                          style: GoogleFonts.sourceCodePro(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF15803D),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: attendance.randomizeStaticCoordinate,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.shuffle_rounded, size: 13, color: Color(0xFF15803D)),
                              const SizedBox(width: 4),
                              Text(
                                'Acak',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, size: 13, color: Color(0xFF16A34A)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Geofence <100m • Otomatis diacak saat masuk & pulang',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF166534),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            // Mode OFF: GPS Sensor Realtime
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sensors_rounded, size: 16, color: AppTheme.accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sensor GPS Perangkat',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: attendance.isLoadingLocation ? null : attendance.refreshLocation,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              attendance.isLoadingLocation
                                  ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(strokeWidth: 1.5),
                                    )
                                  : const Icon(Icons.refresh_rounded, size: 13, color: AppTheme.accent),
                              const SizedBox(width: 4),
                              Text(
                                'Ambil Ulang',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Koordinat: ${attendance.coordinates}',
                    style: GoogleFonts.sourceCodePro(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (attendance.locationError != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      attendance.locationError!,
                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.danger),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Presensi akan mengirim koordinat asli yang dideteksi perangkat',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
