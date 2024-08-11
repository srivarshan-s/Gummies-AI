import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class InsightsPage extends StatefulWidget {
  @override
  _InsightsPageState createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> with SingleTickerProviderStateMixin {
  int? _expandedIndex;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
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
          child: TabBarView(
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
          _buildInsightCard(
            context,
            symbol: bigCompanies ? 'AAPL' : 'SMALL1',
            companyName: bigCompanies ? 'Apple Inc.' : 'Small Cap Co.',
            isProfit: true,
            consensus: 'Strong Buy',
          ),
          const SizedBox(height: 20),
          _buildInsightCard(
            context,
            symbol: bigCompanies ? 'GOOGL' : 'SMALL2',
            companyName: bigCompanies ? 'Alphabet Inc.' : 'Small Tech Co.',
            isProfit: false,
            consensus: 'Buy',
          ),
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
            ? _buildExpandedContent(companyName, symbol, isProfit, consensus)
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
          '$companyName is showing strong financial performance with a promising growth trajectory, making it a strong buy recommendation.',
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
