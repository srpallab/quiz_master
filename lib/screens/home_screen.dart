import 'package:flutter/material.dart';
import 'package:quiz_master/widgets/home_header.dart';

import '../widgets/home_start_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F7FF),
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(onProfileTap: () {}),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: HomeStartCard(screenWidth: screenWidth),
            ),
          ],
        ),
      ),
    );
  }
}
