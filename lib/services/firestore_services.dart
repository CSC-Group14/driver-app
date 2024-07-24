import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<DocumentSnapshot<Map<String, dynamic>>>>
    getPendingRequests() async {
  try {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('rideRequests')
        .where('status', isEqualTo: 'pending')
        .get();

    return snapshot.docs;
  } catch (e) {
    print('Error fetching pending requests: $e');
    throw e; // Rethrow the error to handle it in the UI or debug console
  }
}
