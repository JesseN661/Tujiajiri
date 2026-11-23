import 'package:flutter/foundation.dart';

class JobSearchController extends ChangeNotifier {
  String _searchQuery = '';
  String _selectedEmploymentType = 'All';

  String get searchQuery => _searchQuery;

  String get selectedEmploymentType => _selectedEmploymentType;

  void updateSearchQuery(String value) {
    if (_searchQuery == value) return;

    _searchQuery = value;
    notifyListeners();
  }

  void updateEmploymentType(String value) {
    if (_selectedEmploymentType == value) return;

    _selectedEmploymentType = value;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedEmploymentType = 'All';
    notifyListeners();
  }
}
