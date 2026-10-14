import 'package:flutter/material.dart';
import '../models/counter_model.dart';
import '../models/history_model.dart';
import '../services/api_service.dart';

class HistoryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<HistoryModel> _historyList = [];
  CounterModel _counter = CounterModel.sample();
  bool _isLoading = false;
  String _selectedMonth = '10'; // Oktober
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  List<HistoryModel> get historyList => _historyList;
  CounterModel get counter => _counter;
  bool get isLoading => _isLoading;
  String get selectedMonth => _selectedMonth;
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;

  HistoryProvider() {
    loadAllData();
  }

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      _fetchCounter(),
      _fetchHistory(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchCounter() async {
    _counter = await _apiService.getHomeCounter(monthFilter: _selectedMonth);
  }

  Future<void> _fetchHistory({String? from, String? to}) async {
    _historyList = await _apiService.getHistory(from: from, to: to);
  }

  Future<void> changeMonth(String month) async {
    _selectedMonth = month;
    notifyListeners();
    _counter = await _apiService.getHomeCounter(monthFilter: month);
    notifyListeners();
  }

  Future<void> filterDateRange(DateTime start, DateTime end) async {
    _filterStartDate = start;
    _filterEndDate = end;
    _isLoading = true;
    notifyListeners();

    final fromStr = '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final toStr = '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';

    _historyList = await _apiService.getHistory(from: fromStr, to: toStr);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> resetFilter() async {
    _filterStartDate = null;
    _filterEndDate = null;
    await loadAllData();
  }
}
