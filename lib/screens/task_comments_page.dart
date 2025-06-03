// screens/task_comments_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_node_auth/screens/dashboard_screen.dart';
import 'package:flutter_node_auth/screens/photo_upload_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskCommentsPage extends StatefulWidget {
  final String taskTitle;
  final List<String> selectedSubtasks;

  const TaskCommentsPage({
    super.key,
    required this.taskTitle,
    required this.selectedSubtasks,
  });

  @override
  _TaskCommentsPageState createState() => _TaskCommentsPageState();
}

class _TaskCommentsPageState extends State<TaskCommentsPage> {
  final TextEditingController _commentController = TextEditingController();

  // In task_comments_page.dart
  void _submitComment() async {
    if (_commentController.text.trim().isNotEmpty) {
      // Save comment first
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('taskComment', _commentController.text.trim());

      // Debug logging to check values
      print('TaskCommentsPage - taskTitle: ${widget.taskTitle}');
      print('TaskCommentsPage - selectedSubtasks: ${widget.selectedSubtasks}');

      if (widget.taskTitle.isEmpty) {
        print('Error: taskTitle is null or empty');
        return;
      }

      // Then navigate to photo upload
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => PhotoUploadPage(
                taskTitle: widget.taskTitle,
                subtasks: widget.selectedSubtasks,
              ),
        ),
      );
    }
  }

  //void _submitAndReturn() async {
  //if (_commentController.text.trim().isNotEmpty) {
  // Store comment in SharedPreferences
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // await prefs.setString('taskComment', _commentController.text.trim());

  // Navigator.pushAndRemoveUntil(
  // context,
  //MaterialPageRoute(builder: (context) => const DashboardScreen()),
  // (route) => false,
  // );
  // }
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Comments for ${widget.taskTitle}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Tasks:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              children:
                  widget.selectedSubtasks
                      .map((task) => Text('- $task'))
                      .toList(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write your comments here...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitComment,
              child: Text('Submit Comments'),
            ),
          ],
        ),
      ),
    );
  }
}
