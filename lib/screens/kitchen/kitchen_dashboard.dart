import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/order_card.dart';
import '../login_screen.dart';

class KitchenDashboard extends StatefulWidget {
  const KitchenDashboard({super.key});

  @override
  State<KitchenDashboard> createState() => _KitchenDashboardState();
}

class _KitchenDashboardState extends State<KitchenDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Display System'),
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.new_releases_outlined), text: 'New Orders'),
            Tab(icon: Icon(Icons.soup_kitchen_outlined), text: 'Preparing'),
            Tab(icon: Icon(Icons.check_circle_outlined), text: 'Ready to Serve'),
          ],
        ),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: FirestoreService.instance.streamOrders(),
        builder: (context, snapshot) {
          final allOrders = snapshot.data ?? [];

          final placedOrders = allOrders.where((o) => o.status == OrderStatus.placed).toList();
          final preparingOrders = allOrders.where((o) => o.status == OrderStatus.preparing).toList();
          final readyOrders = allOrders.where((o) => o.status == OrderStatus.ready).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersList(placedOrders, 'No new orders right now', isNew: true),
              _buildOrdersList(preparingOrders, 'No orders currently preparing', isPreparing: true),
              _buildOrdersList(readyOrders, 'No ready orders waiting for waiter', isReady: true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders, String emptyMsg, {bool isNew = false, bool isPreparing = false, bool isReady = false}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(emptyMsg, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];

            Widget? actionButton;
            if (isNew) {
              actionButton = ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusPreparing,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Start Preparing'),
                onPressed: () async {
                  await FirestoreService.instance.updateOrderStatus(order.id, OrderStatus.preparing);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Order #${order.id} is now Preparing'),
                        backgroundColor: AppColors.statusPreparing,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              );
            } else if (isPreparing) {
              actionButton = ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusReady,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.done_all, size: 18),
                label: const Text('Mark as Ready'),
                onPressed: () async {
                  await FirestoreService.instance.updateOrderStatus(order.id, OrderStatus.ready);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Order #${order.id} is Ready! Waiter notified.'),
                        backgroundColor: AppColors.statusReady,
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
    );
  }
}
