import 'package:flutter/material.dart';
import '../../services/cart_service.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import 'order_tracking.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _selectedTable = 'Table 1';
  bool _isOrdering = false;

  final List<String> _tableOptions = [
    'Table 1',
    'Table 2',
    'Table 3',
    'Table 4',
    'Table 5',
  ];

  void _handlePlaceOrder() async {
    final cartItems = CartService.instance.items;
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty. Add food items to order.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isOrdering = true;
    });

    final currentUser = AuthService.instance.currentUser;
    final customerId = currentUser?.uid ?? 'guest_customer';
    final customerName = currentUser?.name ?? 'Guest Diner';
    final totalAmount = CartService.instance.totalAmount;

    try {
      final order = await FirestoreService.instance.placeOrder(
        customerId: customerId,
        customerName: customerName,
        tableNumber: _selectedTable,
        items: List.from(cartItems),
        totalAmount: totalAmount,
      );

      // Clear the cart
      CartService.instance.clearCart();

      if (!mounted) return;
      setState(() {
        _isOrdering = false;
      });

      // Show Order Confirmation Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, size: 56, color: Colors.green),
              ),
              const SizedBox(height: 16),
              const Text(
                'Order Placed Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBrown,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Order ID: ${order.id}',
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
              Text('Assigned to: $_selectedTable', style: const TextStyle(fontSize: 13)),
              Text(
                'Total Amount: ${AppConstants.currency}${order.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderTrackingScreen(orderId: order.id),
                    ),
                  );
                },
                child: const Text('Track Order Live'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isOrdering = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Food Cart'),
      ),
      body: ValueListenableBuilder(
        valueListenable: CartService.instance.cartNotifier,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.remove_shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Browse the menu and add delicious food items to your cart.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  // Table Selection Header
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.table_restaurant, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('Select Table Number:', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        DropdownButton<String>(
                          value: _selectedTable,
                          underline: const SizedBox(),
                          items: _tableOptions.map((table) {
                            return DropdownMenuItem<String>(
                              value: table,
                              child: Text(table, style: const TextStyle(fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedTable = val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  // Cart Items List
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length,
                      separatorBuilder: (ctx, idx) => const Divider(height: 1),
                      itemBuilder: (ctx, idx) {
                        final item = items[idx];
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              // Quantity Controls
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 18),
                                      onPressed: () => CartService.instance.updateQuantity(item.foodId, item.quantity - 1),
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 18),
                                      onPressed: () => CartService.instance.updateQuantity(item.foodId, item.quantity + 1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Food Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    Text(
                                      '${AppConstants.currency}${item.price.toStringAsFixed(0)} each',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),

                              // Subtotal & Delete
                              Text(
                                '${AppConstants.currency}${item.subtotal.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => CartService.instance.removeItem(item.foodId),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Checkout Bottom Sheet Summary
                  Card(
                    margin: const EdgeInsets.all(16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Amount:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(
                                '${AppConstants.currency}${CartService.instance.totalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isOrdering ? null : _handlePlaceOrder,
                              child: _isOrdering
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('Confirm & Place Order'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
