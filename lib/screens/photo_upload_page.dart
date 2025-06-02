import 'package:flutter/material.dart';
import 'package:flutter_node_auth/screens/dashboard_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class PhotoUploadPage extends StatefulWidget {
  const PhotoUploadPage({
    Key? key,
    required String taskTitle,
    required List<String> subtasks,
  }) : super(key: key);

  @override
  State<PhotoUploadPage> createState() => _PhotoUploadPageState();
}

class _PhotoUploadPageState extends State<PhotoUploadPage> {
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  List<TextEditingController> _captionControllers = [];
  bool _isSubmitting = false;

  Future<void> _addPhoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _images.add(File(image.path));
          _captionControllers.add(TextEditingController());
        });
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _images.removeAt(index);
      _captionControllers[index].dispose();
      _captionControllers.removeAt(index);
    });
  }

  Future<void> _submitAllData() async {
    setState(() => _isSubmitting = true);

    try {
      // Get all stored data
      final prefs = await SharedPreferences.getInstance();
      final shelterCode = prefs.getString('selectedShelterCode') ?? '';
      final majorTask = prefs.getStringList('majorTask')?.first ?? '';
      final subTasks = prefs.getStringList('subTasks') ?? [];
      final comment = prefs.getString('taskComment') ?? '';

      // Submit to server
      final success = await _submitToServer(
        shelterCode: shelterCode,
        majorTask: majorTask,
        subTasks: subTasks,
        comment: comment,
        photos: _images,
        captions: _captionControllers.map((c) => c.text).toList(),
      );

      if (success) {
        await _clearLocalData();
        _showSuccess();
        _navigateToDashboard();
      } else {
        _showError('Submission failed');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<bool> _submitToServer({
    required String shelterCode,
    required String majorTask,
    required List<String> subTasks,
    required String comment,
    required List<File> photos,
    required List<String> captions,
  }) async {
    try {
      const String apiUrl = 'https://your-api-endpoint.com/reports';
      var request =
          http.MultipartRequest('POST', Uri.parse(apiUrl))
            ..fields['shelterCode'] = shelterCode
            ..fields['majorTask'] = majorTask
            ..fields['subTasks'] = subTasks.join('|')
            ..fields['comment'] = comment;

      // Add photos
      for (int i = 0; i < photos.length; i++) {
        final file = photos[i];
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();

        request.files.add(
          http.MultipartFile(
            'photos',
            stream,
            length,
            filename: 'photo_$i.jpg',
          ),
        );
        request.fields['caption_$i'] = captions[i];
      }

      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Upload error: $e');
      return false;
    }
  }

  Future<void> _clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedShelterCode');
    await prefs.remove('majorTask');
    await prefs.remove('subTasks');
    await prefs.remove('taskComment');
  }

  void _navigateToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report submitted successfully!')),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    for (var controller in _captionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Upload Photos'),
            actions: [
              if (_images.isNotEmpty)
                TextButton(
                  onPressed: _isSubmitting ? null : _submitAllData,
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child:
                    _images.isEmpty
                        ? const Center(
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  if (_images.isEmpty)
                    const Center(
                      child: Text(
                        'No photos added yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Add photo buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        onPressed: _isSubmitting ? null : () async {
                          try {
                            await _addPhoto(ImageSource.camera);
                          } catch (e) {
                            _showError('Error opening camera: ${e.toString()}');
                          }
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        onPressed: _isSubmitting ? null : () async {
                          try {
                            await _addPhoto(ImageSource.gallery);
                          } catch (e) {
                            _showError('Error accessing gallery: ${e.toString()}');
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
