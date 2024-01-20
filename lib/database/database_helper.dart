import 'package:my_day_app/components/items.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';



enum Tables {
  checklist,
  morningRoutine,
  eveningRoutine,
  todayMorningProgress,
  todayEveningProgress,
  dayStreakInfo,
}

enum Routines {
  morning,
  evening
}



class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;


  DatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await _initDb();
    return _db!;
  }


  Future<int> _generateTaskId() async {
    final prefs = await SharedPreferences.getInstance();
    int intValue = prefs.getInt('todoListIdCounter') ?? 0;
    intValue++;
    prefs.setInt('todoListIdCounter', intValue);
    return intValue;
  }

  Future<void> _clearTaskId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('todoListIdCounter', 0);
  }

  Future<Database> _initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'database_v2.db');

    // Открываем базу данных или создаем новую, если она не существует
    return await openDatabase(path, version: 3,
        onCreate: (Database db, int version) async {
          // Создаем таблицу checklist
          await db.execute('''
            CREATE TABLE ${Tables.checklist.name} (
              id INTEGER PRIMARY KEY,
              task TEXT,
              isChecked INTEGER
            )
          ''');
          // Создаем таблицу morningRoutine
          await db.execute('''
            CREATE TABLE ${Tables.morningRoutine.name} (
              step INTEGER PRIMARY KEY,
              task TEXT
            )
          ''');
          // Создаем таблицу eveningRoutine
          await db.execute('''
            CREATE TABLE ${Tables.eveningRoutine.name} (
              step INTEGER PRIMARY KEY,
              task TEXT
            )
          ''');
          // Создаем таблицу todayMorningProgress
          await db.execute('''
            CREATE TABLE ${Tables.todayMorningProgress.name} (
              step INTEGER PRIMARY KEY,
              state INTEGER,
              timeSpent INTEGER
            )
          ''');
          // Создаем таблицу todayEveningProgress
          await db.execute('''
            CREATE TABLE ${Tables.todayEveningProgress.name} (
              step INTEGER PRIMARY KEY,
              state INTEGER,
              timeSpent INTEGER
            )
          ''');
          // Создаем таблицу daysStreak
          await db.execute('''
            CREATE TABLE ${Tables.dayStreakInfo.name} (
              date TEXT PRIMARY KEY,
              morningDone INTEGER,
              eveningDone INTEGER
            )
          ''');
        });
  }

  // Добавление записи
  Future<int> _insertDataToTable(Map<String, dynamic> data,
      Tables table) async {
    Database dbClient = await db;
    return await dbClient.insert(table.name, data);
  }

  // Получение всех записей
  Future<List<Map<String, dynamic>>> _getAllData(Tables table) async {
    Database dbClient = await db;
    return await dbClient.query(table.name);
  }

  // Получение всех записей
  Future<List<Map<String, dynamic>>> _getAllDataOrdered(Tables table,
      String orderBy) async {
    Database dbClient = await db;
    return await dbClient.query(table.name, orderBy: orderBy);
  }

  // Обновление записи
  Future<int> _updateData(Map<String, dynamic> data, Tables table) async {
    Database dbClient = await db;
    return await dbClient.update(table.name, data,
        where: 'id = ?', whereArgs: [data['id']]);
  }
  
  // Обновление записи v2 (Govnokod)
  Future<int> _updateDataByStep(Map<String, dynamic> data, Tables table) async {
    Database dbClient = await db;
    return await dbClient.update(table.name, data,
        where: 'step = ?', whereArgs: [data['step']]);
  }

  Future<void> _updateDataInTable(Map<String, dynamic> data, Tables table, {String? where}) async {
    Database dbClient = await db;
    await dbClient.update(
      table.name,
      data,
      where: where,
    );
  }

  // Удаление записи
  Future<int> _deleteData(int id, Tables table) async {
    Database dbClient = await db;
    return await dbClient.delete(table.name, where: 'id = ?', whereArgs: [id]);
  }

  // Очистка таблицы
  Future<int> _clearTable(Tables table) async {
    Database dbClient = await db;
    return await dbClient.delete(table.name);
  }


  // Функции взаимодействия с таблицей checklist
  Future<TodoItem> addTodoTaskToDatabase(String task) async {
    int taskID = await _generateTaskId();
    Map<String, dynamic> data = {
      'id': taskID,
      'task': task,
      'isChecked': 0
    };
    await _insertDataToTable(data, Tables.checklist);
    return TodoItem(task, taskID);
  }

  void deleteTaskFromTodoList(TodoItem item) async {
    await _deleteData(item.id, Tables.checklist);
  }

  void clearTodoList() async {
    await _clearTable(Tables.checklist);
    await _clearTaskId();
  }

  Future<List<TodoItem>> getAllTodoListItems() async {
    List<Map<String, dynamic>> tableData = await _getAllData(Tables.checklist);
    List<TodoItem> todoItems = [];
    for (Map<String, dynamic> element in tableData) {
      todoItems.add(
          TodoItem.init(
              element['task'] as String,
              element['id'] as int,
              element['isChecked'] == 1
          ));
    }
    return todoItems;
  }

  Future<void> updateChecklistItem(TodoItem item) async {
    Map<String, dynamic> data = {
      'id': item.id,
      'task': item.value,
      'isChecked': item.isChecked ? 1 : 0
    };
    await _updateData(data, Tables.checklist);
  }


  // Функции взаимодействия с таблицей morningRoutine и eveningRoutine

  Future<void> updateRoutineInfo(List<String> newValues, Routines routine) async {
    Tables table = (routine == Routines.morning)
        ? Tables.morningRoutine : Tables.eveningRoutine;
    await _clearTable(table);
    for (int i = 0; i < newValues.length; i++) {
      await _insertDataToTable(
          {"step": i, "task": newValues[i]},
          table
      );
    }
  }

  Future<List<String>> getRoutineInfo(Routines routine) async {
    Tables table = (routine == Routines.morning)
        ? Tables.morningRoutine : Tables.eveningRoutine;
    List<Map<String, dynamic>> tableData =
    await _getAllDataOrdered(table, 'step');

    List<String> values = [];

    for (Map<String, dynamic> tableString in tableData) {
      values.add(tableString['task']);
    }
    return values;
  }
  
  // Функции взаимодействия с таблицей todayMorningProgress и todayEveningProgress
  Future<List<RoutineItem>> getRoutineItems(Routines routine) async {
    Tables table1 = (routine == Routines.morning)
        ? Tables.morningRoutine : Tables.eveningRoutine;
    Tables table2 = (routine == Routines.morning)
        ? Tables.todayMorningProgress : Tables.todayEveningProgress;
    List<Map<String, dynamic>> routineData = 
      await _getAllDataOrdered(table1, 'step');
    List<Map<String, dynamic>> todayRoutineProgressData =
      await _getAllDataOrdered(table2, 'step');

    List<RoutineItem> routineItems = [];

    RoutineItem newItem;
    for (int i = 0; i < routineData.length; i++) {
      newItem = RoutineItem(
          routineData[i]["step"],
          routineData[i]["task"],
          RoutineItemStates.values[_getRoutineItemState(todayRoutineProgressData, i)],
          Duration(seconds: _getDuration(todayRoutineProgressData, i))
      );
      routineItems.add(newItem);
    }
    return routineItems;
  }

  int _getRoutineItemState(List<Map<String, dynamic>> tableData, int index) {
    if (index >= tableData.length) {
      return RoutineItemStates.undone.index;
    }
    return tableData[index]["state"];
  }

  int _getDuration(List<Map<String, dynamic>> tableData, int index) {
    if (index >= tableData.length) {
      return 0;
    }
    return tableData[index]["timeSpent"];
  }

  Future<void> updateTodayRoutineProgress(List<RoutineItem> newItems, Routines routine) async {
    
    for (RoutineItem newItem in newItems) {
      Map<String, dynamic> tableData = {
        "step" : newItem.id,
        "state" : newItem.state.index,
        "timeSpent" : newItem.timeSpent?.inSeconds
      };
      await _updateDataByStep(
          tableData,
          (routine == Routines.morning) ?
          Tables.todayMorningProgress : Tables.todayEveningProgress);
    }
    
  }


  Future<void> clearTodayRoutinesProgress() async {
    List<String> morningRoutineInfo = await getRoutineInfo(Routines.morning);
    await _clearTable(Tables.todayMorningProgress);
    for (int i = 0; i < morningRoutineInfo.length; i++) {
      _insertDataToTable({
        "step": i,
        "state": RoutineItemStates.undone.index,
        "timeSpent": 0
      }, Tables.todayMorningProgress);
    }

    List<String> eveningRoutineInfo = await getRoutineInfo(Routines.evening);
    await _clearTable(Tables.todayEveningProgress);
    for (int i = 0; i < eveningRoutineInfo.length; i++) {
      _insertDataToTable({
        "step": i,
        "state": RoutineItemStates.undone.index,
        "timeSpent": 0
      }, Tables.todayEveningProgress);
    }
  }

  // Функции работы с таблицей daysStreak
  Future<Map<String, dynamic>?> getDayStreakData(DateTime day) async {
    Database dbClient = await db;
    List<Map<String, dynamic>> query = await dbClient.query(
        Tables.dayStreakInfo.name,
        where: 'date = ?', whereArgs: ["${day.year}-${day.month}-${day.day}"],
        limit: 1
    );
    if (query.isEmpty) {
      return null;
    }
    return query[0];
  }


  // Функции работы с таблицей daysStreak
  Future<bool> checkIfDayIsStreaked(DateTime day) async {
    Map<String, dynamic>? dayStreakInfo = await getDayStreakData(day);
    if (dayStreakInfo == null) {
      return false;
    }
    if (dayStreakInfo["morningDone"] + dayStreakInfo["eveningDone"] == 2) {
      return true;
    }
    return false;
  }

  Future<void> addEmptyDayStreak(DateTime day) async {
    await _insertDataToTable({
      "date": "${day.year}-${day.month}-${day.day}",
      "morningDone": 0,
      "eveningDone": 0
    }, Tables.dayStreakInfo);
  }

  Future<void> setMorningDone() async {
    DateTime day = DateTime.now();
    await _updateDataInTable({
      "morningDone": 1
    }, Tables.dayStreakInfo, where: "date = '${day.year}-${day.month}-${day.day}'");
  }

  Future<void> setEveningDone() async {
    DateTime day = DateTime.now();
    await _updateDataInTable({
      "eveningDone": 1
    }, Tables.dayStreakInfo, where: "date = '${day.year}-${day.month}-${day.day}'");
  }


  Future<int> getDaysStreakNumber() async {
    DateTime date = DateTime.now();
    int streakCounter = 0;

    if (!await checkIfDayIsStreaked(date)) {
      date = date.subtract(const Duration(days: 1));
    }

    while (await checkIfDayIsStreaked(date)) {
      streakCounter++;
      date = date.subtract(const Duration(days: 1));
    }

    return streakCounter;
  }



  // TODO: Решить проблему с обновлением значений по рутинам в homepage.

  // Закрытие базы данных
  Future close() async {
    Database dbClient = await db;
    dbClient.close();
  }
}
