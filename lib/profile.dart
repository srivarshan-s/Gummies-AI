import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userId;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      if (args != null) {
        setState(() {
          userId = args;
        });
        _fetchUserData(args).then((data) {
          setState(() {
            userData = data;
          });
        });
      }
    });
  }

  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    final url = 'http://10.0.2.2:5000/get_user_data?user_id=$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        return userData;
      } else {
        print('Failed to fetch user: ${response.body}');
        throw Exception('Failed to fetch user');
      }
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFF1e1f20),
      ),
      body: userId == null || userData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        NetworkImage(userData!['profileImageUrl'] ?? ''),
                    backgroundColor: Colors.grey[200],
                  ),
                  SizedBox(height: 20),
                  Text(
                    userData!['displayName'] ?? 'Name not available',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    userData!['email'] ?? 'Email not available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'User ID: $userId',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(color: Colors.white60),
                  SizedBox(height: 20),
                  Text(
                    'Additional Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Additional details can be displayed here
                ],
              ),
            ),
      backgroundColor: Color(0xFF131314),
    );
  }
}
