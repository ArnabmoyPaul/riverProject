import 'package:flutter/material.dart';
import 'package:flutter_node_auth/screens/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class SendReportScreen extends StatefulWidget {
  const SendReportScreen({super.key});

  @override
  State<SendReportScreen> createState() => _SendReportScreenState();
}

class _SendReportScreenState extends State<SendReportScreen> {
  late String shelterCode;
  late String majorTask;
  late List<String> subTasks;
  late String comment;
  late List<String> photoPaths;
  late List<String> photoCaptions;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      shelterCode = prefs.getString('selectedShelterCode') ?? 'Not selected';
      majorTask = prefs.getStringList('majorTask')?.first ?? 'No task assigned';
      subTasks = prefs.getStringList('subTasks') ?? [];
      comment = prefs.getString('taskComment') ?? 'No comments';
      photoPaths = prefs.getStringList('photoPaths') ?? [];
      photoCaptions = prefs.getStringList('photoCaptions') ?? [];
    });
  }

  Future<void> _submitToServer() async {
    try {
      // Prepare the complete report data
      final reportData = {
        'shelterCode': shelterCode,
        'majorTask': majorTask,
        'subTasks': subTasks,
        'comment': comment,
        'photos': photoPaths,
        'photoCaptions': photoCaptions,
      };

      // Here you would make your API call
      print('Submitting to server: $reportData');
      
      // Simulate API call success (replace with actual API call)
      // await yourApiCall(reportData);
      
      // Only clear data after successful submission
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('selectedShelterCode');
      await prefs.remove('majorTask');
      await prefs.remove('subTasks');
      await prefs.remove('taskComment');
      await prefs.remove('photoPaths');
      await prefs.remove('photoCaptions');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully')),
      );

      // Navigate to dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      // Show error message if submission fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit report: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shelter Code
            _buildReportItem('Shelter Code', shelterCode),

            // Major Task
            _buildReportItem('Major Task', majorTask),

            // Sub Tasks
            _buildReportItem(
              'Sub Tasks',
              subTasks.isEmpty ? 'None' : subTasks.join('\n• '),
            ),

            // Comment
            _buildReportItem('Comments', comment),

            // Photos Section
            const SizedBox(height: 20),
            const Text(
              'Attached Photos:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (photoPaths.isEmpty)
              const Text('No photos attached')
            else
              Column(
                children: List.generate(photoPaths.length, (index) {
                  return Column(
                    children: [
                      Image.file(
                        File(photoPaths[index]),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Text(
                        photoCaptions.length > index
                            ? 'Caption: ${photoCaptions[index]}'
                            : 'No caption',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                }),
              ),

            // Submit Button
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _submitToServer,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'SEND TO SERVER',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(value),
          const Divider(),
        ],
      ),
    );
  }
}
