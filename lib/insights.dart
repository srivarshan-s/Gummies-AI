import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InsightsPage extends StatefulWidget {
  final String userId;

  InsightsPage({required this.userId});

  @override
  _InsightsPageState createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> with SingleTickerProviderStateMixin {
  int? _expandedIndex;
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Map<String, String>> stockOpinions = [];
  bool isLoading = true;
  List<String> userWatchlist = [];

  final List<Map<String, String>> bigCompaniesList = [];
  final List<Map<String, String>> smallCompaniesList = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchUserWatchlist();
    await fetchAndPopulateCompanyLists(widget.userId);
    await _fetchAndStoreAllOpinions();
  }

  Future<void> fetchAndPopulateCompanyLists(String userId) async {
    if (userWatchlist.isNotEmpty) {
      final symbolsQuery = userWatchlist.join(',');
      final url = 'http://10.0.2.2:8080/expandwatchlist?symbols=$symbolsQuery';

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('Fetched expanded watchlist: $data');

          if (data is Map && data.containsKey('Value')) {
          final companies = data['Value'] as List<dynamic>;

          // Iterate through the list of companies
          for (int i = 0; i < companies.length; i += 2) {
            final symbol = companies[i]; // Symbol is at index i
            final companyName = companies[i + 1]; // Company name is at index i+1

            setState(() {
              bigCompaniesList.add({
                'symbol': symbol.toString(),
                'companyName': companyName.toString(),
              });
              smallCompaniesList.add({
                'symbol': symbol.toString(),
                'companyName': companyName.toString(),
              });
            });
          }
        } else {
          print('Error: Expected data to be a Map with a "Value" key.');
        }

          print('Updated big companies: $bigCompaniesList');
          print('Updated small companies: $smallCompaniesList');
        } else {
          print('Failed to fetch expanded watchlist: ${response.body}');
        }
      } catch (e) {
        print('Error fetching expanded watchlist: $e');
      }
    } else {
      print('User watchlist is empty');
    }
  }

  Future<void> _fetchUserWatchlist() async {
    final url = 'http://10.0.2.2:3000/get_watchlist?user_id=${widget.userId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('selected_companies')) {
          setState(() {
            userWatchlist = List<String>.from(
              data['selected_companies'].map((company) => company['symbol']),
            );
          });
        }
        print('Fetched watchlist symbols: $userWatchlist');
      } else {
        print('Failed to fetch watchlist: ${response.body}');
      }
    } catch (e) {
      print('Error fetching watchlist: $e');
    }
  }

  Future<void> _fetchAndStoreAllOpinions() async {
    List<Map<String, String>> fetchedOpinions = [];

    for (String ticker in bigCompaniesList.map((company) => company['symbol']!)) {
      if (!mounted) return;
      try {
        final opinion = await fetchStockOpinion(ticker);
        if (opinion != null) {
          fetchedOpinions.add({
            'ticker': ticker,
            'Summary': opinion['Summary']!,
            'Opinion': opinion['Opinion']!,
          });
        } else {
          fetchedOpinions.add({
            'ticker': ticker,
            'Summary': 'No summary available',
            'Opinion': 'No opinion available',
          });
        }
      } catch (e) {
        print('Error fetching opinion for $ticker: $e');
        fetchedOpinions.add({
          'ticker': ticker,
          'Summary': 'Failed to fetch opinion',
          'Opinion': 'Error',
        });
      }
    }

    if (mounted) {
      setState(() {
        stockOpinions = fetchedOpinions;
        isLoading = false;
      });
    }
  }

  Future<Map<String, String>?> fetchStockOpinion(String ticker) async {
    final url = 'http://10.0.2.2:8080/stockopinion?ticker=$ticker';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data is Map<String, dynamic>) {
          return {
            'Summary': data['Summary'] ?? 'No summary available',
            'Opinion': data['Opinion'] ?? 'No opinion available',
          };
        } else {
          print('Unexpected data format received.');
          return null;
        }
      } else {
        print('Failed to fetch stock opinion: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching stock opinion: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF1e1f20),
          automaticallyImplyLeading: false, // Removes the back arrow
          titleSpacing: 0, // Removes any extra spacing between the title and the edges
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(2.0), // Keeps the TabBar height
            child: TabBar(
              labelStyle: TextStyle(
                fontSize: 18.0, // Increase font size for tab names
                fontWeight: FontWeight.bold,
              ),
              tabs: [
                Tab(text: 'Big Companies'),
                Tab(text: 'Small Companies'),
              ],
              indicatorColor: Color.fromRGBO(182, 109, 164, 1),
            ),
          ),
        ),

        body: Container(
          decoration: BoxDecoration(
            color: Color(0xFF131314),
          ),
          child: isLoading
              ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
              : TabBarView(
                  children: [
                    _buildCompanyList(bigCompanies: true),
                    _buildCompanyList(bigCompanies: false),
                  ],
                ),
        ),
        
      ),
    );
  }

  Widget _buildCompanyList({required bool bigCompanies}) {
  final companies = bigCompanies ? bigCompaniesList : smallCompaniesList;

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        const Text(
          'Stocks to watch',
          style: TextStyle(
            color: Color.fromRGBO(182, 109, 164, 1),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ...companies.map((company) {
          final opinionData = stockOpinions.firstWhere(
            (opinion) => opinion['ticker'] == company['symbol'],
            orElse: () => {'Summary': 'No summary available', 'Opinion': 'N/A'},
          );

          return Column(
            children: [
              _buildInsightCard(
                context,
                symbol: company['symbol']!,
                companyName: company['symbol']!,
                isProfit: opinionData['Opinion'] == 'Strong Buy' || opinionData['Opinion'] == 'Buy',
                consensus: opinionData['Opinion']!,
                analysis: opinionData['Summary']!,
              ),
              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ],
    ),
  );
}

  Widget _buildInsightCard(
      BuildContext context, {
        required String symbol,
        required String companyName,
        required bool isProfit,
        required String consensus,
        required String analysis,
      }) {
    bool isExpanded = _expandedIndex == symbol.hashCode;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_expandedIndex == symbol.hashCode) {
            _expandedIndex = null;
            _controller.reverse();
          } else {
            _expandedIndex = symbol.hashCode;
            _controller.forward();
          }
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Color(0xFF1e1f20),
          borderRadius: BorderRadius.circular(30),
        ),
        child: isExpanded
            ? _buildExpandedContent(companyName, symbol, isProfit, consensus, analysis)
            : _buildCollapsedContent(symbol, companyName, isProfit, consensus),
      ),
    );
  }

  Widget _buildCollapsedContent(
      String symbol,
      String companyName,
      bool isProfit,
      String consensus,
      ) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              symbol,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              companyName,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Spacer(),
        Container(
          width: 100,
          height: 50,
          child: LineChart(
            _buildSmallGraph(isProfit),
          ),
        ),
        Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              consensus,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandedContent(
      String companyName,
      String symbol,
      bool isProfit,
      String consensus,
      String analysis,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  companyName,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  consensus,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          height: 200,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return LineChart(
                _buildLargeGraph(isProfit, _animation.value),
              );
            },
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Analysis',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          analysis,
          style: TextStyle(
            color: Colors.white60,
            fontSize: 14,
          ),
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pros',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '- Strong revenue growth',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  Text(
                    '- High market share',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cons',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '- High valuation',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  Text(
                    '- Competitive market',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoColumn(
              title1: 'Market Sentiment',
              value1: isProfit ? 'Positive' : 'Negative',
              value1Color: isProfit ? Colors.green : Colors.red,
              title2: 'Volatility Index',
              value2: 'Low',
            ),
            _buildInfoColumn(
              title1: 'Term',
              value1: 'Long Term',
              value1Color: Colors.white60,
              title2: 'Time Horizon',
              value2: '1 Year',
            ),
            _buildInfoColumn(
              title1: 'Strong Buy',
              value1: '13',
              title2: 'Strong Sell',
              value2: '0',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoColumn({
    required String title1,
    required String value1,
    Color? value1Color,
    required String title2,
    required String value2,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title1,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        SizedBox(height: 5),
        Text(
          value1,
          style: TextStyle(color: value1Color ?? Colors.white, fontSize: 14),
        ),
        SizedBox(height: 10),
        Text(
          title2,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        SizedBox(height: 5),
        Text(
          value2,
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
      ],
    );
  }

  LineChartData _buildSmallGraph(bool isProfit) {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, isProfit ? 1 : -1),
            FlSpot(1, isProfit ? 2 : -2),
            FlSpot(2, isProfit ? 1.5 : -1.5),
          ],
          isCurved: true,
          barWidth: 2,
          color: isProfit ? Colors.green : Colors.red,
          dotData: FlDotData(show: false),
        ),
      ],
    );
  }

  LineChartData _buildLargeGraph(bool isProfit, double progress) {
    return LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(show: true),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, isProfit ? 1 : -1),
            FlSpot(progress, isProfit ? progress * 2 : -progress * 2),
            FlSpot(progress * 2, isProfit ? 1.5 : -1.5),
            FlSpot(progress * 3, isProfit ? 3 : -3),
            FlSpot(progress * 4, isProfit ? 2.5 : -2.5),
          ],
          isCurved: true,
          barWidth: 2,
          color: isProfit ? Colors.green : Colors.red,
          dotData: FlDotData(show: false),
        ),
      ],
    );
  }
}
