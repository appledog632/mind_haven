import 'package:flutter/material.dart';
import 'package:mentalwellness/bottom_navbar.dart';
import 'gender_selection_page.dart'; // Import the GenderSelectionPage

class UsernamePasswordPage extends StatefulWidget {
  final bool isSignup; // Determines if it's a signup or login

  UsernamePasswordPage({required this.isSignup});

  @override
  _UsernamePasswordPageState createState() => _UsernamePasswordPageState();
}

class _UsernamePasswordPageState extends State<UsernamePasswordPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _nextStep() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMessage("Please enter both username and password.");
      return;
    }

    if (widget.isSignup) {
      // Perform Sign Up
      _signUp(username, password);
    } else {
      // Perform Login
      _login(username, password);
    }
  }

  void _signUp(String username, String password) {
    // Here you can add the logic to register the user to your database
    // For now, we'll just display a message and pretend the user is saved.

    _showMessage("User $username registered successfully!");
    // Navigate to Gender Selection page after sign-up
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GenderSelectionPage(),
      ),
    );
  }

  void _login(String username, String password) {
    // Here you can add the logic to verify if the user exists and the password matches
    // For now, we'll just display a message.

    if (username == "test" && password == "1234") {
      _showMessage("Login successful! Welcome $username.");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                FloatingNavBarHome()), // Replace with your homepage widget
      );
    } else {
      _showMessage("Invalid credentials.");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                image:
                    AssetImage("assets/images/bg.png"), // Same background image
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Username Field
                  // Username Field
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText:
                          "Username", // Move the text above the TextField
                      labelStyle:
                          TextStyle(color: Colors.white), // White label text
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white), // White bottom line
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .blueAccent), // Blue bottom line when focused
                      ),
                      hintText: "Enter your username",
                      hintStyle: TextStyle(
                          color: Colors.white70), // Slightly dimmed hint text
                    ),
                    style: TextStyle(
                        color: Colors.white), // White text for user input
                  ),
                  SizedBox(height: 20),

// Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText:
                          "Password", // Move the text above the TextField
                      labelStyle:
                          TextStyle(color: Colors.white), // White label text
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white), // White bottom line
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .blueAccent), // Blue bottom line when focused
                      ),
                      hintText: "Enter your password",
                      hintStyle: TextStyle(
                          color: Colors.white70), // Slightly dimmed hint text
                    ),
                    style: TextStyle(
                        color: Colors.white), // White text for user input
                  ),

                  SizedBox(height: 30),

                  // Next Step Button
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      widget.isSignup ? "Sign Up" : "Login",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
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
