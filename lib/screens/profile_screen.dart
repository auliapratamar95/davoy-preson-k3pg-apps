import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showChangePasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ubah Kata Sandi',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Kata Sandi Baru', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Minimal 6 karakter'),
            ),
            const SizedBox(height: 14),
            Text('Konfirmasi Kata Sandi', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Ulangi kata sandi baru'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (passwordController.text.isEmpty) {
                  return;
                }
                if (passwordController.text != confirmController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Konfirmasi kata sandi tidak cocok'),
                      backgroundColor: AppTheme.danger,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final auth = context.read<AuthProvider>();
                final ok = await auth.updatePassword(passwordController.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'Kata sandi berhasil diperbarui' : 'Gagal memperbarui kata sandi'),
                      backgroundColor: ok ? AppTheme.success : AppTheme.danger,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProxySettingsDialog(BuildContext context) {
    final proxyController = TextEditingController(text: ApiService().customProxyUrl ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Pengaturan Server & Proxy',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target default adalah: https://preson.k3pg.co.id.\n\nJika menggunakan local CORS proxy di web, masukkan alamatnya di bawah ini (misal http://localhost:8080):',
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: proxyController,
              decoration: const InputDecoration(
                hintText: 'http://localhost:8080 (Opsional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ApiService().customProxyUrl = null;
              Navigator.pop(ctx);
            },
            child: const Text('Reset Default'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = proxyController.text.trim();
              ApiService().customProxyUrl = val.isEmpty ? null : val;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pengaturan proxy disimpan'), behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Profile Avatar & Main Info Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: const Color(0xFFF1F5F9),
                      backgroundImage: const AssetImage('assets/images/avatar.jpg'),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  user?.name ?? 'WULAN SETYA PUTRI',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.code ?? 'K-19030',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Koperasi Konsumen Karyawan Petrokimia Gresik (K3PG)',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Details List Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.badge_outlined,
                  title: 'ID Anggota / Karyawan',
                  value: user?.code ?? 'K-19030',
                ),
                const Divider(height: 1, indent: 56),
                _buildInfoTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Nama Lengkap',
                  value: user?.name ?? 'WULAN SETYA PUTRI',
                ),
                const Divider(height: 1, indent: 56),
                _buildInfoTile(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: user?.email ?? 'wulan.setya@k3pg.co.id',
                ),
                const Divider(height: 1, indent: 56),
                _buildInfoTile(
                  icon: Icons.phone_outlined,
                  title: 'Nomor Telepon',
                  value: user?.phone ?? '+62 812-3456-7890',
                ),
                const Divider(height: 1, indent: 56),
                _buildInfoTile(
                  icon: Icons.location_on_outlined,
                  title: 'Alamat Domisili',
                  value: user?.address ?? 'Gresik, Jawa Timur',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Settings Action Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lock_reset_rounded, color: AppTheme.primary, size: 20),
                  ),
                  title: Text(
                    'Ubah Kata Sandi',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                  onTap: () => _showChangePasswordDialog(context),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.dns_rounded, color: AppTheme.accent, size: 20),
                  ),
                  title: Text(
                    'Konfigurasi Proxy Server',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                  onTap: () => _showProxySettingsDialog(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text('Konfirmasi Keluar', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                    content: const Text('Apakah Anda yakin ingin keluar dari akun DAVOY?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          auth.logout();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                        child: const Text('Keluar'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout_rounded, color: AppTheme.danger),
              label: Text(
                'Keluar dari Akun',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.danger,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.5),
                backgroundColor: const Color(0xFFFFF1F2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF64748B), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
