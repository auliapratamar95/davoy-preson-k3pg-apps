class JobModel {
  final String id;
  final String date;
  final String startTime;
  final String endTime;
  final String title;
  final int percentage;
  final String nature; // RUTIN, PERIODIK, INSIDENTIL

  const JobModel({
    required this.id,
    required this.date,
    required this.startTime,
    this.endTime = '',
    required this.title,
    required this.percentage,
    required this.nature,
  });

  static List<JobModel> fromHtml(String html) {
    final List<JobModel> list = [];
    final itemRegex = RegExp(r'<div class="item">(.*?)<\/div>\s*<\/div>', dotAll: true);
    final items = itemRegex.allMatches(html).toList();

    for (final item in items) {
      final content = item.group(1) ?? '';
      final titleMatch = RegExp(r'<strong>(.*?)(?:<span|<\/strong>)', dotAll: true).firstMatch(content);
      final badgeMatch = RegExp(r'badge[^>]*>([^<]+)<\/span>').firstMatch(content);
      final idMatch = RegExp(r'data-id="([^"]*)"').firstMatch(content);

      list.add(JobModel(
        id: idMatch?.group(1) ?? '1',
        date: '14-10-2026',
        startTime: '08:00',
        endTime: '16:00',
        title: titleMatch?.group(1)?.trim() ?? 'Pekerjaan Harian',
        percentage: 100,
        nature: badgeMatch?.group(1)?.trim() ?? 'RUTIN',
      ));
    }

    if (list.isEmpty) {
      return sampleList();
    }
    return list;
  }

  static List<JobModel> sampleList() {
    return const [
      JobModel(
        id: '1',
        date: '14-10-2026',
        startTime: '07:30',
        endTime: '12:00',
        title: 'Rekonsiliasi data kehadiran dan administrasi operasional',
        percentage: 100,
        nature: 'RUTIN',
      ),
      JobModel(
        id: '2',
        date: '14-10-2026',
        startTime: '13:00',
        endTime: '16:00',
        title: 'Penyusunan berkas evaluasi berkala K3PG',
        percentage: 85,
        nature: 'PERIODIK',
      ),
    ];
  }
}
