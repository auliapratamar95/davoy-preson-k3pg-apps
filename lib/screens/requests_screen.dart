import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/requests_provider.dart';
import '../widgets/badge_chip.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddDialog(BuildContext context, int tabIndex) {
    final auth = context.read<AuthProvider>();
    final requests = context.read<RequestsProvider>();
    final employeeName = auth.currentUser?.name ?? 'WULAN SETYA PUTRI';

    final startController = TextEditingController(text: DateFormat('dd-MM-yyyy').format(DateTime.now()));
    final endController = TextEditingController(text: DateFormat('dd-MM-yyyy').format(DateTime.now()));
    final descController = TextEditingController();
    final totalDaysController = TextEditingController(text: '1');

    // For job
    final startTimeController = TextEditingController(text: '08:00');
    final endTimeController = TextEditingController(text: '16:00');
    final percentageController = TextEditingController(text: '100');
    String selectedNature = 'RUTIN';

    String title;
    switch (tabIndex) {
      case 0:
        title = 'Pengajuan SPPD';
        break;
      case 1:
        title = 'Pengajuan Cuti';
        break;
      case 2:
        title = 'Pengajuan Izin';
        break;
      default:
        title = 'Laporan Pekerjaan';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
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
                Text(
                  'Pemohon: $employeeName',
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),

                if (tabIndex == 3) ...[
                  // Job specific fields
                  Text('Tanggal Pekerjaan', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(controller: startController, decoration: const InputDecoration(hintText: 'DD-MM-YYYY')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jam Mulai', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            TextField(controller: startTimeController, decoration: const InputDecoration(hintText: '08:00')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Jam Selesai', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            TextField(controller: endTimeController, decoration: const InputDecoration(hintText: '16:00')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Sifat Pekerjaan', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedNature,
                    decoration: const InputDecoration(),
                    items: ['RUTIN', 'PERIODIK', 'INSIDENTIL'].map((n) {
                      return DropdownMenuItem(value: n, child: Text(n));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setSheetState(() => selectedNature = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('Persentase Selesai (%)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(controller: percentageController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '1 - 100')),
                  const SizedBox(height: 12),
                  Text('Deskripsi Pekerjaan', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(controller: descController, maxLines: 2, decoration: const InputDecoration(hintText: 'Rincian tugas dan hasil')),
                ] else ...[
                  // SPPD, Cuti, Izin fields
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tanggal Mulai', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            TextField(controller: startController, decoration: const InputDecoration(hintText: 'DD-MM-YYYY')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tanggal Selesai', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            TextField(controller: endController, decoration: const InputDecoration(hintText: 'DD-MM-YYYY')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (tabIndex == 1) ...[
                    const SizedBox(height: 12),
                    Text('Total Hari Cuti', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(controller: totalDaysController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Jumlah hari')),
                  ],
                  const SizedBox(height: 12),
                  Text('Keterangan / Alasan', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(controller: descController, maxLines: 3, decoration: const InputDecoration(hintText: 'Tuliskan rincian keperluan secara jelas')),
                ],

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    bool ok = false;
                    if (tabIndex == 0) {
                      ok = await requests.createSppd(
                        name: employeeName,
                        startDate: startController.text,
                        endDate: endController.text,
                        description: descController.text,
                      );
                    } else if (tabIndex == 1) {
                      ok = await requests.createCuty(
                        name: employeeName,
                        startDate: startController.text,
                        endDate: endController.text,
                        totalDays: int.tryParse(totalDaysController.text) ?? 1,
                        description: descController.text,
                      );
                    } else if (tabIndex == 2) {
                      ok = await requests.createIzin(
                        name: employeeName,
                        startDate: startController.text,
                        endDate: endController.text,
                        description: descController.text,
                      );
                    } else {
                      ok = await requests.createJob(
                        name: employeeName,
                        date: startController.text,
                        startTime: startTimeController.text,
                        endTime: endTimeController.text,
                        job: descController.text,
                        percentage: int.tryParse(percentageController.text) ?? 100,
                        nature: selectedNature,
                      );
                    }

                    if (context.mounted && ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$title berhasil diajukan'),
                          backgroundColor: AppTheme.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text('Kirim Pengajuan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<RequestsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Segmented Tabs Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primary,
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: AppTheme.primary,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13),
              tabs: const [
                Tab(text: 'SPPD'),
                Tab(text: 'Cuti'),
                Tab(text: 'Izin'),
                Tab(text: 'Pekerjaan'),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Tab Views
          Expanded(
            child: requests.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // SPPD Tab
                      _buildSppdList(requests),
                      // Cuti Tab
                      _buildCutyList(requests),
                      // Izin Tab
                      _buildIzinList(requests),
                      // Pekerjaan Tab
                      _buildJobList(requests),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, _tabController.index),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Buat Baru',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildSppdList(RequestsProvider requests) {
    if (requests.sppdList.isEmpty) {
      return _buildEmptyState('Belum ada data SPPD');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: requests.sppdList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final item = requests.sppdList[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.code,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  BadgeChip.success(item.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                item.employeeName,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    item.dateRange,
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.description_outlined, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.description,
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF334155)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCutyList(RequestsProvider requests) {
    if (requests.cutyList.isEmpty) {
      return _buildEmptyState('Belum ada riwayat cuti');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: requests.cutyList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final item = requests.cutyList[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cuti ${item.totalDays} Hari',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                  ),
                  BadgeChip.warning(item.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.date_range_rounded, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text('${item.startDate} s.d ${item.endDate}', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                ],
              ),
              const SizedBox(height: 4),
              Text(item.description, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF334155))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIzinList(RequestsProvider requests) {
    if (requests.izinList.isEmpty) {
      return _buildEmptyState('Belum ada pengajuan izin');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: requests.izinList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final item = requests.izinList[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pengajuan Izin',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                  ),
                  BadgeChip.info(item.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.date_range_rounded, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text('${item.startDate} - ${item.endDate}', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                ],
              ),
              const SizedBox(height: 4),
              Text(item.description, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF334155))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJobList(RequestsProvider requests) {
    if (requests.jobList.isEmpty) {
      return _buildEmptyState('Belum ada laporan pekerjaan');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: requests.jobList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final item = requests.jobList[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BadgeChip.info(item.nature),
                  Text(
                    '${item.percentage}% Selesai',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    '${item.date}  •  ${item.startTime} - ${item.endTime}',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 52, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
