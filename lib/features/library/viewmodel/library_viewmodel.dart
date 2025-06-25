import 'package:flutter/material.dart';
import 'package:PlantMate/data/models/identified_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LibraryViewModel extends ChangeNotifier {
  static const _prefsKey = 'library_items';
  final List<IdentifiedItem> _items = [];

  LibraryViewModel() {
    _loadItems();
  }

  List<IdentifiedItem> get items => List.unmodifiable(_items);

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
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _items.clear();
      _items.addAll(jsonList.map((e) => IdentifiedItem.fromJson(e as Map<String, dynamic>)));
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
    await _saveItems();
  }
}
