class HistoryModel {
  final String id;
  final String date;
  final String timeIn;
  final String timeOut;
  final String photoIn;
  final String photoOut;
  final String status;
  final bool isLate;
  final bool isEarlyLeave;
  final String information;

  const HistoryModel({
    required this.id,
    required this.date,
    required this.timeIn,
    required this.timeOut,
    this.photoIn = '',
    this.photoOut = '',
    this.status = 'Hadir',
    this.isLate = false,
    this.isEarlyLeave = false,
    this.information = '',
  });

  static List<HistoryModel> fromHtml(String html) {
    final List<HistoryModel> list = [];
    final rowRegex = RegExp(r'<tr[^>]*>(.*?)<\/tr>', dotAll: true);
    final rows = rowRegex.allMatches(html).toList();

    for (final row in rows) {
      final rowContent = row.group(1) ?? '';
      if (rowContent.contains('<th scope="col"') || !rowContent.contains('data-id=')) {
        continue;
      }

      // Extract data-id, data-masuk, data-pulang, data-date, data-information
      final idMatch = RegExp(r'data-id="([^"]*)"').firstMatch(rowContent);
      final masukMatch = RegExp(r'data-masuk="([^"]*)"').firstMatch(rowContent);
      final pulangMatch = RegExp(r'data-pulang="([^"]*)"').firstMatch(rowContent);
      final dateMatch = RegExp(r'data-date="([^"]*)"').firstMatch(rowContent);
      final infoMatch = RegExp(r'data-information="([^"]*)"').firstMatch(rowContent);

      final rowDateMatch = RegExp(r'<th\s+scope="row">\s*([^<]+)\s*<\/th>').firstMatch(rowContent);

      // Photos
      final photoMatches = RegExp(r'href="(\.\/sw-content\/absent\/[^"]+)"').allMatches(rowContent).toList();
      String photoIn = '';
      String photoOut = '';
      if (photoMatches.isNotEmpty) {
        photoIn = photoMatches[0].group(1) ?? '';
        if (photoMatches.length > 1) {
          photoOut = photoMatches[1].group(1) ?? '';
        }
      }

      final isLate = rowContent.contains('Telat');
      final isEarly = rowContent.contains('Pulang Cepat');

      final dateStr = (dateMatch?.group(1)?.isNotEmpty == true)
          ? dateMatch!.group(1)!
          : (rowDateMatch?.group(1)?.trim() ?? '-');

      list.add(HistoryModel(
        id: idMatch?.group(1) ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date: dateStr,
        timeIn: masukMatch?.group(1) ?? '00:00:00',
        timeOut: pulangMatch?.group(1) ?? '00:00:00',
        photoIn: photoIn.replaceFirst('./', 'https://preson.k3pg.co.id/'),
        photoOut: photoOut.replaceFirst('./', 'https://preson.k3pg.co.id/'),
        status: 'Hadir',
        isLate: isLate,
        isEarlyLeave: isEarly,
        information: infoMatch?.group(1) ?? '',
      ));
    }

    return list;
  }

  static List<HistoryModel> sampleList() {
    return const [
      HistoryModel(
        id: '230932652',
        date: '14 Okt 2026',
        timeIn: '07:26:39',
        timeOut: '00:00:00',
        photoIn: 'https://preson.k3pg.co.id/sw-content/absent/2026-10-14-in-1791937600-72.jpeg',
        photoOut: '',
        status: 'Hadir',
        isLate: true,
        isEarlyLeave: false,
      ),
      HistoryModel(
        id: '230932354',
        date: '13 Okt 2026',
        timeIn: '07:29:05',
        timeOut: '19:51:28',
        photoIn: 'https://preson.k3pg.co.id/sw-content/absent/2026-10-13-in-1791851346-72.jpeg',
        photoOut: 'https://preson.k3pg.co.id/sw-content/absent/2026-10-13-out-1791895889-72.jpeg',
        status: 'Hadir',
        isLate: true,
        isEarlyLeave: false,
      ),
      HistoryModel(
        id: '230932011',
        date: '12 Okt 2026',
        timeIn: '06:59:58',
        timeOut: '19:17:30',
        photoIn: 'https://preson.k3pg.co.id/sw-content/absent/2026-10-12-in-1791763198-72.jpeg',
        photoOut: 'https://preson.k3pg.co.id/sw-content/absent/2026-10-12-out-1791807451-72.jpeg',
        status: 'Hadir',
        isLate: false,
        isEarlyLeave: false,
      ),
      HistoryModel(
        id: '230931438',
        date: '09 Okt 2026',
        timeIn: '05:59:17',
        timeOut: '20:45:45',
        photoIn: 'https://preson.k3pg.co.id/sw-content/absent/2026-10-09-in-1791500357-72.jpeg',
        photoOut: 'https://preson.k3pg.co.id/sw-content/absent/2026-10-09-out-1791553545-72.jpeg',
        status: 'Hadir',
        isLate: false,
        isEarlyLeave: false,
      ),
      HistoryModel(
        id: '230931246',
        date: '08 Okt 2026',
        timeIn: '07:23:08',
        timeOut: '19:41:15',
        photoIn: 'https://preson.k3pg.co.id/sw-content/absent/2026-10-08-in-1791418989-72.jpeg',
        photoOut: 'https://preson.k3pg.co.id/sw-content/absent/2026-10-08-out-1791463276-72.jpeg',
        status: 'Hadir',
        isLate: true,
        isEarlyLeave: false,
      ),
      HistoryModel(
        id: '230930937',
        date: '07 Okt 2026',
        timeIn: '07:09:58',
        timeOut: '19:15:47',
        photoIn: 'https://preson.k3pg.co.id/sw-content/absent/2026-10-07-in-1791331798-72.jpeg',
        photoOut: 'https://preson.k3pg.co.id/sw-content/absent/2026-10-07-out-1791375348-72.jpeg',
        status: 'Hadir',
        isLate: true,
        isEarlyLeave: false,
      ),
    ];
  }
}
