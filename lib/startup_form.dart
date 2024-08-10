import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StartupFormPage extends StatefulWidget {
  @override
  _StartupFormPageState createState() => _StartupFormPageState();
}

class _StartupFormPageState extends State<StartupFormPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF131314),
        ),
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 80), // Added padding to the entire background
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: _currentStep == 0 ? _buildFirstPage() : _buildSecondPage(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFirstPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Image.asset('assets/startup_form1.png', height: 300),
        ),
        SizedBox(height: 5),
        Center(
          child: const Text(
            'Tell us more about your small business',
            style: TextStyle(
                color: Color.fromRGBO(182, 109, 164, 1),
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          children: [
            const Text(
              'Click on this icon to Auto-correct grammar.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                // Handle icon click
                print('Icon clicked!');
              },
              child: Image.asset('assets/google-gemini-icon.png', width: 20, height: 20),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'In which year was your company founded?',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Where is your headquarters located?',
        ),
        const SizedBox(height: 20),
        _buildExpandableTextField(
          label: 'Provide a brief description of your company, its mission, and the industry in which it operates.',
        ),
        const SizedBox(height: 20),
        _buildExpandableTextField(
          label: 'What are your main products or services, and who is your primary target market?',
        ),
        const SizedBox(height: 20),
        _buildExpandableTextField(
          label: 'How would you describe your company’s position in the market, and what sets your company apart from its competitors?',
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _currentStep = 1;
              });
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              backgroundColor: Color(0xFF1e1f20),
              foregroundColor: Colors.white,
              textStyle: TextStyle(
                fontSize: 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text('Next'),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Image.asset('assets/startup_form2.png', height: 300),
        ),
        const SizedBox(height: 5),
        _buildExpandableTextField(
          label: 'Provide a brief overview of your company\'s financial performance and its growth strategy for the next 5 years.',
        ),
        const SizedBox(height: 20),
        _buildExpandableTextField(
          label: 'What is your business model? How does your company generate revenue?',
        ),
        const SizedBox(height: 20),
        _buildExpandableTextField(
          label: 'What investment opportunities are available?',
        ),
        const SizedBox(height: 20),
        _buildExpandableTextField(
          label: 'Who should potential investors contact for more information?',
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              // Handle image upload
            },
            icon: Icon(Icons.upload, color: Colors.white),
            label: Text('Upload Logo', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15), // Made the button longer
              backgroundColor: Color.fromRGBO(182, 109, 164, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStep = 0;
                });
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Color(0xFF1e1f20),
                foregroundColor: Colors.white,
                textStyle: TextStyle(
                  fontSize: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('Back'),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                // Handle form submission
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Color(0xFF1e1f20),
                foregroundColor: Colors.white,
                textStyle: TextStyle(
                  fontSize: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('Submit'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        SizedBox(height: 8),
        Stack(
          children: [
            TextFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFF1e1f20),
                contentPadding: EdgeInsets.only(top: 20, left: 40), // Added top padding
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
            ),
            // Positioned(
            //   top: 8,
            //   right: 8,
            //   child: GestureDetector(
            //     onTap: () {
            //       // Handle icon click
            //       print('Icon clicked!');
            //     },
            //     child: Image.asset('assets/google-gemini-icon.png', width: 20, height: 20), // Icon on the top left corner
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandableTextField({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        SizedBox(height: 8),
        Stack(
          children: [
            TextFormField(
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFF1e1f20),
                contentPadding: EdgeInsets.only(top: 20, right: 40, left: 20), // Added top padding
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
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  // Handle icon click
                  print('Icon clicked!');
                },
                child: Padding(
                  padding: EdgeInsets.all(4.0), // Added padding to the icon
                  child: Image.asset('assets/google-gemini-icon.png', width: 20, height: 20), // Icon on the top left corner
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageUploadField({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        SizedBox(height: 13),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              // Handle image upload
            },
            icon: Icon(Icons.upload, color: Colors.white),
            label: Text('Upload Logo', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15), // Made the button longer
              backgroundColor: Color.fromRGBO(182, 109, 164, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
