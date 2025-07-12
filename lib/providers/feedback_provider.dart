import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/feedback_model.dart';
import '../constants/api_endpoints.dart';

class FeedbackProvider with ChangeNotifier {
  List<FeedbackModel> _feedbacks = [];
  bool _isLoading = false;
  String? _error;

  List<FeedbackModel> get feedbacks => _feedbacks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchFeedbacks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(APIEndpoints.feedback));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _feedbacks = data.map((json) => FeedbackModel.fromJson(json)).toList();
      } else {
        _error = 'Failed to load feedback';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitFeedback({
    required String userName,
    required double rating,
    required String receiverId,
    String? comment,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final feedbackData = {
        'userName': userName,
        'rating': rating,
        'receiverId': receiverId,
        'comment': comment ?? '',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final response = await http.post(
        Uri.parse(APIEndpoints.feedback),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(feedbackData),
      );

      if (response.statusCode == 201) {
        // Refresh the list after successful creation
        await fetchFeedbacks();
        return true;
      } else {
        _error = 'Failed to submit feedback';
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