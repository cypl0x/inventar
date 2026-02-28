import '../models/inventory_item.dart';

abstract class InventoryRepository {
  /// Returns a snapshot of all items. Always synchronous — data is warm in
  /// memory after initialization.
  List<InventoryItem> getAll();

  /// Persists a new item. Awaiting guarantees the write completed.
  Future<void> add(InventoryItem item);

  /// Persists an updated item (matched by id). Awaiting guarantees the write.
  Future<void> update(InventoryItem item);

  /// Removes the item with [id]. Awaiting guarantees the write.
  Future<void> delete(String id);
}
