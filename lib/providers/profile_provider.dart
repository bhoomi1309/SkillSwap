import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import '../constants/api_endpoints.dart';

class ProfileProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> updateProfile({
    required String userId,
    required String name,
    String? location,
    String? photoUrl,
    required List<String> skillsOffered,
    required List<String> skillsWanted,
    List<String>? availability,
    bool? isPublic,
    String? bio,
    String? status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updateData = {
        'name': name,
        'location': location ?? '',
        'photoUrl': photoUrl ?? '',
        'skills': skillsOffered, // Add skills field
        'skillsOffered': skillsOffered,
        'skillWanted': skillsWanted,
        'availability': availability ?? [],
        'isPublic': isPublic ?? true,
        'bio': bio ?? '',
        'status': status ?? 'Available',
      };

      final response = await http.put(
        Uri.parse('${APIEndpoints.users}/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        _error = 'Failed to update profile';
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 