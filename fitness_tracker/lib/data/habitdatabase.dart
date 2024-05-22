import 'package:fitness_tracker/dateTime/date_time.dart';
import 'package:hive_flutter/hive_flutter.dart';

//referencing our hive box we made in the main file

final _mybox = Hive.box("habit_database");

class HabitDatabase {
  List todaysHabitList = [];
  Map<DateTime, int> heatMapDataSet = {};

  //create initial database for the first time user opens the app
  void createDefaultData() {
    todaysHabitList = [
      //[habit name , habit completed ]
      ["morning run ", false],
      ["helo bouy ", false]
    ];

    _mybox.put("START_DATE", todaysDateFormatted());
  }

  //load the existing data
  void loadData() {
    // check if its a new day then get habbit list data from the databse
    if (_mybox.get(todaysDateFormatted()) == null) {
      if (_mybox.get("CURRENT_HABIT_LIST") == null) {
        todaysHabitList = [];
      } else {
        todaysHabitList = _mybox.get("CURRENT_HABIT_LIST");
        //set all the habits to false since its a new day
        for (int i = 0; i < todaysHabitList.length; i++) {
          todaysHabitList[i][1] = false;
        }
      }
    }

    // if its not a new day load todayslist
    else {
      todaysHabitList = _mybox.get(todaysDateFormatted());
    }
  }

  //update the existing data
  void updateData() {
    //update todays entry
    _mybox.put(todaysDateFormatted(), todaysHabitList);
    //update the universal habit list incase it changed
    _mybox.put("CURRENT_HABIT_LIST", todaysHabitList);

    //Calculate the habit complete % for each day
    calculateHabitPercentage();
    //load the heatmap
    loadHeatmap();
  }

  void calculateHabitPercentage() {
    int countCompleted = 0;
    for (int i = 0; i < todaysHabitList.length; i++) {
      if (todaysHabitList[i][1] == true) {
        countCompleted++;
      }
    }

    String Percent = todaysHabitList.isEmpty
        ? '0.0'
        : (countCompleted / todaysHabitList.length).toStringAsFixed(1);

    // now to put this in the database
    //key will be "PERCENTAGE_SUMMARY_yyyymmdd"
    //value will be string of 1 decimal number between 0-1
    _mybox.put("PERCENTAGE_SUMMARY_${todaysDateFormatted()}", Percent);
  }

  void loadHeatmap() {
    DateTime startDate = createDateTimeObject(_mybox.get("START_DATE"));
    // count the number of days to load
    int daysInBetween = DateTime.now().difference(startDate).inDays;

    // go from start date to today and add each percentage to the dataset
    // "PERCENTAGE_SUMMARY_yyyymmdd" will be the key in the database
    for (int i = 0; i < daysInBetween + 1; i++) {
      String yyyymmdd = createDateTimeToString(
        startDate.add(Duration(days: i)),
      );

      double strengthAsPercent = double.parse(
        _mybox.get("PERCENTAGE_SUMMARY_$yyyymmdd") ?? "0.0",
      );

      // split the datetime up like below so it doesn't worry about hours/mins/secs etc.

      // year
      int year = startDate.add(Duration(days: i)).year;

      // month
      int month = startDate.add(Duration(days: i)).month;

      // day
      int day = startDate.add(Duration(days: i)).day;

      final percentForEachDay = <DateTime, int>{
        DateTime(year, month, day): (10 * strengthAsPercent).toInt(),
      };

      heatMapDataSet.addEntries(percentForEachDay.entries);
      print(heatMapDataSet);
    }
  }
}
