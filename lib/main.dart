// main.dart 파일

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grin_mind/pages/login_page.dart';
import 'package:grin_mind/app_state.dart'; 
import 'package:grin_mind/pages/leaderboard_page.dart';
import 'package:grin_mind/pages/actions_page.dart';

// 주간 데이터를 관리하는 Provider
class WeeklyData with ChangeNotifier {
  List<String> weeklyTasks = [];

  void resetWeeklyTasks() {
    weeklyTasks.clear();
    notifyListeners();
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeeklyData()),
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _checkAndResetWeeklyData();
  }

  Future<void> _checkAndResetWeeklyData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetTimestamp = prefs.getInt('lastResetTimestamp') ?? 0;
    final lastResetDate = DateTime.fromMillisecondsSinceEpoch(lastResetTimestamp);
    final now = DateTime.now();

    if (!mounted) {
      return;
    }

    if (now.weekday == DateTime.monday && now.day != lastResetDate.day) {
      Provider.of<WeeklyData>(context, listen: false).resetWeeklyTasks();
      await prefs.setInt('lastResetTimestamp', now.millisecondsSinceEpoch);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grin Mind',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6BBA74),
          primary: const Color(0xFF6BBA74),
          secondary: const Color(0xFFC7EBC6),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      // **이 부분을 추가하세요**
      routes: {
        '/leaderboard': (context) => const LeaderboardPage(),
        '/actions': (context) => const ActionsPage(),
      },
    );
  }
}