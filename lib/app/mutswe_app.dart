import 'package:flutter/material.dart';

import 'app_shell.dart';

class MutsweApp extends StatelessWidget {
  const MutsweApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mutswe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1C3F66),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
      ),
      home: const AppShell(),
    );
  }
}
