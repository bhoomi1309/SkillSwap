import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1565C0);
  static const secondary = Color(0xFF00C853);
  static const danger = Color(0xFFD32F2F);
  static const lightBackground = Color(0xFFF5F5F5);
}

class AppTextStyles {
  static const heading = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const subtitle = TextStyle(fontSize: 16, color: Colors.grey);
}

class AppStrings {
  static const appTitle = "Skill Swap";
  static const apiUrl = "https://667323296ca902ae11b33da7.mockapi.io/users";
}

class ApiEndpoints {
  static const String baseUrl = "https://667323296ca902ae11b33da7.mockapi.io";
  static const String users = "$baseUrl/users";
  static const String swapRequests = "$baseUrl/swap_requests";
  static const String feedback = "$baseUrl/feedback";
} 