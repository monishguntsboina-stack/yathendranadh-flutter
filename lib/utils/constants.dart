import 'package:flutter/material.dart';

/// App Constants for Smart Restaurant Serving System
class AppColors {
  // Warm restaurant theme colors
  static const Color primary = Color(0xFFE65100); // Warm Orange
  static const Color primaryDark = Color(0xFFBF360C); // Deep Orange
  static const Color primaryLight = Color(0xFFFFCC80); // Light Warm Amber
  static const Color accent = Color(0xFFFFA000); // Amber Accent

  // Background and surface colors
  static const Color background = Color(0xFFFDFBF7); // Warm Light Cream
  static const Color surface = Colors.white;
  static const Color darkBrown = Color(0xFF3E2723); // Dark Brown
  static const Color textPrimary = Color(0xFF261C14);
  static const Color textSecondary = Color(0xFF795548);
  static const Color divider = Color(0xFFEEEEEE);

  // Status colors
  static const Color statusPlaced = Color(0xFF1976D2); // Blue
  static const Color statusPreparing = Color(0xFFF57C00); // Orange
  static const Color statusReady = Color(0xFF388E3C); // Green
  static const Color statusServed = Color(0xFF6A1B9A); // Purple
}

class UserRoles {
  static const String customer = 'customer';
  static const String waiter = 'waiter';
  static const String kitchen = 'kitchen';
  static const String admin = 'admin';

  static const List<String> allRoles = [customer, waiter, kitchen, admin];

  static String getDisplayName(String role) {
    switch (role) {
      case customer:
        return 'Customer';
      case waiter:
        return 'Waiter';
      case kitchen:
        return 'Kitchen Staff';
      case admin:
        return 'Admin';
      default:
        return role;
    }
  }
}

class OrderStatus {
  static const String placed = 'Placed';
  static const String preparing = 'Preparing';
  static const String ready = 'Ready';
  static const String served = 'Served';

  static const List<String> allStatuses = [placed, preparing, ready, served];

  static Color getStatusColor(String status) {
    switch (status) {
      case placed:
        return AppColors.statusPlaced;
      case preparing:
        return AppColors.statusPreparing;
      case ready:
        return AppColors.statusReady;
      case served:
        return AppColors.statusServed;
      default:
        return Colors.grey;
    }
  }
}

class FoodCategories {
  static const String starters = 'Starters';
  static const String mainCourse = 'Main Course';
  static const String rice = 'Rice';
  static const String beverages = 'Beverages';
  static const String desserts = 'Desserts';

  static const List<String> allCategories = [
    'All',
    starters,
    mainCourse,
    rice,
    beverages,
    desserts,
  ];
}

class AppConstants {
  static const String appName = 'Smart Restaurant';
  static const String appTagline = 'Serving System';
  static const String currency = '₹';
}
