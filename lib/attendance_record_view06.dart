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
  int? selectedCardIndex; // Track the selected card index

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
    body: 
    ListView.builder(
      itemCount: widget.attendanceRecords.length,
      itemBuilder: (BuildContext context, int index) {
        Map<String, dynamic> record = widget.attendanceRecords[index];

        return InteractiveCard(
          record: record,
          checkInAddresses: checkInAddresses,
          checkOutAddresses: checkOutAddresses,
          index:index,
           isSelected: selectedCardIndex == index, // Pass whether the card is selected or not
            onTap: () {
              setState(() {
                selectedCardIndex = index; // Update the selected card index
              });
            },
        )
        
        /*Card(
  elevation: 8,
  margin: EdgeInsets.all(12),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  child: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Check-In',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          Text(
            'Check-Out',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.grey[800],
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '${record['CheckInTime']}',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Text(
                '${record['CheckOutTime']}',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.access_time,
                color: Colors.grey[800],
                size: 24,
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.grey[800],
                size: 24,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${checkInAddresses.length > index ? checkInAddresses[index] ?? 'Address not available' : 'Address not available'}',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        '${checkOutAddresses.length > index ? checkOutAddresses[index] ?? 'Address not available' : 'Address not available'}',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.location_on,
                      color: Colors.grey[800],
                      size: 24,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
)*/
;
      },
    ),
  );
}
}

class InteractiveCard extends StatefulWidget {
  final Map<String, dynamic> record;
  final List<String> checkInAddresses;
  final List<String> checkOutAddresses;
  final int index;
  final bool isSelected; // Add isSelected property
  final Function() onTap; // Add onTap function

  const InteractiveCard({
    Key? key,
    required this.record,
    required this.checkInAddresses,
    required this.checkOutAddresses,
    required this.index,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  _InteractiveCardState createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  //bool isSelected = false;
  

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

    /*void _toggleSelection() {
    setState(() {
      isSelected = !isSelected;
    });*/

  @override
  Widget build(BuildContext context) {
    Color checkOutIconColor = Color.fromARGB(255, 176, 95, 95);
    Color checkInIconColor = Colors.teal;
    String checkInAddress = widget.checkInAddresses.length > widget.index
    ? widget.checkInAddresses[widget.index] ?? 'Address not available'
    : 'Address not available';

String checkOutAddress = widget.checkOutAddresses.length > widget.index
    ? widget.checkOutAddresses[widget.index] ?? 'Address not available'
    : 'Address not available';

final maxLength = 16; // Adjust the maximum length as needed

String limitedCheckInAddress = checkInAddress.length > maxLength
    ? '${checkInAddress.substring(0, maxLength)}...'
    : checkInAddress;

String limitedCheckOutAddress = checkOutAddress.length > maxLength
    ? '${checkOutAddress.substring(0, maxLength)}...'
    : checkOutAddress;

    
    return GestureDetector(
  onTapDown: (_) {
    _controller.forward();
    widget.onTap(); // Toggle selection on tap
  },
  onTapUp: (_) {
    _controller.reverse();
    // Add your onTap logic here
  },
  onTapCancel: () => _controller.reverse(),
  child: ScaleTransition(
    scale: _animation,
    child: Container(
      clipBehavior: Clip.none,
      child: Stack(
  children: [
          Card(
            elevation: widget.isSelected ? 12 : 8,
            margin: EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: widget.isSelected ? Colors.blue : Colors.transparent,
                width: widget.isSelected ? 2 : 0,
              ),
            ),
            color: widget.isSelected ? Colors.blueGrey[50] : Colors.white,
            child: Material(
              borderRadius: BorderRadius.circular(20),
              color: widget.isSelected ? Colors.blueGrey[100] : Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  widget.onTap();
                },
                splashColor: widget.isSelected ? Colors.transparent : Colors.blueGrey.withOpacity(0.3),
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    ClipRect(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Container(
  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
  decoration: BoxDecoration(
    color:widget. isSelected ? Colors.blue : Colors.deepPurple,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    ),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Check-In',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      Text(
        'Check-Out',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ],
  ),
)

,

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: checkInIconColor,
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '${widget.record['CheckInTime']}',
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    '${widget.record['CheckOutTime']}',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.access_time,
                                    color: checkOutIconColor,
                                    size: 24,
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: checkInIconColor,
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      limitedCheckInAddress,
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            limitedCheckOutAddress,
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.location_on,
                                          color: checkOutIconColor,
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),// Positioned Index Display
        // Positioned Index Display
    AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: widget.isSelected
          ? Matrix4.translationValues(-15, -27, 0)
          : Matrix4.translationValues(10, -10, 0),
      child: Container(
        padding: EdgeInsets.only(left:20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isSelected
                  ? [Colors.purple.withOpacity(0.5), Colors.deepOrange.withOpacity(0.7)]
                  : [Colors.lightBlue.withOpacity(0.0), Colors.teal.withOpacity(0.0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
              color: widget.isSelected ? Colors.purple.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          width: 53,
          height: 53,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:widget. isSelected
                  ? [Colors.purple.withOpacity(0.5), Colors.deepOrange.withOpacity(0.7)]
                  : [Colors.lightBlue.withOpacity(0.0), Colors.teal.withOpacity(0.0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.rectangle,
          ),
          child: Center(
    child: Stack(
  children: [
    Text(
      '${widget.index + 81}',
      style: TextStyle(
        color: widget.isSelected ? Colors.red : Colors.white.withOpacity(0.5),
        fontWeight: FontWeight.bold,
        fontSize: 53,
        letterSpacing: -4,
      ),
    ),
    Text(
      '${widget.index + 81}',
      style: TextStyle(
        color: Colors.deepPurple,
        fontWeight: FontWeight.bold,
        fontSize: 50,
        letterSpacing: -4,
        fontStyle: FontStyle.italic, // Apply italic style here
      ),
    ),
    Positioned(
      top: 0,
      left:25,
      child: Text(
        'No.',
        style: TextStyle(
          color: Colors.blueGrey,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          fontStyle: FontStyle.italic, // Apply italic style here
        ),
      ),
    ),
  ],
),
        ),
      ),
    ),
    // Adjusted Index with Opacity
    /*AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: isSelected
          ? Matrix4.translationValues(-20, -27, 0)
          : Matrix4.translationValues(0, 0, 0),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                  ? [Colors.purple.withOpacity(0.9), Colors.deepOrange.withOpacity(0.7)]
                  : [Colors.lightBlue.withOpacity(0.9), Colors.teal.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Opacity(
            opacity: isSelected ? 1.0 : 0.0, // Set the opacity accordingly
            child: Text(
              '${widget.index+10}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 52,
              ),
            ),
          ),
        ),
      ),
    ),*/
      )],
      ),
    ),
  ),
);
  }
}

