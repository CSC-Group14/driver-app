import 'package:flutter/material.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({super.key});

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('images/avatar.png'),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kabogere Salimu',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'salimuloma@gmail.com',
              style: TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const ListTile(
              leading: Icon(
                Icons.badge,
                color: Colors.black,
              ),
              title: Text(
                'License Number',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'U2000340',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const ListTile(
              leading: Icon(
                Icons.calendar_today,
                color: Colors.black,
              ),
              title: Text(
                'License Expiry Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '01/01/2025',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const ListTile(
              leading: Icon(
                Icons.directions_car,
                color: Colors.black,
              ),
              title: Text(
                'Vehicle Make and Model',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Toyota Camry 2020',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const ListTile(
              leading: Icon(
                Icons.confirmation_number,
                color: Colors.black,
              ),
              title: Text(
                'License Plate Number',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'UBG 230U',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const ListTile(
              leading: Icon(
                Icons.star,
                color: Colors.black,
              ),
              title: Text(
                'Rating',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '4.8',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.history,
                color: Colors.black,
              ),
              title: const Text(
                'Trip History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'View recent trips',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                // Navigate to trip history page
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.edit,
                color: Colors.black,
              ),
              title: const Text(
                'Edit Profile',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                // Navigate to edit profile page
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.settings,
                color: Colors.black,
              ),
              title: const Text(
                'Settings',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                // Navigate to settings page
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.help,
                color: Colors.black,
              ),
              title: const Text(
                'Support',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                // Navigate to support page
              },
            ),

             ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.black,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                // Navigate to support page
              },
            ),
          ],
        ),
      ),
    );
  }
}