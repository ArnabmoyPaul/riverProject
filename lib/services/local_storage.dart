import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorage {
  static const String _pendingReportsKey = 'pending_reports';

  Future<void> savePendingReport(Map<String, dynamic> report) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = await getPendingReports();
    pending.add(report);
    await prefs.setString(_pendingReportsKey, json.encode(pending));
  }

  Future<List<Map<String, dynamic>>> getPendingReports() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_pendingReportsKey);
    return data != null
        ? List<Map<String, dynamic>>.from(json.decode(data))
        : [];
  }

  Future<void> removePendingReport(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = await getPendingReports();
    pending.removeAt(index);
    await prefs.setString(_pendingReportsKey, json.encode(pending));
  }
}
