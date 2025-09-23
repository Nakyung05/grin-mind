// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'actions_page.dart';
import 'leaderboard_page.dart';
import 'login_page.dart'; // ✅ LoginPage를 import 해야 합니다.

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grin Mind'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // ✅ 수정된 부분: 로그아웃 후 모든 페이지를 제거하고 로그인 페이지로 이동
              Provider.of<AppState>(context, listen: false).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
                'assets/images/earth.png',
                height: 100,
            ),
            const SizedBox(height: 20),
            Text(
              '환영합니다, Grin Mind와 함께 지구를 지켜요!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 250,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ActionsPage()),
                  );
                },
                icon: const Icon(Icons.task_alt),
                label: const Text('오늘의 실천 기록하기'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LeaderboardPage()),
                  );
                },
                icon: const Icon(Icons.leaderboard),
                label: const Text('주간 순위 확인하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}