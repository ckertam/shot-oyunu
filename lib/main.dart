import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const ShotOyunuApp());
}

class ShotOyunuApp extends StatelessWidget {
  const ShotOyunuApp({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF006E);
    return MaterialApp(
      title: 'Shot Oyunu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF120E16),
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
        ),
        textTheme: Typography.whiteMountainView,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
