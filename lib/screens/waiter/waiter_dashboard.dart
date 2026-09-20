import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/order_card.dart';
import '../login_screen.dart';

class WaiterDashboard extends StatefulWidget {
  const WaiterDashboard({super.key});

  @override
  State<WaiterDashboard> createState() => _WaiterDashboardState();
}

class _WaiterDashboardState extends State<WaiterDashboard> {
  String _filter = 'Ready';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiter Service Console'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (r) => false,
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: FirestoreService.instance.streamOrders(),
        builder: (context, snapshot) {
          final allOrders = snapshot.data ?? [];

          final readyOrders = allOrders.where((o) => o.status == OrderStatus.ready).toList();
          final activeOrders = allOrders.where((o) => o.status == OrderStatus.placed || o.status == OrderStatus.preparing).toList();
          final servedOrders = allOrders.where((o) => o.status == OrderStatus.served).toList();

          List<OrderModel> currentOrders = readyOrders;
          if (_filter == 'Active') {
            currentOrders = activeOrders;
          } else if (_filter == 'Served') {
            currentOrders = servedOrders;
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  // Filter Chips (Ready, Active, Served)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFilterChip('Ready', 'Ready (${readyOrders.length})', AppColors.statusReady),
                        _buildFilterChip('Active', 'In Progress (${activeOrders.length})', AppColors.statusPreparing),
                        _buildFilterChip('Served', 'Completed (${servedOrders.length})', AppColors.statusServed),
                      ],
                    ),
                  ),

                  // Orders List
                  Expanded(
                    child: currentOrders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.room_service, size: 64, color: Colors.grey),
                                const SizedBox(height: 12),
                                Text(
                                  'No $_filter orders found.',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: currentOrders.length,
                            itemBuilder: (context, index) {
                              final order = currentOrders[index];

                              Widget? actionButton;
                              if (order.status == OrderStatus.ready) {
                                actionButton = ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.statusServed,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.check, size: 18),
                                  label: const Text('Mark Served'),
                                  onPressed: () async {
                                    await FirestoreService.instance.updateOrderStatus(order.id, OrderStatus.served);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Order #${order.id} marked as Served to ${order.tableNumber}!'),
                                          backgroundColor: AppColors.statusServed,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                                );
                              }

                              return OrderCard(order: order, actionButton: actionButton);
                            },
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

  Widget _buildFilterChip(String key, String label, Color activeColor) {
    final isSelected = _filter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: activeColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (val) {
        if (val) {
          setState(() => _filter = key);
        }
      },
    );
  }
}
