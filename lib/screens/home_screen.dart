import 'package:flutter/material.dart';
import 'package:quiz_master/widgets/home_header.dart';

import '../widgets/home_start_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      //appBar: AppBar(centerTitle: true, title: const Text('Quiz Master')),
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(onProfileTap: () {}),
            const SizedBox(height: 24),
            // ── Start Quiz CTA ──
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
