import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/history_model.dart';
import '../providers/history_provider.dart';
import '../widgets/badge_chip.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  void _showPhotoDialog(BuildContext context, String title, String photoUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppTheme.primary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Image.network(
              photoUrl,
              height: 280,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: const Color(0xFFF1F5F9),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.broken_image_rounded, size: 40, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 8),
                    Text(
                      'Foto bukti presensi',
                      style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCorrectionSheet(BuildContext context, HistoryModel item) {
    final timeInController = TextEditingController(text: item.timeIn);
    final timeOutController = TextEditingController(text: item.timeOut == '00:00:00' ? '' : item.timeOut);
    final reasonController = TextEditingController();

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
                  'Koreksi Kehadiran',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            Text(
              'Tanggal: ${item.date}',
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            Text(
              'Jam Masuk',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: timeInController,
              decoration: const InputDecoration(hintText: 'HH:mm:ss'),
            ),
            const SizedBox(height: 12),
            Text(
              'Jam Pulang',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: timeOutController,
              decoration: const InputDecoration(hintText: 'HH:mm:ss'),
            ),
            const SizedBox(height: 12),
            Text(
              'Alasan / Keterangan',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'Jelaskan alasan koreksi presensi'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Permohonan koreksi presensi berhasil diajukan'),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Kirim Pengajuan Koreksi'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();

    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2027),
                      initialDateRange: history.filterStartDate != null && history.filterEndDate != null
                          ? DateTimeRange(start: history.filterStartDate!, end: history.filterEndDate!)
                          : null,
                    );
                    if (range != null) {
                      history.filterDateRange(range.start, range.end);
                    }
                  },
                  icon: const Icon(Icons.date_range_rounded, size: 16),
                  label: Text(
                    history.filterStartDate != null
                        ? '${DateFormat('d MMM').format(history.filterStartDate!)} - ${DateFormat('d MMM').format(history.filterEndDate!)}'
                        : 'Filter Rentang Tanggal',
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              if (history.filterStartDate != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.clear_rounded, color: AppTheme.danger),
                  onPressed: history.resetFilter,
                  tooltip: 'Reset Filter',
                ),
              ],
            ],
          ),
        ),

        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // History Records List
        Expanded(
          child: history.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                )
              : history.historyList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_toggle_off_rounded, size: 56, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'Tidak ada riwayat presensi ditemukan',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      itemCount: history.historyList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = history.historyList[index];

                        return Container(
                          padding: const EdgeInsets.all(16),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header date and edit button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.event_note_rounded, size: 16, color: AppTheme.primary),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        item.date,
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primary),
                                    onPressed: () => _showCorrectionSheet(context, item),
                                    tooltip: 'Ajukan Koreksi',
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Time In and Time Out row
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Masuk',
                                            style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                item.timeIn,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF0F172A),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              if (item.photoIn.isNotEmpty)
                                                InkWell(
                                                  onTap: () => _showPhotoDialog(context, 'Foto Masuk (${item.date})', item.photoIn),
                                                  child: const Icon(Icons.photo_camera_rounded, size: 16, color: AppTheme.primary),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          if (item.isLate)
                                            BadgeChip.danger('Telat')
                                          else
                                            BadgeChip.success('Tepat Waktu'),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Pulang',
                                            style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                item.timeOut == '00:00:00' ? '-' : item.timeOut,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF0F172A),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              if (item.photoOut.isNotEmpty)
                                                InkWell(
                                                  onTap: () => _showPhotoDialog(context, 'Foto Pulang (${item.date})', item.photoOut),
                                                  child: const Icon(Icons.photo_camera_rounded, size: 16, color: AppTheme.success),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          if (item.timeOut != '00:00:00')
                                            BadgeChip.success('Selesai')
                                          else
                                            BadgeChip.warning('Belum Pulang'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
