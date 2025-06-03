import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PhotoUploadPage extends StatefulWidget {
  final String taskTitle;
  final List<String> subtasks;

  const PhotoUploadPage({
    Key? key,
    required this.taskTitle,
    required this.subtasks,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _images.removeAt(index);
      _captionControllers[index].dispose();
      _captionControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Photos'),
        actions: [
          if (_images.isNotEmpty)
            TextButton(
              onPressed:
                  _isSubmitting ? null : () {}, // Add your submit logic here
              child: const Text(
                'Submit',
                style: TextStyle(color: Color.fromARGB(255, 190, 22, 22)),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Task Info Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task: ${widget.taskTitle}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Subtasks: ${widget.subtasks.join(", ")}'),
                const Divider(),
              ],
            ),
          ),

          // Photo List
          Expanded(
            child:
                _images.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No photos added yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Image.file(
                                    _images[index],
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    onPressed:
                                        _isSubmitting
                                            ? null
                                            : () => _removePhoto(index),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: _captionControllers[index],
                                  decoration: InputDecoration(
                                    hintText: 'Caption for Photo ${index + 1}',
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),

          // Camera/Gallery Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed:
                        _isSubmitting
                            ? null
                            : () => _addPhoto(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed:
                        _isSubmitting
                            ? null
                            : () => _addPhoto(ImageSource.gallery),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _captionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
