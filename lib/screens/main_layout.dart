import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../services/api_service.dart';
import '../widgets/responsive_wrapper.dart';
import 'attendance_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'requests_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'DAVOY';
      case 1:
        return 'Riwayat Presensi';
      case 2:
        return 'Absen Kehadiran';
      case 3:
        return 'Pengajuan & Tugas';
      case 4:
        return 'Profil Pengguna';
      default:
        return 'DAVOY';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLive = ApiService().isLiveConnected;

    final pages = [
      HomeScreen(onNavigateTab: _onTabSelected),
      const HistoryScreen(),
      const AttendanceScreen(),
      const RequestsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: ResponsiveWrapper(
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            elevation: 0.5,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo_icon.png',
                  height: 28,
                  width: 28,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.fingerprint_rounded,
                    color: AppTheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _getTitle(),
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            actions: [
              // Server status indicator pill
              Container(
                margin: const EdgeInsets.only(right: 14),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLive ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLive ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isLive ? AppTheme.success : AppTheme.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isLive ? 'Live' : 'Online',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isLive ? const Color(0xFF065F46) : const Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: _onTabSelected,
                backgroundColor: Colors.white,
                elevation: 0,
                indicatorColor: AppTheme.primaryLight,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primary),
                    label: 'Beranda',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.history_rounded),
                    selectedIcon: Icon(Icons.history_rounded, color: AppTheme.primary),
                    label: 'Riwayat',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.camera_alt_outlined),
                    selectedIcon: Icon(Icons.camera_alt_rounded, color: AppTheme.primary),
                    label: 'Absen',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.assignment_outlined),
                    selectedIcon: Icon(Icons.assignment_rounded, color: AppTheme.primary),
                    label: 'Pengajuan',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primary),
                    label: 'Profil',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
