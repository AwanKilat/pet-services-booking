import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'admin_booking_detail_screen.dart';

class AdminBookingListScreen extends StatefulWidget {
  const AdminBookingListScreen({super.key});

  @override
  State<AdminBookingListScreen> createState() => _AdminBookingListScreenState();
}

class _AdminBookingListScreenState extends State<AdminBookingListScreen> {
  String selectedFilter = 'All';
  final searchController = TextEditingController();

  // ================= STATUS BADGE =================
  Widget buildStatusBadge(String status) {
    late String text;
    late Color color;

    switch (status) {
      case 'pending':
        text = 'Pending';
        color = Colors.orange;
        break;
      case 'approved':
        text = 'Approved';
        color = Colors.blue;
        break;
      case 'processing':
        text = 'Processing';
        color = Colors.purple;
        break;
      case 'completed':
        text = 'Completed';
        color = Colors.green;
        break;
      case 'rejected':
        text = 'Rejected';
        color = Colors.red;
        break;
      default:
        text = 'Pending';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= FILTER =================
  bool matchesFilter(String status) {
    if (selectedFilter == 'All') return true;
    return status == selectedFilter.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 🔍 SEARCH (OPTIONAL)
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or package',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // 🏷 FILTER BUTTONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              children: [
                'All',
                'Pending',
                'Approved',
                'Processing',
                'Completed',
                'Rejected',
              ].map((label) {
                final isSelected = selectedFilter == label;
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      selectedFilter = label;
                    });
                  },
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // 📋 BOOKING LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No bookings found'),
                  );
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>? ?? {};
                  final status = data['status'] ?? 'pending';
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final packageType =
                      (data['packageType'] ?? '').toString().toLowerCase();
                  final search = searchController.text.toLowerCase();

                  final matchSearch =
                      name.contains(search) || packageType.contains(search);

                  return matchesFilter(status) && matchSearch;
                }).toList();

                if (docs.isEmpty) {
                  return const Center(
                    child: Text('No matching bookings'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final createdAt = data['createdAt'] as Timestamp?;
                    final dateText = createdAt != null
                        ? DateFormat('dd MMM yyyy').format(createdAt.toDate())
                        : '-';

                    final status = data['status'] ?? 'pending';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        title: Text(
                          'Package ${data['packageType']} - ${data['name']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(dateText),
                        trailing: buildStatusBadge(status),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminBookingDetailScreen(
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
          ),
        ],
      ),
    );
  }
}
