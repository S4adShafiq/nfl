import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'standings.dart';
import 'matches.dart';
import 'teams_screen.dart';
import 'stats.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/matches': (context) => const Matches(),
        '/teams': (context) => const TeamsScreen(),
        '/stats': (context) => const Stats(),
        '/live': (context) => const Live(),
      },
    );
  }
}
