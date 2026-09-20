import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'customer/customer_home.dart';
import 'waiter/waiter_dashboard.dart';
import 'kitchen/kitchen_dashboard.dart';
import 'admin/admin_dashboard.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AuthService.instance.currentUserNotifier,
      builder: (context, user, _) {
        if (user == null) {
          return const LoginScreen();
        }

        // Redirect based on user role
        switch (user.role) {
          case UserRoles.waiter:
            return const WaiterDashboard();
          case UserRoles.kitchen:
            return const KitchenDashboard();
          case UserRoles.admin:
            return const AdminDashboard();
          case UserRoles.customer:
          default:
            return const CustomerHome();
        }
      },
    );
  }
}
