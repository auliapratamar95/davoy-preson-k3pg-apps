import 'package:flutter/material.dart';
import '../models/cuty_model.dart';
import '../models/izin_model.dart';
import '../models/job_model.dart';
import '../models/sppd_model.dart';
import '../services/api_service.dart';

enum RequestTab { sppd, cuti, izin, pekerjaan }

class RequestsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  RequestTab _activeTab = RequestTab.sppd;
  bool _isLoading = false;

  List<SppdModel> _sppdList = [];
  List<CutyModel> _cutyList = [];
  List<IzinModel> _izinList = [];
  List<JobModel> _jobList = [];

  RequestTab get activeTab => _activeTab;
  bool get isLoading => _isLoading;

  List<SppdModel> get sppdList => _sppdList;
  List<CutyModel> get cutyList => _cutyList;
  List<IzinModel> get izinList => _izinList;
  List<JobModel> get jobList => _jobList;

  RequestsProvider() {
    loadAllRequests();
  }

  void setActiveTab(RequestTab tab) {
    _activeTab = tab;
    notifyListeners();
  }

  Future<void> loadAllRequests() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getSppd(),
        _apiService.getCuty(),
        _apiService.getIzin(),
        _apiService.getJobs(),
      ]);

      _sppdList = results[0] as List<SppdModel>;
      _cutyList = results[1] as List<CutyModel>;
      _izinList = results[2] as List<IzinModel>;
      _jobList = results[3] as List<JobModel>;
    } catch (e) {
      debugPrint('[RequestsProvider] Error loading: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Submit SPPD
  Future<bool> createSppd({
    required String name,
    required String startDate,
    required String endDate,
    required String description,
  }) async {
    _isLoading = true;
    notifyListeners();

    final res = await _apiService.addSppd(
      name: name,
      startDate: startDate,
      endDate: endDate,
      description: description,
    );

    if (res['success'] == true) {
      _sppdList.insert(
        0,
        SppdModel(
          code: 'SPD${DateTime.now().month}${DateTime.now().year.toString().substring(2)}${_sppdList.length + 10}',
          employeeName: name,
          dateRange: '$startDate - $endDate',
          description: description,
          status: 'Menunggu',
        ),
      );
    }

    _isLoading = false;
    notifyListeners();
    return res['success'] == true;
  }

  // Submit Cuti
  Future<bool> createCuty({
    required String name,
    required String startDate,
    required String endDate,
    required int totalDays,
    required String description,
  }) async {
    _isLoading = true;
    notifyListeners();

    final res = await _apiService.addCuty(
      name: name,
      startDate: startDate,
      endDate: endDate,
      totalDays: totalDays,
      description: description,
    );

    if (res['success'] == true) {
      _cutyList.insert(
        0,
        CutyModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          employeeName: name,
          startDate: startDate,
          endDate: endDate,
          totalDays: totalDays,
          description: description,
          status: 'Menunggu',
        ),
      );
    }

    _isLoading = false;
    notifyListeners();
    return res['success'] == true;
  }

  // Submit Izin
  Future<bool> createIzin({
    required String name,
    required String startDate,
    required String endDate,
    required String description,
  }) async {
    _isLoading = true;
    notifyListeners();

    final res = await _apiService.addIzin(
      name: name,
      startDate: startDate,
      endDate: endDate,
      description: description,
    );

    if (res['success'] == true) {
      _izinList.insert(
        0,
        IzinModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          employeeName: name,
          startDate: startDate,
          endDate: endDate,
          description: description,
          status: 'Menunggu',
        ),
      );
    }

    _isLoading = false;
    notifyListeners();
    return res['success'] == true;
  }

  // Submit Job
  Future<bool> createJob({
    required String name,
    required String date,
    required String startTime,
    required String endTime,
    required String job,
    required int percentage,
    required String nature,
  }) async {
    _isLoading = true;
    notifyListeners();

    final res = await _apiService.addJob(
      name: name,
      date: date,
      startTime: startTime,
      endTime: endTime,
      job: job,
      percentage: percentage,
      nature: nature,
    );

    if (res['success'] == true) {
      _jobList.insert(
        0,
        JobModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: date,
          startTime: startTime,
          endTime: endTime,
          title: job,
          percentage: percentage,
          nature: nature,
        ),
      );
    }

    _isLoading = false;
    notifyListeners();
    return res['success'] == true;
  }
}
