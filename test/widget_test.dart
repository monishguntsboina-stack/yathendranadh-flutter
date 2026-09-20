import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_restaurant/main.dart';
import 'package:smart_restaurant/screens/login_screen.dart';
import 'package:smart_restaurant/screens/customer/customer_home.dart';
import 'package:smart_restaurant/screens/waiter/waiter_dashboard.dart';
import 'package:smart_restaurant/screens/kitchen/kitchen_dashboard.dart';
import 'package:smart_restaurant/screens/admin/admin_dashboard.dart';

void main() {
  testWidgets('Splash screen branding and navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartRestaurantApp());

    expect(find.text('Smart Restaurant'), findsOneWidget);
    expect(find.text('Serving System'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
  });

  testWidgets('Login screen validation and quick logins', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Waiter'), findsOneWidget);
    expect(find.text('Kitchen'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
  });

  testWidgets('Customer Home renders menu and search', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CustomerHome()));
    await tester.pump();

    expect(find.text('Smart Restaurant Menu'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.text('Starters'), findsWidgets);
  });

  testWidgets('Waiter dashboard renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: WaiterDashboard()));
    await tester.pump();

    expect(find.text('Waiter Service Console'), findsOneWidget);
  });

  testWidgets('Kitchen dashboard renders tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: KitchenDashboard()));
    await tester.pump();

    expect(find.text('Kitchen Display System'), findsOneWidget);
    expect(find.text('New Orders'), findsOneWidget);
    expect(find.text('Preparing'), findsOneWidget);
    expect(find.text('Ready to Serve'), findsOneWidget);
  });

  testWidgets('Admin dashboard renders statistics', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdminDashboard()));
    await tester.pump();

    expect(find.text('Restaurant Administration'), findsOneWidget);
    expect(find.text('Live Restaurant Overview'), findsOneWidget);
    expect(find.text('Manage Food Menu'), findsOneWidget);
  });
}
