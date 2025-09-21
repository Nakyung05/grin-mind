import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grin_mind/main.dart';

class ActionsPage extends StatelessWidget {
  const ActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final weeklyData = Provider.of<WeeklyData>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('이번 주 내 실천 현황'),
      ),
      body: Center(
        child: weeklyData.weeklyTasks.isEmpty
            ? const Text('이번 주 실천 현황이 없습니다.')
            : ListView.builder(
                itemCount: weeklyData.weeklyTasks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(weeklyData.weeklyTasks[index]),
                  );
                },
              ),
      ),
    );
  }
}