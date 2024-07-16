import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({super.key});

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? user;
  late DocumentReference driverDocRef;
  Map<String, dynamic>? driverData;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (user != null) {
      driverDocRef = FirebaseFirestore.instance.collection('drivers').doc(user!.uid);
      fetchDriverData();
    } else {
      setState(() {
        errorMessage = 'User not logged in';
      });
    }
  }

  Future<void> fetchDriverData() async {
    try {
      DocumentSnapshot docSnapshot = await driverDocRef.get();
      if (docSnapshot.exists) {
        setState(() {
          driverData = docSnapshot.data() as Map<String, dynamic>?;
          print('Driver data fetched: $driverData');
        });
      } else {
        setState(() {
          errorMessage = 'Document does not exist';
        });
      }
    } catch (e) {
      print('Error fetching driver data: $e');
      setState(() {
        errorMessage = 'Error fetching data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Profile'),
      ),
      body: driverData == null
          ? errorMessage.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Center(child: Text(errorMessage))
          : Padding(
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
                  Text(
                    driverData!['name'] ?? 'Name not available',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    driverData!['email'] ?? 'Email not available',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.badge,
                      color: Colors.black,
                    ),
                    title: const Text(
                      'License Number',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      driverData!['Truck_number'] ?? 'Not available',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Colors.black,
                    ),
                    title: const Text(
                      'License Expiry Date',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      driverData!['Truck_color'] ?? 'Not available',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.directions_car,
                      color: Colors.black,
                    ),
                    title: const Text(
                      'Vehicle Make and Model',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      driverData!['Truck_model'] ?? 'Not available',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.confirmation_number,
                      color: Colors.black,
                    ),
                    title: const Text(
                      'License Plate Number',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      driverData!['Truck_type'] ?? 'Not available',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.star,
                      color: Colors.black,
                    ),
                    title: const Text(
                      'Rating',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      driverData!['rating']?.toString() ?? 'Not available',
                      style: const TextStyle(color: Colors.black),
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
                      // Implement logout functionality
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfileTabPage(),
    );
  }
}