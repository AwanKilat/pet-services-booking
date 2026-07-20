import 'package:flutter/material.dart';
import 'package:pet_care_booking/screens/package_a_screen.dart';
import 'package:pet_care_booking/screens/package_b_screen.dart';
import 'package:pet_care_booking/screens/package_c_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget packageCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 38, color: Colors.white),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyPetCare'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            packageCard(
              icon: Icons.local_offer,
              title: 'Package A',
              subtitle: 'Hotel + Grooming',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PackageAScreen(),
                  ),
                );
              },
            ),
            packageCard(
              icon: Icons.cut,
              title: 'Package B',
              subtitle: 'Grooming',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PackageBScreen(),
                  ),
                );
              },
            ),
            packageCard(
              icon: Icons.bed,
              title: 'Package C',
              subtitle: 'Hotel',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PackageCScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
