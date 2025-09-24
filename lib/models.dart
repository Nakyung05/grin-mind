// models.dart

class LeaderboardItem {
  final String email;
  final int total;
  final int weeklyTotal; // 새로운 속성 추가

  LeaderboardItem({
    required this.email,
    required this.total,
    required this.weeklyTotal, // 생성자에도 추가
  });

  factory LeaderboardItem.fromMap(Map m) => LeaderboardItem(
        email: '${m['email']}',
        total: (m['total'] ?? 0) as int,
        weeklyTotal: (m['weekly_total'] ?? 0) as int, // 서버 데이터를 받아옴
      );
}

class MeInfo {
  final int? rank;
  final int total;
  final int weeklyTotal; // 새로운 속성 추가

  MeInfo({this.rank, required this.total, required this.weeklyTotal}); // 생성자에도 추가

  factory MeInfo.fromMap(Map? m) =>
      m == null
          ? MeInfo(rank: null, total: 0, weeklyTotal: 0) // null인 경우
          : MeInfo(
              rank: m['rank'] as int?,
              total: (m['total'] ?? 0) as int,
              weeklyTotal: (m['weekly_total'] ?? 0) as int, // 서버 데이터를 받아옴
            );
}

class ActionItem {
  final int id;
  final String name;
  final int count;
  ActionItem({required this.id, required this.name, required this.count});
  factory ActionItem.fromMap(Map m) => ActionItem(
        id: (m['id'] ?? 0) as int,
        name: '${m['name']}',
        count: (m['count'] ?? 0) as int,
      );
}