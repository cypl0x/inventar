import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/inventory_item.dart';
import 'inventory_repository.dart';

class SharedPreferencesInventoryRepository implements InventoryRepository {
  static const _storageKey = 'inventory_items';

  final SharedPreferences _prefs;
  final List<InventoryItem> _cache;

  SharedPreferencesInventoryRepository._(this._prefs, this._cache);

  /// Async factory: loads existing data before the app renders its first frame.
  /// Call this in main() before runApp().
  static Future<SharedPreferencesInventoryRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    final items = raw == null
        ? <InventoryItem>[]
        : (jsonDecode(raw) as List<dynamic>)
            .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
            .toList();
    return SharedPreferencesInventoryRepository._(prefs, items);
  }

  @override
  List<InventoryItem> getAll() => List.unmodifiable(_cache);

  @override
  Future<void> add(InventoryItem item) async {
    _cache.add(item);
    await _flush();
  }

  @override
  Future<void> update(InventoryItem item) async {
    final i = _cache.indexWhere((e) => e.id == item.id);
    if (i != -1) {
      _cache[i] = item;
      await _flush();
    }
  }

  @override
  Future<void> delete(String id) async {
    _cache.removeWhere((e) => e.id == id);
    await _flush();
  }

  /// Serialises the entire list and writes it atomically.
  /// shared_preferences itself is not transactional, but because Dart is
  /// single-threaded (event loop) and we update _cache before awaiting the
  /// write, there is no window where an in-flight operation can be lost —
  /// each _flush() snapshot is consistent.
  Future<void> _flush() => _prefs.setString(
        _storageKey,
        jsonEncode(_cache.map((e) => e.toJson()).toList()),
      );
}
