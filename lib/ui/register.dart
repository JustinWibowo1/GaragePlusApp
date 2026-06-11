import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModel/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>{

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  String selectedRole = 'admin';
  
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  } 

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: InputDecoration(labelText: 'Role'),
              items: [
                DropdownMenuItem(value: 'mechanic', child: Text('Mechanic')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  // setState tells the screen to redraw with the new choice
                  setState(() {
                    selectedRole = newValue;
                  });
                }
              },
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: authViewModel.isLoading
                  ? null
                  : () async {
                      bool success = await authViewModel.register(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                        nameController.text.trim(),
                        selectedRole,
                      );
                      if (success) {
                        // Navigate to the next screen or show success message
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(authViewModel.errorMessage ?? 'Registration failed')),
                        );
                      }
                    },
              child: authViewModel.isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}