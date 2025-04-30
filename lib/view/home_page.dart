// filename: home_page.dart
// date: Apr 29, 2025
// author: Clay Wieringa
// description: the home page, central navigation

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controller/controller.dart';
import '../model/model.dart';
import '../data/database_helper.dart';
import 'workout_selection_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final WorkoutController _workoutController;
  final _workoutLog = WorkoutLog();
  DateTime _focusedDay = DateTime.now();
  Set<DateTime> _workoutDates = {}; // Stores dates with logged workouts

  @override
  void initState() {
    super.initState();
    _workoutController = WorkoutController(_workoutLog);
    _loadWorkoutDates(); // Load dates with existing workouts
  }

  // Grabs all workout dates from the database and store them
  Future<void> _loadWorkoutDates() async {
    final db = DatabaseHelper();
    final workouts = await db.getAllWorkouts();

    setState(() {
      _workoutDates = {
        for (var workout in workouts)
          DateTime(
            workout['date'].year,
            workout['date'].month,
            workout['date'].day,
          )
      };
    });
  }

  // Check if a workout exists on the given day
  bool _hasWorkoutOn(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _workoutDates.contains(normalized);
  }

  // Show a box with workout details for the selected day
  Future<void> _showWorkoutDetails(DateTime selectedDay) async {
    final db = DatabaseHelper();
    final workouts = await db.getWorkoutsByDate(selectedDay);

    if (workouts.isNotEmpty) {
      final workoutId = workouts.first['id'];
      final exercises = await db.getExercisesWithSets(workoutId);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Workout on ${selectedDay.toLocal().toString().split(' ')[0]}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                final sets = exercise['sets'] as List<Map<String, dynamic>>;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    // List of sets for the exercise
                    ...sets.map((set) => Text(
                          'Set ${set['set_number']}: ${set['weight']}lb x ${set['reps']} reps - ${set['is_completed'] == 1 ? "✔" : "✘"}',
                        )),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
          actions: [
            // Close button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: Column(
        children: [
          // Welcome message
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Welcome, Clay!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black, 
              ),
            ),
          ),
          // Goal input row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Text(
                  'Goal:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    autofocus: false,
                    decoration: const InputDecoration(
                      hintText: 'Enter a personal goal',
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Calendar to view workout days
          TableCalendar(
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2040, 12, 31),
            focusedDay: _focusedDay,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green.shade400,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Color.fromARGB(255, 102, 187, 106),
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              // Custom cell for days with workouts
              defaultBuilder: (context, day, focusedDay) {
                if (_hasWorkoutOn(day)) {
                  return GestureDetector(
                    onTap: () => _showWorkoutDetails(day),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 102, 187, 106),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
            selectedDayPredicate: (day) => _workoutController.isDayComplete(day),
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
          ),
          const SizedBox(height: 20),
          // Button to start a new workout
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkoutSelectionPage(
                    onWorkoutSaved: () {
                      setState(() {
                        _workoutController.markTodayComplete(); // Mark today as completed
                        _loadWorkoutDates(); // Reload workout dates
                      });
                    },
                  ),
                ),
              );
            },
            child: const Text("Track Workout"),
          ),
        ],
      ),
    );
  }
}
