import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

final logger = Logger();
Future<List<Map<String, String>>> getCompanyAnnouncements() async {
  try {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('announcements')
        .where('announcementType', isEqualTo: 'Company')
        .orderBy('timestamp', descending: false)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final List<Map<String, String>> announcements = querySnapshot.docs
          .map((doc) => {
                'title': doc['title'] as String,
                'content': doc['content'] as String,
                'timestamp': doc['timestamp'].toDate().toString(),
              })
          .toList();

      logger.i('Company announcements: $announcements');
      return announcements;
    } else {
      logger.w('No company announcements found');
      return []; // Return an empty list if no announcements are found
    }
  } catch (e) {
    logger.e('Error fetching company announcements: $e');
    return []; // Return an empty list in case of an error
  }
}
