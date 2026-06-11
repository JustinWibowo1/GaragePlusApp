import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModel/auth_viewmodel.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
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
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: authViewModel.isLoading
                  ? null
                  : () async {
                      bool success = await authViewModel.login(
                        emailController.text,
                        passwordController.text,
                      );
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Login successful!'),
                          backgroundColor: Colors.green, // Optional: green for success
                          duration: Duration(seconds: 2),
                        ),
                      );
                      } else {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(authViewModel.errorMessage ?? 'Login failed')),
                        );
                      }
                    },
              child: authViewModel.isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}