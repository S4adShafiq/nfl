import 'package:flutter/material.dart';
import 'team_details_screen.dart';
import 'nfl_data_cache.dart'; // Import the new cache file

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final NFLDataCache _cache = NFLDataCache(); // Use the singleton instance
  List<dynamic> teams = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  Future<void> fetchTeams() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Use the cache service to fetch teams
      final fetchedTeams = await _cache.fetchTeams();
      setState(() {
        teams = fetchedTeams.take(32).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load teams: $e';
      });
    }
  }

  void openTeamDetails(Map<String, dynamic> team) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TeamDetailsScreen(team: team),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Failed To Load Data",
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: fetchTeams,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          // Clear teams cache and fetch fresh data
                          _cache.clearTeamsCache();
                          await fetchTeams();
                        },
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.2,
                              ),
                          itemCount: teams.length,
                          itemBuilder: (context, index) {
                            final team = teams[index];
                            return GestureDetector(
                              onTap: () => openTeamDetails(team),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      team['logo'],
                                      height: 60,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.sports_football,
                                                size: 60,
                                                color: Colors.white70,
                                              ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      team['name'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Baseball',
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      team['city'],
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
