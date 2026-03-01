import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inventar/models/inventory_item.dart';
import 'package:inventar/repositories/inventory_repository.dart';
import 'package:inventar/screens/inventory_list_screen.dart';

class FakeInventoryRepository implements InventoryRepository {
  FakeInventoryRepository(this._items);

  final List<InventoryItem> _items;

  @override
  List<InventoryItem> getAll() => List.unmodifiable(_items);

  @override
  Future<void> add(InventoryItem item) async {
    _items.add(item);
  }

  @override
  Future<void> update(InventoryItem item) async {
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _items[index] = item;
    }
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((e) => e.id == id);
  }
}

InventoryItem _item({
  required String id,
  required String name,
  required String description,
  required int quantity,
  String? location,
}) {
  final now = DateTime(2024, 1, 1);
  return InventoryItem(
    id: id,
    name: name,
    description: description,
    quantity: quantity,
    location: location,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  testWidgets('shows empty state when inventory has no items', (tester) async {
    final repo = FakeInventoryRepository([]);

    await tester.pumpWidget(
      MaterialApp(home: InventoryListScreen(repo: repo)),
    );

    expect(find.text('Inventory is empty'), findsOneWidget);
    expect(find.text('Tap + below to add your first item'), findsOneWidget);
  });

  testWidgets('renders item count in the app bar chip', (tester) async {
    final repo = FakeInventoryRepository([
      _item(
        id: '1',
        name: 'Pens',
        description: 'Blue pens',
        quantity: 10,
      ),
      _item(
        id: '2',
        name: 'Staplers',
        description: 'Mini staplers',
        quantity: 2,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: InventoryListScreen(repo: repo)),
    );

    expect(find.text('2 items'), findsOneWidget);
  });

  testWidgets('filters items based on search query', (tester) async {
    final repo = FakeInventoryRepository([
      _item(
        id: '1',
        name: 'Pencils',
        description: 'Graphite',
        quantity: 8,
      ),
      _item(
        id: '2',
        name: 'Markers',
        description: 'Red markers',
        quantity: 4,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(home: InventoryListScreen(repo: repo)),
    );

    await tester.enterText(find.byType(TextField), 'mark');
    await tester.pumpAndSettle();

    expect(find.text('Markers'), findsOneWidget);
    expect(find.text('Pencils'), findsNothing);
    expect(find.text('Results for "mark"'), findsOneWidget);
  });
}
