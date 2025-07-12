import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../constants/api_endpoints.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Initialize auth state from SharedPreferences
  Future<void> initializeAuth() async {
    if (_isLoading) return; // Prevent multiple simultaneous initializations
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      
      if (userJson != null) {
        final userMap = json.decode(userJson);
        _currentUser = User.fromJson(userMap);
      }
    } catch (e) {
      _error = 'Error initializing auth: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String skillsOffered,
    required String skillsWanted,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate inputs
      if (name.isEmpty || email.isEmpty || password.isEmpty || skillsOffered.isEmpty || skillsWanted.isEmpty) {
        _error = 'All fields are required';
        return false;
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _error = 'Please enter a valid email address';
        return false;
      }

      if (password.length < 6) {
        _error = 'Password must be at least 6 characters long';
        return false;
      }

      // Check if user already exists
      final response = await http.get(Uri.parse(APIEndpoints.users));
      
      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);
        final existingUser = users.cast<Map<String, dynamic>>().where(
          (user) => user['email'] == email,
        ).toList();

        if (existingUser.isNotEmpty) {
          _error = 'User with this email already exists';
          return false;
        }
      }

      // Create new user with correct field names and arrays
      final skillsOfferedList = skillsOffered.split(',').map((skill) => skill.trim()).where((skill) => skill.isNotEmpty).toList();
      final skillsWantedList = skillsWanted.split(',').map((skill) => skill.trim()).where((skill) => skill.isNotEmpty).toList();
      
      final newUser = {
        'name': name,
        'email': email,
        'password': password, // In real app, hash this
        'skills': skillsOfferedList, // Add skills field
        'skillsOffered': skillsOfferedList,
        'skillWanted': skillsWantedList,
        'location': '',
        'photoUrl': '',
        'availability': [],
        'isPublic': true,
        'rating': 0.0,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'profile_image': '',
        'bio': '',
        'completed_swaps': 0,
      };

      final createResponse = await http.post(
        Uri.parse(APIEndpoints.users),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newUser),
      );

      if (createResponse.statusCode == 201) {
        final userData = json.decode(createResponse.body);
        _currentUser = User.fromJson(userData);
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', json.encode(userData));
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to create user';
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

  // Login existing user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        _error = 'Email and password are required';
        return false;
      }

      // Fetch users from API
      final response = await http.get(Uri.parse(APIEndpoints.users));
      
      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);
        
        // Find user with matching email and password
        final matchingUsers = users.cast<Map<String, dynamic>>().where(
          (user) => user['email'] == email && user['password'] == password,
        ).toList();

        if (matchingUsers.isNotEmpty) {
          final userData = matchingUsers.first;
          _currentUser = User.fromJson(userData);
          
          // Save to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', json.encode(userData));
          
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = 'Invalid email or password';
          return false;
        }
      } else {
        _error = 'Failed to fetch users';
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

  // Logout user
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
    } catch (e) {
      // Handle error silently
    }
    
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Update current user after profile edit
  Future<void> updateCurrentUser(User updatedUser) async {
    _currentUser = updatedUser;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(updatedUser.toJson()));
  }
} 