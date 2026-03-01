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
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
            SizedBox(width: 10),
            Text('Delete Item'),
          ],
        ),
        content: Text(
          'Remove "${item.name}" from your inventory?',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _delete(item.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allItems = widget.repo.getAll();
    final items = _searchQuery.isEmpty
        ? allItems
        : allItems
              .where(
                (i) =>
                    i.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    i.description.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();

    final totalQuantity = allItems.fold(0, (sum, i) => sum + i.quantity);
    final lowStockCount = allItems
        .where((i) => i.quantity > 0 && i.quantity <= 5)
        .length;
    final outOfStockCount = allItems.where((i) => i.quantity == 0).length;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, allItems.length),
          SliverToBoxAdapter(
            child: _buildStatsAndSearch(
              context,
              allItems.length,
              totalQuantity,
              lowStockCount,
              outOfStockCount,
              isDark,
            ),
          ),
          if (items.isEmpty)
            _buildEmptySliver(context, allItems.isNotEmpty)
          else
            _buildItemSliver(context, items, isDark),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddItem,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Item',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, int itemCount) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color(0xFF4338CA),
      foregroundColor: Colors.white,
      title: const Text(
        'Inventory',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$itemCount items',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4338CA), Color(0xFF6D28D9)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsAndSearch(
    BuildContext context,
    int totalItems,
    int totalQty,
    int lowStock,
    int outOfStock,
    bool isDark,
  ) {
    return Column(
      children: [
        // Stats row
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4338CA), Color(0xFF6D28D9)],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Row(
            children: [
              _StatCard(
                label: 'Total Items',
                value: '$totalItems',
                icon: Icons.inventory_2_outlined,
                color: Colors.white,
                bgColor: Colors.white.withValues(alpha: 0.15),
              ),
              const SizedBox(width: 10),
              _StatCard(
                label: 'Total Qty',
                value: '$totalQty',
                icon: Icons.layers_outlined,
                color: Colors.white,
                bgColor: Colors.white.withValues(alpha: 0.15),
              ),
              if (outOfStock > 0) ...[
                const SizedBox(width: 10),
                _StatCard(
                  label: 'Out of Stock',
                  value: '$outOfStock',
                  icon: Icons.remove_circle_outline,
                  color: const Color(0xFFFCA5A5),
                  bgColor: const Color(0xFFEF4444).withValues(alpha: 0.25),
                ),
              ] else if (lowStock > 0) ...[
                const SizedBox(width: 10),
                _StatCard(
                  label: 'Low Stock',
                  value: '$lowStock',
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFFCD34D),
                  bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                ),
              ],
            ],
          ),
        ),
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search inventory…',
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
              ),
              prefixIcon: Icon(
                Icons.search,
                size: 20,
                color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 16, 4),
            child: Row(
              children: [
                Text(
                  'Results for "$_searchQuery"',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEmptySliver(BuildContext context, bool hasItems) {
    final cs = Theme.of(context).colorScheme;
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasItems
                      ? Icons.search_off_rounded
                      : Icons.inventory_2_outlined,
                  size: 48,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                hasItems ? 'No results found' : 'Inventory is empty',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                hasItems
                    ? 'Try a different search term'
                    : 'Tap + below to add your first item',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemSliver(
    BuildContext context,
    List<InventoryItem> items,
    bool isDark,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      sliver: SliverList.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _InventoryCard(
              item: item,
              isDark: isDark,
              onTap: () => _navigateToEditItem(item),
              onDecrement: item.quantity > 0
                  ? () => _update(item.copyWith(quantity: item.quantity - 1))
                  : null,
              onIncrement: () =>
                  _update(item.copyWith(quantity: item.quantity + 1)),
              onEdit: () => _navigateToEditItem(item),
              onDelete: () => _confirmDelete(item),
            ),
          );
        },
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: color.withValues(alpha: 0.75),
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Inventory Card ───────────────────────────────────────────────────────────

class _InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _InventoryCard({
    required this.item,
    required this.isDark,
    required this.onTap,
    required this.onDecrement,
    required this.onIncrement,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _accentColor {
    if (item.quantity == 0) return const Color(0xFFEF4444);
    if (item.quantity <= 5) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String get _stockLabel {
    if (item.quantity == 0) return 'Out of stock';
    if (item.quantity <= 5) return 'Low stock';
    return 'In stock';
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent strip
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                // Avatar column
                Container(
                  width: 60,
                  color: accent.withValues(alpha: 0.08),
                  child: Center(
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          item.name.isNotEmpty
                              ? item.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: accent,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                  height: 1.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Quantity badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: accent.withValues(alpha: 0.35),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${item.quantity}',
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (item.description.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white38
                                  : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        // Bottom row: stock label + location + actions
                        Row(
                          children: [
                            // Stock label pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _stockLabel,
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            if (item.location != null &&
                                item.location!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.location_on_outlined,
                                size: 11,
                                color: isDark
                                    ? Colors.white30
                                    : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  item.location!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white30
                                        : const Color(0xFF94A3B8),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            const Spacer(),
                            // Qty stepper buttons
                            _SmallIconButton(
                              icon: Icons.remove,
                              accentColor: accent,
                              enabled: onDecrement != null,
                              onPressed: onDecrement ?? () {},
                            ),
                            const SizedBox(width: 4),
                            _SmallIconButton(
                              icon: Icons.add,
                              accentColor: accent,
                              enabled: true,
                              onPressed: onIncrement,
                            ),
                            const SizedBox(width: 4),
                            // More options
                            SizedBox(
                              width: 28,
                              height: 28,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.more_vert,
                                  size: 18,
                                  color: isDark
                                      ? Colors.white30
                                      : const Color(0xFF94A3B8),
                                ),
                                onPressed: () => _showActions(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        item.name[0].toUpperCase(),
                        style: TextStyle(
                          color: _accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${item.quantity} units',
                          style: TextStyle(fontSize: 13, color: _accentColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF4F46E5),
                  size: 18,
                ),
              ),
              title: const Text(
                'Edit Item',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Update name, description or location'),
              onTap: () {
                Navigator.pop(ctx);
                onEdit();
              },
            ),
            ListTile(
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFEF4444),
                  size: 18,
                ),
              ),
              title: const Text(
                'Delete Item',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text('Permanently remove from inventory'),
              onTap: () {
                Navigator.pop(ctx);
                onDelete();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Small icon button ────────────────────────────────────────────────────────

class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final bool enabled;
  final VoidCallback onPressed;

  const _SmallIconButton({
    required this.icon,
    required this.accentColor,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Material(
        color: enabled
            ? accentColor.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled ? onPressed : null,
          child: Icon(
            icon,
            size: 14,
            color: enabled ? accentColor : Colors.grey.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
