import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class WatchlistPage extends StatefulWidget {
  @override
  _WatchlistPageState createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  String? userId;
  int? _expandedIndex;
  List<dynamic> selectedCompanies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      setState(() {
        userId = args;
      });
      print('User ID: $userId');
      if (userId != null) {
        loadWatchlist(userId!);
      }
    });
  }

  Future<Map<String, dynamic>> _fetchWatchlist(String userId) async {
    final url = 'http://10.0.2.2:3000/get_watchlist?user_id=$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final watchlistData = json.decode(response.body);
        return watchlistData;
      } else {
        print('Failed to fetch watchlist: ${response.body}');
        throw Exception('Failed to fetch watchlist');
      }
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

Future<void> loadWatchlist(String userId) async {
  try {
    final watchlistData = await _fetchWatchlist(userId);
    selectedCompanies = watchlistData['selected_companies'];

    for (var company in selectedCompanies) {
      final symbol = company['symbol'];
      final quoteDetails = await fetchQuoteDetails(symbol);
      if (quoteDetails.isNotEmpty) {
        company['currentPrice'] = quoteDetails['currentPrice'];
        company['changePercent'] = quoteDetails['changePercent'];
      }
    }

    setState(() {
      isLoading = false;
    });
  } catch (e) {
    print('Error loading watchlist: $e');
    setState(() {
      isLoading = false;
    });
  }
}

  Future<String> _fetchImagePath(String companySymbol) async {
    final url =
        'http://10.0.2.2:3000/generate_chart_icon?ticker=$companySymbol';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return 'http://10.0.2.2:3000/' + data['image_path'];
    } else {
      throw Exception('Failed to generate chart for $companySymbol');
    }
  }

   Future<void> _removeFromWatchlist(String symbol) async {
    final url =
        'http://10.0.2.2:3000/remove_from_watchlist?user=${userId}&symbol=$symbol';

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

  Future<Map<String, dynamic>> fetchQuoteDetails(String symbol) async {
  final url = 'http://10.0.2.2:3000/quote_details?query=$symbol';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final double currentPrice = data['c'];
      final double changePercent = data['d'];

      return {
        'currentPrice': currentPrice,
        'changePercent': changePercent,
      };
    } else {
      print('Failed to fetch quote details: ${response.body}');
      return {};
    }
  } catch (e) {
    print('Error fetching quote details: $e');
    return {};
  }
}

  @override
  Widget build(BuildContext context) {
    if (userId == null || isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Your Watchlist',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF1e1f20),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (selectedCompanies.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Your Watchlist',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF1e1f20),
        ),
        body: Container(
          color: Color(0xFF131314), // Body background color
          child: Center(
            child: Text(
              'Your watchlist is empty.',
              style: TextStyle(color: Colors.white),
            ),
          ),
    ),
  );
    }
    return Scaffold(
    appBar: AppBar(
      title: Text('Your Watchlist', style: TextStyle(color: Colors.white)),
      backgroundColor: Color(0xFF1e1f20),
    ),
    body: Container(
      color: Color(0xFF131314),
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
            padding: const EdgeInsets.only(top: 8.0), // Add padding on top
            child: ListView.builder(
              itemCount: selectedCompanies.length,
              itemBuilder: (context, index) {
                final company = selectedCompanies[index];
                final companyName = company['name'];
                final companySymbol = company['symbol'];
                final currentPrice = company['currentPrice'] ?? 0.0;
                final percentageChange = company['changePercent'] ?? 0.0;
                final isProfit = percentageChange >= 0;

                return Card(
                  color: Color(0xFF1e1f20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  companySymbol,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () async {
                                    await _removeFromWatchlist(companySymbol);
                                    setState(() {
                                      selectedCompanies.removeWhere((company) => company['symbol'] == companySymbol);
                                    });
                                  },
                                  child: Icon(
                                    Icons.favorite,
                                    color: Colors.red,
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
                          // child: LineChart(
                          //   _buildSmallGraph(isProfit),
                          // ),
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
                  ),
                );
              },
            ),
          ),
    ),
  );
  }

}