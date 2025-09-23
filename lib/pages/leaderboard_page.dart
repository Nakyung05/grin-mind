import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import '../api.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  late Future<LeaderboardData> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  void _fetchLeaderboard() {
    final appState = Provider.of<AppState>(context, listen: false);
    setState(() {
      _leaderboardFuture = Api.getLeaderboard(appState.token!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주간 순위'),
      ),
      body: FutureBuilder<LeaderboardData>(
        future: _leaderboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString().replaceFirst('Exception: ', '')));
          } else if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
            return const Center(child: Text('순위 정보가 없습니다.'));
          } else {
            final leaderboardData = snapshot.data!;
            final myRank = leaderboardData.me['rank'];
            final myTotal = leaderboardData.me['total'];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '내 순위: $myRank위, 내 총점: $myTotal점',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: leaderboardData.items.length,
                    itemBuilder: (context, index) {
                      final item = leaderboardData.items[index];
                      return ListTile(
                        leading: Text('${index + 1}', style: const TextStyle(fontSize: 16)),
                        title: Text(item.email),
                        trailing: Text('${item.total}점'),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}