// filename: database_helper.dart
// date: Apr 29, 2025
// author: Clay Wieringa
// description: database helper, functions, setup

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _db;

  // Getter for the database
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  // initializes the database, and file path.
  Future<Database> _initDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'workout_tracker.db');

    print('Database path: $path');  // Print the path of the database (THIS IS FOR EASILY LOCATING DB FILE)

    // Open the database, create if doesn't exist
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // creates the tables (when database created)
  Future _onCreate(Database db, int version) async {
    // create 'workouts' table
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        date TEXT
      )
    ''');

    // create 'exercises' table
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER,
        name TEXT,
        FOREIGN KEY (workout_id) REFERENCES workouts (id)
      )
    ''');

    // create 'sets' table
    await db.execute('''
      CREATE TABLE sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_id INTEGER,
        set_number INTEGER,
        weight INTEGER,
        reps INTEGER,
        is_completed INTEGER,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id)
      )
    ''');
  }

  // inserts a workout into the database
  Future<int> insertWorkout(String title, String description, DateTime date) async {
    final db = await database;
    return await db.insert('workouts', {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
    });
  }

  // inserts an exercise related to a workout into the database
  Future<int> insertExercise(int workoutId, String name) async {
    final db = await database;
    return await db.insert('exercises', {
      'workout_id': workoutId,
      'name': name,
    });
  }

  // inserts a set into the database with the given data
  Future<void> insertSet(int exerciseId, int setNumber, int weight, int reps, bool isCompleted) async {
    final db = await database;
    await db.insert('sets', {
      'exercise_id': exerciseId,
      'set_number': setNumber,
      'weight': weight,
      'reps': reps,
      'is_completed': isCompleted ? 1 : 0,  // convert boolean to integer
    });
  }

  // grabs all workouts from the database
  Future<List<Map<String, dynamic>>> getAllWorkouts() async {
    final db = await database;
    final workouts = await db.query('workouts'); // Fetch all workouts
    return workouts.map((w) {
      return {
        'id': w['id'],
        'title': w['title'],
        'description': w['description'],
        'date': DateTime.parse(w['date'] as String),  // Convert the date string back to a DateTime object
      };
    }).toList();
  }

  // grabs workouts for a specific date
  Future<List<Map<String, dynamic>>> getWorkoutsByDate(DateTime date) async {
    final db = await database;
    final dateString = DateTime(date.year, date.month, date.day).toIso8601String().substring(0, 10);
    return await db.query(
      'workouts',
      where: "date LIKE ?",
      whereArgs: ['$dateString%'],
    );
  }

  // grabs exercises and their sets for a given workout
  Future<List<Map<String, dynamic>>> getExercisesWithSets(int workoutId) async {
    final db = await database;
    final exercises = await db.query('exercises', where: 'workout_id = ?', whereArgs: [workoutId]);

    List<Map<String, dynamic>> result = [];
    for (final exercise in exercises) {
      // grab sets related to the current exercise
      final sets = await db.query('sets', where: 'exercise_id = ?', whereArgs: [exercise['id']]);
      result.add({'name': exercise['name'], 'sets': sets});
    }

    return result;
  }
}
