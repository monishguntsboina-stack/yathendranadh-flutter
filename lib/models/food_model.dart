import 'package:cloud_firestore/cloud_firestore.dart';

class FoodModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final bool available;
  final DateTime createdAt;

  FoodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.available = true,
    required this.createdAt,
  });

  factory FoodModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) {
        return val.toDate();
      } else if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      } else if (val is int) {
        return DateTime.fromMillisecondsSinceEpoch(val);
      }
      return DateTime.now();
    }

    return FoodModel(
      id: documentId ?? (map['id'] as String? ?? ''),
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] as String? ?? 'Main Course',
      imageUrl: map['imageUrl'] as String? ?? '',
      available: map['available'] as bool? ?? true,
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'available': available,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  FoodModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? available,
    DateTime? createdAt,
  }) {
    return FoodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      available: available ?? this.available,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
