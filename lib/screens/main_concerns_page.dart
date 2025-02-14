import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
import 'package:mentalwellness/screens/recomendation_page.dart';
import 'package:mentalwellness/services/api_services.dart';

class MainConcernsPage extends StatefulWidget {
  @override
  _MainConcernsPageState createState() => _MainConcernsPageState();
}

class _MainConcernsPageState extends State<MainConcernsPage> {
  List<String> _concerns = [];
  List<String> _selectedConcerns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConcerns();
  }

  Future<void> _fetchConcerns() async {
    try {
      final concerns = await ApiService.fetchConcerns();
      final prefs = await SharedPreferences.getInstance();
      final savedConcerns = prefs.getStringList('selectedConcerns') ?? [];
      
      setState(() {
        _concerns = concerns;
        // Filter and limit to 3 valid concerns
        _selectedConcerns = savedConcerns
            .where((c) => _concerns.contains(c))
            .take(3)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      _showMessage("Failed to load concerns. Please try again.");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Add this new method to save concerns
  Future<void> _saveSelectedConcerns() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedConcerns', _selectedConcerns);
  }

  void _nextPage() async {
    if (_selectedConcerns.isEmpty) {
      _showMessage("Please select at least one concern.");
      return;
    }

    try {
      final goals = await ApiService.fetchGoals(_selectedConcerns);
      await _saveSelectedConcerns(); // Save before navigation
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecommendationsPage(goals: goals),
        ),
      );
    } catch (e) {
      _showMessage("Failed to fetch goals. Please try again.");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
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
                image: AssetImage("assets/images/bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Dynamic Label
                        Text(
                          "DEFINE YOUR ${_selectedConcerns.length < 3 ? 3 - _selectedConcerns.length : 0} MAIN CONCERNS",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),

                        // Concern Options
                        Wrap(
                          spacing: 8,
                          runSpacing: 15,
                          alignment: WrapAlignment.center,
                          children: _concerns.map((concern) {
                            final isSelected = _selectedConcerns.contains(concern);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedConcerns.remove(concern);
                                  } else if (_selectedConcerns.length < 3) {
                                    _selectedConcerns.add(concern);
                                  } else {
                                    _showMessage("You can select up to 3 concerns only.");
                                  }
                                });
                                _saveSelectedConcerns(); // Save after each change
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  concern.replaceAll("_", " ").toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        SizedBox(height: 40),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
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
                            ElevatedButton(
                              onPressed: _nextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff8C7CE3),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                "NEXT STEP",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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