import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemModel {
  final String foodId;
  final String name;
  final double price;
  final int quantity;
  final double subtotal;

  OrderItemModel({
    required this.foodId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      foodId: map['foodId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodId': foodId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }
}

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String tableNumber;
  final List<OrderItemModel> items;
  final double totalAmount;
  final String status; // 'Placed', 'Preparing', 'Ready', 'Served'
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.tableNumber,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
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

    final rawItems = map['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems
        .map((item) => OrderItemModel.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();

    return OrderModel(
      id: documentId ?? (map['id'] as String? ?? ''),
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      tableNumber: map['tableNumber']?.toString() ?? '',
      items: itemsList,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'Placed',
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'tableNumber': tableNumber,
      'items': items.map((i) => i.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? tableNumber,
    List<OrderItemModel>? items,
    double? totalAmount,
    String? status,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      tableNumber: tableNumber ?? this.tableNumber,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
