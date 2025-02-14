import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalsPage extends StatefulWidget {
  final String taskName;
  final double progress;

  const GoalsPage({Key? key, required this.taskName, required this.progress})
      : super(key: key);

  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  List<String> ongoingTasks = [
    'Study for Mathematics exam',
    'Complete Flutter project',
    'Prepare presentation slides'
  ];
  List<String> completedTasks = [
    'Attend workshop',
    'Finish online course'
  ];
  List<String> ongoingChallenges = [
    '10K steps daily challenge',
    '30-day coding streak'
  ];
  List<String> completedChallenges = [
    '7-day water intake challenge',
    '2-week meditation challenge'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskName),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Fixed Progress Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0),
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: LinearProgressIndicator(
              value: widget.progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              color: Colors.blue[800],
              minHeight: 12,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('ONGOING'),
                  _buildTaskCard(
                    title: 'Ongoing Tasks (${ongoingTasks.length})',
                    items: ongoingTasks,
                    icon: Icons.task,
                  ),
                  _buildTaskCard(
                    title: 'Ongoing Challenges (${ongoingChallenges.length})',
                    items: ongoingChallenges,
                    icon: Icons.emoji_events,
                  ),
                  _buildSectionTitle('COMPLETED'),
                  _buildTaskCard(
                    title: 'Completed Tasks (${completedTasks.length})',
                    items: completedTasks,
                    icon: Icons.task_alt,
                  ),
                  _buildTaskCard(
                    title: 'Completed Challenges (${completedChallenges.length})',
                    items: completedChallenges,
                    icon: Icons.verified,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.blue[800],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required String title,
    required List<String> items,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Theme(
        data: ThemeData().copyWith(
          dividerColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.blue[800]),
        ),
        child: ExpansionTile(
          title: Row(
            children: [
              Icon(icon, color: Colors.blue[800]),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          collapsedBackgroundColor: Colors.white,
          backgroundColor: Colors.blue[50],
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          expandedAlignment: Alignment.centerLeft,
          children: items
              .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildTaskItem(item),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTaskItem(String task) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.chevron_right, color: Colors.blue[800]),
        ),
        title: Text(
          task,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Text(
          'Due: ${DateTime.now().add(Duration(days: 3)).toString().substring(0, 10)}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.more_vert, color: Colors.grey[500]),
        onTap: () => _showTaskDetails(context, task),
      ),
    );
  }

  void _showTaskDetails(BuildContext context, String task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task Details', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Description: ${_generateTaskDescription(task)}'),
            SizedBox(height: 10),
            Text('Status: ${completedTasks.contains(task) ? 'Completed' : 'In Progress'}'),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: completedTasks.contains(task) ? 1.0 : 0.6,
              backgroundColor: Colors.grey[200],
              color: Colors.blue[800],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text('Close', style: TextStyle(color: Colors.blue[800])),
          ),
        ],
      ),
    );
  }

  String _generateTaskDescription(String task) {
    if (task.contains('Study')) return 'Prepare for upcoming examination';
    if (task.contains('project')) return 'Complete Flutter UI implementation';
    if (task.contains('presentation')) return 'Create slides for team meeting';
    return 'Default task description';
  }
}