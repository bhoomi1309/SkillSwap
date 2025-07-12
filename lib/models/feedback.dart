class FeedbackModel {
  final int id;
  final String swapId;
  final String fromUserId;
  final String toUserId;
  final double rating;
  final String comment;
  final int timestamp;

  FeedbackModel({
    required this.id,
    required this.swapId,
    required this.fromUserId,
    required this.toUserId,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      swapId: json['swapId'] ?? '',
      fromUserId: json['fromUserId'] ?? '',
      toUserId: json['toUserId'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      timestamp: json['timestamp'] is int ? json['timestamp'] : int.tryParse(json['timestamp'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'swapId': swapId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp,
    };
  }
} 