import 'package:flutter/material.dart';

import 'ui/game_screen.dart';

void main() {
  runApp(const KelimeUstasiApp());
}

class KelimeUstasiApp extends StatelessWidget {
  const KelimeUstasiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kelime Ustası',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0E0F1A),
        dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1C1D2E)),
      ),
      home: const GameScreen(),
    );
  }
}
