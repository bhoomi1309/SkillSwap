class User {
  final int id;
  final String name;
  final String location;
  final String photoUrl;
  final List<String> skillsOffered;
  final List<String> skillWanted;
  final List<String> skills;
  final List<String> availability;
  final bool isPublic;
  final double rating;
  final int createdAt;
  final String email;
  final String password;
  final String role;
  final String status;
  final List<dynamic> report;
  final String profileImage;
  final String bio;
  final int completedSwaps;

  User({
    required this.id,
    required this.name,
    required this.location,
    required this.photoUrl,
    required this.skillsOffered,
    required this.skillWanted,
    required this.skills,
    required this.availability,
    required this.isPublic,
    required this.rating,
    required this.createdAt,
    required this.email,
    required this.password,
    required this.role,
    required this.status,
    required this.report,
    required this.profileImage,
    required this.bio,
    required this.completedSwaps,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      skillsOffered: List<String>.from(json['skillsOffered'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
      skillWanted: List<String>.from(json['skillWanted'] ?? []),
      availability: List<String>.from(json['availability'] ?? []),
      isPublic: json['isPublic'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      createdAt: json['createdAt'] is int ? json['createdAt'] : int.tryParse(json['createdAt'].toString()) ?? 0,
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? 'user',
      status: json['status'] ?? 'active',
      report: json['report'] ?? [],
      profileImage: json['profile_image'] ?? '',
      bio: json['bio'] ?? '',
      completedSwaps: json['completed_swaps'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'name': name,
      'location': location,
      'photoUrl': photoUrl,
      'skillsOffered': skillsOffered,
      'skills': skills,
      'skillWanted': skillWanted,
      'availability': availability,
      'isPublic': isPublic,
      'rating': rating,
      'createdAt': createdAt,
      'email': email,
      'password': password,
      'role': role,
      'status': status,
      'report': report,
      'profile_image': profileImage,
      'bio': bio,
      'completed_swaps': completedSwaps,
    };
  }
} 