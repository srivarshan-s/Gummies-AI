import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TrendsPage extends StatefulWidget {
  final String userId;

  TrendsPage({required this.userId});

  @override
  _TrendsPageState createState() => _TrendsPageState();
}

class _TrendsPageState extends State<TrendsPage>
    with SingleTickerProviderStateMixin {
  int? _expandedIndex;
  Map<int, bool> _likedStocks = {};
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Map<String, dynamic>> companies = [];
  bool isLoading = true;

  List<String> initialCompanies = [
    "AAPL",   // Apple Inc.
    "MSFT",   // Microsoft Corporation
    "GOOGL",  // Alphabet Inc. (Class A)
    "AMZN",   // Amazon.com Inc.
    "TSLA",   // Tesla, Inc.
    "NVDA",   // NVIDIA Corporation
    "BRK.B",  // Berkshire Hathaway Inc. (Class B)
    "META",   // Meta Platforms, Inc. (formerly Facebook)
    "V",      // Visa Inc.
    "JPM",    // JPMorgan Chase & Co.
    "JNJ"    // Johnson & Johnson
];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    fetchStockDetails();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<Suggestion>> _fetchCompanies(String pattern) async {
    if (pattern.isEmpty) {
      return [];
    }

    final url = 'http://10.0.2.2:5000/autocomplete?query=$pattern';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['result'];
      return List<Suggestion>.from(
          data.map((item) => Suggestion.fromJson(item)));
    } else {
      throw Exception('Failed to fetch search results: ${response.body}');
    }
  }

  // void _onCompanySelected(Suggestion suggestion) {
  //   print("Selected: ${suggestion.symbol}");
  //   setState(() {
  //     initialCompanies.insert(0, suggestion.symbol); // Add to the top
  //   });
  //   print(initialCompanies);
  // }

  void _onCompanySelected(Suggestion suggestion) {
  setState(() {

    // Add the selected company to the top of the list
    initialCompanies.insert(0, suggestion.symbol);
  });
}

  Future<void> _addToWatchlist(String symbol, String companyName) async {
    final url = 'http://10.0.2.2:5000/add_to_watchlist';
    final _selectedCompanies = {'name': companyName, 'symbol': symbol};
    final watchlistData = {
      'user': widget.userId,
      'selected_companies': [_selectedCompanies],
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(watchlistData),
      );

      if (response.statusCode == 201) {
        // Navigate to news page if the data is successfully added
        print('Successfully added to watchlist');
      } else {
        // Handle error
        print('Failed to add watchlist: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _removeFromWatchlist(String symbol) async {
    final url =
        'http://10.0.2.2:5000/remove_from_watchlist?user=${widget.userId}&symbol=$symbol';

    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Company removed from watchlist successfully.');
      } else {
        print('Failed to remove company from watchlist: ${response.body}');
      }
    } catch (e) {
      print('Error removing from watchlist: $e');
    }
  }

  Future<void> fetchStockDetails() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay

    // Fetch the user's watchlist
    await _fetchUserWatchlist();

    try {
      // Fetch details for each symbol
      for (String symbol in initialCompanies) {
        final stockDetails = await _fetchStockDetail(symbol);
        if (stockDetails != null) {
          companies.add(stockDetails);
        }
      }
      setState(() {
        isLoading = false; // Stop loading once all details are fetched
      });
    } catch (e) {
      print('Error fetching stock details: $e');
      setState(() {
        isLoading = false; // Stop loading in case of an error
      });
    }
    for (var company in companies) {
      final symbol = company['symbol'];
      setState(() {
        _likedStocks[symbol.hashCode] = _likedStocks[symbol.hashCode] ?? false;
      });
    }
  }

  Future<Map<String, dynamic>?> _fetchStockDetail(String symbol) async {
    final url = 'http://10.0.2.2:5000/stock_details?query=$symbol';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final companyProfile = data['company_profile'];
        final stockQuote = data['stock_quote'];
        final financial = data['financial'];

        final financialMetrics = financial['series']['annual'];
        final currentRatio = financialMetrics['currentRatio'][0]['v'];
        final salesPerShare = financialMetrics['salesPerShare'][0]['v'];
        final netMargin = financialMetrics['netMargin'][0]['v'];

        // Extracting additional metrics from the "metric" field
        final fiftyTwoWeekHigh = financial['metric']['52WeekHigh'];
        final fiftyTwoWeekLow = financial['metric']['52WeekLow'];
        final averageVolume = financial['metric']['10DayAverageTradingVolume'];

        return {
          'symbol': companyProfile['ticker'],
          'companyName': companyProfile['name'] ?? symbol,
          'currentPrice': stockQuote['c'], // Current price
          'percentageChange':
              ((stockQuote['c'] - stockQuote['pc']) / stockQuote['pc']) *
                  100, // Calculate percentage change
          'isProfit': stockQuote['c'] >=
              stockQuote['pc'], // Determine if it's a profit or loss
          'openPrice': stockQuote['o'],
          'highPrice': stockQuote['h'],
          'lowPrice': stockQuote['l'],
          'volume': averageVolume.toString(), // Replaced with actual data
          'fiftyTwoWeekHigh': fiftyTwoWeekHigh, // Extracted from metric
          'fiftyTwoWeekLow': fiftyTwoWeekLow, // Extracted from metric
          'averageVolume': averageVolume.toString(), // Converted to string
          'currentRatio': currentRatio, // Extracted from financials
          'salesPerShare': salesPerShare, // Extracted from financials
          'netMargin': netMargin, // Extracted from financials
        };
      } else {
        print('Failed to fetch stock details for $symbol: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> _fetchUserWatchlist() async {
    final url = 'http://10.0.2.2:5000/get_watchlist?user_id=${widget.userId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> watchlist = data['selected_companies'];

        setState(() {
          for (var company in watchlist) {
            String symbol =
                company['symbol']; // Extract the symbol from the map
            _likedStocks[symbol.hashCode] = true;
          }
        });
      } else {
        print('Failed to fetch watchlist: ${response.body}');
      }
    } catch (e) {
      print('Error fetching watchlist: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF131314),
        ),
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Autocomplete<Suggestion>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                return await _fetchCompanies(textEditingValue.text);
              },
              displayStringForOption: (Suggestion option) => option.description,
              onSelected: _onCompanySelected,
              fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                return TextField(
                  controller: fieldTextEditingController,
                  style: TextStyle(color: Colors.white),
                  focusNode: fieldFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Search for a company',
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
                );
              },
              optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<Suggestion> onSelected, Iterable<Suggestion> options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 32,
                      decoration: BoxDecoration(
                        color: Color(0xFF1e1f20), // Background color of the dropdown
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.all(8.0),
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Suggestion option = options.elementAt(index);
                          return GestureDetector(
                            onTap: () {
                              onSelected(option);
                            },
                            child: ListTile(
                              title: Text(option.description,style: TextStyle(color: Colors.white)),
                              subtitle: Text(option.symbol, style: TextStyle(color: Colors.white)),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
                  ...companies.map((company) {
                      return Column(
                        children: [
                          _buildTrendCard(
                            context,
                            symbol: company['symbol'],
                            companyName: company['companyName'],
                            currentPrice: company['currentPrice'].toDouble(),
                            percentageChange: company['percentageChange'],
                            isProfit: company['isProfit'],
                            openPrice: company['openPrice'].toDouble(),
                            highPrice: company['highPrice'].toDouble(),
                            lowPrice: company['lowPrice'].toDouble(),
                            volume: company['volume'],
                            fiftyTwoWeekHigh: company['fiftyTwoWeekHigh'].toDouble(),
                            fiftyTwoWeekLow: company['fiftyTwoWeekLow'].toDouble(),
                            averageVolume: company['averageVolume'],
                            currentRatio: company['currentRatio'].toDouble(),
                            salesPerShare: company['salesPerShare'].toDouble(),
                            netMargin: company['netMargin'].toDouble(),
                          ),
                          SizedBox(height: 20),
                        ],
                      );
                    }).toList(),
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
    required double? currentPrice,
    required double? percentageChange,
    required bool isProfit,
    required double? openPrice,
    required double? highPrice,
    required double? lowPrice,
    required String volume,
    required double? fiftyTwoWeekHigh,
    required double? fiftyTwoWeekLow,
    required String averageVolume,
    required double? currentRatio,
    required double? salesPerShare,
    required double? netMargin,
  }) {
    bool isExpanded = _expandedIndex == symbol.hashCode;
    bool isLiked = _likedStocks[symbol.hashCode] ?? false;

    openPrice = openPrice?.toDouble();
    highPrice = highPrice?.toDouble();
    lowPrice = lowPrice?.toDouble();
    fiftyTwoWeekHigh = fiftyTwoWeekHigh?.toDouble();
    fiftyTwoWeekLow = fiftyTwoWeekLow?.toDouble();
    currentRatio = currentRatio?.toDouble();
    salesPerShare = salesPerShare?.toDouble();
    netMargin = netMargin?.toDouble();

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
            ? _buildExpandedContent(
                companyName,
                symbol,
                currentPrice!,
                percentageChange!,
                isProfit,
                isLiked,
                openPrice!,
                highPrice!,
                lowPrice!,
                volume,
                fiftyTwoWeekHigh!,
                fiftyTwoWeekLow!,
                averageVolume,
                currentRatio!,
                salesPerShare!,
                netMargin!,
              )
            : _buildCollapsedContent(
                symbol,
                companyName,
                currentPrice!,
                percentageChange!,
                isProfit,
                isLiked,
              ),
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
                  onTap: () async {
                    setState(() {
                      _likedStocks[symbol.hashCode] =
                          !(_likedStocks[symbol.hashCode] ?? false);
                    });
                    if (_likedStocks[symbol.hashCode]!) {
                      await _addToWatchlist(symbol, companyName);
                    } else {
                      await _removeFromWatchlist(symbol);
                    }
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
    double openPrice,
    double highPrice,
    double lowPrice,
    String volume,
    double fiftyTwoWeekHigh,
    double fiftyTwoWeekLow,
    String averageVolume,
    double currentRatio,
    double salesPerShare,
    double netMargin,
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
              value1: '\$$openPrice',
              title2: 'High',
              value2: '\$$highPrice',
              title3: 'Low',
              value3: '\$$lowPrice',
            ),
            _buildInfoColumn(
              title1: 'Cur Ratio',
              value1: currentRatio.toStringAsFixed(2),
              title2: 'Sales/Share',
              value2: salesPerShare.toStringAsFixed(2),
              title3: 'Net Margin',
              value3: '${(netMargin * 100).toStringAsFixed(2)}%',
            ),
            _buildInfoColumn(
              title1: '52W H',
              value1: '\$$fiftyTwoWeekHigh',
              title2: '52W L',
              value2: '\$$fiftyTwoWeekLow',
              title3: 'Avg Vol',
              value3: averageVolume,
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

class Suggestion {
  final String description;
  final String symbol;

  Suggestion({required this.description, required this.symbol});

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      description: json['description'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
    );
  }
}