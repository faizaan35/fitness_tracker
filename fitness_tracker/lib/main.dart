import 'package:flutter/material.dart';
import 'package:fitness_tracker/pages/home_page.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  //initializing hive database
  await Hive.initFlutter();

  await Hive.openBox("habit_database");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData(primarySwatch: Colors.green),
    );
  }
}
