// filename: model.dart
// date: Apr 29, 2025
// author: Clay Wieringa
// description: model

// Class: a single exercise entry with name, reps, and weight.
class ExerciseEntry {
  final String exerciseName;
  int reps;
  int weight;

  // Constructor to initialize an ExerciseEntry
  ExerciseEntry({
    required this.exerciseName,
    this.reps = 0,
    this.weight = 0,
  });
}

// class for storing workouts by date
class WorkoutLog {
  final Map<DateTime, bool> _log = {};

  // Mark a workout as done for a specific day
  void markWorkoutDone(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    _log[date] = true;
  }

  // Check if a workout was done on a specific day
  bool isWorkoutDone(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _log[date] ?? false;
  }

  // Getter to access the workout log
  Map<DateTime, bool> get log => _log;
}
