import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logitrust_drivers/services/firestore_services.dart';
// Import your Firestore service

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Future<List<DocumentSnapshot<Map<String, dynamic>>>>? _pendingRequests;

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
  }

  Future<void> _fetchPendingRequests() async {
    try {
      _pendingRequests = getPendingRequests();
    } catch (e) {
      print('Error fetching pending requests: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Requests'),
      ),
      body: FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
        future: _pendingRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pending requests found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var request = snapshot.data![index].data();
                return ListTile(
                  title: Text('Request ID: ${snapshot.data![index].id}'),
                  subtitle: Text('User: ${request?['userName']}'),
                  trailing: Text('Destination: ${request?['destination']}'),
                  // Add more fields as needed
                );
              },
            );
          }
        },
      ),
    );
  }
}
