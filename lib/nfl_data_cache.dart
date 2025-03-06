import 'dart:convert';
import 'package:http/http.dart' as http;

/// Singleton Cache Manager for NFL data
class NFLDataCache {
  // Singleton instance
  static final NFLDataCache _instance = NFLDataCache._internal();

  // Factory constructor to return the same instance
  factory NFLDataCache() {
    return _instance;
  }

  // Private constructor
  NFLDataCache._internal();

  // Cache data and timestamps
  final Map<String, dynamic> _teamsCache = {};
  final Map<int, dynamic> _playersCache = {};
  final Map<String, DateTime> _cacheTimes = {};

  // Cache expiration duration
  static const Duration _cacheExpiration = Duration(hours: 24);

  /// Fetch teams with caching
  Future<List<dynamic>> fetchTeams() async {
    final String cacheKey = 'teams';

    // Check if cache exists and is valid
    if (_isCacheValid(cacheKey)) {
      return _teamsCache[cacheKey];
    }

    // Fetch fresh data
    try {
      const url = 'https://securepayments.live/nflfomodev/nfl_teams.json';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final teamsList = List<dynamic>.from(data['response']);

        // Update cache
        _teamsCache[cacheKey] = teamsList;
        _cacheTimes[cacheKey] = DateTime.now();

        return teamsList;
      } else {
        // If network request fails but we have cache, return it regardless of expiration
        if (_teamsCache.containsKey(cacheKey)) {
          return _teamsCache[cacheKey];
        }
        throw Exception('Failed to load teams: ${response.statusCode}');
      }
    } catch (e) {
      // If there's an exception but we have cache, return it regardless of expiration
      if (_teamsCache.containsKey(cacheKey)) {
        return _teamsCache[cacheKey];
      }
      rethrow;
    }
  }

  /// Fetch players for a team with caching
  Future<List<dynamic>> fetchPlayersByTeamId(int teamId) async {
    // Check if cache exists and is valid
    if (_isPlayerCacheValid(teamId)) {
      return _playersCache[teamId];
    }

    // Fetch fresh data
    try {
      final url =
          'https://securepayments.live/nflfomodev/nfl_players_team_$teamId.json';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final playersList = List<dynamic>.from(data['response'] ?? []);

        // Update cache
        _playersCache[teamId] = playersList;
        _cacheTimes['player$teamId'] = DateTime.now();

        return playersList;
      } else {
        // If network request fails but we have cache, return it regardless of expiration
        if (_playersCache.containsKey(teamId)) {
          return _playersCache[teamId];
        }
        throw Exception('Failed to load players: ${response.statusCode}');
      }
    } catch (e) {
      // If there's an exception but we have cache, return it regardless of expiration
      if (_playersCache.containsKey(teamId)) {
        return _playersCache[teamId];
      }
      rethrow;
    }
  }

  /// Clear all cached data
  void clearCache() {
    _teamsCache.clear();
    _playersCache.clear();
    _cacheTimes.clear();
  }

  /// Clear team cache
  void clearTeamsCache() {
    _teamsCache.clear();
    _cacheTimes.removeWhere((key, _) => key == 'teams');
  }

  /// Clear players cache for a specific team
  void clearPlayersCacheForTeam(int teamId) {
    _playersCache.remove(teamId);
    _cacheTimes.remove('player$teamId');
  }

  /// Check if cache is valid for a key
  bool _isCacheValid(String key) {
    if (!_teamsCache.containsKey(key) || !_cacheTimes.containsKey(key)) {
      return false;
    }

    final cacheTime = _cacheTimes[key]!;
    return DateTime.now().difference(cacheTime) < _cacheExpiration;
  }

  /// Check if player cache is valid for a team
  bool _isPlayerCacheValid(int teamId) {
    final cacheKey = 'player_$teamId';

    if (!_playersCache.containsKey(teamId) ||
        !_cacheTimes.containsKey(cacheKey)) {
      return false;
    }

    final cacheTime = _cacheTimes[cacheKey]!;
    return DateTime.now().difference(cacheTime) < _cacheExpiration;
  }
}