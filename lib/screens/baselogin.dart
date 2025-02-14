import 'package:flutter/material.dart';
import 'package:mentalwellness/screens/login_details.dart';

class LoginSignupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/images/login_screen.png"), // Replace with your image path
                fit: BoxFit.cover, // Makes the image cover the entire screen
              ),
            ),
          ),

          // Foreground content
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the row
              children: [
                // Login Button
                ElevatedButton(
                  onPressed: () {
                    // Navigate to UsernamePasswordPage with login
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UsernamePasswordPage(isSignup: false),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8C7CE3),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                SizedBox(width: 20), // Space between buttons

                // Signup Button
                ElevatedButton(
                  onPressed: () {
                    // Navigate to UsernamePasswordPage with signup
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UsernamePasswordPage(isSignup: true),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18,color: Colors.black),
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
