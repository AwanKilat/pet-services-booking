import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../payment/booking_payment_screen.dart';
import '../services/notification_service.dart';

class PackageCScreen extends StatefulWidget {
  const PackageCScreen({super.key});

  @override
  State<PackageCScreen> createState() => _PackageCScreenState();
}

class _PackageCScreenState extends State<PackageCScreen> {
  // ================= CONTROLLERS =================
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final optionalCtrl = TextEditingController();

  DateTime? checkInDate;
  DateTime? checkOutDate;

  final dateFormat = DateFormat('dd MMM yyyy');

  // ================= DATE PICKER =================
  Future<void> pickCheckIn() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        checkInDate = picked;
        checkOutDate = null;
      });
    }
  }

  Future<void> pickCheckOut() async {
    if (checkInDate == null) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: checkInDate!.add(const Duration(days: 1)),
      firstDate: checkInDate!.add(const Duration(days: 1)),
      lastDate: checkInDate!.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => checkOutDate = picked);
    }
  }

  // ================= NEXT =================
  void goNext() {
    if (nameCtrl.text.isEmpty ||
        phoneCtrl.text.isEmpty ||
        checkInDate == null ||
        checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    NotificationService.show(
      context,
      "Booking submitted successfully",
      color: Colors.green,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingPaymentScreen(
          bookingData: {
            'packageType': 'C',
            'name': nameCtrl.text,
            'phone': phoneCtrl.text,
            'checkInDate': checkInDate,
            'checkOutDate': checkOutDate,
            'optionalRequest': optionalCtrl.text,
          },
        ),
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Package C')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Details',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // NAME
            TextField(
              controller: nameCtrl,
              decoration: inputStyle('Enter your name'),
            ),
            const SizedBox(height: 12),

            // PHONE
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: inputStyle('e.g. 0123456789'),
            ),

            const SizedBox(height: 24),
            const Text('Package C Includes',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            includeTile('Room Hotel'),
            includeTile('Food & Drink'),

            const SizedBox(height: 24),
            const Text('Check-in & Check-out',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // CHECK-IN
            ListTile(
              leading: const Icon(Icons.calendar_today),
              tileColor: const Color(0xFFF5F5F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              title: Text(
                checkInDate == null
                    ? 'Select Check-in Date'
                    : 'Check-in: ${dateFormat.format(checkInDate!)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: pickCheckIn,
            ),
            const SizedBox(height: 8),

            // CHECK-OUT
            ListTile(
              leading: const Icon(Icons.calendar_today),
              tileColor: const Color(0xFFF5F5F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              title: Text(
                checkOutDate == null
                    ? 'Select Check-out Date'
                    : 'Check-out: ${dateFormat.format(checkOutDate!)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: pickCheckOut,
            ),

            const SizedBox(height: 24),
            const Text('Optional Request'),
            const SizedBox(height: 12),

            TextField(
              controller: optionalCtrl,
              maxLines: 3,
              decoration: inputStyle('Leave empty if none'),
            ),

            const SizedBox(height: 28),

            // NEXT BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: goNext,
                child: const Text(
                  'Next',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= REUSABLE =================
  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget includeTile(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
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
}
