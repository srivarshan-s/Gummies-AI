import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StartupFormPage extends StatefulWidget {
  @override
  _StartupFormPageState createState() => _StartupFormPageState();
}

class _StartupFormPageState extends State<StartupFormPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  File? _profileImage;

  String? companyID;

  // Controllers to capture user input
  final TextEditingController _yearFoundedController = TextEditingController();
  final TextEditingController _headquartersController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _productsController = TextEditingController();
  final TextEditingController _marketPositionController =
      TextEditingController();
  final TextEditingController _financialPerformanceController =
      TextEditingController();
  final TextEditingController _businessModelController =
      TextEditingController();
  final TextEditingController _investmentOpportunitiesController =
      TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Retrieve the MongoDB user ID passed as an argument and store it in the state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      setState(() {
        companyID = args;
      });
    });
  }

  Future<void> _submitForm() async {
    final formData = {
      'yearFounded': _yearFoundedController.text,
      'headquarters': _headquartersController.text,
      'description': _descriptionController.text,
      'products': _productsController.text,
      'marketPosition': _marketPositionController.text,
      'financialPerformance': _financialPerformanceController.text,
      'businessModel': _businessModelController.text,
      'investmentOpportunities': _investmentOpportunitiesController.text,
      'contactInfo': _contactInfoController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/store_company_data'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(formData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Form submitted successfully!')),
        );

        Navigator.pushNamed(context, '/news', arguments: companyID);
      } else {
        throw Exception('Failed to submit form');
      }
    } catch (e) {
      print('Error submitting form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting form: $e')),
      );
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

  Future<String?> autoCorrectText(String text) async {
    try {
      final url = Uri.parse(
          'http://10.0.2.2:8080/autocorrect?text=${Uri.encodeComponent(text)}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data['text']);
        return data['text'];
      } else {
        print('Failed to auto-correct: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error auto-correcting text: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF131314),
        ),
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 80),
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
              child: Image.asset('assets/google-gemini-icon.png',
                  width: 20, height: 20),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _yearFoundedController,
          label: 'In which year was your company founded?',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _headquartersController,
          label: 'Where is your headquarters located?',
        ),
        const SizedBox(height: 20),
        _buildExpandableTextField(
          controller: _descriptionController,
          label:
              'Provide a brief description of your company, its mission, and the industry in which it operates.',
        ),
        const SizedBox(height: 20),
        _buildExpandableTextField(
          controller: _productsController,
          label:
              'What are your main products or services, and who is your primary target market?',
        ),
        const SizedBox(height: 20),
        _buildExpandableTextField(
          controller: _marketPositionController,
          label:
              'How would you describe your company’s position in the market, and what sets your company apart from its competitors?',
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _currentStep = 1;
                });
              }
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
          controller: _financialPerformanceController,
          label:
              'Provide a brief overview of your company\'s financial performance and its growth strategy for the next 5 years.',
        ),
        const SizedBox(height: 20),
        _buildExpandableTextField(
          controller: _businessModelController,
          label:
              'What is your business model? How does your company generate revenue?',
        ),
        const SizedBox(height: 20),
        _buildExpandableTextField(
          controller: _investmentOpportunitiesController,
          label: 'What investment opportunities are available?',
        ),
        const SizedBox(height: 20),
        _buildExpandableTextField(
          controller: _contactInfoController,
          label: 'Who should potential investors contact for more information?',
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              _updateProfilePicture();
            },
            icon: Icon(Icons.upload, color: Colors.white),
            label: Text('Upload Logo', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                  horizontal: 60, vertical: 15), // Made the button longer
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
                  inherit: true,
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
                if (_formKey.currentState!.validate()) {
                  _submitForm();
                }
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

  Widget _buildTextField(
      {required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFF1e1f20),
            contentPadding:
                EdgeInsets.only(top: 20, left: 40), // Added top padding
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          ),
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildExpandableTextField({
    required String label,
    required TextEditingController controller,
  }) {
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
              controller:
                  controller, // Assign the controller to the TextFormField
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFF1e1f20),
                contentPadding: EdgeInsets.only(
                    top: 20, right: 40, left: 20), // Added top padding
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
              ),
              style: TextStyle(color: Colors.white),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () async {
                  // Call the auto-correct function with the text in the field
                  final correctedText = await autoCorrectText(controller.text);
                  if (correctedText != null) {
                    setState(() {
                      controller.text = correctedText;
                    });
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(4.0), // Added padding to the icon
                  child: Image.asset('assets/google-gemini-icon.png',
                      width: 20, height: 20), // Icon on the top left corner
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
              padding: EdgeInsets.symmetric(
                  horizontal: 60, vertical: 15), // Made the button longer
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
