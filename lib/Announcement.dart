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

          bool isSeen = data['seen_by_$companyId'] ?? false;

          if ((category == 'unseen' && !isSeen) || (category == 'seen' && isSeen)) {
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

    // Add the announcement to Firebase Firestore
    await FirebaseFirestore.instance.collection('announcements').add({
      'title': title,
      'content': content,
      'timestamp': now,
      'seen_by_${widget.companyId}': false, // Set seen status for the current user
    });

    // Close the current page and go back to the previous page
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Announcement'),
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
