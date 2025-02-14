import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mentalwellness/screens/goal_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalsHubPage extends StatefulWidget {
  const GoalsHubPage({super.key});

  @override
  _GoalsHubPageState createState() => _GoalsHubPageState();
}

class _GoalsHubPageState extends State<GoalsHubPage> {
  int _waterCount = 0;
  String _todayKey = _getTodayKey();
  final List<Map<String, dynamic>> _goals = [
    {'task': 'Eat 3 meals', 'icon': Icons.restaurant, 'progress': 0.7},
    {
      'task': 'Meditate for 5 min',
      'icon': Icons.self_improvement,
      'progress': 0.4
    },
    {'task': 'Skincare', 'icon': Icons.spa, 'progress': 0.5},
    {'task': 'Read a book', 'icon': Icons.menu_book, 'progress': 0.3},
    {
      'task': 'Exercise for 30 min',
      'icon': Icons.directions_run,
      'progress': 0.6
    },
    {'task': 'Sleep by 11pm', 'icon': Icons.nights_stay, 'progress': 0.8},
  ];

  @override
  void initState() {
    super.initState();
    _loadWaterCount();
  }

  static String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}'; // Format: YYYY-MM-DD
  }

  void _loadWaterCount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('waterIntake') ?? '{}';
    final waterData = json.decode(savedData) as Map<String, dynamic>;

    setState(() {
      _waterCount = waterData[_todayKey]?.toInt() ?? 0;
    });
  }

  void _updateWaterCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _waterCount = count.clamp(0, 8);
      prefs.setInt('waterCount', _waterCount);
    });
  }

  void _addGoal(String newGoal) {
    setState(() {
      _goals.add({
        'task': newGoal,
        'icon': Icons.add_task,
        'progress': 0.0,
      });
    });
  }

  void _showAddGoalDialog() {
    TextEditingController _goalController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Goal'),
          content: TextField(
            controller: _goalController,
            decoration: InputDecoration(hintText: 'Enter your goal'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_goalController.text.isNotEmpty) {
                  _addGoal(_goalController.text);
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToGoalPage(Map<String, dynamic> goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalsPage(
          taskName: goal['task'], // Pass task name
          progress: goal['progress'], // Pass progress
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Goals Hub',
            style: TextStyle(
              fontWeight: FontWeight.bold, // Makes the text bold
              fontSize: 20, // Optional: Adjust font size
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Water Intake Section (Fixed at the Top)
          Card(
            color: Colors.lightBlue[50],
            margin: EdgeInsets.all(16),
            child: SizedBox(
              height: 120, // Set a fixed height for the Card
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_drink, color: Colors.blue[800]),
                        SizedBox(width: 8),
                        Text(
                          'Daily Water Intake',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16), // Increased spacing
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            children: List.generate(8, (index) {
                              return Container(
                                width: 22,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: index < _waterCount
                                      ? Colors.blue[800]
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.blue[100]!),
                                ),
                              );
                            }),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: Colors.blue[800]),
                          onPressed: () => _updateWaterCount(_waterCount + 1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable Goals List Section
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                ..._goals.map((goal) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(goal['icon'], color: Colors.purple),
                            title: Text(
                              goal['task'],
                              style: TextStyle(fontSize: 16),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => _navigateToGoalPage(goal),
                          ),
                          SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: goal['progress'],
                            backgroundColor: Colors.grey[300],
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                // Add Goal Button
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text(
                      'Add Goal',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    onPressed: _showAddGoalDialog,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
