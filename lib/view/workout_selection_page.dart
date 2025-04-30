// filename: workout_selection_page.dart
// date: Apr 29, 2025
// author: Clay Wieringa
// description: basic page that just holds buttons for selecting workout.

import 'package:flutter/material.dart';
import 'exercise_page.dart';
import 'lower_body_exercise_page.dart';

class WorkoutSelectionPage extends StatelessWidget {
  final VoidCallback onWorkoutSaved;

  const WorkoutSelectionPage({Key? key, required this.onWorkoutSaved}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Workout')), // App bar title
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Upper body workout button
              ElevatedButton(
                onPressed: () {
                  // Navigates to the ExercisePage for upper body workout
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExercisePage(onWorkoutSaved: onWorkoutSaved),
                    ),
                  );
                },
                child: const Text('Upper Body'),
              ),
              const SizedBox(height: 16),
              // Lower body workout button
              ElevatedButton(
                onPressed: () {
                  // Navigates to the LowerBodyExercisePage for lower body workout
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LowerBodyExercisePage(onWorkoutSaved: onWorkoutSaved),
                    ),
                  );
                },
                child: const Text('Lower Body'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
