// filename: exercise_entry_widget.dart
// date: Apr 29, 2025
// author: Clay Wieringa
// description: widget for exercise and lower_body_exercise pages

import 'package:flutter/material.dart';

// Widget to manage and display a single exercise entry with sets
class ExerciseEntryWidget extends StatefulWidget {
  final String exerciseName; // Name of the exercise (e.g., "Bench Press")
  final VoidCallback onVideoTap;

  const ExerciseEntryWidget({
    super.key,
    required this.exerciseName,
    required this.onVideoTap,
  });

  @override
  ExerciseEntryWidgetState createState() => ExerciseEntryWidgetState();
}

class ExerciseEntryWidgetState extends State<ExerciseEntryWidget> {
  // Controllers to manage user input for weights and reps
  final List<TextEditingController> weightControllers = [];
  final List<TextEditingController> repsControllers = [];

  // List to track whether each set is completed
  final List<bool> isCompleted = [];

  // returns a list of all entered sets
  List<Map<String, dynamic>> getExerciseData() {
    final sets = <Map<String, dynamic>>[];
    for (int i = 0; i < weightControllers.length; i++) {
      sets.add({
        'set_number': i + 1,
        'weight': int.tryParse(weightControllers[i].text) ?? 0,
        'reps': int.tryParse(repsControllers[i].text) ?? 0,
        'is_completed': isCompleted[i],
      });
    }
    return sets;
  }

  @override
  void initState() {
    super.initState();
    // start with 3 sets by default
    for (int i = 0; i < 3; i++) {
      weightControllers.add(TextEditingController());
      repsControllers.add(TextEditingController());
      isCompleted.add(false);
    }
  }

  // Adds a new set to the exercise table
  void addSet() {
    setState(() {
      weightControllers.add(TextEditingController());
      repsControllers.add(TextEditingController());
      isCompleted.add(false);
    });
  }

  // toggles whether a specific set is marked as completed
  void toggleComplete(int index) {
    setState(() {
      isCompleted[index] = !isCompleted[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // header with exercise name and popup menu for video access
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.exerciseName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'video') widget.onVideoTap();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'video', child: Text('Watch Video')),
                  ],
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
          const Divider(),

          // Table header and set input rows
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(40),  // Set number
                1: FixedColumnWidth(70),  // Previous placeholder
                2: FixedColumnWidth(60),  // Weight input
                3: FixedColumnWidth(60),  // Reps input
                4: FixedColumnWidth(40),  // Completion check
              },
              children: [
                // Table header row
                const TableRow(
                  decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Set', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Previous', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('lb', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Rep', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.check, color: Colors.black54),
                    ),
                  ],
                ),

                // generate rows for each set
                for (int i = 0; i < weightControllers.length; i++)
                  TableRow(
                    decoration: BoxDecoration(
                      color: isCompleted[i] ? Colors.green.shade100 : Colors.transparent,
                    ),
                    children: [
                      // Set number
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('${i + 1}'),
                      ),
                      // Placeholder for previous data (currently hardcoded as 'N/A')
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('N/A'),
                      ),
                      // Weight input field
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: SizedBox(
                          width: 50,
                          child: TextField(
                            controller: weightControllers[i],
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                            ),
                          ),
                        ),
                      ),
                      // Reps input field
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: SizedBox(
                          width: 50,
                          child: TextField(
                            controller: repsControllers[i],
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                            ),
                          ),
                        ),
                      ),
                      // set completion toggle button
                      IconButton(
                        icon: Icon(
                          isCompleted[i] ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isCompleted[i] ? Colors.green : Colors.grey,
                        ),
                        onPressed: () => toggleComplete(i),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Button to add a new set
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height - 790,
            child: ElevatedButton(
              onPressed: addSet,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300),
              child: const Text('+ Add a Set', style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}
