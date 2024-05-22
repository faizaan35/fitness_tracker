import 'package:fitness_tracker/components/habit_tile.dart';
import 'package:fitness_tracker/components/monthly_summary.dart';
import 'package:fitness_tracker/components/my_alert_box.dart';
import 'package:fitness_tracker/components/my_fab.dart';
import 'package:fitness_tracker/data/habitdatabase.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // data structure for controlling the workout list
  HabitDatabase db = HabitDatabase();
  final _mybox = Hive.box("habit_database");

  @override
  void initState() {
    // check if there is anything in habitlist if not then create default values
    if (_mybox.get("CURRENT_HABIT_LIST") == null) {
      db.createDefaultData();
    }
    // if there is already some data then load the data
    else {
      db.loadData();
    }

    // after checking the if conditions we finally run the upadate function aswell
    db.updateData();

    super.initState();
  }

  void checkBoxTapped(bool? value, int index) {
    setState(() {
      db.todaysHabitList[index][1] = value;
    });
    db.updateData();
  }

//make a controller to get the new habit name ]
  final _newHabitNameController = TextEditingController();

//create a method to add new habits
  void createNewHabit() {
    //show a dialog box for creating a new habit
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertBox(
            controller: _newHabitNameController,
            onSave: saveAlertBox,
            onCancel: cancelAlertBox,
            hintText: "Enter New Habit Name",
          );
        });
  }

  //make fucntions to save new habit , save button function in alert box
  void saveAlertBox() {
    //adding the new habbit to our habit list
    setState(() {
      db.todaysHabitList.add(_newHabitNameController.text);
    });
    // clearing the text field
    _newHabitNameController.clear();
    // poping the alert box
    Navigator.of(context).pop;

    db.updateData();
  }

  //make function to cancel new habit , cancel button function in alert box
  void cancelAlertBox() {
    // clearing the text field
    _newHabitNameController.clear();
    // poping the alert box
    Navigator.of(context).pop;
  }

  // make a function for the slidable button settings
  void openHabitSettings(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertBox(
            controller: _newHabitNameController,
            onSave: () => saveExistingHabit(index),
            onCancel: cancelAlertBox,
            hintText: db.todaysHabitList[index][0],
          );
        });
  }

  // make a function for the slidable button delete
  void deleteHabit(int index) {
    setState(() {
      db.todaysHabitList.remove(index);
    });
    db.updateData();
  }

  // make a new function to save after renaming (seeting tapped) from the slidable buttons
  void saveExistingHabit(int index) {
    setState(() {
      db.todaysHabitList[index][0] = _newHabitNameController.text;
    });
    _newHabitNameController.clear();
    Navigator.pop(context);
    db.updateData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: MyFloatingActionButton(
        onPressed: createNewHabit,
      ),
      backgroundColor: Colors.grey[300],
      body: ListView(
        children: [
          //montly summary here
          MonthlySummary(
              datasets: db.heatMapDataSet, startDate: _mybox.get("START_DATE")),

          //listview builder for the ui to diplay the tasks
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: db.todaysHabitList.length,
              itemBuilder: ((context, index) {
                return habitTile(
                  habitName: db.todaysHabitList[index][0],
                  habitCompleted: db.todaysHabitList[index][1],
                  onchanged: (value) => checkBoxTapped(value, index),
                  settingsTapped: (context) => openHabitSettings(index),
                  deleteTapped: (context) => deleteHabit(index),
                );
              })),
        ],
      ),
    );
  }
}
