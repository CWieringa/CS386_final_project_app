// filename: controller.dart
// date: Apr 29, 2025
// author: Clay Wieringa
// description: controller

import '../model/model.dart';

class ExerciseController {
  final List<ExerciseEntry> entries;

  ExerciseController(this.entries);

  // Updates the reps and weight for a specific entry at the given index
  void updateEntry(int index, int reps, int weight) {
    entries[index].reps = reps;
    entries[index].weight = weight;
  }

  // Returns a summary of all exercise entries as a formatted string
  String getSummary() {
    return entries.map((e) => '${e.exerciseName}: ${e.reps} reps, ${e.weight} lb').join('\n');
  }
}

class WorkoutController {
  final WorkoutLog workoutLog;

  // constructor initializes the workout log
  WorkoutController(this.workoutLog);

  // marks today's workout as complete in the workout log
  void markTodayComplete() {
    final today = DateTime.now();
    workoutLog.markWorkoutDone(today);
  }

  // checks if workout for specific day is marked as complete
  bool isDayComplete(DateTime day) => workoutLog.isWorkoutDone(day);
}
