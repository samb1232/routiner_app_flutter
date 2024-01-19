import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_day_app/database/database_helper.dart';
import 'package:my_day_app/pages/configure_routine_page.dart';
import 'package:my_day_app/pages/home_page.dart';
import 'package:my_day_app/pages/routine_process_page.dart';
import 'package:my_day_app/pages/settings_page.dart';

void main() {
  runApp(OrientationBuilder(
    builder: (context, orientation) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      return MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/morning_routine': (context) => const RoutineProcessPage(routine: Routines.morning),
          '/evening_routine': (context) => const RoutineProcessPage(routine: Routines.evening),
          '/settings': (context) => const SettingsPage(),
          '/settings/mrconfig': (context) => const ConfigureRoutinePage(routine: Routines.morning),
          '/settings/erconfig': (context) => const ConfigureRoutinePage(routine: Routines.evening),
        },
      );
    },
  ));
}


// TODO: Cделать чтобы при выходе из приложения вызывалась функция DatabaseHelper().close();
