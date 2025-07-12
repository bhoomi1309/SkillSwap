import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/swap_requests_provider.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../theme.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';

class UserProfileScreen extends StatefulWidget {
  final User user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = false;

  Future<void> _sendSwapRequest() async {
    setState(() {
      _isLoading = true;
    });

    // Show dialog to select skills
    final result = await showSwapRequestDialog(context, widget.user);

    if (result != null && mounted) {
      final swapRequestsProvider = Provider.of<SwapRequestsProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      
      if (currentUser != null) {
        final success = await swapRequestsProvider.sendSwapRequest(
          fromUserId: currentUser.id.toString(),
          toUserId: widget.user.id.toString(),
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
                success ? 'Swap request sent successfully!' : 'Failed to send request.',
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
        title: Text('${widget.user.name}\'s Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            GlassmorphicContainer(
              width: double.infinity,
              height: 300,
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
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: widget.user.photoUrl.isNotEmpty
                          ? NetworkImage(widget.user.photoUrl)
                          : null,
                      child: widget.user.photoUrl.isEmpty
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.user.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.user.location.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            widget.user.location,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.user.rating.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Skills Offered
            GlassmorphicContainer(
              width: double.infinity,
              height: 120,
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
                      'Skills Offered',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.user.skillsOffered.map((skill) {
                        return Chip(
                          label: Text(skill),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          side: BorderSide(color: AppColors.primary),
                          labelStyle: const TextStyle(fontSize: 14),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Skills Wanted
            GlassmorphicContainer(
              width: double.infinity,
              height: 120,
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
                      'Skills Wanted',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.user.skillWanted.map((skill) {
                        return Chip(
                          label: Text(skill),
                          backgroundColor: Colors.deepPurple.withOpacity(0.1),
                          side: const BorderSide(color: Colors.deepPurple),
                          labelStyle: const TextStyle(fontSize: 14),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Availability
            if (widget.user.availability.isNotEmpty) ...[
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF9800),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.user.availability.map((time) {
                          return Chip(
                            label: Text(time),
                            backgroundColor: const Color(0xFFFF9800).withOpacity(0.1),
                            side: const BorderSide(color: Color(0xFFFF9800)),
                            labelStyle: const TextStyle(fontSize: 14),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Send Swap Request Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _sendSwapRequest,
                icon: _isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.swap_horiz),
                label: Text(_isLoading ? 'Sending...' : 'Send Swap Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Map<String, String>?> showSwapRequestDialog(BuildContext context, User user) async {
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
            value: _selectedSkillOffered,
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
            value: _selectedSkillWanted,
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
        onPressed: _selectedSkillOffered != null && _selectedSkillWanted != null
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