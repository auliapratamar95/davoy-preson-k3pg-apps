import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../models/history_model.dart';
import '../services/api_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  // Static GPS Coordinates for Kantor Pusat K3PG Center
  static const String kDefaultStaticLatitude = '-7.157700';
  static const String kDefaultStaticLongitude = '112.642500';
  static const String kStaticLocationName = 'Kantor Pusat K3PG';

  /// Array titik koordinat nyata di area Kantor Pusat K3PG dalam radius aman geofence (< 100 meter).
  /// Digunakan agar saat Absen Masuk dan Absen Pulang koordinatnya selalu berbeda & bervariasi.
  static const List<Map<String, dynamic>> kGeofenceCoordinates = [
    {
      'name': 'Gedung Utama (Pusat)',
      'lat': -7.157700,
      'lng': 112.642500,
      'distance': '0m (Titik Tengah)',
    },
    {
      'name': 'Lobby Utama Depan',
      'lat': -7.157520,
      'lng': 112.642610,
      'distance': '~23m dari pusat',
    },
    {
      'name': 'Pintu Masuk Barat',
      'lat': -7.157640,
      'lng': 112.642280,
      'distance': '~25m dari pusat',
    },
    {
      'name': 'Area Parkir Karyawan',
      'lat': -7.157880,
      'lng': 112.642390,
      'distance': '~23m dari pusat',
    },
    {
      'name': 'Sayap Timur Kantor',
      'lat': -7.157750,
      'lng': 112.642730,
      'distance': '~26m dari pusat',
    },
    {
      'name': 'Halaman Depan Gedung',
      'lat': -7.157430,
      'lng': 112.642450,
      'distance': '~30m dari pusat',
    },
    {
      'name': 'Pos Penjagaan & Gerbang',
      'lat': -7.157320,
      'lng': 112.642560,
      'distance': '~43m dari pusat',
    },
    {
      'name': 'Taman Samping Kantor',
      'lat': -7.157950,
      'lng': 112.642680,
      'distance': '~34m dari pusat',
    },
    {
      'name': 'Koridor Belakang Gedung',
      'lat': -7.157980,
      'lng': 112.642320,
      'distance': '~37m dari pusat',
    },
    {
      'name': 'Ruang Pelayanan K3PG',
      'lat': -7.157580,
      'lng': 112.642780,
      'distance': '~34m dari pusat',
    },
    {
      'name': 'Gedung Pertemuan',
      'lat': -7.157810,
      'lng': 112.642190,
      'distance': '~36m dari pusat',
    },
    {
      'name': 'Pintu Keluar Selatan',
      'lat': -7.158050,
      'lng': 112.642480,
      'distance': '~39m dari pusat',
    },
    {
      'name': 'Area Drop-off Depan',
      'lat': -7.157380,
      'lng': 112.642650,
      'distance': '~39m dari pusat',
    },
    {
      'name': 'Selasar Barat',
      'lat': -7.157550,
      'lng': 112.642180,
      'distance': '~39m dari pusat',
    },
    {
      'name': 'Area Parkir Motor',
      'lat': -7.157920,
      'lng': 112.642250,
      'distance': '~37m dari pusat',
    },
  ];

  bool _isStaticGps = true; // Aktif secara default untuk Kantor Pusat K3PG
  String _staticLatitude = kDefaultStaticLatitude;
  String _staticLongitude = kDefaultStaticLongitude;
  int _selectedCoordinateIndex = 0;
  String _currentLocationLabel = 'Gedung Utama (Pusat)';

  String _latitude = '-7.157700';
  String _longitude = '112.642500';
  bool _isLoadingLocation = false;
  String? _locationError;

  String _selectedShiftId = '1';
  String _selectedBuildingId = '1';

  Uint8List? _capturedImageBytes;
  bool _isSubmitting = false;
  String? _lastSubmitMessage;

  // Today's attendance state (dynamically synced from server history)
  String _todayTimeIn = 'Belum absen';
  String _todayTimeOut = 'Belum absen';
  bool _hasClockedIn = false;
  bool _hasClockedOut = false;

  // Static GPS getters
  bool get isStaticGps => _isStaticGps;
  String get staticLatitude => _staticLatitude;
  String get staticLongitude => _staticLongitude;
  String get staticCoordinates => '$_staticLatitude,$_staticLongitude';
  int get selectedCoordinateIndex => _selectedCoordinateIndex;
  String get currentLocationLabel => _currentLocationLabel;

  // Effective coordinates for API payload (Static if ON, getLocation if OFF)
  String get effectiveLatitude => _isStaticGps ? _staticLatitude : _latitude;
  String get effectiveLongitude => _isStaticGps ? _staticLongitude : _longitude;
  String get effectiveCoordinates => '$effectiveLatitude,$effectiveLongitude';
  String get activeGpsModeLabel => _isStaticGps ? 'Static GPS (ON)' : 'getLocation GPS (OFF)';

  // Real GPS device getters (from getLocation)
  String get latitude => _latitude;
  String get longitude => _longitude;
  String get coordinates => '$_latitude,$_longitude';
  bool get isLoadingLocation => _isLoadingLocation;
  String? get locationError => _locationError;

  String get selectedShiftId => _selectedShiftId;
  String get selectedBuildingId => _selectedBuildingId;
  Uint8List? get capturedImageBytes => _capturedImageBytes;
  bool get isSubmitting => _isSubmitting;
  String? get lastSubmitMessage => _lastSubmitMessage;

  String get todayTimeIn => _todayTimeIn;
  String get todayTimeOut => _todayTimeOut;
  bool get hasClockedIn => _hasClockedIn;
  bool get hasClockedOut => _hasClockedOut;

  AttendanceProvider() {
    randomizeStaticCoordinate(notify: false);
    refreshLocation();
  }

  void toggleStaticGps(bool enabled) {
    _isStaticGps = enabled;
    if (!enabled) {
      refreshLocation();
    } else {
      randomizeStaticCoordinate();
    }
    notifyListeners();
  }

  Future<void> getLocation() async {
    await refreshLocation();
  }

  void setStaticCoordinates(String lat, String lng, {String? label}) {
    _staticLatitude = lat.trim();
    _staticLongitude = lng.trim();
    if (label != null) {
      _currentLocationLabel = label;
    } else {
      _currentLocationLabel = 'Kustom';
    }
    notifyListeners();
  }

  /// Memilih salah satu titik geofence dari array
  void selectStaticPointByIndex(int index) {
    if (index >= 0 && index < kGeofenceCoordinates.length) {
      _selectedCoordinateIndex = index;
      final point = kGeofenceCoordinates[index];
      final random = Random();
      // Tambahkan fluktuasi mikro realistis (~1-3 meter)
      final jitterLat = (random.nextDouble() * 0.000030) - 0.000015;
      final jitterLng = (random.nextDouble() * 0.000030) - 0.000015;

      _staticLatitude = ((point['lat'] as double) + jitterLat).toStringAsFixed(6);
      _staticLongitude = ((point['lng'] as double) + jitterLng).toStringAsFixed(6);
      _currentLocationLabel = point['name'] as String;
      notifyListeners();
    }
  }

  /// Mengacak titik koordinat secara acak dalam radius geofence 100m.
  /// Menjamin titik yang dipilih berganti dan menambahkan mikro-jitter
  /// sehingga koordinat Absen Masuk dan Absen Pulang selalu berbeda!
  void randomizeStaticCoordinate({bool notify = true}) {
    final random = Random();
    int nextIdx;
    if (kGeofenceCoordinates.length > 1) {
      do {
        nextIdx = random.nextInt(kGeofenceCoordinates.length);
      } while (nextIdx == _selectedCoordinateIndex);
    } else {
      nextIdx = 0;
    }

    _selectedCoordinateIndex = nextIdx;
    final basePoint = kGeofenceCoordinates[nextIdx];

    // Jitter mikro realistis (~1 sampai 4 meter) agar angka desimal ke-6 selalu unik
    final jitterLat = (random.nextDouble() * 0.000040) - 0.000020;
    final jitterLng = (random.nextDouble() * 0.000040) - 0.000020;

    final finalLat = (basePoint['lat'] as double) + jitterLat;
    final finalLng = (basePoint['lng'] as double) + jitterLng;

    _staticLatitude = finalLat.toStringAsFixed(6);
    _staticLongitude = finalLng.toStringAsFixed(6);
    _currentLocationLabel = basePoint['name'] as String;

    if (notify) {
      notifyListeners();
    }
  }

  void resetStaticToK3pg() {
    randomizeStaticCoordinate();
  }

  /// Sync today's clock-in / clock-out status from real server history
  void syncWithHistory(List<HistoryModel> history) {
    if (history.isEmpty) return;
    final latest = history.first;
    final now = DateTime.now();
    final dayStr = now.day.toString();

    // Check if latest history item matches today
    if (latest.date.contains(dayStr)) {
      if (latest.timeIn.isNotEmpty && latest.timeIn != '00:00:00' && latest.timeIn != '-') {
        _hasClockedIn = true;
        _todayTimeIn = latest.timeIn;
      } else {
        _hasClockedIn = false;
        _todayTimeIn = 'Belum absen';
      }

      if (latest.timeOut.isNotEmpty && latest.timeOut != '00:00:00' && latest.timeOut != '-') {
        _hasClockedOut = true;
        _todayTimeOut = latest.timeOut;
      } else {
        _hasClockedOut = false;
        _todayTimeOut = 'Belum absen';
      }
      notifyListeners();
    }
  }

  void setShift(String id) {
    _selectedShiftId = id;
    notifyListeners();
  }

  void setBuilding(String id) {
    _selectedBuildingId = id;
    notifyListeners();
  }

  Future<void> refreshLocation() async {
    _isLoadingLocation = true;
    _locationError = null;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationError = 'Layanan lokasi (GPS) tidak aktif';
        _isLoadingLocation = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _locationError = 'Izin lokasi ditolak';
          _isLoadingLocation = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _locationError = 'Izin lokasi ditolak permanen di pengaturan';
        _isLoadingLocation = false;
        notifyListeners();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      _latitude = position.latitude.toStringAsFixed(6);
      _longitude = position.longitude.toStringAsFixed(6);
      _locationError = null;
    } catch (e) {
      debugPrint('[AttendanceProvider] Location error: $e');
      // Keep default K3PG Kantor Pusat coordinates
      _latitude = kDefaultStaticLatitude;
      _longitude = kDefaultStaticLongitude;
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  Future<void> takeSelfie() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 640,
        maxHeight: 480,
        imageQuality: 85,
      );

      if (photo != null) {
        _capturedImageBytes = await photo.readAsBytes();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[AttendanceProvider] Take selfie error: $e');
    }
  }

  void clearSelfie() {
    _capturedImageBytes = null;
    notifyListeners();
  }

  Future<bool> submitAttendance() async {
    _isSubmitting = true;
    _lastSubmitMessage = null;
    notifyListeners();

    // Jika static GPS ON, otomatis acak koordinat baru dalam radius 100m geofence
    // agar saat Absen Masuk dan Absen Pulang nilainya selalu berbeda & unik!
    if (_isStaticGps) {
      randomizeStaticCoordinate(notify: false);
    } else {
      // Jika static GPS OFF, ambil koordinat GPS realtime perangkat
      await refreshLocation();
    }

    final result = await _apiService.submitAttendance(
      latitude: effectiveCoordinates,
      shiftId: _selectedShiftId,
      buildingId: _selectedBuildingId,
      photoBytes: _capturedImageBytes,
    );

    _isSubmitting = false;
    _lastSubmitMessage = result['message'];

    if (result['success'] == true) {
      final now = DateTime.now();
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      
      if (!_hasClockedIn) {
        _hasClockedIn = true;
        _todayTimeIn = timeStr;
      } else {
        _hasClockedOut = true;
        _todayTimeOut = timeStr;
      }
      _capturedImageBytes = null;
      notifyListeners();
      return true;
    } else {
      notifyListeners();
      return false;
    }
  }
}
