import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'ui/menu/add_car.dart';
import 'ui/menu/edit_car_screen.dart';
import 'ui/menu/service_screen.dart';
import 'viewModel/auth_viewmodel.dart'; 
import 'ui/login.dart';
import 'role_router.dart'; 
import 'ui/menu/home.dart';
import 'viewModel/car_viewmodel.dart';
import 'viewModel/menu_sidebar_viewmodel.dart';
import 'viewModel/order_kerja/order_kerja_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  await Supabase.initialize(
    url: 'https://srokhycoyhclqfnvzfgq.supabase.co',
    anonKey: 'sb_publishable_aj-RTC9DBD0uBfkdP2IYYw_iMBYp0BB',
  );

  runApp(const ServiceApp());
}

class ServiceApp extends StatelessWidget {
  const ServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CarViewModel()),
        ChangeNotifierProvider(create: (_) => OrderKerjaViewModel()),
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
      ],
      child: MaterialApp(
        title: 'Garage Plus',
        debugShowCheckedModeBanner: false, 
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        
        home: const AuthGate(), 

        routes: {
          '/login': (context) => LoginScreen(), 
          '/role_router': (context) => const RoleRouter(),
          '/admin_dashboard': (context) => const AdminDashboard(),
          '/add_car': (context) => const AddCarScreen(),
          '/services': (context) => const ServicesScreen(),
          '/edit_car': (context) => const EditCarScreen(),
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return const RoleRouter(); 
        } else {
          return LoginScreen(); 
        }
      },
    );
  }
}