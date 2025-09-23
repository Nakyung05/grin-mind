// lib/models.dart
class ActionItem {
  final int id;
  final String name;
  final int count;

  ActionItem({required this.id, required this.name, required this.count});

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    return ActionItem(
      id: json['id'],
      name: json['name'],
      count: json['count'],
    );
  }
}

class LeaderboardData {
  final String period;
  final Map<String, dynamic> range;
  final List<LeaderboardItem> items;
  final Map<String, dynamic> me;

  LeaderboardData({
    required this.period,
    required this.range,
    required this.items,
    required this.me,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> json) {
    return LeaderboardData(
      period: json['period'],
      range: json['range'],
      items: (json['items'] as List)
          .map((item) => LeaderboardItem.fromJson(item))
          .toList(),
      me: json['me'],
    );
  }
}

class LeaderboardItem {
  final String email;
  final int total;

  LeaderboardItem({required this.email, required this.total});

  factory LeaderboardItem.fromJson(Map<String, dynamic> json) {
    return LeaderboardItem(
      email: json['email'],
      total: json['total'],
    );
  }
}