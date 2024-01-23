import 'package:flutter/material.dart';
import 'package:my_day_app/components/homepage_routine_section.dart';
import 'package:my_day_app/database/database_helper.dart';
import 'package:my_day_app/components/new_task_box.dart';
import 'package:my_day_app/components/items.dart';


import '../style.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TodoItem> todoList = [];
  int daysStreak = -1;
  bool isTodayStreaked = false;
  List<bool> daysStreakArr = List.generate(7, (index) => false);

  @override
  void initState() {
    super.initState();
    loadChecklist();
    processTodayProgress();
    loadDaysStreakArr();
  }

  Future<void> loadChecklist() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<TodoItem> items = await dbHelper.getAllTodoListItems();
    setState(() {
      todoList = items;
    });
  }


  Future<void> loadDaysStreakArr() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<bool> newDaysStreakArr = List.generate(7, (index) => false);
    for (int index = 0; index < newDaysStreakArr.length; index++) {
      newDaysStreakArr[index] = await dbHelper.checkIfDayIsStreaked(
          DateTime.now().subtract(Duration(days: index))
      );
    }
    setState(() {
      daysStreakArr = newDaysStreakArr;
    });
  }

  Future<void> processTodayProgress() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    DateTime today = DateTime.now();
    Map<String, dynamic>? dayData = await dbHelper.getDayStreakData(today);
    if (dayData == null) {
      await dbHelper.clearTodayRoutinesProgress();
      await dbHelper.addEmptyDayStreak(today);
    }
    int dbDaysStreak = await dbHelper.getDaysStreakNumber();
    bool dbIsTodayStreaked = await dbHelper.checkIfDayIsStreaked(today);
    setState(() {
      daysStreak = dbDaysStreak;
      isTodayStreaked = dbIsTodayStreaked;
    });
    
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: DefaultTabController(
          length: 3,
          initialIndex: 1,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: MyAppStyle.menuMainColor,
              title: const Text('Routiner app'),
              centerTitle: true,
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/settings");
                    },
                  ),
                ),
              ],
              bottom:  const TabBar(
                  tabs: [
                    Tab(
                      icon: Icon(Icons.sunny),
                    ),
                    Tab(
                      icon: Icon(Icons.home)
                    ),
                    Tab(
                      icon: Icon(Icons.nightlight_round_outlined),
                    ),
                  ]
              ),
            ),
            body: TabBarView(
              children: [
                const HomepageRoutineSection(routine: Routines.morning),
                mainScreenPage(),
                const HomepageRoutineSection(routine: Routines.evening)
              ],
            ),
          ),
      ),
    );
  }

  Widget mainScreenPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black,
                width: 4,
              ),
              color: isTodayStreaked ? Colors.orangeAccent : Colors.grey,
            ),
            child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "streak",
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(top: 20)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isTodayStreaked ? const Icon(
                          Icons.local_fire_department_rounded,
                          size: 50,
                          color: Colors.deepOrange,
                        ) : Container(),
                        Text(
                          "$daysStreak",
                          style: const TextStyle(
                            fontSize: 60,
                          ),
                        ),
                        const Text(
                          " days",
                            style: TextStyle(
                              fontSize: 20,
                            )
                        ),
                      ],
                    ),
                  ],
                )
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  dayCircle(_getDayBefore(6), daysStreakArr[6]),
                  dashBetweenCircles(daysStreakArr[6] && daysStreakArr[5]),
                  dayCircle(_getDayBefore(5), daysStreakArr[5]),
                  dashBetweenCircles(daysStreakArr[5] && daysStreakArr[4]),
                  dayCircle(_getDayBefore(4), daysStreakArr[4]),
                  dashBetweenCircles(daysStreakArr[4] && daysStreakArr[3]),
                  dayCircle(_getDayBefore(3), daysStreakArr[3]),
                  dashBetweenCircles(daysStreakArr[3] && daysStreakArr[2]),
                  dayCircle(_getDayBefore(2), daysStreakArr[2]),
                  dashBetweenCircles(daysStreakArr[2] && daysStreakArr[1]),
                  dayCircle(_getDayBefore(1), daysStreakArr[1]),
                  dashBetweenCircles(daysStreakArr[1] && daysStreakArr[0]),
                  dayCircle(_getDayBefore(0), daysStreakArr[0], isToday: true),

                ],
              )
          ),
        ),
        const Padding(padding: EdgeInsets.only(top: 10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Today's tasks",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            Row(
              children: [
                TextButton(
                  onLongPress: () {
                    DatabaseHelper dbHelper = DatabaseHelper();
                    dbHelper.clearTodoList();
                    setState(() {
                      todoList.clear();
                    });
                  },
                  onPressed: () {},
                  child: const Text(
                    "Hold to clear",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _newTaskTextController.clear();
                    showDialog(
                        context: context,
                        builder: (context) {
                          return NewTaskBox(
                            controller: _newTaskTextController,
                            onSave: onSave,
                          );
                        }
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: MyAppStyle.menuMainColor,
                  ),
                  child: const SizedBox(
                      width: 50,
                      height: 50,
                      child: Icon(Icons.add)),
                ),
              ],
            ),
          ],
        ),
        const Padding(padding: EdgeInsets.only(top: 5)),
        Expanded(
          child: ListView.builder(
              itemCount: todoList.isNotEmpty ? todoList.length : 1,
              itemBuilder: (context, index) {
                if (todoList.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Is there no tasks for today?",
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                        Text(
                          "Let's fix it!",
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                } else {
                  return CheckboxListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            todoList[index].value,
                            style: TextStyle(
                              color: todoList[index].isChecked ? Colors.grey : Colors
                                  .black,
                              decoration: todoList[index].isChecked ? TextDecoration
                                  .lineThrough : TextDecoration.none,
                            ),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              DatabaseHelper dbHelper = DatabaseHelper();
                              dbHelper.deleteTaskFromTodoList(todoList[index]);
                              setState(() {
                                todoList.removeAt(index);
                              });
                            },
                            icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    value: todoList[index].isChecked,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        DatabaseHelper dbHelper = DatabaseHelper();
                        setState(() {
                          todoList[index].isChecked = newValue;
                        });
                        dbHelper.updateChecklistItem(todoList[index]);
                      }
                    },
                    activeColor: MyAppStyle.menuMainColor,
                  );
                }
              }
          ),
        ),
      ],
    );
  }

  Widget dayCircle(String dayText, bool isStreaked, {bool isToday = false}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isStreaked ? Colors.lightGreenAccent : Colors.grey,
        border: isToday ? Border.all(
          color: isStreaked ? Colors.green : Colors.black,
          width: 2,
        ) : null,
      ),
      child: Center(
          child: Text(dayText)
      ),
    );
  }

  Widget dashBetweenCircles(bool isStreaked) {
    return Container(
      width: 20,
      height: 2,
      decoration: BoxDecoration(
        color: isStreaked ? Colors.lightGreenAccent : Colors.grey,
      ),
    );
  }


  final _newTaskTextController = TextEditingController();
  void onSave() {
    _saveTask();

    _newTaskTextController.clear();
    Navigator.of(context).pop();
  }
  
  Future<void> _saveTask() async {
    if (_newTaskTextController.text.replaceAll(" ", "").isEmpty) return;
    DatabaseHelper dbHelper = DatabaseHelper();
    TodoItem newTask = await dbHelper.addTodoTaskToDatabase(_newTaskTextController.text);
    setState(() {
      todoList.add(newTask);
    });
  }

  String _getDayBefore(int difference) {
    DateTime date = DateTime.now();
    DateTime dateBefore = date.subtract(Duration(days: difference));
    return dateBefore.day.toString();
  }
}
