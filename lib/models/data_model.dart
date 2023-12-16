import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:logger/logger.dart';

class LeaveModel {
  final logger = Logger();

  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  Future<void> createLeave(
    String companyId,
    Map<String, dynamic> leaveInfo
  ) async {
    try {
  logger.i("usercollection $usersCollection");
      // companyId = 'PF0014';
      DocumentReference userDocRef = usersCollection.doc(companyId);
      
      // Reference to the leaveHistory subcollection
      CollectionReference leaveHistoryCollection = userDocRef.collection('leaveHistory');

      logger.i("leaveHistory $leaveHistoryCollection ");
      // Add a new document to the salaryHistory subcollection
      await leaveHistoryCollection.add(leaveInfo);
      logger.i('successful run');
    } catch (e) {
      // Handle errors as needed
      logger.i('Error creating user: $e');
      rethrow; // Rethrow the exception for the calling code to handle
    }
  }
}


  // final Float? No;
  // final Timestamp start_date;
  // final Timestamp end_date;
  // final String reason;
  // final String remark;

  // const LeaveModel(this.remark, {
  //   required this.start_date,
  //   required this.end_date,
  //   required this.reason,
  //   }
  // );

  // toJson() {
  //   return {
  //     "start_Date": start_date,
  //     "end_Date": start_date,
  //     "Reason": reason,
  //     "Remark": remark,
  //   };
  // }
