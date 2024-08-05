import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isHoveringSubmit = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  final _auth = FirebaseAuth.instance;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      // Handle login with valid inputs
      String email = _emailController.text;
      String password = _passwordController.text;

      // Implement your authentication logic here
      // For now, just print the email and password
      print('Email: $email');
      print('Password: $password');

      _formKey.currentState!.save();
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Navigate to home screen or show success message
        print('Login successful: ${userCredential.user}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful')),
        );
      } on FirebaseAuthException catch (e) {
        // Handle error
        print('Login failed: $e');
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    // Basic email validation
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF131314),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/login_image.png',
                      height: 450), // Add an image in your assets
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Color(0xFF1e1f20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            BorderSide(color: Color.fromRGBO(182, 109, 164, 1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.white60),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Icon(
                          Icons.person,
                          color: Color.fromRGBO(182, 109, 164, 1),
                        ),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    validator: _validateEmail,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Color(0xFF1e1f20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            BorderSide(color: Color.fromRGBO(182, 109, 164, 1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.white60),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Icon(
                          Icons.lock,
                          color: Color.fromRGBO(182, 109, 164, 1),
                        ),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8.0, 15.0, 8.0),
                        child: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Color.fromRGBO(182, 109, 164, 1),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    obscureText: !_isPasswordVisible,
                    validator: _validatePassword,
                  ),
                  SizedBox(height: 20),
                  MouseRegion(
                    onEnter: (_) => setState(() {
                      _isHoveringSubmit = true;
                    }),
                    onExit: (_) => setState(() {
                      _isHoveringSubmit = false;
                    }),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context,
                            '/customer_form'); // Navigate to Sign Up Page
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        backgroundColor:
                            _isHoveringSubmit ? Colors.blue : Color(0xFF1e1f20),
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text('Submit'),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/choice');
                    },
                    child: Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(color: Color.fromRGBO(182, 109, 164, 1)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
