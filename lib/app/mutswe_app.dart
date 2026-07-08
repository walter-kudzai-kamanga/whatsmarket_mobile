import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'app_shell.dart';

class MutsweApp extends StatelessWidget {
  const MutsweApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mutswe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.beigeLight,
      ),
      home: const AppShell(),
    );
  }
}
