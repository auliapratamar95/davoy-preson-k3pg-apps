class CounterModel {
  final int hadir;
  final int izin;
  final int sakit;
  final int terlambat;

  const CounterModel({
    this.hadir = 0,
    this.izin = 0,
    this.sakit = 0,
    this.terlambat = 0,
  });

  factory CounterModel.fromHtml(String html) {
    int parseDays(String keyword) {
      final reg = RegExp('$keyword<\\/strong>\\s*<p>(\\d+)\\s*[Hh]ari<\\/p>', caseSensitive: false);
      final match = reg.firstMatch(html);
      if (match != null) {
        return int.tryParse(match.group(1) ?? '0') ?? 0;
      }
      return 0;
    }

    return CounterModel(
      hadir: parseDays('Hadir'),
      izin: parseDays('Izin'),
      sakit: parseDays('Sakit'),
      terlambat: parseDays('Terlambat'),
    );
  }

  factory CounterModel.sample() {
    return const CounterModel(
      hadir: 9,
      izin: 0,
      sakit: 0,
      terlambat: 7,
    );
  }
}
