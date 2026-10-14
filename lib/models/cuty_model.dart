class CutyModel {
  final String id;
  final String employeeName;
  final String startDate;
  final String endDate;
  final int totalDays;
  final String description;
  final String status;

  const CutyModel({
    required this.id,
    required this.employeeName,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.description,
    this.status = 'Menunggu',
  });

  static List<CutyModel> fromHtml(String html) {
    final List<CutyModel> list = [];
    final itemRegex = RegExp(r'<div class="item">(.*?)<\/div>\s*<\/div>', dotAll: true);
    final items = itemRegex.allMatches(html).toList();

    for (final item in items) {
      final content = item.group(1) ?? '';
      final titleMatch = RegExp(r'<strong>(.*?)(?:<span|<\/strong>)', dotAll: true).firstMatch(content);
      final statusMatch = RegExp(r'badge[^>]*>([^<]+)<\/span>').firstMatch(content);
      final dateMatch = RegExp(r'calendar-outline"><\/ion-icon>\s*([^<]+)<br>', dotAll: true).firstMatch(content);
      final descMatch = RegExp(r'chatbubble-outline"><\/ion-icon>\s*([^<]+)<\/p>', dotAll: true).firstMatch(content);
      final idMatch = RegExp(r'data-id="([^"]*)"').firstMatch(content);

      list.add(CutyModel(
        id: idMatch?.group(1) ?? '1',
        employeeName: titleMatch?.group(1)?.trim() ?? 'WULAN SETYA PUTRI',
        startDate: dateMatch?.group(1)?.split('-').first.trim() ?? '-',
        endDate: dateMatch?.group(1)?.split('-').last.trim() ?? '-',
        totalDays: 1,
        description: descMatch?.group(1)?.trim() ?? '-',
        status: statusMatch?.group(1)?.trim() ?? 'Menunggu',
      ));
    }

    return list;
  }

  static List<CutyModel> sampleList() {
    return const [
      CutyModel(
        id: '1',
        employeeName: 'WULAN SETYA PUTRI',
        startDate: '10-11-2026',
        endDate: '12-11-2026',
        totalDays: 3,
        description: 'Cuti Tahunan Keperluan Keluarga',
        status: 'Disetujui',
      ),
    ];
  }
}
