class FeedbackModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final double rating;
  final String? comment;
  final int timestamp;

  FeedbackModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.rating,
    this.comment,
    required this.timestamp,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id']?.toString() ?? '',
      fromUserId: json['fromUserId']?.toString() ?? '',
      toUserId: json['toUserId']?.toString() ?? '',
      rating: (json['rating'] is int)
          ? (json['rating'] as int).toDouble()
          : (json['rating'] as num).toDouble(),
      comment: json['comment'],
      timestamp: json['timestamp'] is int ? json['timestamp'] : int.tryParse(json['timestamp'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'rating': rating,
        'comment': comment,
        'timestamp': timestamp,
      };
} 