class TodoItem {
  int id;
  String value;
  bool isChecked = false;

  TodoItem(this.value, this.id);
  TodoItem.init(this.value, this.id, this.isChecked);
}


enum RoutineItemStates {
  undone,
  done,
  skipped
}


class RoutineItem {

  int id;
  String value;
  RoutineItemStates state;
  Duration? timeSpent;

  RoutineItem(this.id, this.value, this.state, this.timeSpent);
}


