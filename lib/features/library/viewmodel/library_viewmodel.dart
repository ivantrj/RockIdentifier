import 'package:flutter/material.dart';
import 'package:bug_id/data/models/identified_item.dart';
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

  Future<void> updateItem(IdentifiedItem updatedItem) async {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
      notifyListeners();
      await _saveItems();
    }
  }

  Future<void> toggleFavorite(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _items[index];
      _items[index] = item.copyWith(isFavorite: !item.isFavorite);
      notifyListeners();
      await _saveItems();
    }
  }

  List<IdentifiedItem> get favoriteItems => _items.where((item) => item.isFavorite).toList();

  List<IdentifiedItem> getItemsByCategory(String category) {
    return _items.where((item) => item.category == category).toList();
  }

  List<IdentifiedItem> getItemsByCollection(String collection) {
    return _items.where((item) => item.collection == collection).toList();
  }

  List<String> get categories {
    final categories = _items.map((item) => item.category).whereType<String>().toSet();
    return categories.toList()..sort();
  }

  List<String> get collections {
    final collections = _items.map((item) => item.collection).whereType<String>().toSet();
    return collections.toList()..sort();
  }
}
