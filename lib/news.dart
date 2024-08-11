import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'discover.dart';
import 'trend.dart';

class StockMarketNewsPage extends StatefulWidget {
  @override
  _StockMarketNewsPageState createState() => _StockMarketNewsPageState();
}

class _StockMarketNewsPageState extends State<StockMarketNewsPage> {
  String? userId;
  int? _expandedIndex;
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  List<dynamic> _newsData = []; // State variable to store fetched news data
  bool _isLoading = true;
  String _loadingError = '';

  @override
  void initState() {
    super.initState();
    _fetchNews();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      setState(() {
        userId = args;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose of the PageController
    super.dispose();
  }

  Future<void> _fetchNews() async {
    final url = Uri.parse('http://10.0.2.2:5000/news');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> newsData = json.decode(response.body);
        setState(() {
          _newsData = newsData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _loadingError =
              'Failed to load news. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _loadingError = 'Error fetching news: $e';
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Gracefully handle the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
      throw 'Could not launch $url';
    }
  }

  String capitalize(String s) => s.isNotEmpty
      ? s
          .split(' ')
          .map(
              (word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
          .join(' ')
      : s;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1e1f20),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 1.0), // Added padding to the left side
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
                  icon: Icon(Icons.favorite,
                      color: Color.fromRGBO(
                          182, 109, 164, 1)), // Heart icon filled with red
                  onPressed: () {
                    Navigator.pushNamed(context, '/watchlist',
                        arguments: userId); // Navigate to WatchlistPage
                  },
                ),
                IconButton(
                  icon: Icon(Icons.person,
                      color: Color.fromRGBO(182, 109, 164, 1)),
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile', arguments: userId);
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
          _buildDiscoverPage(),
          _buildtrendPage(),
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
        type: BottomNavigationBarType
            .fixed, // Ensures the background color applies correctly
      ),
    );
  }

  Widget _buildNewsPage() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF131314),
      ),
      padding: const EdgeInsets.all(16.0),
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
            ..._newsData.map((newsItem) {
              return Column(
                children: [
                  _buildNewsCard(
                    context,
                    newsItem['headline'],
                    newsItem['image'],
                    capitalize(newsItem['category']),
                    newsItem['summary'],
                    newsItem['url'],
                    _newsData.indexOf(newsItem),
                  ),
                  SizedBox(height: 20),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverPage() {
    return DiscoverNewsPage(); // Defined in discover.dart
  }

  Widget _buildtrendPage() {
    return TrendsPage(); // Defined in discover.dart
  }


  Widget _buildNewsCard(BuildContext context, String title, String imagePath,
      String subtitle, String detail, String link, int index) {
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
              Image.network(
                imagePath,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey,
                    child: Center(
                      child: Icon(Icons.broken_image, size: 50),
                    ),
                  );
                },
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
                    _launchURL(link);
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
