import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StatsCache {
  static final StatsCache _instance = StatsCache._internal();
  List<dynamic>? _standings;

  factory StatsCache() {
    return _instance;
  }

  StatsCache._internal();

  Future<List<dynamic>> getStandings() async {
    if (_standings != null) {
      return _standings!;
    }

    final url = Uri.parse(
      "https://securepayments.live/nflfomodev/american_football_standings.json",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      _standings = data['response'];
      return _standings!;
    }
    return [];
  }
}

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  List<dynamic> standings = [];

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    final data = await StatsCache().getStandings();
    setState(() {
      standings = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF0A1931), Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: const Text(
                "NFL Standings",
                style: TextStyle(fontFamily: 'Baseball'),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            Expanded(
              child:
                  standings.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: standings.length,
                        itemBuilder: (context, index) {
                          final team = standings[index]['team'];
                          final record = standings[index];

                          return Card(
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: Image.network(
                                team['logo'],
                                width: 50,
                                height: 50,
                              ),
                              title: Center(
                                child: Text(
                                  team['name'],
                                  style: const TextStyle(
                                    fontFamily: 'baseball',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              subtitle: Column(
                                children: [
                                  const SizedBox(height: 3),
                                  Text("Position 🏆 ${record['position']} "),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Wins: ${record['won']} | ",
                                        style: const TextStyle(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      Text(
                                        "Losses: ${record['lost']}",
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Points: ${record['points']['for']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    "Against: ${record['points']['against']}",
                                    style: const TextStyle(
                                      color: Colors.yellow,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
