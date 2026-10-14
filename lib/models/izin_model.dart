class IzinModel {
  final String id;
  final String employeeName;
  final String startDate;
  final String endDate;
  final String description;
  final String status;

  const IzinModel({
    required this.id,
    required this.employeeName,
    required this.startDate,
    required this.endDate,
    required this.description,
    this.status = 'Menunggu',
  });

  static List<IzinModel> fromHtml(String html) {
    final List<IzinModel> list = [];
    final itemRegex = RegExp(r'<div class="item">(.*?)<\/div>\s*<\/div>', dotAll: true);
    final items = itemRegex.allMatches(html).toList();

    for (final item in items) {
      final content = item.group(1) ?? '';
      final titleMatch = RegExp(r'<strong>(.*?)(?:<span|<\/strong>)', dotAll: true).firstMatch(content);
      final statusMatch = RegExp(r'badge[^>]*>([^<]+)<\/span>').firstMatch(content);
      final dateMatch = RegExp(r'calendar-outline"><\/ion-icon>\s*([^<]+)<br>', dotAll: true).firstMatch(content);
      final descMatch = RegExp(r'chatbubble-outline"><\/ion-icon>\s*([^<]+)<\/p>', dotAll: true).firstMatch(content);
      final idMatch = RegExp(r'data-id="([^"]*)"').firstMatch(content);

      list.add(IzinModel(
        id: idMatch?.group(1) ?? '1',
        employeeName: titleMatch?.group(1)?.trim() ?? 'WULAN SETYA PUTRI',
        startDate: dateMatch?.group(1)?.split('-').first.trim() ?? '-',
        endDate: dateMatch?.group(1)?.split('-').last.trim() ?? '-',
        description: descMatch?.group(1)?.trim() ?? '-',
        status: statusMatch?.group(1)?.trim() ?? 'Menunggu',
      ));
    }

    return list;
  }

  static List<IzinModel> sampleList() {
    return const [
      IzinModel(
        id: '1',
        employeeName: 'WULAN SETYA PUTRI',
        startDate: '05-10-2026',
        endDate: '05-10-2026',
        description: 'Izin Mengurus Dokumen Kependudukan',
        status: 'Disetujui',
      ),
    ];
  }
}
