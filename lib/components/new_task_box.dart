import 'package:flutter/material.dart';

import '../style.dart';

class NewTaskBox extends StatelessWidget {
  final TextEditingController? controller;
  final Function()? onSave;

  const NewTaskBox({
    super.key,
    required this.controller,
    required this.onSave
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: TextField(
        autofocus: true,
        controller: controller,
        decoration: const InputDecoration(
          enabledBorder: UnderlineInputBorder(),
        ),
      ),
      backgroundColor: MyAppStyle.backgroundColor,
      actions: [
        MaterialButton(
          onPressed: onSave,
          color: MyAppStyle.menuMainColor,
          child: const Text(
            'Add',
            style: TextStyle(color: MyAppStyle.textColorLight, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
