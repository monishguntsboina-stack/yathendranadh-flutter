import 'package:flutter/foundation.dart';
import '../models/food_model.dart';
import '../models/order_model.dart';

class CartService {
  static final CartService instance = CartService._internal();
  CartService._internal();

  final ValueNotifier<List<OrderItemModel>> cartNotifier = ValueNotifier<List<OrderItemModel>>([]);

  List<OrderItemModel> get items => cartNotifier.value;

  int get totalItemCount {
    int count = 0;
    for (var item in cartNotifier.value) {
      count += item.quantity;
    }
    return count;
  }

  double get totalAmount {
    double total = 0.0;
    for (var item in cartNotifier.value) {
      total += item.subtotal;
    }
    return total;
  }

  void addItem(FoodModel food, {int quantity = 1}) {
    final currentList = List<OrderItemModel>.from(cartNotifier.value);
    final existingIndex = currentList.indexWhere((item) => item.foodId == food.id);

    if (existingIndex != -1) {
      final existingItem = currentList[existingIndex];
      final newQty = existingItem.quantity + quantity;
      currentList[existingIndex] = OrderItemModel(
        foodId: food.id,
        name: food.name,
        price: food.price,
        quantity: newQty,
        subtotal: newQty * food.price,
      );
    } else {
      currentList.add(
        OrderItemModel(
          foodId: food.id,
          name: food.name,
          price: food.price,
          quantity: quantity,
          subtotal: quantity * food.price,
        ),
      );
    }

    cartNotifier.value = currentList;
  }

  void updateQuantity(String foodId, int newQuantity) {
    final currentList = List<OrderItemModel>.from(cartNotifier.value);
    final index = currentList.indexWhere((item) => item.foodId == foodId);

    if (index != -1) {
      if (newQuantity <= 0) {
        currentList.removeAt(index);
      } else {
        final item = currentList[index];
        currentList[index] = OrderItemModel(
          foodId: item.foodId,
          name: item.name,
          price: item.price,
          quantity: newQuantity,
          subtotal: newQuantity * item.price,
        );
      }
      cartNotifier.value = currentList;
    }
  }

  void removeItem(String foodId) {
    final currentList = List<OrderItemModel>.from(cartNotifier.value);
    currentList.removeWhere((item) => item.foodId == foodId);
    cartNotifier.value = currentList;
  }

  void clearCart() {
    cartNotifier.value = [];
  }
}
