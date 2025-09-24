// lib/pages/leaderboard_page.dart 파일

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});
  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  Future<void>? _loading;

  @override
  void initState() {
    super.initState();
    _loading = context.read<AppState>().fetchLeaderboard();
  }

  // 로그아웃 로직을 별도의 함수로 분리하여 린트 경고를 해결
  Future<void> _logoutAndNavigate() async {
    await context.read<AppState>().logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final MeInfo me = app.me;
    final List<LeaderboardItem> lb = app.leaderboard;

    // 주간 랭킹 여부 확인
    final isMonday = app.isMonday();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 8),
            const Text('Grin Mind'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/actions'),
            icon: const Icon(Icons.list_alt),
            tooltip: '실천하러 가기',
          ),
          IconButton(
            onPressed: _logoutAndNavigate, // 분리된 함수 호출
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: FutureBuilder(
        future: _loading,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!isMonday) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '지난주 랭킹은 매주 월요일에 공개됩니다.\n'
                      '이번주 실천을 열심히 해서 다음주 랭킹에 도전해 보세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 100),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset('assets/images/logo.png', width: 200),
                        Positioned(
                          top: -110,
                          left: 100,
                          child: InkWell(
                            onTap: () =>
                                Navigator.pushNamed(context, '/actions'),
                            child: Ink.image(
                              image: const AssetImage(
                                  'assets/images/speech_bubble.png'),
                              fit: BoxFit.contain,
                              width: 300,
                              height: 200,
                              child: const Center(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('랭킹',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                        '내 순위: ${me.rank ?? '-'}  |  내 이번 주 실천수: ${me.weeklyTotal}'),
                  ],
                ),
              ),
              const Divider(height: 0),
              Expanded(
                child: ListView.separated(
                  itemCount: lb.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (_, i) {
                    final e = lb[i];
                    final isMe = (me.rank != null) && (me.rank == i + 1);
                    return ListTile(
                      leading: CircleAvatar(child: Text('${i + 1}')),
                      title: Text(
                        e.email,
                        style: TextStyle(
                          fontWeight:
                              isMe ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: Text('${e.weeklyTotal}'),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/actions'),
                  child: const Text('실천하러 가기'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}