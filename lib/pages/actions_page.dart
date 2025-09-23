import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../models.dart';
import '../api.dart';
import '../widgets/counter_row.dart';

class ActionsPage extends StatefulWidget {
  const ActionsPage({super.key});

  @override
  State<ActionsPage> createState() => _ActionsPageState();
}

class _ActionsPageState extends State<ActionsPage> {
  late Future<List<ActionItem>> _actionsFuture;

  @override
  void initState() {
    super.initState();
    _fetchActions();
  }

  void _fetchActions() {
    final appState = Provider.of<AppState>(context, listen: false);
    setState(() {
      _actionsFuture = Api.getActions(appState.token!);
    });
  }

  void _updateCount(int actionId, int delta) async {
    final appState = Provider.of<AppState>(context, listen: false);
    await Api.updateActionCount(appState.token!, actionId, delta);
    _fetchActions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('실천하러 가기'),
      ),
      body: FutureBuilder<List<ActionItem>>(
        future: _actionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('활동 목록이 없습니다.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final action = snapshot.data![index];
                return CounterRow(
                  action: action,
                  onIncrement: () => _updateCount(action.id, 1),
                  onDecrement: () => _updateCount(action.id, -1),
                );
              },
            );
          }
        },
      ),
    );
  }
}