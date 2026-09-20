import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../login_screen.dart';
import 'menu_management.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Administration'),
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
          final orders = snapshot.data ?? [];

          final totalOrders = orders.length;
          double totalRevenue = 0.0;
          for (var o in orders) {
            totalRevenue += o.totalAmount;
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Live Restaurant Overview',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                    ),
                    const SizedBox(height: 6),
                    const Text('Real-time statistics across all restaurant departments.', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 24),

                    // Metrics Cards Grid
                    LayoutBuilder(
                      builder: (ctx, constraints) {
                        final isNarrow = constraints.maxWidth < 600;
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _buildStatCard('Total Orders', '$totalOrders', Icons.receipt_long, Colors.blue, width: isNarrow ? double.infinity : 200),
                            _buildStatCard('Total Revenue', '${AppConstants.currency}${totalRevenue.toStringAsFixed(0)}', Icons.monetization_on, Colors.green, width: isNarrow ? double.infinity : 200),
                            _buildStatCard('Active Tables', '5 Tables', Icons.table_restaurant, Colors.orange, width: isNarrow ? double.infinity : 200),
                            _buildStatCard('Registered Roles', '4 Roles', Icons.group, Colors.purple, width: isNarrow ? double.infinity : 200),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 36),

                    const Text(
                      'Management Modules',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkBrown),
                    ),
                    const SizedBox(height: 16),

                    // Module Cards
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.restaurant_menu, color: AppColors.primary),
                        ),
                        title: const Text('Manage Food Menu', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Add, edit, delete food items, categories, and prices'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MenuManagementScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.receipt_long, color: Colors.blue),
                        ),
                        title: const Text('All Live & Past Orders', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('$totalOrders total orders placed in system'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Show bottom sheet with all orders
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                            builder: (ctx) => DraggableScrollableSheet(
                              expand: false,
                              initialChildSize: 0.7,
                              maxChildSize: 0.9,
                              builder: (c, scrollCtrl) => ListView.builder(
                                controller: scrollCtrl,
                                itemCount: orders.length,
                                itemBuilder: (cx, idx) => ListTile(
                                  title: Text(orders[idx].id, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('${orders[idx].tableNumber} • ${orders[idx].status}'),
                                  trailing: Text('${AppConstants.currency}${orders[idx].totalAmount.toStringAsFixed(0)}'),
                                ),
                              ),
                            ),
                          );
                        },
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {required double width}) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 14),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkBrown)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
