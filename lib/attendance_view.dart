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

   // Simulated function to fetch attendance data based on selected date
  Stream<Map<String, Map<String, dynamic>>> getAttendanceRecords(DateTime selectedDate) async* {
    // Simulating fetching attendance data in a loop (replace with your actual data retrieval logic)
    while (true) {
      await Future.delayed(Duration(seconds: 3)); // Simulating data refresh every 3 seconds

      // Fetch attendance records for the selected date
      Map<String, Map<String, dynamic>> attendanceData = usersWithAttendance ;

      yield attendanceData; // Emit the fetched attendance records
    }
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
              child: StreamBuilder<Map<String, Map<String, dynamic>>>(
                stream: getAttendanceRecords(_selectedDate),
                builder: (BuildContext context, AsyncSnapshot<Map<String, Map<String, dynamic>>> snapshot) {
                  if (snapshot.hasData) {
                    // Extract attendance records
                    Map<String, Map<String, dynamic>> attendanceData = snapshot.data!;

                    return ListView.builder(
                      itemCount: attendanceData.length,
                      itemBuilder: (BuildContext context, int index) {
                        String userId = attendanceData.keys.elementAt(index);
                        Map<String, dynamic> userData = attendanceData[userId]!;
                        // Build UI components using userData...
                        return ListTile(
                          title: Text(userData['name']),
                          // Display other attendance info...
                        );
                      },
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}





















