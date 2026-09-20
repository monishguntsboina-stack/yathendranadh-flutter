import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_model.dart';
import '../models/order_model.dart';
import '../models/table_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._internal();
  FirestoreService._internal();

  FirebaseFirestore? _firestore;

  void initialize(FirebaseFirestore? firestore) {
    _firestore = firestore;
  }

  // In-memory fallback lists for sample restaurant experience
  final List<FoodModel> _demoFoods = [
    FoodModel(
      id: 'food_1',
      name: 'Paneer Tikka',
      description: 'Cottage cheese marinated in rich spiced yogurt and grilled to perfection in tandoor.',
      price: 240.0,
      category: FoodCategories.starters,
      imageUrl: 'https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?w=500',
      available: true,
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: 'food_2',
      name: 'Crispy Veg Spring Rolls',
      description: 'Golden crunchy spring rolls packed with fresh seasoned vegetables served with sweet chili dip.',
      price: 180.0,
      category: FoodCategories.starters,
      imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500',
      available: true,
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: 'food_3',
      name: 'Butter Chicken Masala',
      description: 'Tender chicken simmered in rich creamy tomato and butter gravy with aromatic fenugreek.',
      price: 360.0,
      category: FoodCategories.mainCourse,
      imageUrl: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=500',
      available: true,
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: 'food_4',
      name: 'Dal Makhani',
      description: 'Slow cooked black lentils and kidney beans cooked overnight with butter and fresh cream.',
      price: 220.0,
      category: FoodCategories.mainCourse,
      imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=500',
      available: true,
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: 'food_5',
      name: 'Hyderabadi Dum Biryani',
      description: 'Aromatic basmati rice cooked with exotic herbs, spices, and tender marinated cuts.',
      price: 320.0,
      category: FoodCategories.rice,
      imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500',
      available: true,
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: 'food_6',
      name: 'Jeera Rice with Ghee',
      description: 'Steamed fragrant basmati rice tempered with roasted cumin seeds and pure desi ghee.',
      price: 150.0,
      category: FoodCategories.rice,
      imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=500',
      available: true,
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: 'food_7',
      name: 'Mango Lassi',
      description: 'Traditional refreshing chilled yogurt smoothie blended with ripe Alphonso mangoes.',
      price: 110.0,
      category: FoodCategories.beverages,
      imageUrl: 'https://images.unsplash.com/photo-1546173159-315724a31696?w=500',
      available: true,
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: 'food_8',
      name: 'Gulab Jamun with Rabri',
      description: 'Warm melt-in-mouth milk dumplings dipped in saffron sugar syrup, topped with rich rabri.',
      price: 140.0,
      category: FoodCategories.desserts,
      imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=500',
      available: true,
      createdAt: DateTime.now(),
    ),
  ];

  final List<TableModel> _demoTables = [
    TableModel(id: 'table_1', tableNumber: 'Table 1', capacity: 2, status: 'available'),
    TableModel(id: 'table_2', tableNumber: 'Table 2', capacity: 4, status: 'occupied'),
    TableModel(id: 'table_3', tableNumber: 'Table 3', capacity: 4, status: 'available'),
    TableModel(id: 'table_4', tableNumber: 'Table 4', capacity: 6, status: 'available'),
    TableModel(id: 'table_5', tableNumber: 'Table 5', capacity: 8, status: 'available'),
  ];

  final List<OrderModel> _demoOrders = [];

  final StreamController<List<FoodModel>> _foodsController = StreamController<List<FoodModel>>.broadcast();
  final StreamController<List<OrderModel>> _ordersController = StreamController<List<OrderModel>>.broadcast();
  final StreamController<List<TableModel>> _tablesController = StreamController<List<TableModel>>.broadcast();

  // FOODS STREAM
  Stream<List<FoodModel>> streamFoods() {
    if (_firestore != null) {
      return _firestore!.collection('foods').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return _demoFoods;
        }
        return snapshot.docs.map((doc) => FoodModel.fromMap(doc.data(), documentId: doc.id)).toList();
      });
    } else {
      Future.microtask(() => _foodsController.add(List<FoodModel>.from(_demoFoods)));
      return _foodsController.stream;
    }
  }

  // ADD FOOD
  Future<void> addFood(FoodModel food) async {
    if (_firestore != null) {
      await _firestore!.collection('foods').doc(food.id).set(food.toMap());
    } else {
      _demoFoods.insert(0, food);
      _foodsController.add(List<FoodModel>.from(_demoFoods));
    }
  }

  // UPDATE FOOD
  Future<void> updateFood(FoodModel food) async {
    if (_firestore != null) {
      await _firestore!.collection('foods').doc(food.id).update(food.toMap());
    } else {
      final index = _demoFoods.indexWhere((f) => f.id == food.id);
      if (index != -1) {
        _demoFoods[index] = food;
        _foodsController.add(List<FoodModel>.from(_demoFoods));
      }
    }
  }

  // DELETE FOOD
  Future<void> deleteFood(String foodId) async {
    if (_firestore != null) {
      await _firestore!.collection('foods').doc(foodId).delete();
    } else {
      _demoFoods.removeWhere((f) => f.id == foodId);
      _foodsController.add(List<FoodModel>.from(_demoFoods));
    }
  }

  // ORDERS STREAM
  Stream<List<OrderModel>> streamOrders() {
    if (_firestore != null) {
      return _firestore!
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), documentId: doc.id)).toList());
    } else {
      Future.microtask(() => _ordersController.add(List<OrderModel>.from(_demoOrders)));
      return _ordersController.stream;
    }
  }

  // STREAM CUSTOMER ORDERS
  Stream<List<OrderModel>> streamCustomerOrders(String customerId) {
    if (_firestore != null) {
      return _firestore!
          .collection('orders')
          .where('customerId', isEqualTo: customerId)
          .snapshots()
          .map((snapshot) {
            final orders = snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), documentId: doc.id)).toList();
            orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return orders;
          });
    } else {
      return streamOrders().map((orders) => orders.where((o) => o.customerId == customerId).toList());
    }
  }

  // PLACE ORDER
  Future<OrderModel> placeOrder({
    required String customerId,
    required String customerName,
    required String tableNumber,
    required List<OrderItemModel> items,
    required double totalAmount,
  }) async {
    final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final order = OrderModel(
      id: orderId,
      customerId: customerId,
      customerName: customerName,
      tableNumber: tableNumber,
      items: items,
      totalAmount: totalAmount,
      status: OrderStatus.placed,
      createdAt: DateTime.now(),
    );

    if (_firestore != null) {
      await _firestore!.collection('orders').doc(orderId).set(order.toMap());
    } else {
      _demoOrders.insert(0, order);
      _ordersController.add(List<OrderModel>.from(_demoOrders));
    }

    return order;
  }

  // UPDATE ORDER STATUS
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    if (_firestore != null) {
      await _firestore!.collection('orders').doc(orderId).update({'status': newStatus});
    } else {
      final index = _demoOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _demoOrders[index] = _demoOrders[index].copyWith(status: newStatus);
        _ordersController.add(List<OrderModel>.from(_demoOrders));
      }
    }
  }

  // TABLES STREAM
  Stream<List<TableModel>> streamTables() {
    if (_firestore != null) {
      return _firestore!.collection('tables').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) return _demoTables;
        return snapshot.docs.map((doc) => TableModel.fromMap(doc.data(), documentId: doc.id)).toList();
      });
    } else {
      Future.microtask(() => _tablesController.add(List<TableModel>.from(_demoTables)));
      return _tablesController.stream;
    }
  }
}
