import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../constants/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'browse_users_screen.dart';
import '../main.dart';
import '../theme.dart';
import 'package:glassmorphism/glassmorphism.dart';


class UserOnboardingScreen extends StatefulWidget {
  const UserOnboardingScreen({super.key});

  @override
  State<UserOnboardingScreen> createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends State<UserOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _locationController;
  late TextEditingController _skillsOfferedController;
  late TextEditingController _skillsWantedController;
  List<String> _selectedAvailability = [];
  bool _isPublicProfile = true;
  bool _isLoading = false;
  File? _selectedImage;
  String? _photoUrl;

  final List<String> _availabilityOptions = [
    'Weekends',
    'Weekdays',
    'Evenings',
    'Mornings',
    'Afternoons',
  ];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _locationController = TextEditingController(text: user?.location ?? '');
    _skillsOfferedController = TextEditingController(text: user?.skillsOffered.join(', ') ?? '');
    _skillsWantedController = TextEditingController(text: user?.skillWanted.join(', ') ?? '');
    _selectedAvailability = List.from(user?.availability ?? []);
    _isPublicProfile = user?.isPublic ?? true;
    _photoUrl = user?.photoUrl;
  }

  @override
  void dispose() {
    _locationController.dispose();
    _skillsOfferedController.dispose();
    _skillsWantedController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _photoUrl = null; // Clear any previous URL
      });
    }
  }

  Future<String?> _uploadImage(File imageFile, String userId) async {
    // This is a placeholder for image upload logic. In a real app, upload to a server or storage bucket.
    // For now, just return a dummy URL or base64 string.
    // You can replace this with your actual upload logic.
    return null;
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      String? photoUrl = _photoUrl;
      if (_selectedImage != null) {
        photoUrl = await _uploadImage(_selectedImage!, currentUser.id.toString()) ?? photoUrl;
      }

      final skillsOffered = _skillsOfferedController.text
          .split(',')
          .map((skill) => skill.trim())
          .where((skill) => skill.isNotEmpty)
          .toList();
      final skillsWanted = _skillsWantedController.text
          .split(',')
          .map((skill) => skill.trim())
          .where((skill) => skill.isNotEmpty)
          .toList();

      // Update user in API
      final updateData = {
        'name': currentUser.name,
        'location': _locationController.text,
        'photoUrl': photoUrl ?? '',
        'skills': skillsOffered,
        'skillsOffered': skillsOffered,
        'skillWanted': skillsWanted,
        'availability': _selectedAvailability,
        'isPublic': _isPublicProfile,
        'email': currentUser.email,
        'password': currentUser.password,
      };
      final response = await http.put(
        Uri.parse('${APIEndpoints.users}/${currentUser.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updateData),
      );
      if (response.statusCode == 200) {
        final updatedUser = User.fromJson(json.decode(response.body));
        await authProvider.updateCurrentUser(updatedUser);
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainNavScreen()),
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile'), backgroundColor: Colors.red),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleAvailability(String availability) {
    setState(() {
      if (_selectedAvailability.contains(availability)) {
        _selectedAvailability.remove(availability);
      } else {
        _selectedAvailability.add(availability);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Photo Section
                GlassmorphicContainer(
                  width: double.infinity,
                  height: 240,
                  borderRadius: 20,
                  blur: 10,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  border: 2,
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.3),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Profile Photo',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (user?.photoUrl.isNotEmpty ?? false)
                                    ? NetworkImage(user!.photoUrl)
                                    : null as ImageProvider?,
                            child: (_selectedImage == null && (user?.photoUrl?.isEmpty ?? true))
                                ? const Icon(Icons.camera_alt, size: 60)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Tap to select a photo'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Location
                GlassmorphicContainer(
                  width: double.infinity,
                  height: 140,
                  borderRadius: 20,
                  blur: 10,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  border: 2,
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.3),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            labelText: 'Location',
                            prefixIcon: const Icon(Icons.location_on),
                            labelStyle: Theme.of(context).textTheme.labelLarge,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your location';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Skills
                GlassmorphicContainer(
                  width: double.infinity,
                  height: 230,
                  borderRadius: 20,
                  blur: 10,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  border: 2,
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.3),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Skills',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _skillsOfferedController,
                          decoration: InputDecoration(
                            labelText: 'Skills Offered (comma separated)',
                            prefixIcon: const Icon(Icons.offline_bolt),
                            labelStyle: Theme.of(context).textTheme.labelLarge,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter at least one skill you offer';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _skillsWantedController,
                          decoration: InputDecoration(
                            labelText: 'Skills Wanted (comma separated)',
                            prefixIcon: const Icon(Icons.search),
                            labelStyle: Theme.of(context).textTheme.labelLarge,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter at least one skill you want';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Availability
                GlassmorphicContainer(
                  width: double.infinity,
                  height: 180,
                  borderRadius: 20,
                  blur: 10,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  border: 2,
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.3),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Availability',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          children: _availabilityOptions.map((option) {
                            final selected = _selectedAvailability.contains(option);
                            return FilterChip(
                              label: Text(option),
                              selected: selected,
                              onSelected: (_) => _toggleAvailability(option),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Public Profile Toggle
                GlassmorphicContainer(
                  width: double.infinity,
                  height: 60,
                  borderRadius: 20,
                  blur: 10,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  border: 2,
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.3),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.public),
                        const SizedBox(width: 8),
                        Text('Public Profile'),
                        const Spacer(),
                        Switch(
                          value: _isPublicProfile,
                          onChanged: (value) {
                            setState(() {
                              _isPublicProfile = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Save Profile',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 