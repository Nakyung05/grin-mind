import 'package:flutter/material.dart';

class CounterRow extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const CounterRow({
    super.key,
    required this.title,
    required this.count,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: onMinus, icon: const Icon(Icons.remove_circle_outline)),
          Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(onPressed: onPlus, icon: const Icon(Icons.add_circle_outline)),
        ],
      ),
    );
  }
}