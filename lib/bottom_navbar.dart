import 'package:flutter/material.dart';
import 'package:mentalwellness/screens/goals_hub_page.dart';
import 'package:mentalwellness/screens/home_page.dart';
import 'package:mentalwellness/screens/safe_space.dart';

class FloatingNavBarHome extends StatefulWidget {
  @override
  _FloatingNavBarHomeState createState() => _FloatingNavBarHomeState();
}

class _FloatingNavBarHomeState extends State<FloatingNavBarHome> {
  int _selectedIndex = 1;

  // List of widgets to display for each navigation item
  final List<Widget> _pages = [
    const GoalsHubPage(),
    const HomePage(), // Your existing HomePage
    const SafeSpacePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<IconData> icons = [
      Icons.flag, // Goals
      Icons.home, // Home
      Icons.handshake, // Friends
    ];

    return Scaffold(
      body: _pages[_selectedIndex], // Show selected page
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedItemColor: Colors.purple,
            unselectedItemColor: Colors.grey,
            items: icons
                .map(
                  (icon) => BottomNavigationBarItem(
                    icon: Icon(icon, size: 28),
                    label: '', // No text
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}