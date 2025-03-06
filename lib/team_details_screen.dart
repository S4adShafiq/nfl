import 'package:flutter/material.dart';
import 'nfl_data_cache.dart'; // Import the new cache file

class TeamDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> team;
  const TeamDetailsScreen({super.key, required this.team});

  @override
  State<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

Widget _buildPlayerInfoRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen> {
  final NFLDataCache _cache = NFLDataCache(); // Use the singleton instance
  bool isLoading = true;
  List<dynamic> players = [];
  Map<int, bool> expandedPlayers = {};
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPlayers();
  }

  Future<void> fetchPlayers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Use the cache service to fetch players
      final fetchedPlayers = await _cache.fetchPlayersByTeamId(
        widget.team['id'],
      );
      setState(() {
        players = fetchedPlayers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load players: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8, // Set a fixed height
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(
            widget.team['logo'],
            height: 80,
            errorBuilder:
                (context, error, stackTrace) => const Icon(
                  Icons.sports_football,
                  size: 80,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.team['name'],
            style: const TextStyle(
              fontFamily: 'Baseball',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.team['city'],
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(
            'Coach: ${widget.team['coach']}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            'Owner: ${widget.team['owner']}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            'Stadium: ${widget.team['stadium']}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            'Established: ${widget.team['established']}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 16),
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
                      errorMessage!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: fetchPlayers,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    // Clear players cache for this team and fetch fresh data
                    _cache.clearPlayersCacheForTeam(widget.team['id']);
                    await fetchPlayers();
                  },
                  child:
                      players.isEmpty
                          ? ListView(
                            children: const [
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Text(
                                    'No player data available',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
                          )
                          : ListView.builder(
                            shrinkWrap: true,
                            itemCount: players.length,
                            itemBuilder: (context, index) {
                              final player = players[index];
                              return Column(
                                children: [
                                  ListTile(
                                    leading:
                                        player['image'] != null
                                            ? Image.network(
                                              player['image'],
                                              height: 40,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                  ),
                                            )
                                            : const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            ),
                                    title: Text(
                                      player['name'],
                                      style: const TextStyle(
                                        fontFamily: 'Baseball',
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${player['position']} - ${player['group']}',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 14,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        expandedPlayers[player['id']] == true
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          expandedPlayers[player['id']] =
                                              !(expandedPlayers[player['id']] ??
                                                  false);
                                        });
                                      },
                                    ),
                                  ),
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child:
                                        expandedPlayers[player['id']] == true
                                            ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 20,
                                                    horizontal: 24,
                                                  ),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white12,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: Colors.white24,
                                                  width: 1,
                                                ),
                                              ),
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    _buildPlayerInfoRow(
                                                      'Age',
                                                      player['age']
                                                              ?.toString() ??
                                                          'N/A',
                                                    ),
                                                    _buildPlayerInfoRow(
                                                      'Height',
                                                      player['height'] ?? 'N/A',
                                                    ),
                                                    _buildPlayerInfoRow(
                                                      'Weight',
                                                      player['weight'] ?? 'N/A',
                                                    ),
                                                    _buildPlayerInfoRow(
                                                      'College',
                                                      player['college'] ??
                                                          'N/A',
                                                    ),
                                                    _buildPlayerInfoRow(
                                                      'Experience',
                                                      player['experience'] !=
                                                              null
                                                          ? '${player['experience']} years'
                                                          : 'N/A',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            : const SizedBox.shrink(),
                                  ),
                                ],
                              );
                            },
                          ),
                ),
              ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white10,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
