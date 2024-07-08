// driver_profile_page.dart
import 'package:flutter/material.dart';

class DriverProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/avatar.png'),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Kabogere Salimu',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'salimuloma@gmail.com',
              style: TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.badge,
                color: Colors.white60,
              ),
              title: Text(
                'License Number',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'U2000340',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.calendar_today,
                color: Colors.white60,
              ),
              title: Text(
                'License Expiry Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '01/01/2025',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.directions_car,
                color: Colors.white60,
              ),
              title: Text(
                'Vehicle Make and Model',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Toyota Camry 2020',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.confirmation_number,
                color: Colors.white60,
              ),
              title: Text(
                'License Plate Number',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'UBG 230U',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.star,
                color: Colors.white60,
              ),
              title: Text(
                'Rating',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '4.8',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.history,
                color: Colors.white60,
              ),
              title: Text(
                'Trip History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'View recent trips',
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                // Navigate to trip history page
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.edit,
                color: Colors.white60,
              ),
              title: Text(
                'Edit Profile',
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                // Navigate to edit profile page
              },
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: Colors.white60,
              ),
              title: Text(
                'Settings',
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                // Navigate to settings page
              },
            ),
            ListTile(
              leading: Icon(
                Icons.help,
                color: Colors.white60,
              ),
              title: Text(
                'Support',
                style: TextStyle(color: Colors.white70),
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
