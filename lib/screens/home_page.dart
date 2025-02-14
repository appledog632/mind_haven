import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isDailySelected = true; // Toggle for "Daily Tasks" and "Challenges"
  int _waterCount = 0; // Water intake count
  String _todayKey = _getTodayKey(); // Key for today's data
  List<Map<String, dynamic>> _dailyTasks = []; // List of daily tasks

  // Generate today's key in the format YYYY-MM-DD
  static String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  @override
  void initState() {
    super.initState();
    _loadWaterCount();
    _loadDailyTasks();
  }

  // Load water intake count for today
  Future<void> _loadWaterCount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('waterIntake') ?? '{}';
    final waterData = json.decode(savedData) as Map<String, dynamic>;

    setState(() {
      _waterCount = waterData[_todayKey]?.toInt() ?? 0;
    });
  }

  // Load daily tasks from SharedPreferences
  Future<void> _loadDailyTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTasks = prefs.getString('dailyTasks');

    if (savedTasks != null) {
      setState(() {
        _dailyTasks = List<Map<String, dynamic>>.from(json.decode(savedTasks));
      });
    } else {
      await _initializeDefaultTasks();
    }
  }

  // Initialize default tasks if no saved tasks are found
  Future<void> _initializeDefaultTasks() async {
    _dailyTasks = [
      {'task': 'Eat 3 meals', 'completed': false},
      {'task': 'Meditate for 5 min', 'completed': false},
      {'task': 'Skincare', 'completed': false},
      {'task': 'Read a book', 'completed': false},
      {'task': 'Exercise for 30 min', 'completed': false},
      {'task': 'Sleep by 11pm', 'completed': false},
    ];
    await _saveDailyTasks();
  }

  // Save daily tasks to SharedPreferences
  Future<void> _saveDailyTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dailyTasks', json.encode(_dailyTasks));
  }

  // Update water count and save it to SharedPreferences
  void _updateWaterCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('waterIntake') ?? '{}';
    final waterData = json.decode(savedData) as Map<String, dynamic>;

    waterData[_todayKey] = count.clamp(0, 8); // Ensure count is between 0 and 8

    setState(() {
      _waterCount = waterData[_todayKey];
    });

    await prefs.setString('waterIntake', json.encode(waterData));
  }

  // Toggle task completion status
  void _toggleTaskCompletion(int index) {
    setState(() {
      _dailyTasks[index]['completed'] = !_dailyTasks[index]['completed'];
    });
    _saveDailyTasks();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final avatarHeight = screenHeight * 0.35;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: avatarHeight * 0.5,
                  height: avatarHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/avatar.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Eve',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Weight: 58 kg',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const Text(
                        'Height: 165 cm',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(
                          height:
                              16), // Add extra space between height and tasks
                      // Daily Tasks with LVL 1 Section
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8), // Add padding at the top
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _dailyTasks
                              .map(
                                (task) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        task['task'],
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const Text(
                                        'LVL 1',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Buttons Section
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isDailySelected ? Colors.purple : Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _isDailySelected = true;
                      });
                    },
                    child: Text(
                      'Daily Tasks',
                      style: TextStyle(
                          color:
                              _isDailySelected ? Colors.white : Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !_isDailySelected ? Colors.purple : Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _isDailySelected = false;
                      });
                    },
                    child: Text(
                      'Challenges',
                      style: TextStyle(
                          color:
                              !_isDailySelected ? Colors.white : Colors.black),
                    ),
                  ),
                ),
              ],
            ),

            // Scrollable Content Section
            Expanded(
              child: _isDailySelected
                  ? ListView(
                      children: [
                        // Water Intake Section
                        Card(
                          color: Colors.lightBlue[50],
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Daily Water Intake',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
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
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                  color: Colors.blue[100]!),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add_circle,
                                          color: Colors.blue[800]),
                                      onPressed: () =>
                                          _updateWaterCount(_waterCount + 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Daily Tasks Section
                        ..._dailyTasks.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> task = entry.value;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const Icon(
                                Icons.star,
                                color: Colors.purple,
                                size: 30,
                              ),
                              title: Text(
                                task['task'],
                                style: const TextStyle(fontSize: 16),
                              ),
                              trailing: Checkbox(
                                value: task['completed'],
                                onChanged: (bool? value) {
                                  _toggleTaskCompletion(index);
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    )
                  : const Center(
                      child: Text(
                        'No challenges available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
