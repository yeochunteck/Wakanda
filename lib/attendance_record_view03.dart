import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'package:swipeable_page_route/swipeable_page_route.dart';

class AttendanceRecordsPage extends StatefulWidget {
  final Map<String, dynamic> userDetails;
  final List<Map<String, dynamic>> attendanceRecords;

  AttendanceRecordsPage({required this.userDetails, required this.attendanceRecords});

  @override
  _AttendanceRecordsPageState createState() => _AttendanceRecordsPageState();
}

class _AttendanceRecordsPageState extends State<AttendanceRecordsPage> {
  List<String> checkInAddresses = [];
  List<String> checkOutAddresses = [];

  @override
  void initState() {
    super.initState();
    transformGeoPoints();
  }

  Future<void> transformGeoPoints() async {
    for (var record in widget.attendanceRecords) {
      String checkInAddress = await getAddressFromLocation(record['CheckInLocation']);
      String checkOutAddress = await getAddressFromLocation(record['CheckOutLocation']);
      setState(() {
        checkInAddresses.add(checkInAddress);
        checkOutAddresses.add(checkOutAddress);
      });
    }
  }

  Future<String> getAddressFromLocation(GeoPoint? geoPoint) async {
    if (geoPoint != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          geoPoint.latitude,
          geoPoint.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks.first;
          return '${placemark.locality ?? ''}, ${placemark.postalCode ?? ''}, ${placemark.country ?? ''}';
        }
      } catch (e) {
        print('Error getting address: $e');
      }
    }
    return 'Address not available';
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        widget.userDetails['name'] ?? 'Attendance Records',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.purpleAccent,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    body: ListView.builder(
      itemCount: widget.attendanceRecords.length,
      itemBuilder: (BuildContext context, int index) {
        Map<String, dynamic> record = widget.attendanceRecords[index];

        return Card(
          elevation: 4,
          margin: EdgeInsets.all(8),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Check-In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    Text(
                      'Check-Out',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                subtitle: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded(
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${record['CheckInTime']}',
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            Text(
              '${record['CheckOutTime']}',
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${checkInAddresses.length > index ? checkInAddresses[index] ?? 'Address not available' : 'Address not available'}',
                style: TextStyle(
                  color: Colors.grey[700],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Text(
                '${checkOutAddresses.length > index ? checkOutAddresses[index] ?? 'Address not available' : 'Address not available'}',
                style: TextStyle(
                  color: Colors.grey[700],
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    ),
  ],
),
              ),
            ],
          ),
        );
      },
    ),
  );
}







}
