import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Singleton class for caching match data
class MatchesCache {
  static final MatchesCache _instance = MatchesCache._internal();
  List<dynamic> allGames = [];
  bool isDataLoaded = false;
  DateTime lastFetched = DateTime.now().subtract(const Duration(days: 1));

  factory MatchesCache() {
    return _instance;
  }

  MatchesCache._internal();

  bool get shouldRefresh {
    // Refresh if data is not loaded or if it's been more than 1 hour since the last fetch
    return !isDataLoaded || DateTime.now().difference(lastFetched).inHours >= 1;
  }

  void updateCache(List<dynamic> games) {
    allGames = games;
    isDataLoaded = true;
    lastFetched = DateTime.now();
  }

  void clearCache() {
    allGames = [];
    isDataLoaded = false;
  }
}

class Matches extends StatefulWidget {
  const Matches({super.key});

  @override
  _MatchesState createState() => _MatchesState();
}

class _MatchesState extends State<Matches> {
  final MatchesCache _cache = MatchesCache();
  List<dynamic> filteredGames = [];
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => isLoading = true);

    // Check if we have cached data and if it's fresh enough
    if (_cache.isDataLoaded && !_cache.shouldRefresh) {
      // Use cached data
      setState(() {
        filterGamesByDate();
        isLoading = false;
      });
    } else {
      // Fetch fresh data
      await fetchAllGames();
    }
  }

  Future<void> fetchAllGames() async {
    setState(() => isLoading = true);

    // New API endpoint
    String url =
        'https://securepayments.live/nflfomodev/american_football_games.json';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              return http.Response('{"response": []}', 408);
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Update cache
        _cache.updateCache(data['response']);

        setState(() {
          filterGamesByDate();
          isLoading = false;
        });
      } else {
        // If failed to fetch new data but we have cached data, use it
        if (_cache.isDataLoaded) {
          setState(() {
            filterGamesByDate();
            isLoading = false;
          });
        } else {
          setState(() {
            filteredGames = [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      // If error fetching but we have cached data, use it
      if (_cache.isDataLoaded) {
        setState(() {
          filterGamesByDate();
          isLoading = false;
        });
      } else {
        setState(() {
          filteredGames = [];
          isLoading = false;
        });
      }
      print("Error fetching games: $e");
    }
  }

  void filterGamesByDate() {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    setState(() {
      filteredGames =
          _cache.allGames.where((game) {
            return game['game']['date']['date'] == formattedDate;
          }).toList();
    });
  }

  void _changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
    if (_cache.isDataLoaded) {
      filterGamesByDate();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2022, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      builder: (context, child) {
        return Theme(data: ThemeData.dark(), child: child!);
      },
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
      if (_cache.isDataLoaded) {
        filterGamesByDate();
      }
    }
  }

  Future<void> _refreshData() async {
    await fetchAllGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left, color: Colors.white),
              onPressed: () => _changeDate(-1),
            ),
            Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
            IconButton(
              icon: const Icon(Icons.arrow_right, color: Colors.white),
              onPressed: () => _changeDate(1),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () => _selectDate(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.white,
        backgroundColor: Colors.blue[900],
        child:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                : filteredGames.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "No matches found for this date",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      if (!_cache.isDataLoaded)
                        ElevatedButton(
                          onPressed: _refreshData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                          ),
                          child: const Text("Retry Loading Data"),
                        ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredGames.length,
                  itemBuilder: (context, index) {
                    var game = filteredGames[index];
                    var teams = game['teams'];
                    var scores = game['scores'];
                    var status = game['game']['status'];
                    var time = game['game']['date']['time'];
                    var venue = game['game']['venue']['name'];
                    var stage = game['game']['stage'];
                    var week = game['game']['week'];

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Colors.black, Color(0xFF0D47A1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "$stage - $week",
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Baseball',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                time,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.stadium, color: Colors.white),
                              const SizedBox(width: 10),
                              Text(
                                venue,
                                style: const TextStyle(
                                  fontFamily: 'Baseball',
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.flag, color: Colors.white),
                              const SizedBox(width: 10),
                              Text(
                                status['long'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Image.network(
                                    teams['home']['logo'],
                                    width: 50,
                                    height: 50,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.sports_football,
                                        size: 50,
                                        color: Colors.white,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    teams['home']['name'].replaceAll(' ', '\n'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Baseball',
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "${scores['home']['total'] ?? '-'} - ${scores['away']['total'] ?? '-'}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Column(
                                children: [
                                  Image.network(
                                    teams['away']['logo'],
                                    width: 50,
                                    height: 50,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.sports_football,
                                        size: 50,
                                        color: Colors.white,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    teams['away']['name'].replaceAll(' ', '\n'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Baseball',
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Display quarter scores if available
                          const SizedBox(height: 16),
                          if (scores['home']['quarter_1'] != null ||
                              scores['home']['quarter_2'] != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Quarter Scores",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  FittedBox(
                                    child: DataTable(
                                      columnSpacing: 24,
                                      horizontalMargin: 12,
                                      headingRowHeight: 32,
                                      dataRowHeight: 32,
                                      border: TableBorder(
                                        horizontalInside: BorderSide(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      columns: const [
                                        DataColumn(
                                          label: Text(
                                            "Team",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            "Q1",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            "Q2",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            "Q3",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            "Q4",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            "OT",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: [
                                        DataRow(
                                          cells: [
                                            DataCell(
                                              Text(
                                                "HOME",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                "${scores['home']['quarter_1'] ?? '-'}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                "${scores['home']['quarter_2'] ?? '-'}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                "${scores['home']['quarter_3'] ?? '-'}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                "${scores['home']['quarter_4'] ?? '-'}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                "${scores['home']['overtime'] ?? '-'}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        DataRow(
                                          cells: [
                                            DataCell(
                                              Text(
                                                "AWAY",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                "${scores['away']['quarter_1'] ?? '-'}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                "${scores['away']['quarter_2'] ?? '-'}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                "${scores['away']['quarter_3'] ?? '-'}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                "${scores['away']['quarter_4'] ?? '-'}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                "${scores['away']['overtime'] ?? '-'}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
