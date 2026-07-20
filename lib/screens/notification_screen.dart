import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    final userId = user.uid;

    // 🔥 DEBUG – boleh buang lepas confirm
    print('🔥 NotificationScreen UID: $userId');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // 🔴 ERROR HANDLING (WAJIB)
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // ⏳ LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 📭 EMPTY STATE
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>? ?? {};

              final title = data['title'] ?? 'Notification';
              final message = data['message'] ?? '';
              final isRead = data['read'] == true;
              final createdAt = data['createdAt'] as Timestamp?;

              final dateText = createdAt != null
                  ? DateFormat('dd MMM yyyy, hh:mm a')
                      .format(createdAt.toDate())
                  : '';

              return ListTile(
                leading: Icon(
                  Icons.notifications,
                  color: isRead ? Colors.grey : Colors.orange,
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message),
                    const SizedBox(height: 4),
                    Text(
                      dateText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                trailing: isRead
                    ? null
                    : const Icon(
                        Icons.circle,
                        color: Colors.red,
                        size: 10,
                      ),
                onTap: () async {
                  // ✅ Mark as read bila ditekan
                  await FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(docs[index].id)
                      .update({'read': true});
                },
              );
            },
          );
        },
      ),
    );
  }
}
