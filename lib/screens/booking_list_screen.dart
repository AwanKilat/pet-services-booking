import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'booking_detail_screen.dart';

class BookingListScreen extends StatelessWidget {
  const BookingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // 🔴 SAFETY CHECK
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    final uid = user.uid;
    debugPrint('🔥 CURRENT LOGIN UID: $uid');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        centerTitle: true,
      ),

      // 🔥 DEBUG VERSION: TAK GUNA orderBy DULU
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          debugPrint('📦 SNAPSHOT STATE: ${snapshot.connectionState}');
          debugPrint('📦 HAS DATA: ${snapshot.hasData}');
          debugPrint('📦 DOC COUNT: ${snapshot.data?.docs.length ?? 0}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No bookings yet',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final doc = bookings[index];
              final data = doc.data() as Map<String, dynamic>;

              debugPrint('🧾 BOOKING DOC ID: ${doc.id}');
              debugPrint('🧾 BOOKING USER ID: ${data['userId']}');

              final status =
                  (data['status'] ?? 'pending').toString().toLowerCase();

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColor(status).withOpacity(0.2),
                    child: Icon(
                      Icons.pets,
                      color: statusColor(status),
                    ),
                  ),
                  title: Text(
                    'Package ${data['packageType'] ?? '-'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    data['createdAt'] != null
                        ? DateFormat('dd MMM yyyy')
                            .format(data['createdAt'].toDate())
                        : '-',
                  ),
                  trailing: statusChip(status),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingDetailScreen(
                          bookingId: doc.id,
                          bookingData: data,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ================= STATUS UI =================

  Widget statusChip(String status) {
    return Chip(
      label: Text(
        statusLabel(status),
        style: TextStyle(
          color: statusColor(status),
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: statusColor(status).withOpacity(0.15),
    );
  }

  Color statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default: // pending
        return Colors.orange;
    }
  }

  String statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }
}
