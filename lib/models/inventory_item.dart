class InventoryItem {
  final String id;
  String name;
  String description;
  int quantity;
  String? location;
  DateTime createdAt;
  DateTime updatedAt;

  InventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'quantity': quantity,
        'location': location,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        quantity: json['quantity'] as int,
        location: json['location'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  InventoryItem copyWith({
    String? name,
    String? description,
    int? quantity,
    String? location,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      location: location ?? this.location,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
