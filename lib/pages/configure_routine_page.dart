import 'package:flutter/material.dart';
import 'package:my_day_app/components/new_task_box.dart';
import 'package:my_day_app/database/database_helper.dart';
import 'package:my_day_app/style.dart';


class ConfigureRoutinePage extends StatefulWidget {
  final Routines routine;
  
  const ConfigureRoutinePage({super.key, required this.routine});

  @override
  State<ConfigureRoutinePage> createState() => _ConfigureRoutinePageState();
}

class _ConfigureRoutinePageState extends State<ConfigureRoutinePage> {

  List<String> routineTasksList = [];

  @override
  void initState() {
    super.initState();
    loadTaskList();
  }

  Future<void> loadTaskList() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<String> routineInfo = await dbHelper.getRoutineInfo(widget.routine);
    setState(() {
      routineTasksList = routineInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configure ${widget.routine.name} routine"),
        backgroundColor: MyAppStyle.menuMainColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: routineTasksList.isNotEmpty ? routineTasksList.length : 1,
                itemBuilder: (context, index) {
                  if (routineTasksList.isEmpty) {
                    return const SizedBox(
                      height: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "List of tasks is empty",
                            style: TextStyle(fontSize: 20, color: Colors.grey),
                          ),
                          Text(
                            "Click + button to add new task",
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
                          Text("${index+1}:"),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                          Expanded(
                            child: Text(
                              routineTasksList[index],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: (index == 0) ? null :
                                    () {
                                  String temp = routineTasksList[index];
                                  setState(() {
                                    routineTasksList.removeAt(index);
                                    routineTasksList.insert(index-1, temp);
                                  });
                                },
                                icon: const Icon(Icons.arrow_upward),
                              ),
                              IconButton(
                                onPressed:(index == routineTasksList.length-1) ? null :
                                    () {
                                  String temp = routineTasksList[index];
                                  setState(() {
                                    routineTasksList.removeAt(index);
                                    routineTasksList.insert(index+1, temp);
                                  });
                                },
                                icon: const Icon(Icons.arrow_downward),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    routineTasksList.removeAt(index);
                                  });
                                },
                                icon: const Icon(Icons.close),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                }
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  _newTaskTextController.clear();
                  showDialog(
                      context: context,
                      builder: (context) {
                        return NewTaskBox(
                          controller: _newTaskTextController,
                          onSave: onAdd,
                        );
                      }
                  );
                },
                style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: MyAppStyle.menuMainColor,
                ),
                child: const SizedBox(
                    width: 70,
                    height: 70,
                    child: Icon(Icons.add, size: 35)
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: double.infinity,
              height: 100,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyAppStyle.menuMainColor,
                ),
                onPressed: () {
                  DatabaseHelper dbHelper = DatabaseHelper();
                  dbHelper.updateRoutineInfo(routineTasksList, widget.routine);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Save",
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
            ),
          )
        ],
      ),

    );
  }

  final _newTaskTextController = TextEditingController();
  void onAdd() {
    _saveTask();

    _newTaskTextController.clear();
    Navigator.of(context).pop();
  }

  void _saveTask() {
    if (_newTaskTextController.text.replaceAll(" ", "").isEmpty) return;
    setState(() {
      routineTasksList.add(_newTaskTextController.text);
    });
  }
}
