import 'package:flutter/material.dart';

class SwapRequest {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final String skillOffered;
  final String skillWanted;
  final String status; // 'pending', 'accepted', 'rejected', 'completed'
  final DateTime createdAt;
  final DateTime? completedAt;

  SwapRequest({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.skillOffered,
    required this.skillWanted,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });
}

class SwapFeedback {
  final String id;
  final String swapId;
  final String fromUserId;
  final String toUserId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  SwapFeedback({
    required this.id,
    required this.swapId,
    required this.fromUserId,
    required this.toUserId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}

class SwapProvider extends ChangeNotifier {
  List<SwapRequest> _swapRequests = [];
  List<SwapFeedback> _feedbacks = [];

  List<SwapRequest> get swapRequests => _swapRequests;
  List<SwapRequest> get incomingRequests => _swapRequests.where((req) => req.toUserId == '1').toList();
  List<SwapRequest> get outgoingRequests => _swapRequests.where((req) => req.fromUserId == '1').toList();
  List<SwapFeedback> get feedbacks => _feedbacks;

  SwapProvider() {
    // _initializeMockData(); // This line is removed as per the edit hint.
  }

  Future<bool> sendSwapRequest(String toUserId, String toUserName, String skillOffered, String skillWanted) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    final newRequest = SwapRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromUserId: '1',
      fromUserName: 'John Doe',
      toUserId: toUserId,
      toUserName: toUserName,
      skillOffered: skillOffered,
      skillWanted: skillWanted,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    
    _swapRequests.add(newRequest);
    notifyListeners();
    return true;
  }

  Future<bool> respondToSwapRequest(String requestId, String response) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    final requestIndex = _swapRequests.indexWhere((req) => req.id == requestId);
    if (requestIndex != -1) {
      _swapRequests[requestIndex] = SwapRequest(
        id: _swapRequests[requestIndex].id,
        fromUserId: _swapRequests[requestIndex].fromUserId,
        fromUserName: _swapRequests[requestIndex].fromUserName,
        toUserId: _swapRequests[requestIndex].toUserId,
        toUserName: _swapRequests[requestIndex].toUserName,
        skillOffered: _swapRequests[requestIndex].skillOffered,
        skillWanted: _swapRequests[requestIndex].skillWanted,
        status: response,
        createdAt: _swapRequests[requestIndex].createdAt,
        completedAt: response == 'completed' ? DateTime.now() : null,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteSwapRequest(String requestId) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    _swapRequests.removeWhere((req) => req.id == requestId);
    notifyListeners();
    return true;
  }

  Future<bool> submitFeedback(String swapId, String toUserId, double rating, String comment) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    final newFeedback = SwapFeedback(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      swapId: swapId,
      fromUserId: '1',
      toUserId: toUserId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    
    _feedbacks.add(newFeedback);
    notifyListeners();
    return true;
  }
} 