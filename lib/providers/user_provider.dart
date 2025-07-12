import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String? location;
  final String? photoUrl;
  final List<String> skillsOffered;
  final List<String> skillsWanted;
  final List<String> availability;
  final bool isPublicProfile;
  final double rating;
  final int totalSwaps;

  User({
    required this.id,
    required this.name,
    this.location,
    this.photoUrl,
    required this.skillsOffered,
    required this.skillsWanted,
    required this.availability,
    this.isPublicProfile = true,
    this.rating = 0.0,
    this.totalSwaps = 0,
  });
}

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  List<User> _allUsers = [];
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  List<User> get allUsers => _allUsers;
  bool get isLoading => _isLoading;

  UserProvider() {
    _initializeMockData();
  }

  void _initializeMockData() {
    _currentUser = User(
      id: '1',
      name: 'John Doe',
      location: 'New York, NY',
      photoUrl: 'https://picsum.photos/200/200?random=1',
      skillsOffered: ['Web Development', 'Graphic Design', 'Photography'],
      skillsWanted: ['Cooking', 'Guitar Lessons', 'Spanish'],
      availability: ['Weekends', 'Evenings'],
      isPublicProfile: true,
      rating: 4.5,
      totalSwaps: 12,
    );

    _allUsers = [
      User(
        id: '2',
        name: 'Sarah Johnson',
        location: 'Los Angeles, CA',
        photoUrl: 'https://picsum.photos/200/200?random=2',
        skillsOffered: ['Cooking', 'Yoga', 'Painting'],
        skillsWanted: ['Web Development', 'Photography'],
        availability: ['Weekends'],
        rating: 4.8,
        totalSwaps: 8,
      ),
      User(
        id: '3',
        name: 'Mike Chen',
        location: 'San Francisco, CA',
        photoUrl: 'https://picsum.photos/200/200?random=3',
        skillsOffered: ['Guitar Lessons', 'Spanish', 'Math Tutoring'],
        skillsWanted: ['Graphic Design', 'Cooking'],
        availability: ['Evenings', 'Weekends'],
        rating: 4.2,
        totalSwaps: 15,
      ),
      User(
        id: '4',
        name: 'Emily Davis',
        location: 'Chicago, IL',
        photoUrl: 'https://picsum.photos/200/200?random=4',
        skillsOffered: ['Photography', 'Dance', 'French'],
        skillsWanted: ['Yoga', 'Painting'],
        availability: ['Weekends'],
        rating: 4.6,
        totalSwaps: 6,
      ),
      User(
        id: '5',
        name: 'Alex Rodriguez',
        location: 'Miami, FL',
        photoUrl: 'https://picsum.photos/200/200?random=5',
        skillsOffered: ['Cooking', 'Soccer Coaching', 'Portuguese'],
        skillsWanted: ['Web Development', 'Guitar Lessons'],
        availability: ['Evenings'],
        rating: 4.3,
        totalSwaps: 10,
      ),
    ];
  }

  void updateProfile({
    String? name,
    String? location,
    String? photoUrl,
    List<String>? skillsOffered,
    List<String>? skillsWanted,
    List<String>? availability,
    bool? isPublicProfile,
  }) {
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        name: name ?? _currentUser!.name,
        location: location ?? _currentUser!.location,
        photoUrl: photoUrl ?? _currentUser!.photoUrl,
        skillsOffered: skillsOffered ?? _currentUser!.skillsOffered,
        skillsWanted: skillsWanted ?? _currentUser!.skillsWanted,
        availability: availability ?? _currentUser!.availability,
        isPublicProfile: isPublicProfile ?? _currentUser!.isPublicProfile,
        rating: _currentUser!.rating,
        totalSwaps: _currentUser!.totalSwaps,
      );
      notifyListeners();
    }
  }

  List<User> searchUsersBySkill(String skill) {
    return _allUsers.where((user) {
      return user.skillsOffered.any((userSkill) =>
          userSkill.toLowerCase().contains(skill.toLowerCase()));
    }).toList();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
} 