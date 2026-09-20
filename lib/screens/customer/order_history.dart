import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/order_card.dart';
import '../../utils/constants.dart';
import 'order_tracking.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customerId = AuthService.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Order History'),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: FirestoreService.instance.streamCustomerOrders(customerId),
        builder: (context, snapshot) {
          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 70, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No past orders yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                  ),
                  SizedBox(height: 6),
                  Text('Your completed and active orders will show up here.', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return OrderCard(
                    order: order,
                    actionButton: TextButton.icon(
                      icon: const Icon(Icons.navigation, size: 16),
                      label: const Text('Track'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderTrackingScreen(orderId: order.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
