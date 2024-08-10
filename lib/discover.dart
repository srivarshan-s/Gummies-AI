import 'package:flutter/material.dart';

class DiscoverNewsPage extends StatefulWidget {
  @override
  _DiscoverNewsPageState createState() => _DiscoverNewsPageState();
}

class _DiscoverNewsPageState extends State<DiscoverNewsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Color(0xFF1e1f20),
      //   title: Text(
      //     'Discover Small Businesses',
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       color: Colors.white,
      //     ),
      //   ),
      // ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF131314),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Discover Small Businesses',
                  style: TextStyle(
                    color: Color.fromRGBO(182, 109, 164, 1),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                _buildDiscoverCard(
                  context,
                  'Gummies Inc.',
                  'assets/company_logo1.png',
                  'Gummies Inc. specializes in organic gummy candies with a focus on sustainability and eco-friendly packaging.',
                  "Gummies Inc. is a pioneer in the confectionery industry, known for its organic and eco-friendly gummy candies. With a mission to promote healthy snacking, the company has gained a strong foothold in the market by providing a variety of flavors that cater to health-conscious consumers. Gummies Inc. sets itself apart with its commitment to sustainability, using only biodegradable packaging and sourcing ingredients from certified organic farms. The company's innovative approach and dedication to quality have made it a favorite among customers looking for delicious yet responsible snack options.",
                ),
                SizedBox(height: 20),
                _buildDiscoverCard(
                  context,
                  'TechWave Solutions',
                  'assets/company_logo2.png',
                  'TechWave Solutions offers cutting-edge technology services including AI, ML, and cloud computing solutions.',
                  "TechWave Solutions is a leading technology service provider, offering a wide range of solutions in artificial intelligence, machine learning, and cloud computing. The company focuses on delivering innovative and customized technology services to businesses across various industries. TechWave's expertise in AI and ML allows clients to harness the power of data, driving growth and efficiency. The company's cloud solutions ensure that businesses can operate seamlessly and securely in the digital age. With a strong team of tech experts, TechWave Solutions continues to lead the way in the ever-evolving technology landscape.",
                ),
                SizedBox(height: 20),
                _buildDiscoverCard(
                  context,
                  'Gummies Inc.',
                  'assets/company_logo1.png',
                  'Gummies Inc. specializes in organic gummy candies with a focus on sustainability and eco-friendly packaging.',
                  "Gummies Inc. is a pioneer in the confectionery industry, known for its organic and eco-friendly gummy candies. With a mission to promote healthy snacking, the company has gained a strong foothold in the market by providing a variety of flavors that cater to health-conscious consumers. Gummies Inc. sets itself apart with its commitment to sustainability, using only biodegradable packaging and sourcing ingredients from certified organic farms. The company's innovative approach and dedication to quality have made it a favorite among customers looking for delicious yet responsible snack options.",
                ),
                SizedBox(height: 20),
                _buildDiscoverCard(
                  context,
                  'TechWave Solutions',
                  'assets/company_logo2.png',
                  'TechWave Solutions offers cutting-edge technology services including AI, ML, and cloud computing solutions.',
                  "TechWave Solutions is a leading technology service provider, offering a wide range of solutions in artificial intelligence, machine learning, and cloud computing. The company focuses on delivering innovative and customized technology services to businesses across various industries. TechWave's expertise in AI and ML allows clients to harness the power of data, driving growth and efficiency. The company's cloud solutions ensure that businesses can operate seamlessly and securely in the digital age. With a strong team of tech experts, TechWave Solutions continues to lead the way in the ever-evolving technology landscape.",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverCard(BuildContext context, String companyName,
      String logoPath, String shortDescription, String fullDescription) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BrandDetailPage(
              companyName: companyName,
              logoPath: logoPath,
              fullDescription: fullDescription,
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
              Image.asset(
                logoPath,
                height: 125,
                width: 125,
                fit: BoxFit.cover,
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
                      shortDescription,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
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

class BrandDetailPage extends StatelessWidget {
  final String companyName;
  final String logoPath;
  final String fullDescription;

  BrandDetailPage({
    required this.companyName,
    required this.logoPath,
    required this.fullDescription,
  });

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
              Text(
                'Year the company was founded:',
                style: TextStyle(
                  color: Color.fromRGBO(182, 109, 164, 1), // Purple color
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '2018',  // Example data
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Headquarters location:',
                style: TextStyle(
                  color: Color.fromRGBO(182, 109, 164, 1), // Purple color
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'San Francisco',  // Example data
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'About the company, its mission, and the industry in which it operates:',
                style: TextStyle(
                  color: Color.fromRGBO(182, 109, 164, 1), // Purple color
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 8),
              Text(
                fullDescription,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
              Text(
                'Main products/services, and the primary target market:',
                style: TextStyle(
                  color: Color.fromRGBO(182, 109, 164, 1), // Purple color
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'This company offers organic gummy candies targeting health-conscious consumers.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
              Text(
                'Company’s position in the market, and how the company is different from its competitors:',
                style: TextStyle(
                  color: Color.fromRGBO(182, 109, 164, 1), // Purple color
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Gummies Inc. stands out for its commitment to sustainability and eco-friendly packaging, differentiating it from competitors.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
              Text(
                'Overview of your company\'s financial performance and its growth strategy for the next 5 years:',
                style: TextStyle(
                  color: Color.fromRGBO(182, 109, 164, 1), // Purple color
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Gummies Inc. has experienced consistent growth and aims to expand its product line and global reach in the coming years.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
              Text(
                'Business model and generation of company\'s revenue:',
                style: TextStyle(
                  color: Color.fromRGBO(182, 109, 164, 1), // Purple color
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'The company generates revenue through direct sales of gummy products both online and through retail partnerships.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
              Text(
                'Investment opportunities that are available:',
                style: TextStyle(
                  color: Color.fromRGBO(182, 109, 164, 1), // Purple color
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Gummies Inc. is open to equity investments to fund its expansion plans.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
              Text(
                'Contact information:',
                style: TextStyle(
                  color: Color.fromRGBO(182, 109, 164, 1), // Purple color
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'For more information, contact us at info@gummiesinc.com.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                // textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color(0xFF131314),
    );
  }
}
