import 'package:flutter/material.dart';

class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://your-api-domain.com';
  static const String apiVersion = 'v1';
  
  // API Endpoints
  static const String loginEndpoint = '/$apiVersion/auth/login';
  static const String todayScheduleEndpoint = '/$apiVersion/guard/today-schedule';
  static const String checkInEndpoint = '/$apiVersion/guard/check-in';
  static const String checkOutEndpoint = '/$apiVersion/guard/check-out';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // UI Constants
  static const String appName = 'AFWest Guard';
  static const Color primaryColor = Color(0xFF1E3A8A);
  static const double borderRadius = 12.0;
  static const double padding = 16.0;
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

class ShiftStatus {
  static const String notStarted = 'not_started';
  static const String ongoing = 'ongoing';
  static const String completed = 'completed';
}
