import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceView extends StatefulWidget {
  @override
  _AttendanceViewState createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _selectedDate = DateTime.now(); // Set initial date to today
  Map<String, Map<String, dynamic>> usersWithAttendance = {};
  

Future<Map<String, Map<String, dynamic>>> getUsersWithAttendance(DateTime chosenDate) async {
  String formattedDate = "${chosenDate.day}-${chosenDate.month}-${chosenDate.year}";
  Map<String, Map<String, dynamic>> usersWithAttendance = {};

  QuerySnapshot attendanceSnapshot = await _firestore.collection('Attendance').get();

  print("Attendance Snapshot size: ${attendanceSnapshot.size}");

  for (var doc in attendanceSnapshot.docs) {
    print("Document ID: ${doc.id}");
    print("Document data: ${doc.data()}");
  }

  for (var doc in attendanceSnapshot.docs) {
    QuerySnapshot dateSnapshot = await doc.reference.collection(formattedDate).get();
    List<Map<String, dynamic>> attendanceRecords = [];
    for (var record in dateSnapshot.docs) {
      attendanceRecords.add(record.data() as Map<String, dynamic>);
    }

    if (attendanceRecords.isNotEmpty) {
      DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(doc.id).get();
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

      usersWithAttendance[doc.id] = {
        'userDetails': userData,
        'attendanceRecords': attendanceRecords,
      };
    }
  }

  return usersWithAttendance;
}


  Future<Map<String, dynamic>> getUserDetails(String companyId) async {
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(companyId).get();

    return userSnapshot.data() as Map<String, dynamic>;
  }

  Future<void> checkAttendanceAndFetchUsers() async {
    Map<String, Map<String, dynamic>> usersAttendanceInfo =
        await getUsersWithAttendance(_selectedDate);

    print("Users with Attendance: $usersAttendanceInfo");

    setState(() {
      usersWithAttendance = usersAttendanceInfo;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    checkAttendanceAndFetchUsers();
  }

  void navigateToAttendanceRecordPage(String companyId, Map<String, dynamic> userData,List<Map<String, dynamic>> attendanceRecords) {
    // Implement navigation to a page showing attendance records for the selected user
    // Pass 'companyId' and 'userData' to the next page
  }

  

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance View'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2023),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null && pickedDate != _selectedDate) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                  await checkAttendanceAndFetchUsers();
                }
              },
              child: Text(
                'Select Date',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: usersWithAttendance.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: usersWithAttendance.length,
                      itemBuilder: (BuildContext context, int index) {
                        String companyId = usersWithAttendance.keys.elementAt(index);
                        Map<String, dynamic> userAttendance = usersWithAttendance[companyId]!;
                        Map<String, dynamic> userDetails = userAttendance['userDetails'] as Map<String, dynamic>;
                        List<Map<String, dynamic>> attendanceRecords = userAttendance['attendanceRecords'] as List<Map<String, dynamic>>;

                        return GestureDetector(
                          onTap: () {
                            // Handle user tap
                          },
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(userDetails['image']),
                                radius: 28,
                              ),
                              title: Text(
                                userDetails['name'],
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userDetails['position'],
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Total Attendance Records: ${attendanceRecords.length}',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                              onLongPress: () {
                                // Handle long press
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}





















