import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Order Tracking'),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: FirestoreService.instance.streamOrders(),
        builder: (context, snapshot) {
          final orders = snapshot.data ?? [];
          final order = orders.firstWhere(
            (o) => o.id == orderId,
            orElse: () => OrderModel(
              id: orderId,
              customerId: '',
              customerName: 'Customer',
              tableNumber: 'Table 1',
              items: [],
              totalAmount: 0.0,
              status: OrderStatus.placed,
              createdAt: DateTime.now(),
            ),
          );

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
                  children: [
                    // Order Summary Banner
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order #${order.id}',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Text('Table: ${order.tableNumber}', style: const TextStyle(color: AppColors.textSecondary)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: OrderStatus.getStatusColor(order.status).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    order.status,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: OrderStatus.getStatusColor(order.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Vertical Timeline Status Stepper
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            _buildTimelineStep(
                              icon: Icons.receipt_long,
                              title: 'Order Placed',
                              subtitle: 'Kitchen has received your order',
                              isDone: true,
                              isActive: order.status == OrderStatus.placed,
                              isLast: false,
                            ),
                            _buildTimelineStep(
                              icon: Icons.soup_kitchen,
                              title: 'Kitchen Preparing',
                              subtitle: 'Chefs are preparing fresh food',
                              isDone: order.status == OrderStatus.preparing ||
                                  order.status == OrderStatus.ready ||
                                  order.status == OrderStatus.served,
                              isActive: order.status == OrderStatus.preparing,
                              isLast: false,
                            ),
                            _buildTimelineStep(
                              icon: Icons.check_circle_outline,
                              title: 'Food is Ready',
                              subtitle: 'Waiter is picking up your tray',
                              isDone: order.status == OrderStatus.ready || order.status == OrderStatus.served,
                              isActive: order.status == OrderStatus.ready,
                              isLast: false,
                            ),
                            _buildTimelineStep(
                              icon: Icons.room_service,
                              title: 'Served at Table',
                              subtitle: 'Enjoy your meal!',
                              isDone: order.status == OrderStatus.served,
                              isActive: order.status == OrderStatus.served,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isActive,
    required bool isLast,
  }) {
    final color = isDone ? Colors.green : Colors.grey.shade400;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDone ? Colors.green.shade50 : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: isDone ? Colors.green : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDone ? AppColors.darkBrown : Colors.grey,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                if (isActive)
                  const Padding(
                    padding: EdgeInsets.only(top: 6.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'In Progress...',
                          style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
