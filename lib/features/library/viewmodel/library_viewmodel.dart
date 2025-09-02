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
    }
    // Remove placeholder data - let the collection be truly empty

    _isLoading = false;
    notifyListeners();
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
