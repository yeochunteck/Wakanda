import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'dart:io';

class LeaveModel {
  final logger = Logger();

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  Future<void> createLeave(
      String companyId, Map<String, dynamic> leaveInfo) async {
    try {
      logger.i("usercollection $usersCollection");
      // companyId = 'PF0014';
      DocumentReference userDocRef = usersCollection.doc(companyId);

      // Reference to the leaveHistory subcollection
      CollectionReference leaveHistoryCollection =
          userDocRef.collection('leaveHistory');

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

  Future<Map<String, dynamic>> getUserData(String companyId) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('companyId', isEqualTo: companyId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs[0].data() as Map<String, dynamic>;

        return userData;
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }

  //Pending Leave Query for specific user
  // Future<List<Map<String, dynamic>>> getLeaveDataForUser(String companyId) async {
  //   try {
  //     final QuerySnapshot usersSnapshot =
  //         await FirebaseFirestore.instance.collection('users').get();

  //     final List<Map<String, dynamic>> usersWithPendingLeave = [];

  //     print("trying query");
  //     final QuerySnapshot leaveHistorySnapshot = await FirebaseFirestore
  //         .instance
  //         .collection('users')
  //         .doc(companyId)
  //         .collection('leaveHistory')
  //         .where('status', isEqualTo: 'pending')
  //         .where('companyId', isEqualTo: companyId)
  //         .get();

  //     final List<Map<String, dynamic>> leaveDataForUser = leaveHistorySnapshot.docs.map((leaveDoc) {
  //       final Map<String, dynamic> leaveData = leaveDoc.data() as Map<String, dynamic>;

  //       final Timestamp timestamp = leaveData['startDate'];
  //       final DateTime startDate = timestamp.toDate();
  //       final Timestamp? timestamp1 = leaveData.containsKey('endDate') ? leaveData['endDate'] : null;
  //       final DateTime? endDate = timestamp1?.toDate();
  //       final String leaveType = leaveData['leaveType'] ?? '';
  //       final double leaveDay = leaveData['leaveDay'] ?? '';
  //       final String reason = leaveData['reason'] ?? '';
  //       final String remark = leaveData['remark'] ?? '';
  //       final String fullORHalf = leaveData['fullORHalf'] ?? '';

  //       leaveData['startDate'] = startDate;
  //       leaveData['endDate'] = endDate;
  //       leaveData['leaveType'] = leaveType;
  //       leaveData['leaveDay'] = leaveDay;
  //       leaveData['reason'] = reason;
  //       leaveData['remark'] = remark;
  //       leaveData['fullORHalf'] = fullORHalf;

  //       return leaveData;
  //     }).toList();

  //     return leaveDataForUser;
  //   } catch (e) {
  //     logger.e('Error fetching leave data for user: $e');
  //     return [];
  //   }
  // }

  //Pending Leave Query for specific user2
   Future<List<Map<String, dynamic>>> getLeaveDataForUser(String paraCompanyId) async {
    try {
      final QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance
          .collection('users')
          .where('companyId', isEqualTo: paraCompanyId)
          .limit(1)
          .get();

      final List<Map<String, dynamic>> usersWithPendingLeave = [];

      for (final userDoc in usersSnapshot.docs) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final String companyId = userData['companyId'];

        print("trying query with companyId: $companyId, paraCompanyId: $paraCompanyId");
        // Fetch the 'leaveHistory' subcollection for each user with 'pending' status
        final QuerySnapshot leaveHistorySnapshot = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(companyId)
            .collection('leaveHistory')
            //.where('status', isEqualTo: 'pending')
            .get();

        final List<Map<String, dynamic>> pendingLeaveRecords =
            leaveHistorySnapshot.docs.map((leaveDoc) {
          final Map<String, dynamic> leaveData =
              leaveDoc.data() as Map<String, dynamic>;

          final Timestamp timestamp = leaveData['startDate'];
          final DateTime startDate = timestamp.toDate();
          final Timestamp? timestamp1 = leaveData.containsKey('endDate') ? leaveData['endDate'] : null;
          final DateTime? endDate = timestamp1?.toDate();
          final String leaveType = leaveData['leaveType'] ?? '';
          final double leaveDay = leaveData['leaveDay'] ?? '';
          final String reason = leaveData['reason'] ?? '';
          final String remark = leaveData['remark'] ?? '';
          final String fullORHalf = leaveData['fullORHalf'] ?? '';

          leaveData['startDate'] = startDate;
          leaveData['endDate'] = endDate;
          leaveData['leaveType'] = leaveType;
          leaveData['leaveDay'] = leaveDay;
          leaveData['reason'] = reason;
          leaveData['remark'] = remark;
          leaveData['fullORHalf'] = fullORHalf;

          // Preserve user data in the leave record
          leaveData['userData'] = userData;

          return leaveData;
        }).toList();

        usersWithPendingLeave.addAll(pendingLeaveRecords);
      }

      return usersWithPendingLeave;
    } catch (e) {
      logger.e('Error fetching users with pending leave: $e');
      return [];
    }
  }

  //Pending Leave Query
  Future<List<Map<String, dynamic>>> getUsersWithPendingLeave() async {
    try {
      final QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      final List<Map<String, dynamic>> usersWithPendingLeave = [];

      for (final userDoc in usersSnapshot.docs) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final String companyId = userData['companyId'];

        // Fetch the 'leaveHistory' subcollection for each user with 'pending' status
        final QuerySnapshot leaveHistorySnapshot = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(companyId)
            .collection('leaveHistory')
            .where('status', isEqualTo: 'pending')
            .get();

        final List<Map<String, dynamic>> pendingLeaveRecords =
            leaveHistorySnapshot.docs.map((leaveDoc) {
          final Map<String, dynamic> leaveData =
              leaveDoc.data() as Map<String, dynamic>;

          final Timestamp timestamp = leaveData['startDate'];
          final DateTime startDate = timestamp.toDate();
          final Timestamp? timestamp1 = leaveData.containsKey('endDate') ? leaveData['endDate'] : null;
          final DateTime? endDate = timestamp1?.toDate();
          final String leaveType = leaveData['leaveType'] ?? '';
          final double leaveDay = leaveData['leaveDay'] ?? '';
          final String reason = leaveData['reason'] ?? '';
          final String remark = leaveData['reamrk'] ?? '';
          final String fullORHalf = leaveData['fullORHalf'] ?? '';

          leaveData['startDate'] = startDate;
          leaveData['endDate'] = endDate;
          leaveData['leaveType'] = leaveType;
          leaveData['leaveDay'] = leaveDay;
          leaveData['reason'] = reason;
          leaveData['remark'] = remark;
          leaveData['fullORHalf'] = fullORHalf;

          // Preserve user data in the leave record
          leaveData['userData'] = userData;

          return leaveData;
        }).toList();

        usersWithPendingLeave.addAll(pendingLeaveRecords);
      }

      return usersWithPendingLeave;
    } catch (e) {
      logger.e('Error fetching users with pending leave: $e');
      return [];
    }
  }

  //Approved Leave Query
  Future<List<Map<String, dynamic>>> getUsersWithApprovedLeave() async {
    try {
      final QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      final List<Map<String, dynamic>> usersWithPendingLeave = [];

      for (final userDoc in usersSnapshot.docs) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final String companyId = userData['companyId'];

        // Fetch the 'history' subcollection for each user
        final QuerySnapshot leaveHistorySnapshot = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(companyId)
            .collection('history')
            .where('status',
                isEqualTo: 'approved') // Filter by 'pending' status
            .get();

        if (leaveHistorySnapshot.docs.isNotEmpty) {
          // Retrieve the data from the first document (most recent startDate)
          final Map<String, dynamic> latestLeaveHistory =
              leaveHistorySnapshot.docs[0].data() as Map<String, dynamic>;

          final DateTime startDate = latestLeaveHistory['startDate'];
          final DateTime endDate = latestLeaveHistory['endDate'];
          final String leaveType = latestLeaveHistory['leaveType'] ?? '';

          userData['startDate'] = startDate;
          userData['endDate'] = endDate;
          userData['leaveType'] = leaveType;

          usersWithPendingLeave.add(userData);
        }
      }

      return usersWithPendingLeave;
    } catch (e) {
      logger.e('Error fetching users with pending leave: $e');
      return [];
    }
  }
}