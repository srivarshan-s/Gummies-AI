
import 'package:flutter/material.dart';

class ChoicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF131314), // Matching the main page background color
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/customer_signup'); // Navigate to SignupPage
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 250, // Increased size
                      height: 250, // Increased size
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white24,
                          width: 4.0,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 150, // Adjusted radius
                        backgroundColor: Color(0xFF1e1f20),
                        backgroundImage: AssetImage('assets/customer_circle.png'), // Use the provided file name
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Customer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30), // Add spacing between the two buttons
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/startup_signup'); // Navigate to SignupPage
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 250, // Increased size
                      height: 250, // Increased size
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white24,
                          width: 4.0,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 150, // Adjusted radius
                        backgroundColor: Color(0xFF1e1f20),
                        backgroundImage: AssetImage('assets/startup_circle.png'), // Use the provided file name
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Start up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
