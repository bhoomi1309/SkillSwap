import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/users_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/swap_requests_provider.dart';
import '../models/user.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../theme.dart';
import 'user_profile_screen.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';

class BrowseUsersScreen extends StatefulWidget {
  const BrowseUsersScreen({super.key});

  @override
  State<BrowseUsersScreen> createState() => _BrowseUsersScreenState();
}

class _BrowseUsersScreenState extends State<BrowseUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredUsers = [];
  List<User> _relatedUsers = [];
  bool _isLoading = false;

  // Mapping of broad skills to related skills
  final Map<String, List<String>> _relatedSkillsMap = {
    'coding': [
      'flutter',
      'python',
      'front-end',
      'backend',
      'java',
      'c++',
      'javascript',
      'react',
      'node',
      'mobile',
      'web',
      'programming',
      'development',
      'software'
    ],
    'design': [
      'ui',
      'ux',
      'figma',
      'photoshop',
      'illustrator',
      'graphic',
      'web design',
      'adobe'
    ],
    'music': ['guitar', 'piano', 'singing', 'drums', 'violin', 'composition'],
    'art': ['drawing', 'painting', 'sketching', 'digital art', 'illustration'],
    // Add more as needed
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UsersProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchUsers(String query) {
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    List<User> availableUsers = usersProvider.users.where((user) {
      return currentUser == null || user.id != currentUser.id;
    }).toList();

    if (query.isEmpty) {
      setState(() {
        _filteredUsers = availableUsers;
        _relatedUsers = [];
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    final relatedSkills = _relatedSkillsMap[lowerQuery] ?? [];

    // Direct matches
    final directMatches = availableUsers
        .where((user) => user.skillsOffered
            .any((skill) => skill.toLowerCase().contains(lowerQuery)))
        .toList();

    // Related matches (not already in direct matches)
    final relatedMatches = availableUsers
        .where((user) =>
            !directMatches.contains(user) &&
            user.skillsOffered.any((skill) =>
                relatedSkills.any((rel) => skill.toLowerCase().contains(rel))))
        .toList();

    setState(() {
      _filteredUsers = directMatches;
      _relatedUsers = relatedMatches;
    });
  }

  Future<Map<String, String>?> showSwapRequestDialog(
      BuildContext context, User user) async {
    String? _selectedSkillOffered;
    String? _selectedSkillWanted;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    final currentUserSkills = currentUser?.skillsOffered ?? [];
    Map<String, String>? result;
    await Dialogs.materialDialog(
      context: context,
      title: 'Request Swap with ${user.name}',
      customView: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: currentUserSkills.contains(_selectedSkillOffered)
                  ? _selectedSkillOffered
                  : null,
              decoration: const InputDecoration(
                labelText: 'Skill You\'ll Offer',
                border: OutlineInputBorder(),
              ),
              items: currentUserSkills
                  .map((skill) => DropdownMenuItem(
                        value: skill,
                        child: Text(skill),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSkillOffered = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: user.skillsOffered.contains(_selectedSkillWanted)
                  ? _selectedSkillWanted
                  : null,
              decoration: const InputDecoration(
                labelText: 'Skill You Want',
                border: OutlineInputBorder(),
              ),
              items: user.skillsOffered
                  .map((skill) => DropdownMenuItem(
                        value: skill,
                        child: Text(skill),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSkillWanted = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        IconsButton(
          onPressed: () => Navigator.of(context).pop(),
          text: 'Cancel',
          iconData: Icons.cancel,
          color: Colors.grey,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
        IconsButton(
          onPressed:
              _selectedSkillOffered != null && _selectedSkillWanted != null
                  ? () {
                      result = {
                        'skillOffered': _selectedSkillOffered!,
                        'skillWanted': _selectedSkillWanted!,
                      };
                      Navigator.of(context).pop();
                    }
                  : () {},
          text: 'Send Request',
          iconData: Icons.send,
          color: Colors.blue,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
    return result;
  }

  Future<void> _sendSwapRequest(User user) async {
    setState(() {
      _isLoading = true;
    });

    // Show dialog to select skills
    final result = await showSwapRequestDialog(context, user);

    if (result != null && mounted) {
      final swapRequestsProvider =
          Provider.of<SwapRequestsProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser != null) {
        final success = await swapRequestsProvider.sendSwapRequest(
          fromUserId: currentUser.id.toString(),
          toUserId: user.id.toString(),
          offeredSkill: result['skillOffered']!,
          wantedSkill: result['skillWanted']!,
        );

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Swap request sent successfully!'
                    : 'Failed to send request.',
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Skills'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer2<UsersProvider, AuthProvider>(
        builder: (context, usersProvider, authProvider, child) {
          final user = authProvider.currentUser;
          if (usersProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (usersProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading users',
                    style: TextStyle(fontSize: 18, color: Colors.red[300]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    usersProvider.error!,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      usersProvider.clearError();
                      usersProvider.fetchUsers();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Filter out current user and initialize filtered users if empty
          final currentUser = authProvider.currentUser;
          List<User> availableUsers = usersProvider.users.where((user) {
            return (currentUser == null || user.id != currentUser.id) &&
                user.role.toLowerCase() != 'admin';
          }).toList();

          if (_filteredUsers.isEmpty && availableUsers.isNotEmpty) {
            _filteredUsers = availableUsers;
          }

          return Column(
            children: [
              // Greeting/Welcome Message
              if (user != null) ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GlassmorphicContainer(
                    width: double.infinity,
                    height: 100,
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
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: user.photoUrl.isNotEmpty
                                ? NetworkImage(user.photoUrl)
                                : null,
                            child: user.photoUrl.isEmpty
                                ? const Icon(Icons.person, size: 28)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome, ${user.name}! 👋',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Find people to swap skills with!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by skill (e.g., "Flutter", "Cooking")',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchUsers('');
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: _searchUsers,
                ),
              ),

              // Results
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (_filteredUsers.isEmpty && _relatedUsers.isEmpty)
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No users found',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Try searching for a different skill',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            if (_filteredUsers.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0),
                                child: Text('Direct Matches',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                              ),
                              ..._filteredUsers.map((user) => UserCard(
                                    user: user,
                                    onViewProfile: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              UserProfileScreen(user: user),
                                        ),
                                      );
                                    },
                                    onRequestSwap: () =>
                                        _sendSwapRequest(user),
                                  )),
                            ],
                            if (_relatedUsers.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0),
                                child: Text('Related Skills',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            color: Colors.deepPurple)),
                              ),
                              ..._relatedUsers.map((user) => UserCard(
                                    user: user,
                                    onViewProfile: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              UserProfileScreen(user: user),
                                        ),
                                      );
                                    },
                                    onRequestSwap: () =>
                                        _sendSwapRequest(user),
                                  )),
                            ],
                          ],
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onViewProfile;
  final VoidCallback onRequestSwap;

  const UserCard({
    super.key,
    required this.user,
    required this.onViewProfile,
    required this.onRequestSwap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicBox(
      blur: 10,
      borderRadius: 20,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
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
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: user.photoUrl.isNotEmpty
                  ? NetworkImage(user.photoUrl)
                  : null,
              child: user.photoUrl.isEmpty
                  ? const Icon(Icons.person, size: 30)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (user.location.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          user.location,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${user.rating.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Skills Offered
        Text(
          'Skills Offered:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: user.skillsOffered.map((skill) {
            return Chip(
              label: Text(skill),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              side: BorderSide(color: AppColors.primary),
              labelStyle: const TextStyle(fontSize: 12),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // Skills Wanted
        Text(
          'Skills Wanted:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: user.skillWanted.map((skill) {
            return Chip(
              label: Text(skill),
              backgroundColor: Colors.deepPurple.withOpacity(0.1),
              side: const BorderSide(color: Colors.deepPurple),
              labelStyle: const TextStyle(fontSize: 12),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Availability
        if (user.availability.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.schedule,
                  size: 16, color: Color(0xFFFF9800)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Available: ${user.availability.join(', ')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Request Button
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onViewProfile,
                  icon: const Icon(Icons.person),
                  label: const Text('View Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onRequestSwap,
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Request Swap'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
                  ],
                ),
      ),
    );
  }
}

class GlassmorphicBox extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Gradient backgroundGradient;
  final Gradient borderGradient;

  const GlassmorphicBox({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 10,
    required this.backgroundGradient,
    required this.borderGradient,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          // Blur layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(),
          ),
          // Glass effect + border
          Container(
            decoration: BoxDecoration(
              gradient: backgroundGradient,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                width: 2,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  width: 1.5,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
