import 'package:flutter/material.dart';
import 'package:coin_id/data/models/identified_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LibraryViewModel extends ChangeNotifier {
  static const _prefsKey = 'library_items';
  final List<IdentifiedItem> _items = [];
  bool _isLoading = true;

  LibraryViewModel() {
    _loadItems();
  }

  List<IdentifiedItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  Future<void> addItem(IdentifiedItem item) async {
    _items.insert(0, item);
    notifyListeners();
    await _saveItems();
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _items.map((e) => e.toJson()).toList();
    await prefs.setString(_prefsKey, json.encode(jsonList));
  }

  Future<void> _loadItems() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _items.clear();
      _items.addAll(jsonList.map((e) => IdentifiedItem.fromJson(e as Map<String, dynamic>)));
    } else {
      // If no items are saved, add placeholders
      _addPlaceholderData();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _addPlaceholderData() {
    _items.addAll([
      IdentifiedItem(
        id: '1',
        imagePath: 'assets/icon/icon.png', // Using an existing asset
        result: 'Morgan Dollar',
        subtitle: '1887, USA',
        confidence: 0.98,
        details: {
          'Country': 'USA',
          'Year': '1887',
          'Denomination': '\$1',
          'Composition': '90% Silver, 10% Copper',
          'Mintage': '20,290,000',
          'Description':
              'The Morgan dollar was a United States dollar coin minted from 1878 to 1904, and again in 1921.'
        },
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
      ),
      IdentifiedItem(
        id: '2',
        imagePath: 'assets/icon/icon.png', // Using an existing asset
        result: 'Roman Denarius',
        subtitle: 'AD 117-138, Roman Empire',
        confidence: 0.94,
        details: {
          'Country': 'Roman Empire',
          'Year': 'c. AD 120',
          'Denomination': 'Denarius',
          'Composition': 'Silver',
          'Mintage': 'N/A',
          'Description':
              "This denarius was struck under Emperor Hadrian, known for his substantial building projects, including Hadrian's Wall."
        },
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
      ),
      IdentifiedItem(
        id: '3',
        imagePath: 'assets/icon/icon.png', // Using an existing asset
        result: 'Japanese 1 Yen',
        subtitle: '1901 (Meiji 34), Japan',
        confidence: 0.99,
        details: {
          'Country': 'Japan',
          'Year': '1901',
          'Denomination': '1 Yen',
          'Composition': '90% Silver, 10% Copper',
          'Mintage': '1,056,000',
          'Description':
              'A silver one yen coin from the Meiji era, featuring a dragon design symbolic of power and good fortune.'
        },
        dateTime: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ]);
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
    await _saveItems();
  }

  Future<void> updateItem(IdentifiedItem updatedItem) async {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
      notifyListeners();
      await _saveItems();
    }
  }
}
