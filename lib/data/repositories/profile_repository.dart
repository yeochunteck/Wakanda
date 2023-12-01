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

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> createUser(Map<String, dynamic> userData) async {
    try {
      await usersCollection.add(userData);
    } catch (e) {
      // Handle errors as needed
      logger.w('Error creating user: $e');
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
}
