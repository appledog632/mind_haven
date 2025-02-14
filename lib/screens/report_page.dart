import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {
  final Map<String, dynamic> serverData;

  const ReportPage({required this.serverData, Key? key}) : super(key: key);

  Color _getProgressColor(double value) {
    if (value <= 0.25) return Colors.red;
    if (value <= 0.5) return Colors.orange;
    if (value <= 0.75) return Colors.lightGreen;
    return Colors.green;
  }

  String _getMeterLabel(double value) {
    if (value <= 0.25) return 'Worst';
    if (value <= 0.5) return 'Mild';
    if (value <= 0.75) return 'Good';
    return 'Great';
  }

  Widget _buildParameterRow(String parameter, int value, String? interpretation) {
    if (interpretation == null) {
      return SizedBox.shrink();  // If interpretation is null, return an empty widget
    }

    double progressValue = (value + 1) / 4.0; // Convert to 0-1 range
    Color progressColor = _getProgressColor(progressValue);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parameter.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey[800],
            ),
          ),
          SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(progressColor),
              minHeight: 12,
            ),
          ),
          SizedBox(height: 6),
          Text(
            _getMeterLabel(progressValue),
            style: TextStyle(
              color: progressColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parameters = serverData['parameters'] as Map<String, dynamic>;
    final interpretation = serverData['interpretation'] as Map<String, dynamic>;
    final emotion = serverData['emotion'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text('Wellness Report'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Overall Emotion',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      emotion.toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Health Parameters',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 16),
            ...parameters.entries.map((entry) {
              final paramKey = entry.key;
              final paramValue = entry.value;
              final paramInterpretation = interpretation[paramKey];

              // Check if the value is not null before proceeding
              if (paramValue == null) {
                return SizedBox.shrink(); // Skip if value is null
              }

              return _buildParameterRow(paramKey, (paramValue as num).toInt(), paramInterpretation);
            }).toList(),
          ],
        ),
      ),
    );
  }
}
