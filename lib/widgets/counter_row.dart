import 'package:flutter/material.dart';
import '../models.dart';

class CounterRow extends StatelessWidget {
  final ActionItem action;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CounterRow({
    super.key,
    required this.action,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              action.name,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: onDecrement,
              ),
              Text(
                '${action.count}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }
}