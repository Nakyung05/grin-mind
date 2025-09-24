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
  // 사용자가 제공한 39가지 실천 항목 목록
  Map<String, int> weeklyTasks = {
    '지역 농산물 시장을 이용하며, 현지 음식(로컬 푸드)을 먹는다': 0,
    '유기농 식품을 구입한다': 0,
    '식품의 라벨에서 환경에 해로운 성분을 확인하고 소비한다': 0,
    '고도로 가공된 식품(소시지 등)의 소비를 피한다': 0,
    '주변의 녹지를 찾는다': 0,
    '올바른 재활용 방법에 대해 스스로 공부한다': 0,
    '자연, 동물 및 환경 보호의 중요성에 대해 가족 및 친구와 함께 이야기한다': 0,
    '친구 및 가족과 지속 가능한 행동 변화에 대한 아이디어를 공유한다': 0,
    '생태 발자국을 최소화하기 위한 계획을 세워본다': 0,
    '도움이 필요한 사람들에게 헌 옷이나 가정 용품을 기부한다': 0,
    '에너지, 빈곤 및 기후 사이의 상호 작용을 공부한다': 0,
    '플라스틱 용기 대신 샴푸 바, 비누 바를 구입한다': 0,
    '집을 청소할 때 천연 세제를 사용한다': 0,
    '플라스틱 칫솔을 대나무 칫솔로 바꾸고, 이를 닦는 동안 수도꼭지를 잠근다': 0,
    '집에서 소비하는 에너지를 알아 둔다': 0,
    '기후 변화가 경제에 영향을 미칠 것이라는 사실을 사람들에게 이야기한다': 0,
    '공정무역 제품을 구매한다': 0,
    '탄소 발자국이 낮은 회사의 제품을 구입한다': 0,
    '가전 제품을 바꿀 때 기존의 제품은 기부한다': 0,
    '현지에서 생산된 제품을 구매한다': 0,
    '주변 사람들과 전기 제품을 공유한다': 0,
    '환경 변화가 지역사회에 어떤 영향을 미치는지에 대해 논의한다': 0,
    '새 제품 대신 중고품을 구입한다': 0,
    '재사용 또는 재활용 재료로 만든 옷을 구입한다': 0,
    '제로웨이스트 매장에서 음식을 구입한다': 0,
    '유기농 면과 친환경 재료를 구입한다': 0,
    '생태 관광에 참여한다': 0,
    '냉장고와 에어컨을 올바르게 폐기하는 방법에 대해 알아본다': 0,
    '기후에 대한 미신을 없애고, 사람들괴 사실과 허구를 구분하는 것이 중요함을 이야기한다': 0,
    '지속 가능한 출처의 생선이나 해산물을 구입한다': 0,
    '나무를 심는다': 0,
    '벼룩시장을 조직하거나 참여한다': 0,
    '정부가 재생 에너지 생산에 보조금을 지급 정책에 알아본다': 0,
    '기업의 사회적 책임을 주장한다': 0,
    '정부에 공원이나 숲과 같은 더 많은 녹지 공간을 확보하도록 요구한다': 0,
    '지역사회에서 일회용 플라스틱 사용을 없애도록 노력한다': 0,
    '재생지를 구입한다': 0,
    '선거에서 환경과 기후변화 관련 공약을 제시하는 후보를 지지한다': 0,
    '종이타월이나 핸드드라이어 대신 개인 손수건을 사용한다': 0,
  };

  void incrementTaskCount(String task) {
    if (weeklyTasks.containsKey(task)) {
      weeklyTasks[task] = weeklyTasks[task]! + 1;
      notifyListeners();
    }
  }

  void decrementTaskCount(String task) {
    if (weeklyTasks.containsKey(task) && weeklyTasks[task]! > 0) {
      weeklyTasks[task] = weeklyTasks[task]! - 1;
      notifyListeners();
    }
  }

  void resetWeeklyTasks() {
    for (var task in weeklyTasks.keys) {
      weeklyTasks[task] = 0;
    }
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
      routes: {
        '/leaderboard': (context) => const LeaderboardPage(),
        '/actions': (context) => const ActionsPage(),
      },
    );
  }
}