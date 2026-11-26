class Item {
  final String id;
  final String name;
  final String userId;
  final DateTime createdAt;

  const Item({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as String,
      name: map['name'] as String,
      userId: map['user_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
