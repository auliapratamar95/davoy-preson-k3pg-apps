class SppdModel {
  final String code;
  final String employeeName;
  final String dateRange;
  final String description;
  final String status;

  const SppdModel({
    required this.code,
    required this.employeeName,
    required this.dateRange,
    required this.description,
    this.status = 'Disetujui',
  });

  static List<SppdModel> fromHtml(String html) {
    final List<SppdModel> list = [];
    final itemRegex = RegExp(r'<div class="item">(.*?)<\/div>\s*<\/div>', dotAll: true);
    final items = itemRegex.allMatches(html).toList();

    for (final item in items) {
      final content = item.group(1) ?? '';
      final titleMatch = RegExp(r'<strong>(.*?)(?:<span|<\/strong>)', dotAll: true).firstMatch(content);
      final statusMatch = RegExp(r'badge[^>]*>([^<]+)<\/span>').firstMatch(content);
      final dateMatch = RegExp(r'calendar-outline"><\/ion-icon>\s*([^<]+)<br>', dotAll: true).firstMatch(content);
      final descMatch = RegExp(r'chatbubble-outline"><\/ion-icon>\s*([^<]+)<\/p>', dotAll: true).firstMatch(content);

      final fullTitle = titleMatch?.group(1)?.trim() ?? '';
      String code = 'SPPD';
      String name = 'Karyawan';
      if (fullTitle.contains('-')) {
        final parts = fullTitle.split('-');
        code = parts[0].trim();
        name = parts.sublist(1).join('-').trim();
      } else {
        name = fullTitle;
      }

      list.add(SppdModel(
        code: code,
        employeeName: name,
        dateRange: dateMatch?.group(1)?.trim() ?? '-',
        description: descMatch?.group(1)?.trim() ?? '-',
        status: statusMatch?.group(1)?.trim() ?? 'Menunggu',
      ));
    }

    if (list.isEmpty) {
      return sampleList();
    }
    return list;
  }

  static List<SppdModel> sampleList() {
    return const [
      SppdModel(
        code: 'SPD10250028',
        employeeName: 'WULAN SETYA PUTRI',
        dateRange: '22-10-2025 - 23-10-2025',
        description: 'Pendidikan Mediator 2025',
        status: 'Disetujui',
      ),
      SppdModel(
        code: 'SPD09250012',
        employeeName: 'WULAN SETYA PUTRI',
        dateRange: '15-09-2025 - 16-09-2025',
        description: 'Rapat Koordinasi Wilayah Timur',
        status: 'Selesai',
      ),
    ];
  }
}
