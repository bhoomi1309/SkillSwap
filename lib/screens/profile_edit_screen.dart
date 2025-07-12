import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _skillsOfferedController;
  late TextEditingController _skillsWantedController;

  List<String> _selectedAvailability = [];
  bool _isPublicProfile = true;
  bool _isLoading = false;

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
    if (user != null) {
      _nameController = TextEditingController(text: user.name);
      _locationController = TextEditingController(text: user.location);
      _skillsOfferedController = TextEditingController(text: user.skillsOffered.join(', '));
      _skillsWantedController = TextEditingController(text: user.skillWanted.join(', '));
      _selectedAvailability = List.from(user.availability);
      _isPublicProfile = user.isPublic;
    } else {
      _nameController = TextEditingController();
      _locationController = TextEditingController();
      _skillsOfferedController = TextEditingController();
      _skillsWantedController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _skillsOfferedController.dispose();
    _skillsWantedController.dispose();
    super.dispose();
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

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Parse skills from comma-separated strings
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

      final success = await profileProvider.updateProfile(
        userId: currentUser.id.toString(),
        name: _nameController.text,
        location: _locationController.text.isEmpty ? null : _locationController.text,
        photoUrl: currentUser.photoUrl,
        skillsOffered: skillsOffered,
        skillsWanted: skillsWanted,
        availability: _selectedAvailability,
        isPublic: _isPublicProfile,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(profileProvider.error ?? 'Failed to update profile'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              );
            },
          ),
        ],
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Profile Photo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            final user = authProvider.currentUser;
                            return Stack(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage: user?.photoUrl != null
                                      ? NetworkImage(user!.photoUrl!)
                                      : null,
                                  child: user?.photoUrl == null
                                      ? const Icon(Icons.person, size: 60)
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                                      onPressed: () {
                                        // Mock image picker
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Image picker - Coming Soon!'),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Basic Information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Basic Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location (Optional)',
                            prefixIcon: Icon(Icons.location_on),
                            hintText: 'e.g., New York, NY',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Skills Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Skills',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _skillsOfferedController,
                          decoration: const InputDecoration(
                            labelText: 'Skills You Offer',
                            prefixIcon: Icon(Icons.offline_bolt),
                            hintText: 'e.g., Web Development, Cooking, Guitar',
                            helperText: 'Separate skills with commas',
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter at least one skill';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _skillsWantedController,
                          decoration: const InputDecoration(
                            labelText: 'Skills You Want to Learn',
                            prefixIcon: Icon(Icons.search),
                            hintText: 'e.g., Photography, Spanish, Yoga',
                            helperText: 'Separate skills with commas',
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter at least one skill';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Availability Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Availability',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'When are you available for skill swaps?',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availabilityOptions.map((availability) {
                            final isSelected = _selectedAvailability.contains(availability);
                            return FilterChip(
                              label: Text(availability),
                              selected: isSelected,
                              onSelected: (selected) => _toggleAvailability(availability),
                              backgroundColor: isSelected
                                  ? Theme.of(context).primaryColor.withOpacity(0.2)
                                  : null,
                              selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Privacy Settings
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Privacy Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Public Profile'),
                          subtitle: const Text('Allow others to see your profile'),
                          value: _isPublicProfile,
                          onChanged: (value) {
                            setState(() {
                              _isPublicProfile = value;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: Consumer<ProfileProvider>(
                    builder: (context, profileProvider, child) {
                      return ElevatedButton(
                        onPressed: (profileProvider.isLoading || _isLoading) ? null : _saveProfile,
                        child: (profileProvider.isLoading || _isLoading)
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    },
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