import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/swap_requests_provider.dart';
import '../providers/users_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/feedback_provider.dart';
import '../models/swap_request.dart';
import '../models/user.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../theme.dart';
import 'feedback_screen.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';

class SwapRequestsScreen extends StatefulWidget {
  const SwapRequestsScreen({super.key});

  @override
  State<SwapRequestsScreen> createState() => _SwapRequestsScreenState();
}

class _SwapRequestsScreenState extends State<SwapRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SwapRequestsProvider>(context, listen: false).fetchSwapRequests();
      Provider.of<UsersProvider>(context, listen: false).fetchUsers();
    });
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
        title: const Text('Swap Requests'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Incoming'),
            Tab(text: 'Outgoing'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _RequestsTab(isIncoming: true),
                _RequestsTab(isIncoming: false),
              ],
            ),
    );
  }
}

class _RequestsTab extends StatelessWidget {
  final bool isIncoming;
  const _RequestsTab({required this.isIncoming});

  @override
  Widget build(BuildContext context) {
    return Consumer3<SwapRequestsProvider, UsersProvider, AuthProvider>(
      builder: (context, swapRequestsProvider, usersProvider, authProvider, child) {
        if (swapRequestsProvider.isLoading || usersProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final currentUser = authProvider.currentUser;
        if (currentUser == null) {
          return const Center(child: Text('Please log in to view requests'));
        }
        
        final currentUserId = currentUser.id.toString();
        final requests = swapRequestsProvider.swapRequests.where((req) {
          return isIncoming ? req.toUserId == currentUserId : req.fromUserId == currentUserId;
        }).toList();

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isIncoming ? Icons.inbox : Icons.send, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  isIncoming ? 'No incoming requests' : 'No outgoing requests',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  isIncoming
                      ? 'When someone sends you a swap request, it will appear here'
                      : 'When you send swap requests, they will appear here',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final fromUser = usersProvider.getUserById(request.fromUserId);
            final toUser = usersProvider.getUserById(request.toUserId);
            return _RequestCard(
              request: request,
              fromUser: fromUser,
              toUser: toUser,
              isIncoming: isIncoming,
              currentUserId: currentUserId,
            );
          },
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  final SwapRequest request;
  final User? fromUser;
  final User? toUser;
  final bool isIncoming;
  final String currentUserId;

  const _RequestCard({
    required this.request,
    required this.fromUser,
    required this.toUser,
    required this.isIncoming,
    required this.currentUserId,
  });

  Future<void> _respondToRequest(BuildContext context, String status) async {
    final swapRequestsProvider = Provider.of<SwapRequestsProvider>(context, listen: false);
    
    String? cancelReason;
    if (status == 'cancelled') {
      final TextEditingController reasonController = TextEditingController();
      await Dialogs.materialDialog(
        context: context,
        title: 'Cancel Reason',
        msg: 'Please provide a reason for cancellation:',
        customView: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for cancellation',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
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
            onPressed: () => Navigator.of(context).pop(reasonController.text),
            text: 'Submit',
            iconData: Icons.check,
            color: Colors.blue,
            textStyle: const TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
        ],
      );
      cancelReason = reasonController.text;
    }

    final success = await swapRequestsProvider.respondToSwapRequest(
      requestId: request.id.toString(),
      status: status,
      cancelReason: cancelReason,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Request ${status} successfully!' : 'Failed to ${status} request.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteRequest(BuildContext context) async {
    bool confirmed = false;
    await Dialogs.materialDialog(
      context: context,
      title: 'Delete Request',
      msg: 'Are you sure you want to delete this request?',
      actions: [
        IconsButton(
          onPressed: () {
            confirmed = false;
            Navigator.of(context).pop();
          },
          text: 'Cancel',
          iconData: Icons.cancel,
          color: Colors.grey,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
        IconsButton(
          onPressed: () {
            confirmed = true;
            Navigator.of(context).pop();
          },
          text: 'Delete',
          iconData: Icons.delete,
          color: Colors.red,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
    if (confirmed && context.mounted) {
      final swapRequestsProvider = Provider.of<SwapRequestsProvider>(context, listen: false);
      final success = await swapRequestsProvider.deleteSwapRequest(request.id.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Request deleted successfully!' : 'Failed to delete request.',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _giveFeedback(BuildContext context) async {
    final otherUser = isIncoming ? fromUser : toUser;
    if (otherUser != null) {
      await showDialog(
        context: context,
        builder: (context) => FeedbackDialog(
          swapRequest: request,
          otherUser: otherUser,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = isIncoming ? fromUser : toUser;
    final isCompleted = request.status == 'completed';
    final isAccepted = request.status == 'accepted';
    final isPending = request.status == 'pending';
    
    return GlassmorphicContainer(
      width: double.infinity,
      height: 200,
      borderRadius: 20,
      blur: 10,
      border: 2,
      linearGradient: LinearGradient(
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
                  radius: 24,
                  backgroundImage: user?.photoUrl.isNotEmpty == true ? NetworkImage(user!.photoUrl) : null,
                  child: user?.photoUrl.isEmpty == true || user == null
                      ? const Icon(Icons.person, size: 24)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Unknown User',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${request.statusText}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: request.statusColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Skills Information
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offering:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(request.offeredSkill),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wanting:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(request.wantedSkill),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            if (isIncoming && isPending) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _respondToRequest(context, 'accepted'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _respondToRequest(context, 'declined'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                ],
              ),
            ] else if (!isIncoming && isPending) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _respondToRequest(context, 'cancelled'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _deleteRequest(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ] else if (isAccepted) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _respondToRequest(context, 'completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Mark Complete'),
                    ),
                  ),
                ],
              ),
            ] else if (isCompleted) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _giveFeedback(context),
                      icon: const Icon(Icons.star),
                      label: const Text('Give Feedback'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FeedbackDialog extends StatefulWidget {
  final SwapRequest swapRequest;
  final User otherUser;

  const FeedbackDialog({
    super.key,
    required this.swapRequest,
    required this.otherUser,
  });

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  double _rating = 0.0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Optionally use Future.microtask here instead
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future.microtask(() => _showFeedbackDialog(context));
    return const SizedBox.shrink(); // Does not render visible UI
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser != null) {
      final success = await feedbackProvider.submitFeedback(
        userName: currentUser.name,
        rating: _rating,
        receiverId: widget.otherUser.id.toString(),
        comment: _commentController.text.isNotEmpty ? _commentController.text : null,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Feedback submitted successfully!' : 'Failed to submit feedback.',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showFeedbackDialog(BuildContext context) async {
    await Dialogs.materialDialog(
      context: context,
      title: 'Give Feedback to ${widget.otherUser.name}',
      customView: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('How would you rate this swap experience?'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    _rating = index + 1.0;
                  });
                },
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Comment (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
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
          onPressed: _submitFeedback,
          text: 'Submit',
          iconData: Icons.send,
          color: Colors.blue,
          textStyle: const TextStyle(color: Colors.white),
          iconColor: Colors.white,
        ),
      ],
    );
  }
}

