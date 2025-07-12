import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../constants/api_endpoints.dart';
import '../providers/auth_provider.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.deepPurple,
          tabs: const [
            Tab(text: 'Skill Listings'),
            Tab(text: 'User Management'),
            Tab(text: 'Announcements'),
            Tab(text: 'Data Export'),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: const [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Log out?'),
                      ],
                    ),
                    content: const Text(
                      'Are you sure you want to log out?',
                      style: TextStyle(fontSize: 16),
                    ),
                    actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    actions: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.logout();
                }
              }
          )
        ],
      ),

      body: TabBarView(
        controller: _tabController,
        children: const [
          _SkillListingsTab(),
          _UserManagementTab(),
          _AnnouncementsTab(),
          _DataExportTab(),
        ],
      ),
    );
  }
}


class _SkillListingsTab extends StatefulWidget {
  const _SkillListingsTab();

  @override
  State<_SkillListingsTab> createState() => _SkillListingsTabState();
}

class _SkillListingsTabState extends State<_SkillListingsTab> {
  List<Map<String, dynamic>> pendingSwaps = [];
  List<Map<String, dynamic>> declinedSwaps = [];
  List<Map<String, dynamic>> completedSwaps = [];
  List<Map<String, dynamic>> cancelledSwaps = [];
  bool isLoading = true;
  Map<String, String> userMap = {};

  @override
  void initState() {
    super.initState();
    fetchSwapRequests();
  }

  Future<void> fetchSwapRequests() async {
    final url = Uri.parse(APIEndpoints.swapRequests);
    final userUrl = Uri.parse(APIEndpoints.users);
    final response = await http.get(url);
    final userResponse = await http.get(userUrl);


    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final swaps = List<Map<String, dynamic>>.from(data);
      final userData = List<Map<String, dynamic>>.from(jsonDecode(userResponse.body));

      setState(() {
        pendingSwaps = swaps.where((swap) => swap['status'] == 'pending').toList();
        declinedSwaps = swaps.where((swap) => swap['status'] == 'declined').toList();
        completedSwaps = swaps.where((swap) => swap['status'] == 'completed').toList();
        cancelledSwaps = swaps.where((swap) => swap['status'] == 'cancelled').toList();
        isLoading = false;

        userMap = {
          for (var user in userData) user['id']: user['name']
        };
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load swap requests")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AdminCard(
          title: 'Completed Swaps',
          subtitle: '${completedSwaps.length} successfully completed',
          icon: Icons.check_circle_outline,
          color: Colors.green,
          onTap: () => _showSwapsDialog(
              context,
              completedSwaps,
              'Completed Swaps',
                  (id) async {
                final url = Uri.parse('https://667323296ca902ae11b33da7.mockapi.io/swapRequests/$id');
                final res = await http.delete(url);
                if (res.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request deleted')),
                  );
                }
              },
              fetchSwapRequests
          ),
        ),
        const SizedBox(height: 16),
        _AdminCard(
          title: 'Cancelled Swaps',
          subtitle: '${cancelledSwaps.length} requests were cancelled',
          icon: Icons.cancel_outlined,
          color: Colors.grey,
          onTap: () => _showSwapsDialog(
              context,
              cancelledSwaps,
              'Cancelled Swaps',
                  (id) async {
                final url = Uri.parse('https://667323296ca902ae11b33da7.mockapi.io/swapRequests/$id');
                final res = await http.delete(url);
                if (res.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request deleted')),
                  );
                }
              },
              fetchSwapRequests
          ),
        ),
        const SizedBox(height: 16),
        _AdminCard(
          title: 'Pending Swaps',
          subtitle: '${pendingSwaps.length} pending approval',
          icon: Icons.pending_actions,
          color: Colors.orange,
          onTap: () => _showSwapsDialog(
              context,
              pendingSwaps,
              'Pending Swaps',
                  (id) async {
                final url = Uri.parse('https://667323296ca902ae11b33da7.mockapi.io/swapRequests/$id');
                final res = await http.delete(url);
                if (res.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request deleted')),
                  );
                }
              },
              fetchSwapRequests
          ),
        ),
        const SizedBox(height: 16),
        _AdminCard(
          title: 'Declined Swaps',
          subtitle: '${declinedSwaps.length} swaps declined',
          icon: Icons.cancel,
          color: Colors.red,
          onTap: () => _showSwapsDialog(
              context,
              declinedSwaps,
              'Declined Swaps',
                  (id) async {
                final url = Uri.parse('https://667323296ca902ae11b33da7.mockapi.io/swapRequests/$id');
                final res = await http.delete(url);
                if (res.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request deleted')),
                  );
                }
              },
              fetchSwapRequests
          ),
        ),
      ],
    );
  }

  void _showSwapsDialog(
      BuildContext context,
      List<Map<String, dynamic>> swaps,
      String title,
      Future<void> Function(String id)? onDelete,
      Future<void> Function()? onRefresh,
      ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.6,
          child: ListView.builder(
            itemCount: swaps.length,
            itemBuilder: (context, index) {
              final swap = swaps[index];
              final fromName = userMap[swap['fromUserId']] ?? 'User ${swap['fromUserId']}';
              final toName = userMap[swap['toUserId']] ?? 'User ${swap['toUserId']}';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text(fromName[0])),
                  title: Text('$fromName ↔ $toName'),
                  subtitle: Text(
                    'Offered: ${swap['offeredSkill']}\nWanted: ${swap['wantedSkill'] ?? 'N/A'}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        if (onDelete != null) await onDelete(swap['id']);
                        Navigator.of(context).pop();
                        if (onRefresh != null) await onRefresh();
                      }
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

}






class _UserManagementTab extends StatefulWidget {
  const _UserManagementTab();

  @override
  State<_UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<_UserManagementTab> {
  List<Map<String, dynamic>> activeUsers = [];
  List<Map<String, dynamic>> bannedUsers = [];
  List<Map<String, dynamic>> reportedUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final url = Uri.parse(APIEndpoints.users);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final users = List<Map<String, dynamic>>.from(data);

      setState(() {
        activeUsers = users.where((u) => u['status'] == 'active').toList();
        bannedUsers = users.where((u) => u['status'] == 'banned').toList();
        reportedUsers = users.where((u) =>
        u['reports'] != null && (u['reports'] as List).isNotEmpty).toList();
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch users')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AdminCard(
          title: 'Active Users',
          subtitle: '${activeUsers.length} active users',
          icon: Icons.people,
          color: Colors.green,
          onTap: () => _showUserListDialog(context, 'Active Users', activeUsers),
        ),
        const SizedBox(height: 16),
        _AdminCard(
          title: 'Banned Users',
          subtitle: '${bannedUsers.length} users are banned',
          icon: Icons.block,
          color: Colors.red,
          onTap: () => _showUserListDialog(context, 'Banned Users', bannedUsers),
        ),
        const SizedBox(height: 16),
        _AdminCard(
          title: 'User Reports',
          subtitle: '${reportedUsers.length} reports pending review',
          icon: Icons.report,
          color: Colors.orange,
          onTap: () => _showUserReportsDialog(context),
        ),
        const SizedBox(height: 16),
        _AdminCard(
          title: 'Ban User',
          subtitle: 'Ban a user account',
          icon: Icons.security,
          color: Colors.red,
          onTap: () => _showBanUserDialog(context),
        ),
        const SizedBox(height: 16),
        _AdminCard(
          title: 'Delete User',
          subtitle: 'Permanently remove a user',
          icon: Icons.delete_forever,
          color: Colors.grey,
          onTap: () => _showDeleteUserDialog(context),
        ),
      ],
    );
  }

  void _showDeleteUserDialog(BuildContext context) async {
    // Show loading dialog while fetching
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Fetch all users from API
    final res = await http.get(Uri.parse(APIEndpoints.users));

    Navigator.pop(context); // Remove loading dialog

    if (res.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch users')),
      );
      return;
    }

    final List<dynamic> data = jsonDecode(res.body);
    final List<Map<String, dynamic>> allUsers = List<Map<String, dynamic>>.from(data);

    String? selectedUserId;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select User',
                border: OutlineInputBorder(),
              ),
              items: allUsers
                  .where((user) => user['role']?.toLowerCase() != 'admin')
                  .map((user) {
                return DropdownMenuItem<String>(
                  value: user['id'].toString(),
                  child: Text(user['name'] ?? 'No Name'),
                );
              }).toList(),
              onChanged: (value) {
                selectedUserId = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (selectedUserId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a user to delete'),backgroundColor: Colors.red,),
                );
                return;
              }

              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Confirm Deletion'),
                  content: const Text('Are you sure you want to permanently delete this user?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;

              final deleteRes = await http.delete(
                Uri.parse(APIEndpoints.users+'/'+selectedUserId!),
              );

              Navigator.pop(context); // Close delete dialog

              if (deleteRes.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User deleted successfully')),
                );
                await fetchUsers(); // Refresh UI
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete user')),
                );
              }
            },
          ),
        ],
      ),
    );
  }



  void _showUserListDialog(
      BuildContext context, String title, List<Map<String, dynamic>> users) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (_, index) {
              final user = users[index];
              final image = user['profile_image']?.isNotEmpty == true
                  ? user['profile_image']
                  : user['photoUrl'] ?? '';
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: image.isNotEmpty
                      ? NetworkImage(image)
                      : const AssetImage('assets/default_avatar.png')
                  as ImageProvider,
                ),
                title: Text(user['name'] ?? 'No Name'),
                subtitle: Text('Email: ${user['email'] ?? 'N/A'}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'))
        ],
      ),
    );
  }

  void _showUserReportsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('User Reports'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: reportedUsers.length,
            itemBuilder: (_, index) {
              final user = reportedUsers[index];
              final reports = user['reports'] as List;
              return ListTile(
                leading: const Icon(Icons.report, color: Colors.orange),
                title: Text('User: ${user['name']}'),
                subtitle: Text('Reason: ${reports.map((r) => r['reason']).join(', ')}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'))
        ],
      ),
    );
  }

  void _showBanUserDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ban User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason for ban',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ban User'),
            onPressed: () async {
              final name = nameController.text.trim();
              final reason = reasonController.text.trim();

              if (name.isEmpty || reason.isEmpty) return;

              final userToBan = activeUsers.firstWhere(
                    (u) => u['name'].toString().toLowerCase() == name.toLowerCase(),
                orElse: () => {},
              );

              if (userToBan.isEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User not found')),
                );
                return;
              }

              final userId = userToBan['id'];
              final updatedUser = {
                ...userToBan,
                'status': 'banned',
                'reports': [
                  ...((userToBan['reports'] ?? []) as List),
                  {'reason': reason}
                ]
              };

              final res = await http.put(
                Uri.parse(
                    'https://667323296ca902ae11b33da7.mockapi.io/users/$userId'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(updatedUser),
              );

              Navigator.pop(context);

              if (res.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User banned successfully')),
                );
                await fetchUsers();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to ban user')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}







class _AnnouncementsTab extends StatelessWidget {
  const _AnnouncementsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AdminCard(
          title: 'Send Global Announcement',
          subtitle: 'Send message to all users',
          icon: Icons.announcement,
          color: Colors.blue,
          onTap: () {
            _showAnnouncementDialog(context);
          },
        ),
        const SizedBox(height: 16),
        _AdminCard(
          title: 'Previous Announcements',
          subtitle: 'View sent announcements',
          icon: Icons.history,
          color: Colors.grey,
          onTap: () {
            _showPreviousAnnouncementsDialog(context);
          },
        ),
      ],
    );
  }

  void _showAnnouncementDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Global Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Announcement',
                hintText: 'Enter your announcement...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Announcement sent successfully')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showPreviousAnnouncementsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Previous Announcements'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.announcement),
              title: Text('System Maintenance'),
              subtitle: Text('Sent: 2 days ago\nPlatform will be down for maintenance'),
            ),
            ListTile(
              leading: Icon(Icons.announcement),
              title: Text('New Features'),
              subtitle: Text('Sent: 1 week ago\nNew skill categories added'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _DataExportTab extends StatelessWidget {
  const _DataExportTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AdminCard(
          title: 'Export User Data',
          subtitle: 'Download user information',
          icon: Icons.download,
          color: Colors.green,
          onTap: () {
            _showExportDialog(context, 'User Data');
          },
        ),
        const SizedBox(height: 16),
        _AdminCard(
          title: 'Export Swap Data',
          subtitle: 'Download swap activity data',
          icon: Icons.swap_horiz,
          color: Colors.blue,
          onTap: () {
            _showExportDialog(context, 'Swap Data');
          },
        ),
        const SizedBox(height: 16),
        _AdminCard(
          title: 'Export Analytics',
          subtitle: 'Download platform analytics',
          icon: Icons.analytics,
          color: Colors.purple,
          onTap: () {
            _showExportDialog(context, 'Analytics');
          },
        ),
        const SizedBox(height: 16),
        _AdminCard(
          title: 'Backup Database',
          subtitle: 'Create database backup',
          icon: Icons.backup,
          color: Colors.orange,
          onTap: () {
            _showExportDialog(context, 'Database Backup');
          },
        ),
      ],
    );
  }

  void _showExportDialog(BuildContext context, String dataType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export $dataType'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select export format:'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$dataType exported as CSV')),
                      );
                    },
                    icon: const Icon(Icons.table_chart),
                    label: const Text('CSV'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$dataType exported as JSON')),
                      );
                    },
                    icon: const Icon(Icons.code),
                    label: const Text('JSON'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                radius: 28,
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}