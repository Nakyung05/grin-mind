// lib/pages/actions_page.dart 파일

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grin_mind/main.dart';

class ActionsPage extends StatelessWidget {
  const ActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final weeklyData = Provider.of<WeeklyData>(context);
    final tasks = weeklyData.weeklyTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('이번 주 내 실천 현황'),
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('이번 주 실천 현황이 없습니다.'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks.keys.elementAt(index);
                final count = tasks[task];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          task,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => weeklyData.decrementTaskCount(task),
                      ),
                      Text(
                        '$count',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => weeklyData.incrementTaskCount(task),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}