import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'receipt_preview_screen.dart';
import '../services/notification_service.dart';

class AdminBookingDetailScreen extends StatelessWidget {
  final String bookingId;
  final Map<String, dynamic> bookingData;

  const AdminBookingDetailScreen({
    super.key,
    required this.bookingId,
    required this.bookingData,
  });

  // ================= UPDATE STATUS =================
  Future<void> updateStatus(
    BuildContext context,
    String status,
  ) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({'status': status});

    await NotificationService.sendToUser(
      userId: bookingData['userId'],
      bookingId: bookingId,
      title: 'Booking Update',
      message: 'Your booking has been $status',
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking $status'),
        backgroundColor: status == 'approved'
            ? Colors.green
            : status == 'rejected'
                ? Colors.red
                : Colors.orange,
      ),
    );
  }

  // ================= CONFIRM DIALOG =================
  void showConfirmDialog(
    BuildContext context,
    String label,
    String status,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text('Are you sure to $label this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await updateStatus(context, status);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  // ================= ACTION BUTTONS =================
  Widget buildActionButtons(BuildContext context) {
    final status = bookingData['status'] ?? 'pending';

    // 🔴 BARU BOOKING
    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () =>
                  showConfirmDialog(context, 'approve', 'approved'),
              child: const Text('APPROVE'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => showConfirmDialog(context, 'reject', 'rejected'),
              child: const Text('REJECT'),
            ),
          ),
        ],
      );
    }

    // 🟡 APPROVED → PROCESSING
    if (status == 'approved') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () =>
              showConfirmDialog(context, 'mark as processing', 'processing'),
          child: const Text('Mark as Processing'),
        ),
      );
    }

    // 🟢 PROCESSING → COMPLETED
    if (status == 'processing') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () =>
              showConfirmDialog(context, 'mark as completed', 'completed'),
          child: const Text('Mark as Completed'),
        ),
      );
    }

    // ✅ COMPLETED / REJECTED
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = bookingData['createdAt'] as Timestamp?;
    final dateText = createdAt != null
        ? DateFormat('dd MMM yyyy').format(createdAt.toDate())
        : '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Package: ${bookingData['packageType']}'),
            const SizedBox(height: 8),
            Text('Name: ${bookingData['name']}'),
            const SizedBox(height: 8),
            Text('Phone: ${bookingData['phone']}'),
            const SizedBox(height: 8),
            Text('Created: $dateText'),
            const SizedBox(height: 8),
            Text(
              'Optional Request:\n${bookingData['optionalRequest'] ?? '-'}',
            ),
            const SizedBox(height: 24),
            if (bookingData['hasReview'] == true)
              const Text(
                'Review submitted',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),

            // 📄 RECEIPT
            if (bookingData['receiptUrl'] != null)
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('View Payment Receipt'),
                subtitle: const Text('Tap to preview receipt'),
                onTap: () {
                  final url = bookingData['receiptUrl'];

                  if (url == null || url.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Receipt not available')),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReceiptPreviewScreen(url: url),
                    ),
                  );
                },
              ),

            const Spacer(),

            // 🔘 BUTTON IKUT STATUS
            buildActionButtons(context),
          ],
        ),
      ),
    );
  }
}
