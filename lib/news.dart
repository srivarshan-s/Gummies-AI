import 'package:flutter/material.dart';

class StockMarketNewsPage extends StatefulWidget {
  @override
  _StockMarketNewsPageState createState() => _StockMarketNewsPageState();
}

class _StockMarketNewsPageState extends State<StockMarketNewsPage> {
  int? _expandedIndex;
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1e1f20),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 1.0), // Added padding to the left side
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Colors.blue,
                    Color.fromRGBO(182, 109, 164, 1),
                    Color.fromRGBO(217, 100, 112, 1),
                  ],
                  tileMode: TileMode.mirror,
                ).createShader(bounds),
                child: Text(
                  'Gummies',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.favorite, color: Color.fromRGBO(182, 109, 164, 1)), // Heart icon filled with red
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DummyPage()),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.person, color: Color.fromRGBO(182, 109, 164, 1)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DummyPage()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          _buildNewsPage(),
          DummyPage(),
          DummyPage(),
          DummyPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph),
            label: 'Trend',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_invitation),
            label: 'Insight',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromRGBO(182, 109, 164, 1),
        onTap: _onItemTapped,
        backgroundColor: Color(0xFF1e1f20), // Force background color to blue
        unselectedItemColor: Color.fromRGBO(217, 100, 112, 1),
        type: BottomNavigationBarType.fixed, // Ensures the background color applies correctly
      ),
    );
  }

  Widget _buildNewsPage() {
    return Container(
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
                'Stock Market News',
                style: TextStyle(
                  color: Color.fromRGBO(182, 109, 164, 1),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _buildNewsCard(
                context,
                'Kamala Harris to Announce Vice President Pick Ahead of Key Battleground States Tour',
                'assets/news1.jpg',
                'Strategic Move for 2024 Election Campaign',
                "Vice President Kamala Harris is set to reveal her running mate before embarking on a critical tour of battleground states for the 2024 election. This announcement aims to strengthen the Democratic campaign by highlighting the chosen vice-presidential candidate's attributes and readiness to address pivotal issues facing voters. The tour will focus on rallying support in states that are crucial for securing electoral votes in the upcoming presidential election. For more information, click the link below.",
                'https://www.reuters.com/world/us/kamala-harris-announce-vice-president-pick-before-battleground-states-tour-2024-08-05/',
                0,
              ),
              SizedBox(height: 20),
              _buildNewsCard(
                context,
                'Student Protests in Bangladesh Turn Violent',
                'assets/news2.jpg',
                "Student demonstrations over government job quotas escalate into clashes with police, challenging Prime Minister Sheikh Hasina's administration.",
                "Bangladesh is experiencing significant unrest as students demand reforms to the government job quota system, arguing it unfairly benefits certain groups. The protests have escalated into violent confrontations with law enforcement. Prime Minister Sheikh Hasina has promised to address the issue, but tensions remain high as students continue to push for change. For more information, click the link below.",
                'https://apnews.com/article/bangladesh-hasina-student-protest-quota-violence-fdc7f2632c3d8fcbd913e6c0a1903fd4',
                1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, String title, String imagePath, String subtitle, String detail, String link, int index) {
    bool isExpanded = _expandedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedIndex = isExpanded ? null : index;
        });
      },
      child: Card(
        color: Color(0xFF1e1f20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Image.asset(
                  imagePath,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                ),
              ),
              if (isExpanded) ...[
                SizedBox(height: 16),
                Text(
                  detail,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    // Handle link click
                  },
                  child: Text(
                    'Read more',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DummyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dummy Page'),
      ),
      body: Center(
        child: Text('This is a dummy page'),
      ),
    );
  }
}
