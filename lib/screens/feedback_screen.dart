import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feedback_provider.dart';
import '../providers/users_provider.dart';
import '../models/feedback_model.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import '../theme.dart';
import 'package:glassmorphism/glassmorphism.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer2<FeedbackProvider, UsersProvider>(
        builder: (context, feedbackProvider, usersProvider, child) {
          if (feedbackProvider.isLoading || usersProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final feedbacks = feedbackProvider.feedbacks;
          if (feedbacks.isEmpty) {
            return const Center(
              child: Text('No feedback yet.'),
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    final feedback = feedbacks[index];
                    final fromUser = usersProvider.getUserById(feedback.fromUserId);
                    final toUser = usersProvider.getUserById(feedback.toUserId);
                    return GlassmorphicContainer(
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
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundImage: fromUser?.photoUrl.isNotEmpty == true ? NetworkImage(fromUser!.photoUrl) : null,
                                  child: fromUser?.photoUrl.isEmpty == true || fromUser == null
                                      ? const Icon(Icons.person, size: 22)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fromUser?.name ?? 'Unknown',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      Text(
                                        'to ${toUser?.name ?? 'Unknown'}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              feedback.comment ?? '',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 