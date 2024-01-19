import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_day_app/components/items.dart';
import 'package:my_day_app/components/routine_task_screen.dart';
import 'package:my_day_app/database/database_helper.dart';
import 'package:my_day_app/style.dart';

class RoutineProcessPage extends StatefulWidget {
  final Routines routine;

  const RoutineProcessPage({super.key, required this.routine});

  @override
  State<RoutineProcessPage> createState() => _RoutineProcessPageState();
}

class _RoutineProcessPageState extends State<RoutineProcessPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          return showExitDialogue();
        },
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: widget.routine == Routines.morning ?
                                  MyAppStyle.morningMainColor
                                : MyAppStyle.eveningMainColor,
                          width: 2,
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {
                          showExitDialogue();
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: widget.routine == Routines.morning ?
                                MyAppStyle.morningMainColor
                              : MyAppStyle.eveningMainColor,
                        ),
                      ),
                    ),
                    Text("Good ${widget.routine.name}"),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: widget.routine == Routines.morning ?
                                MyAppStyle.morningMainColor
                              : MyAppStyle.eveningMainColor,
                          width: 2,
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {
                          skipTask();
                        },
                        child: Icon(
                          Icons.skip_next,
                          color: widget.routine == Routines.morning ?
                                MyAppStyle.morningMainColor
                              : MyAppStyle.eveningMainColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 550,
                    child: PageView.builder(
                      itemCount: routineItems.length + 1,
                      physics: const NeverScrollableScrollPhysics(),
                      controller: pageController,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Center(
                            child: ClipOval(
                              child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      beginRoutine();
                                      pageController.nextPage(
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.easeInOut);
                                    });
                                  },
                                  child: Container(
                                    width: 300,
                                    height: 300,
                                    color: widget.routine == Routines.morning ?
                                          MyAppStyle.morningMainColor
                                        : MyAppStyle.eveningMainColor,
                                    child: const Center(
                                      child: Text(
                                        "Begin",
                                        style: TextStyle(
                                          fontSize: 40,
                                          color: MyAppStyle.textColorLight,
                                        ),
                                      ),
                                    ),
                                  )
                              ),
                            ),
                          );
                        }
                        return TaskScreen(
                          routineItem: routineItems[index - 1],
                          onComplete: completeTask,
                          isLastTask: index == routineItems.length,
                          bgColor: widget.routine == Routines.morning ?
                                    MyAppStyle.morningMainColor
                                  : MyAppStyle.eveningMainColor,
                        );

                      },
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: routineItems.map((item) {
                          Color circleColor = _getCircleColor(item.state);
                          return _buildCircle(circleColor);
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              !isStarted ? Container() :
              InkWell(
                  onTap: () {
                    switchPauseTimer();
                    },
                  child: Icon(
                    isPaused ?
                    Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: Colors.grey,
                    size: 90,
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int currentProgressIndex = 0;
  bool isStarted = false;
  bool isPaused = false;
  List<RoutineItem> routineItems = [];
  int totalItems = 1;


  PageController pageController = PageController();
  Timer? timer;

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (isPaused) return;
        setState(() {
          routineItems[currentProgressIndex].timeSpent =
              (routineItems[currentProgressIndex].timeSpent ?? const Duration())
                  + const Duration(seconds: 1);
        });
    });
  }

  void completeTask() {
    routineItems[currentProgressIndex].state = RoutineItemStates.done;
    if (currentProgressIndex < routineItems.length-1) {
      setState(() {
        currentProgressIndex++;
        isPaused = false;

        pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
      });
    } else {
      finishRoutine();
    }
  }

  void skipTask() {
    if (!isStarted) {
      return;
    }
    routineItems[currentProgressIndex].state = RoutineItemStates.skipped;
    if (currentProgressIndex < routineItems.length-1) {
      setState(() {
        currentProgressIndex++;
        isPaused = false;

        pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
      });
    } else {
      finishRoutine();
    }
  }

  void beginRoutine() {
    isStarted = true;
    startTimer();
  }

  void finishRoutine() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    dbHelper.updateTodayRoutineProgress(routineItems, widget.routine);
    Navigator.pop(context);
  }



  @override
  void initState() {
    super.initState();
    getRoutineItems();
  }

  void getRoutineItems() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<RoutineItem> items = await dbHelper.getRoutineItems(widget.routine);
    setState(() {
      routineItems = items;
    });
  }


  
  bool showExitDialogue() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: const SizedBox(
              width: 100,
              height: 50,
              child: Column(
                children: [
                  Text(
                      "If you drop routine now, "),
                  Text(
                      "progress will not be saved"),
                ],
              ),
            ),
            backgroundColor: MyAppStyle.backgroundColor,
            actions: [
              Center(
                child: MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  color: widget.routine == Routines.morning ?
                          MyAppStyle.morningMainColor
                        : MyAppStyle.eveningMainColor,
                  child: const Text(
                    'Leave routine',
                    style: TextStyle(
                        color: MyAppStyle.textColorLight,
                        fontSize: 16
                    ),
                  ),
                ),
              ),
            ],
          );
        }
    );
    return false;
  }

  Widget _buildCircle(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Color _getCircleColor(RoutineItemStates state) {
    switch (state) {
      case RoutineItemStates.undone:
        return Colors.grey;
      case RoutineItemStates.done:
        return Colors.greenAccent;
      case RoutineItemStates.skipped:
        return Colors.yellowAccent;
    }
  }


  void switchPauseTimer () {
    setState(() {
      isPaused = !isPaused;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    pageController.dispose();
    super.dispose();
  }
}
