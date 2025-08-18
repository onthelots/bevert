import 'dart:ui';

class Folder {
  final String id;
  final String name;
  final String colorHex;
  final DateTime createdAt; // ✅ 추가

  Folder({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.createdAt, // ✅
  });

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'],
      name: map['name'],
      colorHex: map['color_hex'] ?? '#448aff',
      createdAt: DateTime.parse(map['created_at']), // ✅
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color_hex': colorHex,
      'created_at': createdAt.toIso8601String(), // ✅
    };
  }

  Color get color => Color(int.parse(colorHex.replaceFirst('#', '0xff')));
}
