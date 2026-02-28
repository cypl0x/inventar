import 'package:flutter/material.dart';

import 'repositories/inventory_repository.dart';
import 'repositories/shared_preferences_inventory_repository.dart';
import 'screens/inventory_list_screen.dart';

void main() async {
  // Must be called before any plugin (including shared_preferences) is used.
  WidgetsFlutterBinding.ensureInitialized();
  final repo = await SharedPreferencesInventoryRepository.create();
  runApp(InventoryApp(repo: repo));
}

class InventoryApp extends StatelessWidget {
  final InventoryRepository repo;

  const InventoryApp({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: InventoryListScreen(repo: repo),
    );
  }
}
