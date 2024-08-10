import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WatchlistPage extends StatefulWidget {
  @override
  _WatchlistPageState createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  String? userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      setState(() {
        userId = args;
      });
    });
  }

  Future<Map<String, dynamic>> _fetchWatchlist(String userId) async {
    final url = 'http://10.0.2.2:5000/get_watchlist?user_id=$userId';

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

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Your Watchlist',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF1e1f20),
        ),
        body: Center(
            child:
                CircularProgressIndicator()), // Show loading while userId is being fetched
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Watchlist', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1e1f20),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchWatchlist(userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData ||
              snapshot.data!['selected_companies'].isEmpty) {
            return Center(child: Text('No watchlist available.'));
          } else {
            final watchlistData = snapshot.data!;
            return ListView.builder(
              itemCount: watchlistData['selected_companies'].length,
              itemBuilder: (context, index) {
                return Card(
                  color: Color(0xFF1e1f20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(
                      watchlistData['selected_companies'][index],
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Icon(Icons.trending_up, color: Colors.green),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
