import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ReportService {
  static const String _baseUrl = 'https://your-api-domain.com/api';
  static const int _timeoutSeconds = 30;

  Future<bool> submitReport({
    required String shelterCode,
    required String majorTask,
    required List<String> subTasks,
    required String comment,
    required List<File> photos,
    required List<String> captions,
  }) async {
    try {
      // 1. Create multipart request
      final uri = Uri.parse('$_baseUrl/reports');
      var request =
          http.MultipartRequest('POST', uri)
            ..headers.addAll(await _getAuthHeaders())
            ..fields['shelterCode'] = shelterCode
            ..fields['majorTask'] = majorTask
            ..fields['subTasks'] = subTasks.join('|')
            ..fields['comment'] = comment;

      // 2. Add photos
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

      // 3. Send request with timeout
      final response = await request.send().timeout(
        const Duration(seconds: _timeoutSeconds),
      );

      // 4. Handle response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        debugPrint('Server error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Submission error: $e');
      rethrow;
    }
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'Authorization': 'Bearer ${prefs.getString('authToken') ?? ''}',
      'Content-Type': 'multipart/form-data',
    };
  }
}
