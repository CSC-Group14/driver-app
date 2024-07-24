// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logitrust_drivers/Model/driver_info_model.dart';

import '../utils/error_notification.dart';

final globalFirestoreRepoProvider = Provider<AddFirestoreData>((ref) {
  return AddFirestoreData();
});

class AddFirestoreData {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void addDriversDataToFirestore(BuildContext context, String truckName,
      String truckPlateNum, String truckType) async {
    try {
      await db
          .collection("Drivers")
          .doc(auth.currentUser!.email.toString())
          .set({
        "name": FirebaseAuth.instance.currentUser!.email!.split("@")[0],
        "email": FirebaseAuth.instance.currentUser!.email,
        "Truck Name": truckName,
        "Truck Plate Num": truckPlateNum,
        "Truck Type": truckType
      });
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }

  void getDriverDetails(BuildContext context) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> data = await db
          .collection("Drivers")
          .doc(auth.currentUser!.email.toString())
          .get();

      DriverInfoModel driver = DriverInfoModel(
          auth.currentUser!.uid,
          data.data()?["name"],
          data.data()?["email"],
          data.data()?["Truck Name"],
          data.data()?["Truck Plate Num"],
          data.data()?["Truck Type"]);

      print("data is ${driver.truckType}");
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }

  void setDriverStatus(BuildContext context, String status) async {
    try {
      await db
          .collection("Drivers")
          .doc(auth.currentUser!.email.toString())
          .update({"driverStatus": status});
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }

  void listenForRideRequests(Function(DocumentSnapshot) onNewRequest) {
    _firestore
        .collection('requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          onNewRequest(change.doc);
        }
      });
    });
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _firestore.collection('requests').doc(requestId).update({
      'status': status,
    });
  }

  void setDriverLocationStatus(BuildContext context, GeoPoint? loc) async {
    try {
      await db
          .collection("Drivers")
          .doc(auth.currentUser!.email.toString())
          .update({"driverLoc": loc});
    } catch (e) {
      if (context.mounted) {
        ErrorNotification().showError(context, "An Error Occurred $e");
      }
    }
  }
}
