import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_node_auth/services/local_storage.dart';
import 'package:flutter_node_auth/services/report_service.dart';

class SyncManager {
  final LocalStorage _storage = LocalStorage();
  final ReportService _api = ReportService();

  Future<void> syncPendingReports() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;

    final pending = await _storage.getPendingReports();
    for (int i = 0; i < pending.length; i++) {
      try {
        final success = await _api.submitReport(
          shelterCode: '',
          majorTask: '',
          subTasks: [],
          comment: '',
          photos: [],
          captions: [] /* convert from stored data */,
        );
        if (success) await _storage.removePendingReport(i);
      } catch (e) {
        debugPrint('Failed to sync report $i: $e');
      }
    }
  }
}
