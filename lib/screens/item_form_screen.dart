import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/inventory_item.dart';

class ItemFormScreen extends StatefulWidget {
  final InventoryItem? item;

  const ItemFormScreen({super.key, this.item});

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.item?.description ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.item?.quantity.toString() ?? '1',
    );
    _locationController = TextEditingController(
      text: widget.item?.location ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _increment() {
    final current = int.tryParse(_quantityController.text) ?? 0;
    setState(() => _quantityController.text = (current + 1).toString());
  }

  void _decrement() {
    final current = int.tryParse(_quantityController.text) ?? 0;
    if (current > 0) {
      setState(() => _quantityController.text = (current - 1).toString());
    }
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final item = InventoryItem(
        id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        quantity: int.parse(_quantityController.text),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        createdAt: widget.item?.createdAt ?? now,
        updatedAt: now,
      );
      Navigator.pop(context, item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Discard',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Item' : 'New Item',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _saveItem,
              icon: Icon(isEditing ? Icons.save_outlined : Icons.add, size: 18),
              label: Text(isEditing ? 'Save' : 'Add'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            _SectionLabel(label: 'Item Details'),
            const SizedBox(height: 12),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name *',
                hintText: 'e.g. Blue Ballpoint Pens',
                prefixIcon: Icon(
                  Icons.inventory_2_outlined,
                  size: 20,
                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Optional notes…',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 42),
                  child: Icon(
                    Icons.notes_outlined,
                    size: 20,
                    color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  ),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              minLines: 2,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 28),
            _SectionLabel(label: 'Quantity'),
            const SizedBox(height: 12),

            // Quantity stepper card
            _QuantityStepper(
              controller: _quantityController,
              isDark: isDark,
              primaryColor: cs.primary,
              onIncrement: _increment,
              onDecrement: _decrement,
              onChanged: () => setState(() {}),
            ),

            const SizedBox(height: 28),
            _SectionLabel(label: 'Location'),
            const SizedBox(height: 12),

            // Location field
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                hintText: 'e.g. Shelf A3, Storage Room B',
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _saveItem(),
            ),

            const SizedBox(height: 32),

            // Save button (secondary, for convenience)
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _saveItem,
                icon: Icon(isEditing ? Icons.save_outlined : Icons.add),
                label: Text(
                  isEditing ? 'Save Changes' : 'Add to Inventory',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
      ),
    );
  }
}

// ─── Quantity stepper card ────────────────────────────────────────────────────

class _QuantityStepper extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onChanged;

  const _QuantityStepper({
    required this.controller,
    required this.isDark,
    required this.primaryColor,
    required this.onIncrement,
    required this.onDecrement,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentQty = int.tryParse(controller.text) ?? 0;

    Color accentColor;
    if (currentQty == 0) {
      accentColor = const Color(0xFFEF4444);
    } else if (currentQty <= 5) {
      accentColor = const Color(0xFFF59E0B);
    } else {
      accentColor = const Color(0xFF10B981);
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          // Big quantity display + stepper buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              children: [
                // Decrement button
                _StepButton(
                  icon: Icons.remove,
                  color: accentColor,
                  onPressed: onDecrement,
                ),
                // Quantity number
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        controller.text.isEmpty ? '0' : controller.text,
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentQty == 1 ? 'unit' : 'units',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white38
                              : const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Increment button
                _StepButton(
                  icon: Icons.add,
                  color: accentColor,
                  onPressed: onIncrement,
                ),
              ],
            ),
          ),
          // Stock level indicator bar
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isDark ? Colors.white12 : const Color(0xFFF1F5F9),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: currentQty == 0
                  ? 0.0
                  : (currentQty / (currentQty + 10)).clamp(0.05, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _stockLabel(currentQty),
                  style: TextStyle(
                    fontSize: 11,
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  'Tap − / + or type below',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white30 : const Color(0xFFCBD5E1),
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Divider(
            height: 1,
            color: isDark ? Colors.white12 : const Color(0xFFF1F5F9),
          ),
          // Manual text input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Or type a number',
                prefixIcon: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              onChanged: (_) => onChanged(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a quantity';
                }
                if (int.tryParse(value) == null || int.parse(value) < 0) {
                  return 'Please enter a valid quantity';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  String _stockLabel(int qty) {
    if (qty == 0) return 'Out of stock';
    if (qty <= 5) return 'Low stock';
    return 'In stock';
  }
}

// ─── Stepper button ───────────────────────────────────────────────────────────

class _StepButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _StepButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }
}
