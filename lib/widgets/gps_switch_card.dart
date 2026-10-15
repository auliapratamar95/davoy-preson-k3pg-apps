import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/attendance_provider.dart';
import 'badge_chip.dart';

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
          color: isStatic ? AppTheme.primary.withAlpha(100) : const Color(0xFFCBD5E1),
          width: isStatic ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isStatic ? AppTheme.primary.withAlpha(15) : Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Column(
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
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Switch ON / OFF Pill
                  GestureDetector(
                    onTap: () => attendance.toggleStaticGps(!isStatic),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isStatic ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isStatic ? 'ON' : 'OFF',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isStatic ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Switch.adaptive(
                    value: isStatic,
                    activeTrackColor: const Color(0xFF16A34A),
                    onChanged: (val) => attendance.toggleStaticGps(val),
                  ),
                ],
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
                        : 'OFF: Menggunakan hasil getLocation (${attendance.coordinates})',
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
          color: isStatic ? AppTheme.primary.withAlpha(120) : const Color(0xFFCBD5E1),
          width: isStatic ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isStatic ? AppTheme.primary.withAlpha(15) : Colors.black.withAlpha(8),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isStatic ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isStatic ? Icons.location_pin : Icons.my_location_rounded,
                      color: isStatic ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fitur Static GPS',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Payload Absen Masuk & Pulang',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated ON / OFF Pill Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isStatic ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isStatic ? const Color(0xFF86EFAC) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Text(
                      isStatic ? 'ON' : 'OFF',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isStatic ? const Color(0xFF15803D) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch.adaptive(
                    value: isStatic,
                    activeTrackColor: const Color(0xFF16A34A),
                    onChanged: (val) => attendance.toggleStaticGps(val),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Dual Segmented Selector Buttons: [ ON: Static K3PG ] | [ OFF: getLocation GPS ]
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => attendance.toggleStaticGps(true),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isStatic ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isStatic
                            ? [
                                BoxShadow(
                                  color: Colors.black.withAlpha(15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 15,
                            color: isStatic ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ON (Static K3PG)',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isStatic ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => attendance.toggleStaticGps(false),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !isStatic ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: !isStatic
                            ? [
                                BoxShadow(
                                  color: Colors.black.withAlpha(15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sensors_rounded,
                            size: 15,
                            color: !isStatic ? AppTheme.accent : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'OFF (getLocation)',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: !isStatic ? const Color(0xFF0F172A) : const Color(0xFF64748B),
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

          const Divider(height: 24, color: Color(0xFFE2E8F0)),

          // Body Description & Details based on Switch State
          if (isStatic) ...[
            // ==================== MODE: ON (STATIC) ====================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.business_rounded, size: 15, color: Color(0xFF16A34A)),
                          const SizedBox(width: 6),
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
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Koordinat: ${attendance.staticCoordinates} (Geofence <100m)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Text(
                          'Payload URL: &latitude=${attendance.staticCoordinates}',
                          style: GoogleFonts.sourceCodePro(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shuffle_rounded, size: 20, color: Color(0xFF16A34A)),
                      onPressed: attendance.randomizeStaticCoordinate,
                      tooltip: 'Acak Koordinat Baru (100m Geofence)',
                    ),
                    if (onSettingsTap != null)
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, size: 20, color: AppTheme.primary),
                        onPressed: onSettingsTap,
                        tooltip: 'Pilih Titik Spot',
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            BadgeChip.success(
              'STATUS: ON — Koordinat otomatis diacak dalam geofence 100m',
              icon: Icons.check_circle_rounded,
            ),
          ] else ...[
            // ==================== MODE: OFF (GETLOCATION) ====================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.sensors_rounded, size: 15, color: AppTheme.accent),
                          const SizedBox(width: 6),
                          Text(
                            'Hasil getLocation (Sensor Perangkat)',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Koordinat: ${attendance.coordinates}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Text(
                          'Payload URL: &latitude=${attendance.coordinates}',
                          style: GoogleFonts.sourceCodePro(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: attendance.isLoadingLocation
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded, color: AppTheme.accent),
                  onPressed: attendance.isLoadingLocation ? null : attendance.refreshLocation,
                  tooltip: 'Ambil Ulang Lokasi Realtime (getLocation)',
                ),
              ],
            ),
            if (attendance.locationError != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 14, color: AppTheme.danger),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        attendance.locationError!,
                        style: GoogleFonts.inter(fontSize: 11, color: AppTheme.danger),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            BadgeChip.info(
              'STATUS: OFF — Absen Masuk & Pulang menggunakan hasil getLocation',
              icon: Icons.my_location_rounded,
            ),
          ],
        ],
      ),
    );
  }
}
