import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/swap_request.dart';
import '../constants/api_endpoints.dart';

class SwapRequestsProvider with ChangeNotifier {
  List<SwapRequest> _swapRequests = [];
  bool _isLoading = false;
  String? _error;

  List<SwapRequest> get swapRequests => _swapRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSwapRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(APIEndpoints.swapRequests));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _swapRequests = data.map((json) => SwapRequest.fromJson(json)).toList();
      } else {
        _error = 'Failed to load swap requests';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendSwapRequest({
    required String fromUserId,
    required String toUserId,
    required String offeredSkill,
    required String wantedSkill,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newRequest = {
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'offeredSkill': offeredSkill,
        'wantedSkill': wantedSkill,
        'status': 'pending',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'cancelReason': '',
      };

      final response = await http.post(
        Uri.parse(APIEndpoints.swapRequests),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newRequest),
      );

      if (response.statusCode == 201) {
        // Refresh the list after successful creation
        await fetchSwapRequests();
        return true;
      } else {
        _error = 'Failed to send swap request';
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

  Future<bool> respondToSwapRequest({
    required String requestId,
    required String status,
    String? cancelReason,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updateData = {
        'status': status,
        if (cancelReason != null) 'cancelReason': cancelReason,
      };

      final response = await http.put(
        Uri.parse('${APIEndpoints.swapRequests}/$requestId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        // Refresh the list after successful update
        await fetchSwapRequests();
        return true;
      } else {
        _error = 'Failed to update swap request';
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

  Future<bool> deleteSwapRequest(String requestId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('${APIEndpoints.swapRequests}/$requestId'),
      );

      if (response.statusCode == 200) {
        // Refresh the list after successful deletion
        await fetchSwapRequests();
        return true;
      } else {
        _error = 'Failed to delete swap request';
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