import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_day_app/components/items.dart';
import 'package:my_day_app/database/database_helper.dart';
import 'package:my_day_app/style.dart';

class HomepageRoutineSection extends StatefulWidget {
  final Routines routine;

  const HomepageRoutineSection({super.key, required this.routine});


  @override
  State<HomepageRoutineSection> createState() => _HomepageRoutineSectionState();
}

class _HomepageRoutineSectionState extends State<HomepageRoutineSection> {




  List<RoutineItem> routineList = [];

  @override
  void initState() {
    super.initState();
    loadRoutineList();
  }

  Future<void> loadRoutineList() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<RoutineItem> items = await dbHelper.getRoutineItems(widget.routine);
    setState(() {
      routineList = items;
    });
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "${widget.routine == Routines.morning ? "Morning": "Evening"} routine",
            style: const TextStyle(
              fontSize: 30,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 180,
          child: Lottie.asset(
              "assets/${widget.routine == Routines.morning ?
              "sun": "moon"}Animation.json"
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: routineList.isNotEmpty ? routineList.length : 1,
              itemBuilder: (context, index) {
                if (routineList.isEmpty) {
                  return SizedBox(
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${widget.routine == Routines.morning ?
                          "Morning": "Evening"} routine is not configured.",
                          style: const TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                        const Text(
                          "Set it up in settings!",
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                } else {
                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 10),
                          child: Icon(
                            (routineList[index].state == RoutineItemStates.skipped)
                                ? Icons.navigate_next : Icons.check,
                            color: getCheckColor(routineList[index].state),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            routineList[index].value,
                            ),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 10)),
                        Text(
                            (routineList[index].state == RoutineItemStates.done) ?
                                '${
                                    routineList[index].timeSpent!.inMinutes.toString().padLeft(2, '0')
                                }:${
                                    (routineList[index].timeSpent!.inSeconds % 60).toString().padLeft(2, '0')
                                }'
                                : '',
                          style: const TextStyle(
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            width: double.infinity,
            height: 100,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.routine == Routines.morning ?
                      MyAppStyle.morningMainColor
                    : MyAppStyle.eveningMainColor,
              ),
              onPressed: checkIfStartButtonActive() ? () {
                Navigator.pushNamed(context, "/${widget.routine.name}_routine");
              }
              : null,
              child: const Text(
                "Start",
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Color getCheckColor(RoutineItemStates state) {
    switch (state) {
      case RoutineItemStates.done:
        return Colors.green;
      case RoutineItemStates.skipped:
        return Colors.orangeAccent;
      default:
        return Colors.black;
    }
  }

  bool checkIfStartButtonActive() {
    if (routineList.isEmpty) {
      return false;
    }

    return true;

  }
}
