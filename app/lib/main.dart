import 'package:app/firebase_options.dart';
import 'package:app/pages/admin_home_page.dart';
import 'package:app/pages/admin_inventory_page.dart';
import 'package:app/pages/admin_profile.dart';
import 'package:app/pages/inventory_page.dart';
import 'package:app/pages/user_profile.dart';
import 'package:app/services/auth/login_or_register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/pages/work_order_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Field Service App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginOrRegister(), //login page
      routes: {
        '/home_page': (context) =>
            const HomepageWidget(), // Define the home page route
        '/inventory_page': (context) =>
            const InventoryWidget(), // Inventory page route
        '/work_order_page': (context) =>
            const WorkOrderWidget(), // Add the work order page route
        '/admin_page': (context) =>
            const AdminWidget(), // Add your Admin Page here
        '/admin_profile': (context) =>
            const ProfileAdminWidget(), // Add the admin profile page route
        '/user_profile': (context) => const ProfileUserWidget(),
        '/admin_inventory_page': (context) => const AdminInventoryWidget()
      },
    );
  }
}
