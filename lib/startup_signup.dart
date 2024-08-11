import 'package:flutter/material.dart';
import 'startup_form.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class StartupSignupPage extends StatefulWidget {
  @override
  _StartupSignupPageState createState() => _StartupSignupPageState();
}

class _StartupSignupPageState extends State<StartupSignupPage> {
  bool _isHoveringSubmit = false;
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  final _auth = FirebaseAuth.instance;

  void _submit() async{
    if (_formKey.currentState!.validate()) {
      String companyName = _companyNameController.text;
      String companyEmail = _companyEmailController.text;
      String password = _passwordController.text;

      _formKey.currentState!.save();
    try {
      // Store company in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: companyEmail,
        password: password,
      );
      print('Sign-up successful: ${userCredential.user}');

      // Store company details in MongoDB
      final mongoDBCompanyId = await _storeCompanyInMongoDB(
          companyName, companyEmail, userCredential.user!.uid);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup successful')),
      );

      // Navigate to the next page (e.g., a form for additional company details)
      Navigator.pushNamed(
        context,
        '/customer_form',
        arguments: mongoDBCompanyId,
      );
    } on FirebaseAuthException catch (e) {
      // Handle sign-up error
      print('Sign-up failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-up failed: ${e.message}')),
      );
    }
    }
  }

  Future<String> _storeCompanyInMongoDB(String companyName, String companyEmail, String uid) async {
  // Prepare the company data
  final companyData = {
    'companyName': companyName,
    'companyEmail': companyEmail,
    'firebaseUid': uid,
    'createdAt': DateTime.now().toIso8601String(),
  };

  // Replace with your MongoDB API endpoint
  final url = 'http://10.0.2.2:3000/store_company';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(companyData),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['id']; 
    } else {
      throw Exception('Failed to store company in MongoDB');
    }
  } catch (e) {
    print('Error storing company in MongoDB: $e');
    throw e;
  }
}

  String? _validateCompanyName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your company name';
    }
    return null;
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

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
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
                  Image.asset('assets/signup_startup.png', height: 350), // Add an image in your assets
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _companyNameController,
                    decoration: InputDecoration(
                      labelText: 'Company Name',
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Color(0xFF1e1f20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Color.fromRGBO(182,109,164,1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.white60),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    validator: _validateCompanyName,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _companyEmailController,
                    decoration: InputDecoration(
                      labelText: 'Company Email',
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Color(0xFF1e1f20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Color.fromRGBO(182,109,164,1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.white60),
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
                        borderSide: BorderSide(color: Color.fromRGBO(182,109,164,1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.white60),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8.0, 15.0, 8.0),
                        child: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Color.fromRGBO(182,109,164,1),
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
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Re-enter Password',
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Color(0xFF1e1f20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Color.fromRGBO(182,109,164,1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.white60),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8.0, 15.0, 8.0),
                        child: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Color.fromRGBO(182,109,164,1),
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
                    validator: _validateConfirmPassword,
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
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        backgroundColor: _isHoveringSubmit ? Colors.blue : Color(0xFF1e1f20),
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
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      "Already have an account? Sign in",
                      style: TextStyle(color: Color.fromRGBO(182,109,164,1)),
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
