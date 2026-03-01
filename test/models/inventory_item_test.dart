import 'package:flutter_test/flutter_test.dart';
import 'package:inventar/models/inventory_item.dart';

void main() {
  test('InventoryItem serializes and deserializes', () {
    final createdAt = DateTime(2024, 1, 10, 12, 30);
    final updatedAt = DateTime(2024, 1, 11, 9, 15);
    final item = InventoryItem(
      id: 'item-1',
      name: 'Pens',
      description: 'Blue pens',
      quantity: 12,
      location: 'Shelf A',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    final json = item.toJson();
    final restored = InventoryItem.fromJson(json);

    expect(restored.id, item.id);
    expect(restored.name, item.name);
    expect(restored.description, item.description);
    expect(restored.quantity, item.quantity);
    expect(restored.location, item.location);
    expect(restored.createdAt, item.createdAt);
    expect(restored.updatedAt, item.updatedAt);
  });

  test('InventoryItem copyWith preserves id and createdAt', () {
    final createdAt = DateTime(2024, 5, 1, 10, 0);
    final original = InventoryItem(
      id: 'item-2',
      name: 'Folders',
      description: 'Green folders',
      quantity: 3,
      location: null,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    final updated = original.copyWith(
      name: 'Folders (green)',
      quantity: 5,
      location: 'Cabinet 2',
    );

    expect(updated.id, original.id);
    expect(updated.createdAt, original.createdAt);
    expect(updated.name, 'Folders (green)');
    expect(updated.quantity, 5);
    expect(updated.location, 'Cabinet 2');
    expect(updated.updatedAt.isAfter(original.updatedAt), isTrue);
  });
}
