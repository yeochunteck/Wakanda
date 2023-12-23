import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:swipeable_page_route/swipeable_page_route.dart'; // Add this import statement

class AttendanceRecordsPage extends StatelessWidget {
  final Map<String, dynamic> userDetails;
  final List<Map<String, dynamic>> attendanceRecords;

  AttendanceRecordsPage({required this.userDetails, required this.attendanceRecords});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MorphingAppBar(
        title: Text(userDetails['name'] ?? 'Attendance Records',
        style: TextStyle(
        color: Colors.black87, // Adjust text color for modern style
        fontWeight: FontWeight.bold,
        fontSize: 20,),
        ),
        centerTitle: true,
        backgroundColor: Colors.purpleAccent,
        iconTheme: IconThemeData(color: Colors.black), // Set the back arrow color   
      ),
      /*body: ListView.builder(
        itemCount: attendanceRecords.length,
        itemBuilder: (BuildContext context, int index) {
          Map<String, dynamic> record = attendanceRecords[index];
          DateTime date = record['date'].toDate(); // Assuming 'date' is a Timestamp in Firestore

          return ListTile(
            title: Text('Date: ${DateFormat.yMd().format(date)}'),
            subtitle: Text('Status: ${record['status']}'),
            // Add more fields from the attendance record as needed
          );
        }
      )*/
    );
  }
}


