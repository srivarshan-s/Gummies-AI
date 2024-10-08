import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isHoveringSubmit = false;
  String? userId;
  Map<String, dynamic>? userData;
  bool _isEditing =
      false; // State variable to toggle between view and edit mode
  File? _profileImage;

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

  Future<void> _editUser(String userId, Map<String, String> userData) async {
    try {
      print(userData);
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/edit_user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'userData': userData,
        }),
      );

      if (response.statusCode == 200) {
        print('User updated successfully');
      } else {
        print('Failed to update user: ${response.body}');
      }
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  void _submitEditForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Map<String, String> updatedData = {
        'name': userData!['name']!,
        'email': userData!['email']!,
      };

      _editUser(userId!, updatedData);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile details saved')),
    );
  }

  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    final url = 'http://10.0.2.2:3000/get_user_data?user_id=$userId';

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

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Implement form submission logic
      print(
          'Profile updated: ${userData!['displayName']}, ${userData!['email']}');
      _toggleEditMode();
    }
  }

  Future<void> _updateProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected')),
      );
    }
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  final _formKey = GlobalKey<FormState>();

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
              child: _isEditing ? _buildEditForm() : _buildProfileView(),
            ),
      backgroundColor: Color(0xFF131314),
    );
  }

  Widget _buildProfileView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        Stack(
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/dummy_profilePic.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: CircleAvatar(
                radius: 100,
                backgroundImage: NetworkImage(userData!['profileImage'] ?? ''),
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Text(
          userData!['displayName'] ?? 'Name not available',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(182, 109, 164, 1),
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
        SizedBox(height: 20),
        MouseRegion(
          onEnter: (_) => setState(() {
            _isHoveringSubmit = true;
          }),
          onExit: (_) => setState(() {
            _isHoveringSubmit = false;
          }),
          child: ElevatedButton(
            onPressed: _toggleEditMode,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
            child: Text('Edit Profile'),
          ),
        ),
        SizedBox(height: 20),
        Divider(color: Color.fromRGBO(182, 109, 164, 1)),
        SizedBox(height: 20),
        _buildPortfolioDetails(),
        SizedBox(height: 20),
        MouseRegion(
          onEnter: (_) => setState(() {
            _isHoveringSubmit = true;
          }),
          onExit: (_) => setState(() {
            _isHoveringSubmit = false;
          }),
          child: ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
            child: Text('Logout'),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          GestureDetector(
            onTap: _updateProfilePicture,
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/dummy_profilePic.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 100,
                          backgroundImage:
                              NetworkImage(userData!['profileImage'] ?? ''),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: -13,
                        child: IconButton(
                          icon: Icon(Icons.camera_alt, color: Colors.white),
                          onPressed: _updateProfilePicture,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            initialValue: userData!['displayName'] ?? '',
            decoration: InputDecoration(
              labelText: 'User Name',
              labelStyle: TextStyle(color: Colors.white),
              filled: true,
              fillColor: Color(0xFF1e1f20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Color.fromRGBO(182, 109, 164, 1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.white60),
              ),
            ),
            style: TextStyle(color: Colors.white),
            onSaved: (value) => userData!['name'] = value!,
          ),
          SizedBox(height: 20),
          TextFormField(
            initialValue: userData!['email'] ?? '',
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
                borderSide: BorderSide(color: Color.fromRGBO(182, 109, 164, 1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.white60),
              ),
            ),
            style: TextStyle(color: Colors.white),
            onSaved: (value) => userData!['email'] = value!,
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
              onPressed: _submitEditForm,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
        ],
      ),
    );
  }

  Widget _buildPortfolioDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Portfolio Value:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10),
        Text(
          '\$${userData!['portfolioValue'] ?? 'N/A'}',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Current Holdings:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10),
        Text(
          userData!['currentHoldings'] ?? 'No holdings available',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Investment Performance:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10),
        Text(
          userData!['investmentPerformance'] ?? 'No performance data available',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
