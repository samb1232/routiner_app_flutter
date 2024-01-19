import 'package:flutter/material.dart';
import 'package:my_day_app/components/items.dart';

class TaskScreen extends StatelessWidget {
  final RoutineItem routineItem;
  final VoidCallback onComplete;
  final Color bgColor;
  final bool isLastTask;

  const TaskScreen({
    super.key,
    required this.routineItem,
    required this.onComplete,
    required this.isLastTask,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            routineItem.value,
            style: const TextStyle(
              fontSize: 35,
            ),
          ),
          const SizedBox(height: 40),

          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 7,
                color: bgColor,
              ),
            ),
            child: Center(
              child: Text(
                '${(routineItem.timeSpent?.inMinutes ?? 0).toString().padLeft(2, "0")}:'
                    '${((routineItem.timeSpent?.inSeconds  ?? 0) % 60).toString().padLeft(2, "0")}',
                style: const TextStyle(
                  fontSize: 70,
                ),
              ),
            ),
          ),
          const SizedBox(height: 50,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.all(Radius.circular(15)),
              ),
              height: 70,
              width: double.infinity,
              child: TextButton(
                  onPressed: () {
                    onComplete();
                  },
                  child: Text(
                    isLastTask ? "Finish" : "Done",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  )
              ),
            ),
          ),
        ],
      );
  }
}