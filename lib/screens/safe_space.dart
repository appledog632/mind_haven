import 'package:flutter/material.dart';
import 'package:mentalwellness/screens/chat_companion_page.dart';
import 'package:mentalwellness/screens/take_test.dart';

class SafeSpacePage extends StatefulWidget {
  const SafeSpacePage({super.key});

  @override
  _SafeSpacePage createState() => _SafeSpacePage();
}

class _SafeSpacePage extends State<SafeSpacePage> {
  @override
  Widget build(BuildContext context) {
    // Define the width for buttons based on the screen width (or any fixed value)
    double buttonWidth =
        MediaQuery.of(context).size.width * 0.65; // 80% of screen width
    double buttonHeight = 50.0; // Fixed height for buttons

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // "YOUR SAFE SPACE" text in the center
          Spacer(), // Push the text to the center
          Text(
            "YOUR SAFE SPACE",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          Spacer(), // Push the buttons below the text

          // Centered buttons
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: buttonWidth, // Set the width of the button
                height: buttonHeight, // Set the height of the button
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatWithCompanionPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD9D2FF), // Light purple color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "CHAT WITH COMPANION",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15), // Space between the buttons
              Container(
                width: buttonWidth, // Set the width of the button
                height: buttonHeight, // Set the height of the button
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TakeTestPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    backgroundColor: Color(0xFF8C7CE3), // Purple color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "TAKE TEST",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Spacer(), // Push the image to the bottom

          // Image at the very bottom of the screen
          Image.asset(
            'assets/images/chatbot.png', // Replace with your actual image path
            width: MediaQuery.of(context).size.width, // Full-width image
            height: 250, // Adjust the height of the image
            fit: BoxFit.contain, // Ensure the image fits properly
          ),
        ],
      ),
    );
  }
}
