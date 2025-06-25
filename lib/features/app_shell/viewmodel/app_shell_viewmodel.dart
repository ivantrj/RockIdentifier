// lib/features/app_shell/viewmodel/app_shell_viewmodel.dart
import 'package:flutter/foundation.dart'; // For ChangeNotifier

class AppShellViewModel extends ChangeNotifier {
  int _currentIndex = 0; // Default to the first tab (e.g., Home)

  int get currentIndex => _currentIndex;

  void changeTab(int index) {
    if (_currentIndex == index) return; // No change needed
    _currentIndex = index;
    notifyListeners(); // Notify the view (AppShellScreen) to rebuild
  }
}
