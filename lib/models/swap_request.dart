import 'package:flutter/material.dart';

class SwapRequest {
  final int id;
  final String fromUserId;
  final String toUserId;
  final String offeredSkill;
  final String wantedSkill;
  final String status;
  final int createdAt;
  final String cancelReason;

  SwapRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.offeredSkill,
    required this.wantedSkill,
    required this.status,
    required this.createdAt,
    required this.cancelReason,
  });

  factory SwapRequest.fromJson(Map<String, dynamic> json) {
    return SwapRequest(
      id: int.tryParse(json['id'].toString()) ?? 0,
      fromUserId: json['fromUserId'] ?? '',
      toUserId: json['toUserId'] ?? '',
      offeredSkill: json['offeredSkill'] ?? '',
      wantedSkill: json['wantedSkill'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] is int ? json['createdAt'] : int.tryParse(json['createdAt'].toString()) ?? 0,
      cancelReason: json['cancelReason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'offeredSkill': offeredSkill,
      'wantedSkill': wantedSkill,
      'status': status,
      'createdAt': createdAt,
      'cancelReason': cancelReason,
    };
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'declined':
        return 'Declined';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.isNotEmpty ? status[0].toUpperCase() + status.substring(1) : 'Unknown';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
} 