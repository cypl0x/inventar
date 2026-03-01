import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inventar/models/inventory_item.dart';
import 'package:inventar/screens/item_form_screen.dart';

void main() {
  testWidgets('validates required name field', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ItemFormScreen()));

    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pump();

    expect(find.text('Please enter a name'), findsOneWidget);
  });

  testWidgets('prefills fields when editing an item', (tester) async {
    final item = InventoryItem(
      id: 'item-1',
      name: 'Tape',
      description: 'Packing tape',
      quantity: 2,
      location: 'Drawer 1',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    await tester.pumpWidget(MaterialApp(home: ItemFormScreen(item: item)));

    expect(find.text('Edit Item'), findsOneWidget);
    expect(find.text('Tape'), findsOneWidget);
    expect(find.text('Packing tape'), findsOneWidget);
    expect(find.text('Drawer 1', skipOffstage: false), findsOneWidget);
  });
}
