// lib/core/network/network_monitor.dart
import 'dart:async';
import 'package:aroha_facility_app/core/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class NetworkMonitor {
  // Global reactive state
  static final ValueNotifier<bool> isOnline = ValueNotifier(false);
  static Timer? _timer;

  // Call this once in your main.dart or after Login
  static void startMonitoring() {
    _pingServer(); // Initial check
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _pingServer());
  }

  static void stopMonitoring() {
    _timer?.cancel();
  }

  static Future<void> _pingServer() async {
    try {
      // Very fast 2-second timeout ping to your server's health/base endpoint
      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 2)));
      final response = await dio.get(ApiConstants.getCriticalityCount);
      
      if (response.statusCode == 200) {
        if (!isOnline.value) isOnline.value = true;
      } else {
        if (isOnline.value) isOnline.value = false;
      }
    } catch (e) {
      // Any DioException (timeout, connection refused) means SATCOM is down
      if (isOnline.value) isOnline.value = false;
    }
  }
}