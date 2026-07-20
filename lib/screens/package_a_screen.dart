import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../payment/booking_payment_screen.dart';
import '../services/notification_service.dart';

class PackageAScreen extends StatefulWidget {
  const PackageAScreen({super.key});

  @override
  State<PackageAScreen> createState() => _PackageAScreenState();
}

class _PackageAScreenState extends State<PackageAScreen> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final optionalCtrl = TextEditingController();

  DateTime? checkInDate;
  DateTime? checkOutDate;

  // ================= SAVE BOOKING =================
  Future<String> _saveBooking() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final docRef = await FirebaseFirestore.instance.collection('bookings').add({
      'userId': user.uid,
      'packageType': 'A',
      'name': nameCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
      'checkInDate': Timestamp.fromDate(checkInDate!),
      'checkOutDate': Timestamp.fromDate(checkOutDate!),
      'optionalRequest': optionalCtrl.text.trim(),
      'status': 'pending',
      'hasReview': false,
      'createdAt': Timestamp.now(),
    });

    return docRef.id; // 🔥 bookingId
  }

  // ================= SUBMIT =================
  Future<void> _submitBooking() async {
    final name = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();

    if (name.isEmpty) {
      _showError('Please enter your name');
      return;
    }

    if (phone.isEmpty) {
      _showError('Please enter phone number');
      return;
    }

    if (checkInDate == null) {
      _showError('Please select check-in date');
      return;
    }

    if (checkOutDate == null) {
      _showError('Please select check-out date');
      return;
    }

    try {
      // 🔥 SIMPAN BOOKING DULU
      final bookingId = await _saveBooking();

      final bookingData = {
        'bookingId': bookingId,
        'packageType': 'A',
        'name': nameCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'checkInDate': checkInDate,
        'checkOutDate': checkOutDate,
        'optionalRequest': optionalCtrl.text.trim(),
        'status': 'pending',
      };

      // 🔥 BARU KE PAYMENT SCREEN
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingPaymentScreen(
            bookingData: bookingData,
          ),
        ),
      );
    } catch (e) {
      _showError('Failed to submit booking');
    }
  }

  // ================= DATE PICKER =================
  Future<void> _pickDate({required bool isCheckIn}) async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = picked;
        } else {
          checkOutDate = picked;
        }
      });
    }
  }

  void _showError(String msg) {
    NotificationService.show(
      context,
      msg,
      color: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> packageAIncludes = [
      'Room Hotel',
      'Food & Drink',
      'Baths',
      'Nail Trimming',
      'Ear Cleaning',
      'Extra Brushing',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Package A'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= YOUR DETAILS =================
            const Text(
              'Your Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _roundedField(
              controller: nameCtrl,
              hint: 'Enter your name',
              icon: Icons.person,
            ),
            const SizedBox(height: 12),
            _roundedField(
              controller: phoneCtrl,
              hint: 'e.g. 0123456789',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 24),

            // ================= INCLUDES =================
            const Text(
              'Package A Includes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...packageAIncludes.map(
              (item) => _includeItem(item),
            ),

            const SizedBox(height: 24),

            // ================= CHECK-IN / CHECK-OUT =================
            const Text(
              'Check-in & Check-out',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _dateTile(
              label: 'Select Check-in Date',
              date: checkInDate,
              onTap: () => _pickDate(isCheckIn: true),
            ),
            const SizedBox(height: 12),
            _dateTile(
              label: 'Select Check-out Date',
              date: checkOutDate,
              onTap: () => _pickDate(isCheckIn: false),
            ),

            const SizedBox(height: 24),

            // ================= OPTIONAL =================
            const Text(
              'Optional Request',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _roundedField(
              controller: optionalCtrl,
              hint: 'Leave empty if none',
              icon: Icons.note,
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            // ================= BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submitBooking,
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================
  Widget _roundedField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _includeItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  Widget _dateTile({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 12),
            Text(
              date == null ? label : '${date.day}/${date.month}/${date.year}',
            ),
          ],
        ),
      ),
    );
  }
}
