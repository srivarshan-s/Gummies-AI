import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TrendsPage extends StatefulWidget {
  @override
  _TrendsPageState createState() => _TrendsPageState();
}

class _TrendsPageState extends State<TrendsPage> with SingleTickerProviderStateMixin {
  int? _expandedIndex;
  Map<int, bool> _likedStocks = {};
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF131314),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTrendCard(
                context,
                symbol: 'AAPL',
                companyName: 'Apple Inc.',
                currentPrice: 254.32,
                percentageChange: 1.34,
                isProfit: true,
              ),
              SizedBox(height: 20),
              _buildTrendCard(
                context,
                symbol: 'GOOGL',
                companyName: 'Alphabet Inc.',
                currentPrice: 1350.62,
                percentageChange: -0.56,
                isProfit: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendCard(
      BuildContext context, {
        required String symbol,
        required String companyName,
        required double currentPrice,
        required double percentageChange,
        required bool isProfit,
      }) {
    bool isExpanded = _expandedIndex == symbol.hashCode;
    bool isLiked = _likedStocks[symbol.hashCode] ?? false;

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
            ? _buildExpandedContent(companyName, symbol, currentPrice, percentageChange, isProfit, isLiked)
            : _buildCollapsedContent(symbol, companyName, currentPrice, percentageChange, isProfit, isLiked),
      ),
    );
  }

  Widget _buildCollapsedContent(
      String symbol,
      String companyName,
      double currentPrice,
      double percentageChange,
      bool isProfit,
      bool isLiked) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  symbol,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _likedStocks[symbol.hashCode] =
                      !(_likedStocks[symbol.hashCode] ?? false);
                    });
                  },
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                ),
              ],
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
              '\$$currentPrice',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              '${percentageChange.toStringAsFixed(2)}%',
              style: TextStyle(
                color: isProfit ? Colors.green : Colors.red,
                fontSize: 16,
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
      double currentPrice,
      double percentageChange,
      bool isProfit,
      bool isLiked,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      symbol,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _likedStocks[symbol.hashCode] =
                          !(_likedStocks[symbol.hashCode] ?? false);
                        });
                      },
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                    ),
                  ],
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
                  '\$$currentPrice',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '${percentageChange.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: isProfit ? Colors.green : Colors.red,
                    fontSize: 16,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoColumn(
              title1: 'Open',
              value1: '\$251.00',
              title2: 'High',
              value2: '\$256.00',
              title3: 'Low',
              value3: '\$250.00',
            ),
            _buildInfoColumn(
              title1: 'Vol',
              value1: '2.1M',
              title2: 'P/E',
              value2: '35.0',
              title3: 'Mkt Cap',
              value3: '\$1.2T',
            ),
            _buildInfoColumn(
              title1: '52W H',
              value1: '\$300.00',
              title2: '52W L',
              value2: '\$200.00',
              title3: 'Avg Vol',
              value3: '1.8M',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoColumn({
    required String title1,
    required String value1,
    required String title2,
    required String value2,
    required String title3,
    required String value3,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title1: $value1',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        SizedBox(height: 5),
        Text(
          '$title2: $value2',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        SizedBox(height: 5),
        Text(
          '$title3: $value3',
          style: TextStyle(color: Colors.white, fontSize: 14),
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
