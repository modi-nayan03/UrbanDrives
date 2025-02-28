import 'package:flutter/material.dart';
import 'package:zoomwheels/widget/bottom_navbar.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class LoginScreen extends StatefulWidget {
const LoginScreen({super.key});
@override
LoginScreenState createState() => LoginScreenState();
}
class LoginScreenState extends State<LoginScreen> {
final _formKey = GlobalKey<FormState>();
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
bool _obscureText = true;
bool _isLoading = false;
Future<void> _saveLoginData(String name, String email, String phone, String userId) async {
final prefs = await SharedPreferences.getInstance();
await prefs.setString('userName', name);
await prefs.setString('userRole', 'user'); // Always set to 'user' on login
await prefs.setString('email', email);
await prefs.setString('phone', phone);
await prefs.setString('userId', userId); // Store the userId here
}
@override
void dispose() {
_emailController.dispose();
_passwordController.dispose();
super.dispose();
}
String? _validateEmail(String? value) {
if (value == null || value.isEmpty) {
return 'Please enter your email';
}
if (!RegExp(r'^[\w-]+(.[\w-]+)*@([\w-]+.)+[a-zA-Z]{2,7}$')
.hasMatch(value)) {
return 'Please enter a valid email';
}
return null;
}
String? _validatePassword(String? value) {
if (value == null || value.isEmpty) {
return 'Please enter your password';
}
if (value.length < 8) {
return 'Password must be at least 8 characters';
}
return null;
}
void _submitForm() async {
if (_formKey.currentState!.validate()) {
setState(() {
_isLoading = true;
});
final email = _emailController.text;
  final password = _passwordController.text;

  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final userName = responseData['userName'];
      final email = responseData['email'];
      final phone = responseData['phone'];
      final userId = responseData['userId']; // Extract the userId from the login response

      await _saveLoginData(userName, email, phone, userId);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BottomNavBar(
            userName: userName,
            userEmail: email,
            userId: userId, //Pass It
            initialIndex: 0,
          ),
        ),
      );
    } else {
      final responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'])),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to connect to server')),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
} else {
  FocusScope.of(context).requestFocus(FocusNode());
}
}
@override
Widget build(BuildContext context) {
return Scaffold(
body: Padding(
padding: const EdgeInsets.all(20.0),
child: Form(
key: _formKey,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const SizedBox(height: 50),
const Text(
'Hi! Welcome Back',
style: TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
color: Colors.black87),
),
const Text(
'Log into your account',
style: TextStyle(
fontSize: 16,
color: Colors.grey,
),
),
const SizedBox(height: 30),
TextFormField(
controller: _emailController,
keyboardType: TextInputType.emailAddress,
decoration: InputDecoration(
prefixIcon: const Icon(Icons.email_outlined),
hintText: 'johndoe@gmail.com',
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
borderSide: const BorderSide(color: Colors.grey)),
),
validator: _validateEmail,
),
const SizedBox(height: 20),
TextFormField(
controller: _passwordController,
obscureText: _obscureText,
decoration: InputDecoration(
prefixIcon: const Icon(Icons.vpn_key_outlined),
hintText: '********',
suffixIcon: IconButton(
icon: Icon(
_obscureText ? Icons.visibility_off : Icons.visibility),
onPressed: () {
setState(() {
_obscureText = !_obscureText;
});
},
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
borderSide: const BorderSide(color: Colors.grey)),
),
validator: _validatePassword,
),
Align(
alignment: Alignment.topRight,
child: TextButton(
onPressed: () {
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) => const ForgotPasswordScreen()),
);
},
child: const Text('Forgot Password?',
style: TextStyle(color: Colors.blue))),
),
const SizedBox(height: 20),
SizedBox(
width: double.infinity,
child: _isLoading
? const Center(child: CircularProgressIndicator())
: ElevatedButton(
onPressed: _submitForm,
style: ElevatedButton.styleFrom(
backgroundColor: Colors.blue,
padding: const EdgeInsets.symmetric(vertical: 16),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(10))),
child: const Text(
'Log In',
style: TextStyle(color: Colors.white, fontSize: 18),
),
),
),
const SizedBox(height: 30),
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Text("Don't have an account?",
style: TextStyle(fontSize: 16, color: Colors.grey)),
TextButton(
onPressed: () {
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) => const RegisterScreen()),
);
},
child: const Text('Sign Up',
style: TextStyle(fontSize: 16, color: Colors.blue)))
],
),
],
),
),
),
);
}
}
