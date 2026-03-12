// lib/core/services/connectivity_service.dart

import 'dart:async';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';

enum ConnectivityStatus { online, offline, checking }

class ConnectivityService {
  final http.Client client;
  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  ConnectivityStatus _currentStatus = ConnectivityStatus.checking;
  Timer? _timer;

  ConnectivityService({required this.client});

  Stream<ConnectivityStatus> get statusStream => _statusController.stream;
  ConnectivityStatus get currentStatus => _currentStatus;

  void init() {
    // Start periodic health checks every 5 seconds
    _checkHealth();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkHealth());
  }

  Future<void> _checkHealth() async {
    try {
      // Use the root endpoint which we added in index.js
      final response = await client
          .get(Uri.parse(ApiEndpoints.baseUrl.replaceAll('/api', '')))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        _updateStatus(ConnectivityStatus.online);
      } else {
        _updateStatus(ConnectivityStatus.offline);
      }
    } catch (_) {
      _updateStatus(ConnectivityStatus.offline);
    }
  }

  void _updateStatus(ConnectivityStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
      if (status == ConnectivityStatus.offline) {
        print('🌐 Backend status: OFFLINE (Check ${ApiEndpoints.baseUrl})');
      } else {
        print('🌐 Backend status: ONLINE');
      }
    }
  }

  void dispose() {
    _timer?.cancel();
    _statusController.close();
  }
}
