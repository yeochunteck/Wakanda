import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:swipeable_page_route/swipeable_page_route.dart'; // Add this import statement
import 'package:geocoding/geocoding.dart';

class AttendanceRecordsPage extends StatefulWidget {
  final Map<String, dynamic> userDetails;
  final List<Map<String, dynamic>> attendanceRecords;

  AttendanceRecordsPage({required this.userDetails, required this.attendanceRecords});

    @override
  _AttendanceRecordsPageState createState() => _AttendanceRecordsPageState();
}

class _AttendanceRecordsPageState extends State<AttendanceRecordsPage> {
  int selectedCardIndex = -1;
    late List<String?> checkInLocations;
  late List<String?> checkOutLocations;

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    List<GeoPoint> checkInGeoPoints = widget.attendanceRecords
        .map((record) => record['CheckInLocation'] as GeoPoint)
        .toList();

    List<GeoPoint> checkOutGeoPoints = widget.attendanceRecords
        .map((record) => record['CheckOutLocation'] as GeoPoint)
        .toList();

    List<String?> checkInAddressList = await Future.wait(checkInGeoPoints
        .map((geoPoint) => getLocationString(geoPoint))
        .toList());

    List<String?> checkOutAddressList = await Future.wait(checkOutGeoPoints
        .map((geoPoint) => getLocationString(geoPoint))
        .toList());

    setState(() {
      checkInLocations = checkInAddressList;
      checkOutLocations = checkOutAddressList;
    });
  }

Future<String> getLocationString(GeoPoint? location) async {
  if (location != null) {
    try {
      return await getAddressFromCoordinates(location.latitude, location.longitude);
    } catch (e) {
      print('Error: $e');
      return 'Error getting address';
    }
  } else {
    return 'Unknown Location';
  }
}

Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      return '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
    } else {
      return 'Address not found';
    }
  } catch (e) {
    print('Error: $e');
    return 'Error getting address';
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MorphingAppBar(
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
          DateTime checkinTime = DateFormat('HH:mm:ss').parse(record['CheckInTime']);
          DateTime checkoutTime = DateFormat('HH:mm:ss').parse(record['CheckOutTime']);

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCardIndex = index;
              });
            },
            onLongPress: (){},
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: selectedCardIndex == index ? Colors.blueAccent : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            child: ListTile(
  leading: Icon(Icons.access_time),
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Check-in Location: ${(getLocationString(record['CheckInLocation']))}',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 4),
      Text(
        'Check-in Time: ${DateFormat.yMd().add_jm().format(checkinTime)}',
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
      SizedBox(height: 4),
      Text(
        'Check-out Location: ${getLocationString(record['CheckOutLocation'])}',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 4),
      Text(
        'Check-out Time: ${DateFormat.yMd().add_jm().format(checkoutTime)}',
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
    ],
  ),
),
            )
          );
        },
      ),
    );
  }
}





