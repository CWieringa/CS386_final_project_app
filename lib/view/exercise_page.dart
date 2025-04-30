// filename: exercise_page.dart
// date: Apr 29, 2025
// author: Clay Wieringa
// description: the exercise page, upper body

import 'package:flutter/material.dart';
import 'widgets/exercise_entry_widget.dart';
import '../data/database_helper.dart';
import 'dart:async';

// Main page that manages workout exercises and saves data
class ExercisePage extends StatefulWidget {
  final VoidCallback onWorkoutSaved;

  const ExercisePage({Key? key, required this.onWorkoutSaved}) : super(key: key);

  @override
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final TextEditingController _titleController = TextEditingController(text: "Upper Body Workout"); // Title for workout
  final TextEditingController _descriptionController = TextEditingController(); // notes for workout
  Duration _duration = Duration.zero;
  late final Timer _timer; // Timer for tracking workout duration

  final List<GlobalKey<ExerciseEntryWidgetState>> exerciseKeys = [];

  // List of exercise names for this workout
  final List<String> exerciseNames = [
    'Bench Press',
    'Bentover Row',
    'Overhead Press',
    'Pull-Ups',
    'Bicep Curls',
    'Tricep Extensions',
  ];

  @override
  void initState() {
    super.initState();
    for (var _ in exerciseNames) {
      exerciseKeys.add(GlobalKey<ExerciseEntryWidgetState>());
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _duration += const Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // format time for display
  String get _formattedTime {
    final minutes = _duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Confirm before the user cancels workout
  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Cancel Workout'),
            content: const Text('Are you sure you want to cancel your workout?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
            ],
          ),
        ) ??
        false;
  }

  // finish the workout and save it to the database
  void _finishWorkout() async {
    final db = DatabaseHelper();
    // Insert workout details into the database
    final workoutId = await db.insertWorkout(
      _titleController.text,
      _descriptionController.text,
      DateTime.now(),
    );

    // Iterate through exercises and save each set data to the database
    for (int i = 0; i < exerciseKeys.length; i++) {
      final key = exerciseKeys[i];
      final exerciseData = key.currentState?.getExerciseData() ?? [];
      final exerciseId = await db.insertExercise(workoutId, exerciseNames[i]);

      // Save each set for this exercise
      for (var set in exerciseData) {
        await db.insertSet(
          exerciseId,
          set['set_number'],
          set['weight'],
          set['reps'],
          set['is_completed'],
        );
      }
    }

    widget.onWorkoutSaved();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Workout saved to database!")));
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (await _onWillPop()) Navigator.pop(context);
            },
          ),
          title: const Text(''),
          actions: [
            // Finish workout button in the top-right corner
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: TextButton(
                onPressed: _finishWorkout, // Call _finishWorkout when tapped
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 78, 190, 243),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Finish', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title input field for workout
              TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
              Row(
                children: [
                  // Display time
                  Text('⏱️ $_formattedTime', style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              // Notes for workout
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Notes...',
                  border: InputBorder.none,
                  isDense: true,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              // Exercise entry widgets for each exercise in the workout
              for (int i = 0; i < exerciseNames.length; i++)
                ExerciseEntryWidget(
                  key: exerciseKeys[i], // diff key for each exercise
                  exerciseName: exerciseNames[i], // name of the exercise
                  onVideoTap: () {}, // handle video tap
                ),
            ],
          ),
        ),
      ),
    );
  }
}
