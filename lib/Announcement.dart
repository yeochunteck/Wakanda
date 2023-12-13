import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementPage extends StatefulWidget {
  final String userPosition;
  final String companyId; // Unique user ID

  AnnouncementPage({Key? key, required this.userPosition, required this.companyId}) : super(key: key);

  @override
  _AnnouncementPageState createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  String currentCategory = 'unseen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement Page'),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentCategory = 'unseen';
                  });
                },
                child: const Text('Unseen'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentCategory = 'seen';
                  });
                },
                child: const Text('Seen'),
              ),
            ],
          ),
          Expanded(
            child: AnnouncementList(userPosition: widget.userPosition, companyId: widget.companyId, category: currentCategory),
          ),
          if (widget.userPosition == 'Manager')
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MakeAnnouncementPage(companyId: widget.companyId),
                    ),
                  );
                },
                child: const Text('Make Announcement'),
              ),
            ),
        ],
      ),
    );
  }
}

class AnnouncementList extends StatelessWidget {
  final String userPosition;
  final String companyId;
  final String category;

  AnnouncementList({required this.userPosition, required this.companyId, required this.category});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('announcements').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading announcements');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        List<Widget> announcementWidgets = [];

        // Display announcements based on category
        for (QueryDocumentSnapshot document in snapshot.data!.docs) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          String title = data['title'];
          DateTime timestamp = data['timestamp'].toDate();

          List<String> visibleTo = List<String>.from(data['visible_to'] ?? []);

          bool isSeen = data['seen_by_$companyId'] ?? false;

          if (
            ((category == 'unseen' && !isSeen) ||
            (category == 'seen' && isSeen))&&
            (visibleTo.contains(companyId))
          ) {
            announcementWidgets.add(
              ListTile(
                title: Text(title),
                onTap: () async {
                  // Mark the announcement as seen for the current user
                  await FirebaseFirestore.instance
                      .collection('announcements')
                      .doc(document.id)
                      .update({'seen_by_$companyId': true});

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnnouncementDetailPage(title: title, content: data['content']),
                    ),
                  );
                },
                trailing: Text('${timestamp.toLocal()}'),
              ),
            );
          }
        }

        return ListView(
          children: announcementWidgets,
        );
      },
    );
  }
}

class AnnouncementDetailPage extends StatelessWidget {
  final String title;
  final String content;

  AnnouncementDetailPage({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(content),
          ],
        ),
      ),
    );
  }
}

class MakeAnnouncementPage extends StatefulWidget {
  final String companyId;

  MakeAnnouncementPage({required this.companyId});

  @override
  _MakeAnnouncementPageState createState() => _MakeAnnouncementPageState();
}

class _MakeAnnouncementPageState extends State<MakeAnnouncementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> _postAnnouncement() async {
    String title = _titleController.text.trim();
    String content = _contentController.text.trim();
    DateTime now = DateTime.now();

  Future<int> getLatestAnnouncementNumber() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('announcements').get();

      int latestNumber = 0;

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        String documentId = document.id;
        if (documentId.startsWith('General_Announcement_')) {
          // Extract the announcement number
          int number = int.tryParse(documentId.split('_').last) ?? 0;
          if (number > latestNumber) {
            latestNumber = number;
          }
        }
      }

      return latestNumber;
    } catch (e) {
      print('Error fetching latest announcement number: $e');
      return 0;
    }
  }

    // Get the latest announcement number
    int latestAnnouncementNumber = await getLatestAnnouncementNumber();

    // Create a unique document ID for the announcement
    String documentId = 'General_Announcement_${latestAnnouncementNumber + 1}';

    Future<List<String>> getAllCompanyIds() async {
      List<String> companyIds = [];

      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();

        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          // Assuming each document in 'users' has a field 'companyId'
          String companyId = document['companyId'];
          if (companyId.isNotEmpty) {
            companyIds.add(companyId);
          }
        }
      } catch (e) {
        print('Error fetching company IDs: $e');
      }

      return companyIds;
    }

    // Get all company IDs
    List<String> allCompanyIds = await getAllCompanyIds();

    // Add the announcement to Firebase Firestore
    await FirebaseFirestore.instance.collection('announcements').doc(documentId).set({
      'title': title,
      'content': content,
      'timestamp': now,
      'seen_by_${widget.companyId}': false,
      'visible_to': allCompanyIds, // Set the visible array to all companyId
    });

    // Close the current page and go back to the previous page
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Announcement'),
        // Back button in the AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Announcement Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Announcement Content'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _postAnnouncement,
              child: const Text('Post Announcement'),
            ),
          ],
        ),
      ),
    );
  }
}
