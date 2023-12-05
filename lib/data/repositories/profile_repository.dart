import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfileRepository {
  final logger = Logger();

  Future<Map<String, dynamic>> getUserData(String companyId) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('companyId', isEqualTo: companyId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs[0].data() as Map<String, dynamic>;

        // Fetch the 'bankHistory' subcollection
        final QuerySnapshot bankHistorySnapshot = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(companyId)
            .collection('bankHistory')
            .orderBy('effectiveDate', descending: true)
            .get();

        // Check if there are documents in the 'bankHistory' subcollection
        if (bankHistorySnapshot.docs.isNotEmpty) {
          // Retrieve the data from the first document (most recent effectiveDate)
          final Map<String, dynamic> latestBankHistory =
              bankHistorySnapshot.docs[0].data() as Map<String, dynamic>;

          final String bankName = latestBankHistory['bankName'] ?? '';
          final String accountNumber = latestBankHistory['accountNumber'] ?? '';

          userData['bankName'] = bankName;
          userData['accountNumber'] = accountNumber;
        }

        // Fetch the 'bankHistory' subcollection
        final QuerySnapshot salaryHistorySnapshot = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(companyId)
            .collection('salaryHistory')
            .orderBy('effectiveDate', descending: true)
            .get();

        // Check if there are documents in the 'bankHistory' subcollection
        if (salaryHistorySnapshot.docs.isNotEmpty) {
          // Retrieve the data from the first document (most recent effectiveDate)
          final Map<String, dynamic> latestsalaryHistory =
              salaryHistorySnapshot.docs[0].data() as Map<String, dynamic>;

          final num basicSalary = latestsalaryHistory['basicSalary'] ?? '';
          final String epfNo = latestsalaryHistory['epfNo'] ?? '';
          final String socsoNo = latestsalaryHistory['socsoNo'] ?? '';

          userData['basicSalary'] = basicSalary;
          userData['epfNo'] = epfNo;
          userData['socsoNo'] = socsoNo;
        }

        return userData;
      } else {
        logger.w('User not found for companyId: $companyId');
        return {};
      }
    } catch (e) {
      logger.e('Error fetching user data: $e');
      return {};
    }
  }

  // Future<Map<String, dynamic>> getUserData(String companyId) async {
  //   try {
  //     final DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(companyId)
  //         .get();

  //     if (userDoc.exists) {
  //       final userData = userDoc.data() as Map<String, dynamic>;

  //       // Fetch data from 'saleHistory' subcollection
  //       final QuerySnapshot saleHistorySnapshot =
  //           await userDoc.reference.collection('saleHistory').get();
  //       final List<Map<String, dynamic>> saleHistoryData = saleHistorySnapshot
  //           .docs
  //           .map<Map<String, dynamic>>(
  //               (doc) => doc.data() as Map<String, dynamic>)
  //           .toList();

  //       // Fetch data from 'bankHistory' subcollection
  //       final QuerySnapshot bankHistorySnapshot =
  //           await userDoc.reference.collection('bankHistory').get();
  //       final List<Map<String, dynamic>> bankHistoryData = bankHistorySnapshot
  //           .docs
  //           .map<Map<String, dynamic>>(
  //               (doc) => doc.data() as Map<String, dynamic>)
  //           .toList();

  //       // Add saleHistoryData and bankHistoryData to userData
  //       userData['saleHistory'] = saleHistoryData;
  //       userData['bankHistory'] = bankHistoryData;

  //       return userData;
  //     } else {
  //       logger.w('User not found for companyId: $companyId');
  //       return {};
  //     }
  //   } catch (e) {
  //     logger.e('Error fetching user data: $e');
  //     return {};
  //   }
  // }

  Future<List<Map<String, dynamic>>> getAllUserData() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      if (querySnapshot.docs.isNotEmpty) {
        final List<Map<String, dynamic>> userDataList = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        return userDataList;
      } else {
        logger.w('No users found');
        return [];
      }
    } catch (e) {
      logger.e('Error fetching user data: $e');
      return [];
    }
  }

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Future<void> createUser(Map<String, dynamic> userData) async {
  //   try {
  //     await usersCollection.add(userData);
  //   } catch (e) {
  //     // Handle errors as needed
  //     logger.w('Error creating user: $e');
  //     rethrow; // Rethrow the exception for the calling code to handle
  //   }
  // }

  // Future<void> createUser(
  //     String companyId, Map<String, dynamic> userData) async {
  //   try {
  //     // Use employeeId as the document ID
  //     await usersCollection.doc(companyId).set(userData);

  //   } catch (e) {
  //     // Handle errors as needed
  //     logger.w('Error creating user: $e');
  //     rethrow; // Rethrow the exception for the calling code to handle
  //   }
  // }

  // Future<void> createUser(
  //   String companyId,
  //   Map<String, dynamic> personalInfo,
  //   Map<String, dynamic> salaryHistory,
  //   Map<String, dynamic> bankHistory,
  // ) async {
  //   try {
  //     // Use companyId as the document ID
  //     await usersCollection.doc(companyId).set({
  //       ...personalInfo,
  //       'financialInfo': {
  //         'salaryHistory': [salaryHistory],
  //         'bankHistory': [bankHistory],
  //       },
  //     });
  //   } catch (e) {
  //     // Handle errors as needed
  //     logger.w('Error creating user: $e');
  //     rethrow; // Rethrow the exception for the calling code to handle
  //   }
  // }

  Future<void> createUser(
    String companyId,
    Map<String, dynamic> personalInfo,
    Map<String, dynamic> salaryHistory,
    Map<String, dynamic> bankHistory,
  ) async {
    try {
      // Reference to the user document
      DocumentReference userDocRef = usersCollection.doc(companyId);

      // Use companyId as the document ID
      await userDocRef.set(personalInfo);

      // Reference to the salaryHistory subcollection
      CollectionReference salaryHistoryCollection =
          userDocRef.collection('salaryHistory');

      // Add a new document to the salaryHistory subcollection
      await salaryHistoryCollection.add(salaryHistory);

      // Reference to the bankHistory subcollection
      CollectionReference bankHistoryCollection =
          userDocRef.collection('bankHistory');

      // Add a new document to the bankHistory subcollection
      await bankHistoryCollection.add(bankHistory);
    } catch (e) {
      // Handle errors as needed
      print('Error creating user: $e');
      rethrow; // Rethrow the exception for the calling code to handle
    }
  }

  final storage = FirebaseStorage.instance;

  Future<String> uploadImage(String imagePath, String companyId) async {
    try {
      final ref = storage.ref().child('profile_images/$companyId.jpg');
      await ref.putFile(File(imagePath));
      final downloadURL = await ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      logger.e('Error uploading image: $e');
      return '';
    }
  }

  Future<void> updateUser(
    String companyId,
    Map<String, dynamic> personalInfo,
    Map<String, dynamic> salaryHistory,
    Map<String, dynamic> bankHistory,
  ) async {
    try {
      // Reference to the user document
      DocumentReference userDocRef = usersCollection.doc(companyId);

      // Use companyId as the document ID
      await userDocRef.update(personalInfo);

      // Reference to the salaryHistory subcollection
      CollectionReference salaryHistoryCollection =
          userDocRef.collection('salaryHistory');

      // Add a new document to the salaryHistory subcollection
      await salaryHistoryCollection.add(salaryHistory);

      // Reference to the bankHistory subcollection
      CollectionReference bankHistoryCollection =
          userDocRef.collection('bankHistory');

      // Add a new document to the bankHistory subcollection
      await bankHistoryCollection.add(bankHistory);
    } catch (e) {
      // Handle errors as needed
      print('Error updating user: $e');
      rethrow; // Rethrow the exception for the calling code to handle
    }
  }
}