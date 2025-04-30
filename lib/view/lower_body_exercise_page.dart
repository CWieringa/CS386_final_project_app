// filename: lower_body_exercise_page.dart
// date: Apr 29, 2025
// author: Clay Wieringa
// description: the lower body exercise page

import 'package:flutter/material.dart';
import 'widgets/exercise_entry_widget.dart';
import '../data/database_helper.dart';
import 'dart:async';

class LowerBodyExercisePage extends StatefulWidget {
  final VoidCallback onWorkoutSaved;

  const LowerBodyExercisePage({Key? key, required this.onWorkoutSaved}) : super(key: key);

  @override
  _LowerBodyExercisePageState createState() => _LowerBodyExercisePageState();
}

class _LowerBodyExercisePageState extends State<LowerBodyExercisePage> {
  final TextEditingController _titleController = TextEditingController(text: "Lower Body Workout");
  final TextEditingController _descriptionController = TextEditingController();
  Duration _duration = Duration.zero;
  late final Timer _timer;

  final List<GlobalKey<ExerciseEntryWidgetState>> exerciseKeys = [];
  final List<String> exerciseNames = ['Squat', 'Deadlift', 'Split Squat', 'Nordic Curl', 'SL Calf Raises'];

  @override
  void initState() {
    super.initState();
    // Initialize exercise entries for each exercise
    for (var _ in exerciseNames) {
      exerciseKeys.add(GlobalKey<ExerciseEntryWidgetState>());
    }
    // Timer to track workout duration
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

  // Formats the workout duration as MM:SS
  String get _formattedTime {
    final minutes = _duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Prompt user before leaving the page (cancel workout)
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

  // Saves the workout to the database and notifies the user
  void _finishWorkout() async {
    final db = DatabaseHelper();
    final workoutId = await db.insertWorkout(
      _titleController.text,
      _descriptionController.text,
      DateTime.now(),
    );

    // Save exercise data for each exercise entry
    for (int i = 0; i < exerciseKeys.length; i++) {
      final key = exerciseKeys[i];
      final exerciseData = key.currentState?.getExerciseData() ?? [];
      final exerciseId = await db.insertExercise(workoutId, exerciseNames[i]);

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

    // Notify that workout is saved and return to the first page
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
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: TextButton(
                onPressed: _finishWorkout,
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
              // Input for workout title
              TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
              Row(
                children: [
                  Text('⏱️ $_formattedTime', style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              // Input for workout notes
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
              // Exercise entry widgets for each exercise
              for (int i = 0; i < exerciseNames.length; i++)
                ExerciseEntryWidget(
                  key: exerciseKeys[i],
                  exerciseName: exerciseNames[i],
                  onVideoTap: () {}, // Placeholder for video handling
                ),
            ],
          ),
        ),
      ),
    );
  }
}
