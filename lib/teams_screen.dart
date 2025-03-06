import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For HTTP requests


class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  Map<String, dynamic>? teamData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeamData();
  }

  Future<void> fetchTeamData() async {
    const String apiUrl =
        'https://v1.american-football.api-sports.io/teams?id=1';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'x-rapidapi-host': 'v1.american-football.api-sports.io',
        'x-rapidapi-key':
            '8a9125ed2dmshcf29a2074d5c92dp1e391ejsnbea36dd23fb', // Ensure apiKey is defined in auth.dart
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      if (jsonData['results'] > 0) {
        setState(() {
          teamData = jsonData['response'][0];
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : teamData != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(teamData!['logo'], height: 100),
                      Text(
                        teamData!['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'City: ${teamData!['city']}',
                        style: const TextStyle(color: Colors.white54),
                      ),
                      Text(
                        'Coach: ${teamData!['coach']}',
                        style: const TextStyle(color: Colors.white54),
                      ),
                      Text(
                        'Stadium: ${teamData!['stadium']}',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  )
                : const Text(
                    'Failed to load team data',
                    style: TextStyle(color: Colors.white),
                  ),
      ),
    );
  }
}
