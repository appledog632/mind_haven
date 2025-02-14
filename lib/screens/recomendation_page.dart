import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mentalwellness/bottom_navbar.dart';

class RecommendationsPage extends StatelessWidget {
  final List<String> goals;

  const RecommendationsPage({Key? key, required this.goals}) : super(key: key);

  // Save goals to SharedPreferences in the required format
  Future<void> saveGoalsToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // Convert goals to the required format
    List<Map<String, dynamic>> dailyTasks = goals
        .map((goal) => {'task': goal, 'completed': false})
        .toList();

    // Save the formatted list as a JSON string
    await prefs.setString('dailyTasks', json.encode(dailyTasks));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Based on your concerns, we recommend these goals:",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),

                  Column(
                    children: goals.map((goal) {
                      return Container(
                        width: 130,
                        padding: EdgeInsets.all(15),
                        margin: EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          goal,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 30),

                  // Row for Previous and OK buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "PREVIOUS",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff8C7CE3),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await saveGoalsToLocalStorage();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FloatingNavBarHome(), // Navigate to home
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Color(0xff8C7CE3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "OK",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
