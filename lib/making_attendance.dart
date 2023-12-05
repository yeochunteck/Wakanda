import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:developer' as developer;
import 'package:logger/logger.dart';
import 'dart:ui';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2, // number of method calls to be displayed
    errorMethodCount: 8, // number of method calls if stacktrace is provided
    lineLength: 120, // width of the output
    colors: true, // enable colors
    printEmojis: true, // print an emoji for each log message
    printTime: true, // print time in the log messages
  ),
);

class AttendancePage extends StatefulWidget {
  final String companyId;

  AttendancePage({required this.companyId});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isCheckedIn = false;
  String _currentDate = '';
  LatLng? _currentLocation; // Nullable type for current location
  GoogleMapController? _mapController;
  String _locationName = 'Unknown'; // Variable to store the location name
  String _address = 'Unknown';
  StreamSubscription <QuerySnapshot>? _attendanceStream;
  Timer? _listenerTimer;
  Timer? _validateTimer;
  bool _isProcessing = false;
  
  
  @override
  void initState() {
    super.initState();
    _getCurrentDate();
    _requestLocationPermission();
    _startListenerRefresh(); // Start the timer for listener refresh
    _listenToAttendanceChanges();
  }

void _listenToAttendanceChanges() {
  _attendanceStream = FirebaseFirestore.instance
      .collection('Attendance')
      .doc(widget.companyId)
      .collection(_currentDate)
      .orderBy('CheckInTime', descending: true)
      .limit(1)
      .snapshots()
      .listen((QuerySnapshot snapshot) {
    try{
      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot latestRecord = snapshot.docs.first;

        var documentId = latestRecord.id;
        logger.d('Document ID: $documentId');
        
        var data = latestRecord.data();
        logger.i('=== Fields of the current latest record ===');
        if (data != null && data is Map<String, dynamic>) {
          data.forEach((key, value) {
            logger.i('$key: $value'); // Log fields of the latest record
          });
        } else {
          logger.i('No data available in the latest record');
        }

        if (data != null &&
            data is Map<String, dynamic> &&
            data.containsKey('CheckOutTime')) {
          setState(() {
            _isCheckedIn = false;
          });
          logger.i('User status: Checked OUT'); // Indicate that the user is checked out
        } else {
          setState(() {
            _isCheckedIn = true;
          });
          logger.i('User status: Checked IN'); // Indicate that the user is checked in
        }

        logger.i('Is checked in? $_isCheckedIn'); // Log the value of _isCheckedIn
      } else {
        // Collection or document doesn't exist
        setState(() {
          _isCheckedIn = false; // Handle default state when no data is available
        });
        logger.i('No attendance record found'); // Indicate that no record exists
      }
    }catch(e){
      logger.e('Error listenining to attendance changes: $e');
    }
  });
}

void _startListenerRefresh() {
  const refreshInterval = Duration(seconds: 30); // Refresh interval of 30 seconds (modify as needed)

  _listenerTimer = Timer.periodic(refreshInterval, (timer) {
    _attendanceStream?.cancel(); // Cancel the current listener
    _listenToAttendanceChanges(); // Re-establish the listener
  });
}

void _stopListenerRefresh() {
  _listenerTimer?.cancel();
}



  Future<void> _getCurrentDate() async {
    DateTime now = DateTime.now();
    _currentDate = '${now.day}-${now.month}-${now.year}';
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

       /*// Perform reverse geocoding to get location name
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _locationName = placemarks.first.name ?? 'Unknown'; // Update location name
      });*/

      _updateLocationDetails(position.latitude, position.longitude);

    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  Future<void>_requestLocationPermission() async{
    PermissionStatus permissionStatus = await Permission.location.request();

    if(permissionStatus.isGranted){
      _getCurrentLocation();
    }else if(permissionStatus.isDenied || permissionStatus.isRestricted) {
      // Handle denied or restricted permission
      _showPermissionDeniedDialog();
    }
    else{
      // Handle permanently denied permission
      _showPermanentlyDeniedDialog();
    };
  }

    void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Denied'),
        content: Text('Please grant access to the location to use this feature.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings(); // Opens the app settings to allow users to grant permission
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Permanently Denied'),
        content: Text('Please grant access to the location from settings to use this feature.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings(); // Opens the app settings for permission
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

   void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    _getCurrentLocation();
    _startLocationUpdates();
  }

void _startLocationUpdates() {
  Geolocator.getPositionStream().listen((Position position) {
    if (mounted) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      _updateLocationDetails(position.latitude, position.longitude);
    }
  });
}

  @override
void dispose() {
  // Stop listening to position updates when the widget is disposed
  // This prevents calling setState() on a disposed widget
  Geolocator.getPositionStream().listen((Position position) {}).cancel();
  _stopListenerRefresh(); // Stop the timer when the widget is disposed
  _attendanceStream?.cancel(); // Cancel the stream subscription;
  _validateTimer?.cancel();
  super.dispose();
}

  Future<void> _updateLocationDetails(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      setState(() {
        _locationName = placemarks.first.name ?? 'Unknown';
        _address = placemarks.first.street ?? 'Unknown';
        // You can access other address details like locality, subLocality, etc. from the placemarks if needed
      });
    } catch (e) {
      print("Error getting location details: $e");
    }
  }


  
Future<void> _checkInOut() async {
  try {
    setState(() {
        _isProcessing = true; // Start the processing/loading indicator
      });

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    GeoPoint geoPoint = GeoPoint(
      position.latitude,
      position.longitude,
    );

    String timeKey =
        '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}';

    // Check the latest attendance type
    bool isCheckIn = await _getLastAttendanceType();

    DocumentReference latestAttendanceDoc;

    if (!isCheckIn) {
      // If the latest record is a check-in, create a new document for check-out
      await _firestore
          .collection('Attendance')
          .doc(widget.companyId)
          .collection(_currentDate)
          .doc()
          .set({
            'CheckInLocation': geoPoint,
            'CheckInTime': timeKey,
          });

      // Fetch the latest attendance document after check-in
      latestAttendanceDoc = await _getLatestAttendanceDoc();

      // Check the status of the latest record after check-in
        /*var latestDocData = (await latestAttendanceDoc.get()).data();
        if (latestDocData != null &&
            latestDocData is Map<String, dynamic> &&
            latestDocData.containsKey('CheckOutTime')) {
          // If the status is already check-out, inform the user and return
          /*ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Check-out process is currently unavailable. Please retry after a moment.'),
              duration: Duration(seconds: 5), // Display for 5 seconds (adjust as needed)
            ),
          );*/
            _showUnavailableCheckoutDialog();
          
        }*/

    } else {
      // Get the latest attendance document before updating
      latestAttendanceDoc = await _getLatestAttendanceDoc();

      // If the latest record is a check-out, update the existing document
      await latestAttendanceDoc.update({
        'CheckOutLocation': geoPoint,
        'CheckOutTime': timeKey,
      });


      // Fetch the latest attendance document after check-out
      latestAttendanceDoc = await _getLatestAttendanceDoc();
      
    }

    // Log the latest attendance document after check-in or check-out
    var latestDocId = latestAttendanceDoc.id;
    var latestDocData = (await latestAttendanceDoc.get()).data();
    logger.d('Latest Attendance Document ID after Action: $latestDocId');
    logger.d('Latest Attendance Document Data after Action: $latestDocData');
     // Check if the latest attendance record matches the expected status
    bool expectedStatus = !isCheckIn;
    bool latestRecordStatus = !(latestDocData != null &&
        latestDocData is Map<String, dynamic> &&
        latestDocData.containsKey('CheckOutTime'));

    if (latestRecordStatus != expectedStatus) {
      // Set a flag to indicate processing
      setState(() {
        _isProcessing = true;
      });

      // Check continuously until the expected status is reached
      _checkLatestRecordStatus(expectedStatus: expectedStatus);
    } else {
      // Reset processing flag if the status matches
      setState(() {
        _isProcessing = false;
      });
    }
  } catch (e) {
    print("Error checking in/out: $e");
  }
}

 void _checkLatestRecordStatus({required bool expectedStatus}) {
    _validateTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      DocumentReference latestAttendanceDoc = await _getLatestAttendanceDoc();
      var latestDocData = (await latestAttendanceDoc.get()).data();
      bool latestRecordStatus = !(latestDocData != null &&
          latestDocData is Map<String, dynamic> &&
          latestDocData.containsKey('CheckOutTime'));

      if (latestRecordStatus == expectedStatus) {
        timer.cancel(); // Stop the timer if the expected status is reached
        setState(() {
          _isProcessing = false; // Reset the processing flag
        });
      } else {
        print('Latest record status does not match the expected status');
        // Optionally add a delay before the next check
        // await Future.delayed(Duration(seconds: 5));
      }
    });
  }

Future<DocumentReference> _getLatestAttendanceDoc() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Attendance')
        .doc(widget.companyId)
        .collection(_currentDate)
        .orderBy('CheckInTime', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Return the reference to the latest attendance document
      return querySnapshot.docs.first.reference;
    } else {
      // Handle if no documents are found
      // You might want to create a new document in this case
      print('No attendance documents found for $_currentDate');
      // Return a reference to a new document (it can be updated by _checkInOut)
      return FirebaseFirestore.instance
          .collection('Attendance')
          .doc(widget.companyId)
          .collection(_currentDate)
          .doc();
    }
  } catch (e) {
    print('Error getting latest attendance document: $e');
    // Return a reference to a new document as a fallback
    return FirebaseFirestore.instance
        .collection('Attendance')
        .doc(widget.companyId)
        .collection(_currentDate)
        .doc();
  }
}


Future<bool> _getLastAttendanceType() async {
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Attendance')
        .doc(widget.companyId)
        .collection(_currentDate)
        .orderBy('CheckInTime', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var data = snapshot.docs.first.data();
      return !(data != null && data is Map<String,dynamic> && data.containsKey('CheckOutTime'));
    }
  } catch (e) {
    print("Error getting last attendance type: $e");
  }
  return false;
}

 void _showUnavailableCheckoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Check-out Unavailable'),
          content: Text(
              'Check-out process is currently unavailable. Please retry after a moment.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Attendance'),
    ),
    body: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date: $_currentDate',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                SizedBox(height: 10.0),
                Container(
                  height: 200.0,
                  child: _currentLocation != null
                      ? GoogleMap(
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          initialCameraPosition: _currentLocation != null
                              ? CameraPosition(
                                  target: _currentLocation!,
                                  zoom: 15.0,
                                )
                              : CameraPosition(
                                  target: LatLng(0.0, 0.0),
                                  zoom: 1.0,
                                ),
                          onMapCreated: _onMapCreated,
                          markers: _currentLocation != null
                              ? {
                                  Marker(
                                    markerId: MarkerId('currentLocation'),
                                    position: _currentLocation!,
                                  ),
                                }
                              : {},
                        )
                      : Center(child: CircularProgressIndicator()),
                ),
                SizedBox(height: 20),
                Text('Location: $_locationName'),
                Text('Address: $_address'),
                SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: _checkInOut,
                  child: Text(_isCheckedIn ? 'Out' : 'Work'),
                ),
                if (_isProcessing) _buildLoadingInterface(),
              ],
            ),
          ),
        ),
        if (_isProcessing) _buildDarkOverlay(),
      ],
    ),
  );
}

Widget _buildDarkOverlay() {
  return Container(
    color: Colors.black.withOpacity(0.5),
    child: Center(
      child: CircularProgressIndicator(),
    ),
  );
}

Widget _buildLoadingInterface() {
  return IgnorePointer(
    ignoring: false,
    child: Container(
      color: Colors.transparent,
      child: Center(
        //child: CircularProgressIndicator(),
      ),
    ),
  );
}


}
