import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/attendance_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/badge_chip.dart';
import '../widgets/gps_switch_card.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({
    super.key,
    required this.onNavigateTab,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final attendance = context.watch<AttendanceProvider>();
    final history = context.watch<HistoryProvider>();

    final user = auth.currentUser;
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);

    // Auto-sync attendance provider with real history from server
    if (history.historyList.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        attendance.syncWithHistory(history.historyList);
      });
    }

    final months = [
      {'val': '01', 'name': 'Januari'},
      {'val': '02', 'name': 'Februari'},
      {'val': '03', 'name': 'Maret'},
      {'val': '04', 'name': 'April'},
      {'val': '05', 'name': 'Mei'},
      {'val': '06', 'name': 'Juni'},
      {'val': '07', 'name': 'Juli'},
      {'val': '08', 'name': 'Agustus'},
      {'val': '09', 'name': 'September'},
      {'val': '10', 'name': 'Oktober'},
      {'val': '11', 'name': 'November'},
      {'val': '12', 'name': 'Desember'},
    ];

    return RefreshIndicator(
      onRefresh: () async {
        await history.loadAllData();
        await attendance.refreshLocation();
        attendance.syncWithHistory(history.historyList);
      },
      color: AppTheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Hero Banner Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withAlpha(80),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withAlpha(220),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.name ?? 'WULAN SETYA PUTRI',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      // Employee ID badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withAlpha(60)),
                        ),
                        child: Text(
                          user?.code ?? 'K-19030',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  Container(
                    height: 1,
                    color: Colors.white.withAlpha(40),
                  ),
                  const SizedBox(height: 16),

                  // Quick Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickAction(
                        icon: Icons.camera_alt_rounded,
                        label: 'Absen',
                        color: Colors.white,
                        bgColor: Colors.white.withAlpha(40),
                        onTap: () => onNavigateTab(2), // Attendance tab
                      ),
                      _buildQuickAction(
                        icon: Icons.calendar_month_rounded,
                        label: 'Cuti',
                        color: Colors.white,
                        bgColor: Colors.white.withAlpha(40),
                        onTap: () => onNavigateTab(3), // Requests tab
                      ),
                      _buildQuickAction(
                        icon: Icons.flight_takeoff_rounded,
                        label: 'SPPD',
                        color: Colors.white,
                        bgColor: Colors.white.withAlpha(40),
                        onTap: () => onNavigateTab(3), // Requests tab
                      ),
                      _buildQuickAction(
                        icon: Icons.person_rounded,
                        label: 'Profil',
                        color: Colors.white,
                        bgColor: Colors.white.withAlpha(40),
                        onTap: () => onNavigateTab(4), // Profile tab
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Interactive Static GPS Switch Card
            const GpsSwitchCard(compact: true),

            const SizedBox(height: 16),

            // Today's Status Cards (Absen Masuk & Absen Pulang)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => onNavigateTab(2),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: attendance.hasClockedIn ? const Color(0xFFE2E8F0) : AppTheme.primary.withAlpha(60),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.login_rounded, size: 16, color: Color(0xFF059669)),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Absen Masuk',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            attendance.todayTimeIn,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (attendance.hasClockedIn)
                            BadgeChip.success('Hadir')
                          else
                            BadgeChip.warning('Tap untuk Absen'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => onNavigateTab(2),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: attendance.hasClockedOut ? const Color(0xFFE2E8F0) : AppTheme.primary.withAlpha(60),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.logout_rounded, size: 16, color: Color(0xFFDC2626)),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Absen Pulang',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            attendance.todayTimeOut,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: attendance.hasClockedOut ? const Color(0xFF0F172A) : AppTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (attendance.hasClockedOut)
                            BadgeChip.success('Selesai')
                          else if (attendance.hasClockedIn)
                            BadgeChip.warning('Tap untuk Absen')
                          else
                            BadgeChip.neutral('Menunggu Masuk'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Monthly Attendance Section Title & Month Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik Kehadiran',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                // Month Selector Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: history.selectedMonth,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppTheme.primary),
                      isDense: true,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                      items: months.map((m) {
                        return DropdownMenuItem<String>(
                          value: m['val'],
                          child: Text('${m['name']} 2026'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          history.changeMonth(val);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 4 Stats Cards Grid
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Hadir',
                    value: '${history.counter.hadir} Hari',
                    icon: Icons.check_circle_outline_rounded,
                    color: const Color(0xFF059669),
                    backgroundColor: const Color(0xFFD1FAE5),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'Izin',
                    value: '${history.counter.izin} Hari',
                    icon: Icons.assignment_turned_in_outlined,
                    color: const Color(0xFF0284C7),
                    backgroundColor: const Color(0xFFE0F2FE),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Sakit',
                    value: '${history.counter.sakit} Hari',
                    icon: Icons.healing_outlined,
                    color: const Color(0xFFD97706),
                    backgroundColor: const Color(0xFFFEF3C7),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'Terlambat',
                    value: '${history.counter.terlambat} Hari',
                    icon: Icons.alarm_outlined,
                    color: const Color(0xFFDC2626),
                    backgroundColor: const Color(0xFFFEE2E2),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent 7 days Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1 Minggu Terakhir',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateTab(1), // Go to History tab
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // History mini list
            if (history.historyList.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  'Belum ada riwayat tercatat',
                  style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                ),
              )
            else
              ...history.historyList.take(5).map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.date,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Masuk: ${item.timeIn}  •  Pulang: ${item.timeOut == "00:00:00" ? "-" : item.timeOut}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item.isLate)
                        BadgeChip.danger('Telat')
                      else
                        BadgeChip.success('Tepat Waktu'),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
