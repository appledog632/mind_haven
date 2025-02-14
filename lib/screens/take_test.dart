import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mentalwellness/screens/report_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mentalwellness/services/api_services.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class TakeTestPage extends StatefulWidget {
  @override
  _TakeTestPageState createState() => _TakeTestPageState();
}

class _TakeTestPageState extends State<TakeTestPage> {
  List<String> _questions = [];
  Map<int, double> _answers = {};
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, Map<String, dynamic>> _emotionResponses = {};
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  int _selectedCameraIdx = 0;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
    _initializeCamera();
  }

  // Initialize camera
  Future<void> _initializeCamera() async {
    try {
      // Request camera permission (if not already granted)
      final cameraPermission = await Permission.camera.request();
      if (!cameraPermission.isGranted) {
        print("Camera permission not granted");
        return; // Exit if permission is not granted
      }

      // Initialize the available cameras
      _cameras = await availableCameras();

      // Check if there are available cameras
      if (_cameras == null || _cameras!.isEmpty) {
        print("No cameras available");
        return; // Exit if no cameras are available
      }

      // Initialize camera controller with the first available camera
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
      );

      // Wait for the camera to initialize
      await _cameraController!.initialize();
      setState(() {}); // Rebuild to ensure UI reflects camera initialization

      print("Camera initialized successfully");
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  // Fetch questions from the API
  Future<void> _fetchQuestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final concerns = prefs.getStringList('selectedConcerns') ?? [];

      if (concerns.isEmpty) {
        setState(() {
          _errorMessage =
              'No concerns selected. Please complete previous steps.';
          _isLoading = false;
        });
        return;
      }

      final questions = await ApiService.getQuestions(concerns);
      setState(() {
        _questions = questions;
        _isLoading = false;
        _answers = {for (var i = 0; i < _questions.length; i++) i: 0.0};
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load questions. Please try again.';
        _isLoading = false;
      });
    }
  }

  // Capture image using the camera
  Future<File?> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      print("Camera not initialized or controller is null");
      return null; // Return null if the camera is not initialized
    }

    try {
      // Capture the image and get the XFile
      final XFile file = await _cameraController!.takePicture();

      // Get the file path from XFile and return it as a File object
      print("Image captured: ${file.path}");
      return File(file.path);
    } catch (e) {
      print('Error capturing image: $e');
      return null;
    }
  }

  // Handle image upload to the server
  void _handleImageUpload(int questionIndex) async {
    final imageFile = await _captureImage();
    if (imageFile != null) {
      try {
        final response = await ApiService.uploadImage(imageFile);
        setState(() {
          // Extract the nested emotions data from the response
          _emotionResponses[_questions[questionIndex]] = response['emotions'];
        });
      } catch (e) {
        print('Error sending image to backend: $e');
      }
    }
  }

  // Submit answers to the server
  void _submitAnswers() async {
    final List<Map<String, dynamic>> formattedAnswers = [];

    for (int i = 0; i < _questions.length; i++) {
      formattedAnswers.add({
        'answer': _questions[i],
        'scale': _answers[i]?.toInt() ?? 0,
        'emotion': _emotionResponses[_questions[i]] ?? {},
      });
    }

    try {
      // Get server response
      final serverResponse = await ApiService.submitAnswers(formattedAnswers);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportPage(serverData: serverResponse),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit answers: $e')),
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GENTLE CHECK-IN',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('INSTRUCTIONS',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                )),
                            SizedBox(height: 10),
                            Text(
                              '1. Using the 0-3 scale below...\n'
                              '2. Please answer according to...\n'
                              '3. Please treat each item separately...',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _questions.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _questions[index]
                                        .replaceAll(RegExp(r'\[.*?\]\s*'), ''),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 10),
                                  Slider.adaptive(
                                    value: _answers[index] ?? 0.0,
                                    min: 0,
                                    max: 3,
                                    divisions: 3,
                                    label: _answers[index]?.toStringAsFixed(0),
                                    onChanged: (value) {
                                      setState(() {
                                        _answers[index] = value;
                                      });
                                      // Directly handle the image upload as slider value changes
                                      _handleImageUpload(index);
                                    },
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [0, 1, 2, 3]
                                        .map((e) => Text(e.toString()))
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitAnswers,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff8C7CE3),
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Generate Report',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
