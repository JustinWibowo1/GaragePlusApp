import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ui/menu/home.dart';

class RoleRouter extends StatefulWidget {
  const RoleRouter({super.key});

  @override
  State<RoleRouter> createState() => _RoleRouterState();
}

class _RoleRouterState extends State<RoleRouter> {
  bool _isLoading = true;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final response = await Supabase.instance.client
          .from('user') 
          .select('role')
          .eq('id', userId)
          .single(); 

      if (!mounted) return;
      setState(() {
        _userRole = response['role'];
        _isLoading = false;
      });
      
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a quick loading spinner while checking the database
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Teleport the user based on their role
    if (_userRole == 'admin') {
      return const AdminDashboard();
    } else if (_userRole == 'mechanic') {
      // return const MechanicDashboard();
      return Scaffold(
        body: Center(
          child: Text('Mechanic Dashboard - Coming Soon!'),
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error: Role not found or unauthorized.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                },
                child: const Text('Log Out'),
              )
            ],
          ),
        ),
      );
    }
  }
}