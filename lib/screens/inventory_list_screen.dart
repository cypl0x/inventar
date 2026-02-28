import 'package:flutter/material.dart';

import '../models/inventory_item.dart';
import '../repositories/inventory_repository.dart';
import 'item_form_screen.dart';

class InventoryListScreen extends StatefulWidget {
  final InventoryRepository repo;

  const InventoryListScreen({super.key, required this.repo});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  Future<void> _add(InventoryItem item) async {
    await widget.repo.add(item);
    if (mounted) setState(() {});
  }

  Future<void> _update(InventoryItem item) async {
    await widget.repo.update(item);
    if (mounted) setState(() {});
  }

  Future<void> _delete(String id) async {
    await widget.repo.delete(id);
    if (mounted) setState(() {});
  }

  void _navigateToAddItem() async {
    final newItem = await Navigator.push<InventoryItem>(
      context,
      MaterialPageRoute(builder: (context) => const ItemFormScreen()),
    );
    if (newItem != null) await _add(newItem);
  }

  void _navigateToEditItem(InventoryItem item) async {
    final updated = await Navigator.push<InventoryItem>(
      context,
      MaterialPageRoute(builder: (context) => ItemFormScreen(item: item)),
    );
    if (updated != null) await _update(updated);
  }

  void _confirmDelete(InventoryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _delete(item.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.repo.getAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                'No items in inventory.\nTap + to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.description.isNotEmpty) Text(item.description),
                        const SizedBox(height: 4),
                        Text(
                          'Quantity: ${item.quantity}'
                          '${item.location != null && item.location!.isNotEmpty ? ' • Location: ${item.location}' : ''}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: item.quantity > 0
                              ? () => _update(item.copyWith(quantity: item.quantity - 1))
                              : null,
                        ),
                        Text(
                          '${item.quantity}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => _update(item.copyWith(quantity: item.quantity + 1)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _navigateToEditItem(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(item),
                        ),
                      ],
                    ),
                    onTap: () => _navigateToEditItem(item),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddItem,
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
