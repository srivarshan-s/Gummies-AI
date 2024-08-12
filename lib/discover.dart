import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DiscoverNewsPage extends StatefulWidget {
  @override
  _DiscoverNewsPageState createState() => _DiscoverNewsPageState();
}

class _DiscoverNewsPageState extends State<DiscoverNewsPage> {
  List<String> smallCompanies = [
    "PayGround Inc",
    // "Melio Payments",
    // "MicroEra Power, Inc.",
    // "The SMBX",
    // "Fulcrum Pro",
    // "Parafin Inc",
    // "NorthOne",
    // "Fundbox",
    // "SentiLink",
    // "Relativity6, Inc"
  ];

  List<Map<String, dynamic>> companyData = [];
  List<Map<String, String>> summarizedData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    for (String name in smallCompanies) {
      final data = await fetchCompanyData(companyName: name);
      if (data != null) {
        companyData.add(data);
      }
    }

    // After fetching all data, pass it to the summarization endpoint
    if (companyData.isNotEmpty) {
      await sendStartupDataForSummarization(companyData);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<Map<String, dynamic>?> fetchCompanyData(
      {String? companyId, String? companyName}) async {
    try {
      // Construct the base URL
      String url = 'http://10.0.2.2:3000/get_company_data';

      // Add query parameters
      if (companyId != null) {
        url += '?id=$companyId';
      } else if (companyName != null) {
        url += '?name=$companyName';
      } else {
        throw Exception('Either companyId or companyName must be provided');
      }

      // Make the GET request
      final response = await http.get(Uri.parse(url));

      // Check if the request was successful
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print('Failed to fetch company data: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching company data: $e');
      return null;
    }
  }

  Future<void> sendStartupDataForSummarization(
      List<Map<String, dynamic>> startupData) async {
    for (var company in startupData) {
      try {
        String jsonString = jsonEncode(company);

        final response = await http.post(
          Uri.parse('http://10.0.2.2:8080/summarizestartup'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(jsonString),
        );

        if (response.statusCode == 200) {
          var item = json.decode(response.body);

          summarizedData.add({
            'companyName': item['Company name'],
            'yearFounded': item['Year founded'],
            'headquarters': item['Headquarters'],
            'contactInfo': item['Contact Information'],
            'about': item['About'],
            'summary': item['One-line-summary'],
          });
        } else {
          print(
              'Failed to summarize startup data for ${company['companyName']}: ${response.body}');
        }
      } catch (e) {
        print(
            'Error summarizing startup data for ${company['companyName']}: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover Small Businesses',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1e1f20),
      ),
      body: Container(
        color: Color(0xFF131314),
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: summarizedData.length,
                itemBuilder: (context, index) {
                  final company = summarizedData[index];
                  return _buildDiscoverCard(
                    context,
                    company['companyName']!,
                    company['yearFounded']!,
                    company['headquarters']!,
                    company['contactInfo']!,
                    company['about']!,
                    company['summary']!,
                  );
                },
              ),
      ),
    );
  }

  Widget _buildDiscoverCard(
    BuildContext context,
    String companyName,
    String yearFounded,
    String headquarters,
    String contactInfo,
    String about,
    String summary,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BrandDetailPage(
              companyName: companyName,
              yearFounded: yearFounded,
              headquarters: headquarters,
              contactInfo: contactInfo,
              fullDescription: about,
              logoPath: '',
            ),
          ),
        );
      },
      child: Card(
        color: Color(0xFF1e1f20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Replace with Image.network or Image.asset if you have a logo
              Container(
                width: 125,
                height: 125,
                color: Colors.grey, // Placeholder for the logo
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      summary,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                      ),
                      maxLines: 3, // Limits text to 3 lines
                      overflow: TextOverflow.ellipsis,
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

class BrandDetailPage extends StatelessWidget {
  final String companyName;
  final String logoPath;
  final String fullDescription;
  final String yearFounded;
  final String headquarters;
  final String contactInfo;

  BrandDetailPage({
    required this.companyName,
    required this.logoPath,
    required this.fullDescription,
    required this.yearFounded,
    required this.headquarters,
    required this.contactInfo,
  });

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Color.fromRGBO(182, 109, 164, 1), // Purple color
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1e1f20),
        title: Text(
          companyName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  logoPath,
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
              _buildDetailSection('Year Founded', yearFounded),
              SizedBox(height: 20),
              _buildDetailSection('Headquarters', headquarters),
              SizedBox(height: 20),
              _buildDetailSection('About the Company', fullDescription),
              SizedBox(height: 20),
              _buildDetailSection('Contact Information', contactInfo),
            ],
          ),
        ),
      ),
      backgroundColor: Color(0xFF131314),
    );
  }
}
