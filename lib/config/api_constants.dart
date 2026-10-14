class ApiConstants {
  static const String baseUrl = 'https://preson.k3pg.co.id';
  
  // Endpoints
  static const String prosesUrl = '$baseUrl/sw-proses';
  static const String loginAction = 'login';
  static const String homeCounterAction = 'load-home-counter';
  static const String historyAction = 'history';
  static const String updateHistoryAction = 'update-history';
  static const String absentAction = 'absent';
  static const String profileAction = 'profile';
  static const String updatePasswordAction = 'update-password';
  static const String updatePhotoAction = 'update-photo';
  static const String cutyAction = 'cuty';
  static const String addCutyAction = 'add-cuty';
  static const String updateCutyAction = 'update-cuty';
  static const String izinAction = 'izin';
  static const String addIzinAction = 'add-izin';
  static const String updateIzinAction = 'update-izin';
  static const String sppdAction = 'sppd';
  static const String addSppdAction = 'add-sppd';
  static const String updateSppdAction = 'update-sppd';
  static const String jobAction = 'job';
  static const String addJobAction = 'add-job';
  static const String updateJobAction = 'update-job';
  static const String deleteJobAction = 'delete-job';
  static const String tugasAction = 'tugas';
  static const String logoutUrl = '$baseUrl/logout';

  // Assets
  static const String defaultAvatar = '$baseUrl/sw-content/avatar.jpg';
  static const String logoUrl = '$baseUrl/sw-content/pres_onpng.png';
  static const String absentPhotoBase = '$baseUrl/sw-content/absent';

  // Shifts list from PresOn
  static const List<Map<String, String>> availableShifts = [
    {'id': '1', 'name': 'FULL TIME', 'time': '07:00:00 s.d 16:00:00'},
    {'id': '14', 'name': 'FULL TIME JUMAT', 'time': '06:00:00 s.d 16:00:00'},
    {'id': '15', 'name': 'CS/OB SPBU 1', 'time': '06:00:00 s.d 14:00:00'},
    {'id': '16', 'name': 'CS/OB SPBU 2', 'time': '07:00:00 s.d 15:00:00'},
    {'id': '20', 'name': 'PROPERTY 6 HARI', 'time': '08:00:00 s.d 16:00:00'},
    {'id': '24', 'name': 'JOGLO FULL TIME', 'time': '07:00:00 s.d 21:00:00'},
    {'id': '10', 'name': 'SATPAM SPBU1 SHIFT 1', 'time': '07:00:00 s.d 14:00:00'},
    {'id': '11', 'name': 'SATPAM SPBU1 SHIFT 2', 'time': '15:00:00 s.d 22:00:00'},
    {'id': '12', 'name': 'SATPAM SPBU2 SHIFT 2', 'time': '15:00:00 s.d 23:00:00'},
    {'id': '13', 'name': 'SATPAM SPBU2 SHIFT 3', 'time': '23:00:00 s.d 07:00:00'},
    {'id': '8', 'name': 'SHIFT 1 JAM 7', 'time': '07:00:00 s.d 15:00:00'},
    {'id': '9', 'name': 'SHIFT 2 JAM 3', 'time': '15:00:00 s.d 23:00:00'},
    {'id': '6', 'name': 'SHIFT 3 JAM 11', 'time': '23:00:00 s.d 07:00:00'},
    {'id': '17', 'name': 'SPBU 1 SHIFT 1', 'time': '06:00:00 s.d 14:00:00'},
    {'id': '18', 'name': 'SPBU 1 SHIFT 2', 'time': '14:00:00 s.d 22:00:00'},
    {'id': '19', 'name': 'SPBU 1 SHIFT 3', 'time': '22:00:00 s.d 06:00:00'},
    {'id': '5', 'name': 'TOKO SHIFT 1', 'time': '07:00:00 s.d 14:00:00'},
    {'id': '7', 'name': 'TOKO SHIFT 2', 'time': '14:00:00 s.d 21:00:00'},
    {'id': '21', 'name': 'Tomoro Coffee I', 'time': '07:00:00 s.d 15:00:00'},
    {'id': '22', 'name': 'Tomoro Coffee II', 'time': '10:00:00 s.d 18:00:00'},
    {'id': '23', 'name': 'Tomoro Coffee III', 'time': '15:00:00 s.d 22:00:00'},
  ];

  // Buildings list from PresOn
  static const List<Map<String, String>> availableBuildings = [
    {'id': '1', 'name': 'Kantor Pusat'},
  ];
}
