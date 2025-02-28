import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart'; // Import your login screen

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String resetToken;
  const ResetPasswordScreen({super.key, required this.email, required this.resetToken});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;
   bool _isLoading = false;
    String? _errorMessage;

   @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length != 8) {
      return 'Password must be exactly 8 characters';
    }
     if (!RegExp(r'^(?=.*?[A-Za-z0-9]).{8,}$')
         .hasMatch(value)) {
      return 'Password must have at least 8 character';
    }
    return null;
  }

 Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });

      final String newPassword = _newPasswordController.text;
     
      try {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:5000/reset-password'),
          headers: {'Content-Type': 'application/json'},
           body: jsonEncode({
            'email': widget.email,
            'reset_token': widget.resetToken,
            'new_password': newPassword,
           }),
        );
         if (response.statusCode == 200) {
               Navigator.pushReplacement(
                 context,
                 MaterialPageRoute(builder: (context) => const LoginScreen()),
               );
          } else {
            final responseData = jsonDecode(response.body);
            setState(() {
              _errorMessage = responseData['message'] ?? 'Failed to reset password';
            });
          }

      } catch (error) {
          setState(() {
              _errorMessage = 'Failed to connect to the server, check your internet';
           });
      } finally {
        setState(() {
            _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
         title: const Text(''),
      ),
      body: Stack(
        children: [
           SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
             child: Form(
                  key: _formKey,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                   const SizedBox(height: 20),
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      ),
                  ),
                  const SizedBox(height: 8),
                   const Text(
                     'Enter your new password',
                       style: TextStyle(fontSize: 16, color: Colors.grey),
                       ),
                     const SizedBox(height: 30),
                     // New Password Input
                     TextFormField(
                       controller: _newPasswordController,
                       obscureText: !_newPasswordVisible,
                        decoration: InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: const Icon(Icons.key),
                        suffixIcon: IconButton(
                            icon: Icon(
                                _newPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            ),
                             onPressed: () {
                                setState(() {
                                  _newPasswordVisible = !_newPasswordVisible;
                                  });
                            },
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                         validator: _validatePassword,
                         inputFormatters: [
                           LengthLimitingTextInputFormatter(8),
                         ],
                    ),
                   const SizedBox(height: 16),
                    // Confirm Password Input
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_confirmPasswordVisible,
                      decoration: InputDecoration(
                         labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.key),
                         suffixIcon: IconButton(
                            icon: Icon(
                              _confirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                           ),
                            onPressed: () {
                              setState(() {
                                _confirmPasswordVisible = !_confirmPasswordVisible;
                              });
                            },
                          ),
                       border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                         if (value == null || value.isEmpty) {
                           return 'Please confirm your password';
                         }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                           }
                         return _validatePassword(value);
                         },
                           inputFormatters: [
                            LengthLimitingTextInputFormatter(8),
                          ],
                    ),
                   const SizedBox(height: 30),
                    // Continue Button
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: _isLoading ? null :  _handleResetPassword,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.blue,
                         padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(8),
                           ),
                      ),
                       child:  _isLoading ?  const CircularProgressIndicator(color: Colors.white,) : const Text(
                         'Continue',
                           style: TextStyle(fontSize: 18, color: Colors.white),
                       ),
                      ),
                    ),
                  if (_errorMessage != null)
                   Padding(
                       padding: const EdgeInsets.only(top: 16.0),
                     child: Text(
                       _errorMessage!,
                       style: const TextStyle(color: Colors.red),
                       ),
                    ),
                    ],
                ),
           ),
         ),
      ],
      )
    );
  }
}