import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'admin_export_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No booking data available'));
          }

          final docs = snapshot.data!.docs;

          int total = docs.length;
          int pending = 0;
          int approved = 0;
          int rejected = 0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            switch (data['status']) {
              case 'approved':
                approved++;
                break;
              case 'rejected':
                rejected++;
                break;
              default:
                pending++;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== STAT CARDS =====
                Row(
                  children: [
                    statCard('Total', total, Colors.blue),
                    statCard('Pending', pending, Colors.orange),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    statCard('Approved', approved, Colors.green),
                    statCard('Rejected', rejected, Colors.red),
                  ],
                ),

                const SizedBox(height: 20),

                // ===== PRINT PDF BUTTON =====
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.print),
                    label: const Text('Print Booking Report (PDF)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () async {
                      await AdminExportService.printBookingsPDF();
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // ===== BAR CHART =====
                const Text(
                  'Booking Status Analytics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height: 260,
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Text('Pending');
                                case 1:
                                  return const Text('Approved');
                                case 2:
                                  return const Text('Rejected');
                                default:
                                  return const SizedBox();
                              }
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        bar(0, pending.toDouble(), Colors.orange),
                        bar(1, approved.toDouble(), Colors.green),
                        bar(2, rejected.toDouble(), Colors.red),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ===== RECENT BOOKINGS =====
                const Text(
                  'Recent Bookings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length > 5 ? 5 : docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        title: Text(
                          'Package ${data['packageType']} - ${data['name']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          DateFormat('dd MMM yyyy')
                              .format(data['createdAt'].toDate()),
                        ),
                        trailing: statusChip(data['status']),
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

  // ===== BAR =====
  BarChartGroupData bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 30,
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  // ===== STAT CARD =====
  Widget statCard(String title, int value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== STATUS CHIP =====
  Widget statusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'approved':
        color = Colors.green;
        label = 'Approved';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        break;
      default:
        color = Colors.orange;
        label = 'Pending';
    }

    return Chip(
      label: Text(label),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
      backgroundColor: color.withOpacity(0.15),
    );
  }
}
