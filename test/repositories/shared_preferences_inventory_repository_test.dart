import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:inventar/models/inventory_item.dart';
import 'package:inventar/repositories/shared_preferences_inventory_repository.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('create loads an empty cache when no data stored', () async {
    final repo = await SharedPreferencesInventoryRepository.create();

    expect(repo.getAll(), isEmpty);
  });

  test('add persists items to shared preferences', () async {
    final repo = await SharedPreferencesInventoryRepository.create();
    final item = InventoryItem(
      id: 'item-1',
      name: 'Markers',
      description: 'Red markers',
      quantity: 4,
      location: 'Bin 3',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    await repo.add(item);

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('inventory_items');
    expect(raw, isNotNull);

    final decoded = jsonDecode(raw!) as List<dynamic>;
    expect(decoded.length, 1);
    expect(decoded.first['name'], 'Markers');
    expect(repo.getAll().single.name, 'Markers');
  });

  test('update persists changes for matching id', () async {
    final repo = await SharedPreferencesInventoryRepository.create();
    final item = InventoryItem(
      id: 'item-2',
      name: 'Paper',
      description: 'A4 sheets',
      quantity: 50,
      location: 'Shelf B',
      createdAt: DateTime(2024, 2, 1),
      updatedAt: DateTime(2024, 2, 1),
    );

    await repo.add(item);
    await repo.update(item.copyWith(quantity: 60));

    final stored = repo.getAll().single;
    expect(stored.quantity, 60);

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('inventory_items');
    final decoded = jsonDecode(raw!) as List<dynamic>;
    expect(decoded.first['quantity'], 60);
  });

  test('delete removes items and persists', () async {
    final repo = await SharedPreferencesInventoryRepository.create();
    final item = InventoryItem(
      id: 'item-3',
      name: 'Staples',
      description: 'Box of staples',
      quantity: 1,
      location: null,
      createdAt: DateTime(2024, 3, 1),
      updatedAt: DateTime(2024, 3, 1),
    );

    await repo.add(item);
    await repo.delete(item.id);

    expect(repo.getAll(), isEmpty);

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('inventory_items');
    final decoded = jsonDecode(raw!) as List<dynamic>;
    expect(decoded, isEmpty);
  });
}
