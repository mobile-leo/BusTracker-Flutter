import 'package:flutter/material.dart';
import '../../domain/entities/bus_line.dart';
import '../../domain/usecases/manage_history_usecase.dart';

class HistoryProvider extends ChangeNotifier {
  final ManageHistoryUseCase manageHistoryUseCase;

  HistoryProvider({required this.manageHistoryUseCase});

  List<BusLine> _history = [];
  bool _isLoading = false;

  List<BusLine> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      _history = await manageHistoryUseCase.getHistory();
    } catch (_) {
      _history = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToHistory(BusLine line) async {
    await manageHistoryUseCase.addToHistory(line);
    await loadHistory();
  }

  Future<void> clearHistory() async {
    await manageHistoryUseCase.clearHistory();
    _history = [];
    notifyListeners();
  }
}
