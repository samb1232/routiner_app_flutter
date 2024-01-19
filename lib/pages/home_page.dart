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

  @override
  void initState() {
    super.initState();
    loadChecklist();
    processTodayProgress();
  }

  Future<void> loadChecklist() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<TodoItem> items = await dbHelper.getAllTodoListItems();
    setState(() {
      todoList = items;
    });
  }

  Future<void> processTodayProgress() async {
    // TODO: Доделать функцию. Добавить провеку в базе данных на наличие этого дня
    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.clearTodayRoutinesProgress();
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
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
                    Navigator.pushNamed(context, "/settings");
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
              color: Colors.orangeAccent,
            ),
            child: const Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "streak",
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 20)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          size: 50,
                          color: Colors.deepOrange,
                        ),
                        Text(
                          "21",
                          style: TextStyle(
                            fontSize: 60,
                          ),
                        ),
                        Text(
                          " day",
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
                  dayCircle("23"),
                  dashBetweenCircles(),
                  dayCircle("24"),
                  dashBetweenCircles(),
                  dayCircle("25"),
                  dashBetweenCircles(),
                  dayCircle("26"),
                  dashBetweenCircles(),
                  dayCircle("27"),
                  dashBetweenCircles(),
                  dayCircle("28"),
                  dashBetweenCircles(),
                  dayCircle("29", isToday: true),

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

  Widget dayCircle(String dayText, {bool isToday = false}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.lightGreenAccent,
        border: isToday ? Border.all(
          color: Colors.green,
          width: 2,
        ) : null,
      ),
      child: Center(
          child: Text(dayText)
      ),
    );
  }

  Widget dashBetweenCircles() {
    return Container(
      width: 20,
      height: 2,
      decoration: const BoxDecoration(
        color: Colors.lightGreenAccent,
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
}
