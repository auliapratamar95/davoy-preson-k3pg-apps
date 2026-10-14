import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  // Static GPS Coordinates for Kantor Pusat K3PG
  static const String kDefaultStaticLatitude = '-7.1602651';
  static const String kDefaultStaticLongitude = '112.6330005';
  static const String kStaticLocationName = 'Kantor Pusat K3PG';

  bool _isStaticGps = true; // Aktif secara default untuk Kantor Pusat K3PG
  String _staticLatitude = kDefaultStaticLatitude;
  String _staticLongitude = kDefaultStaticLongitude;

  String _latitude = '-7.161042';
  String _longitude = '112.653421';
  bool _isLoadingLocation = false;
  String? _locationError;

  String _selectedShiftId = '1';
  String _selectedBuildingId = '1';

  Uint8List? _capturedImageBytes;
  bool _isSubmitting = false;
  String? _lastSubmitMessage;

  // Today's attendance state
  String _todayTimeIn = '07:26:39';
  String _todayTimeOut = 'Belum absen';
  bool _hasClockedIn = true;
  bool _hasClockedOut = false;

  // Static GPS getters
  bool get isStaticGps => _isStaticGps;
  String get staticLatitude => _staticLatitude;
  String get staticLongitude => _staticLongitude;
  String get staticCoordinates => '$_staticLatitude,$_staticLongitude';

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
    refreshLocation();
  }

  void toggleStaticGps(bool enabled) {
    _isStaticGps = enabled;
    if (!enabled) {
      refreshLocation();
    }
    notifyListeners();
  }

  Future<void> getLocation() async {
    await refreshLocation();
  }

  void setStaticCoordinates(String lat, String lng) {
    _staticLatitude = lat.trim();
    _staticLongitude = lng.trim();
    notifyListeners();
  }

  void resetStaticToK3pg() {
    _staticLatitude = kDefaultStaticLatitude;
    _staticLongitude = kDefaultStaticLongitude;
    notifyListeners();
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
      _latitude = '-7.161042';
      _longitude = '112.653421';
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

    // Jika static GPS OFF, pastikan koordinat GPS realtime terbaru diambil via getLocation
    if (!_isStaticGps) {
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
