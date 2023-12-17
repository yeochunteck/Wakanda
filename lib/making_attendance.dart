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
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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

class _AttendancePageState extends State<AttendancePage>
    with TickerProviderStateMixin {
  //Animation controller
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  //Firebase     
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentReference? _recentlyCheckInDoc;
  DocumentSnapshot? _recentlyCheckOutDoc;
  DocumentSnapshot? previousAttendanceDoc;
  Map<String, dynamic>? previousAttendanceData;
  bool? expectedStatus;
  //Control Flag
  bool? initialButtonState;
  bool _isCheckedIn = false;
  //Current variable
  String _currentDate = '';
  String _currentTime = '';
  bool _isProcessing = false;
  bool _showCircle = false;
    //Location
  LatLng? _currentLocation; // Nullable type for current location
  GoogleMapController? _mapController;
  String _locationName = 'Unknown'; // Variable to store the location name
  String _address = 'Unknown';
  //Update
  StreamSubscription <QuerySnapshot>? _attendanceStream;
  Timer? _listenerTimer;
  Timer? _validateTimer;
  late Timer _dateTimeTimer;
//Personal
  Map<String, dynamic>? userData;
//Method
  //Personal
    Future<Map<String, dynamic>?> _getUserData() async {
    final docSnapshot = await _firestore
      .collection('users')
      .doc(widget.companyId)
      .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      return data;
    }
    
    return null; // Return null if data doesn't exist or isn't in the expected format
  }

  Future<void> _fetchUserData() async {
    // Fetch user data asynchronously
    final data = await _getUserData(); // Replace this with your data fetching logic
    setState(() {
      userData = data;
    });
  }  

  //Announcement
  Future<void> _postCheckInOutAnnouncement(String title, String content, String companyId) async {
    try {
      DateTime now = DateTime.now();

      // Add the announcement to Firebase Firestore
      await FirebaseFirestore.instance.collection('announcements').add({
        'title': title,
        'content': content,
        'timestamp': now,
        'seen_by_${widget.companyId}': false,
        'visible_to': [companyId], // Set visible status for the current user
      });

    } catch (e) {
      print("Error posting announcement: $e");
      // Handle error if needed
    }
  }
  

  //ListenToDatabase
  void _listenToAttendanceChanges() {
    _attendanceStream = FirebaseFirestore.instance
        .collection('Attendance')
        .doc(widget.companyId)
        .collection(_currentDate)
        .orderBy('CheckInTime', descending: true)
        .limit(1)
        .snapshots(includeMetadataChanges: true)
        .listen((QuerySnapshot snapshot) {
      try{
        snapshot.docChanges.forEach((change) {
          var metadata = change.doc.metadata;
          if (metadata.hasPendingWrites) {
            print('Data came frFom the local cache');
          } else {
            print('Data came from the server');
          }

      // Handle other changes in the snapshot as needed
        });
        if (snapshot.docs.isNotEmpty) {
          DocumentSnapshot latestRecord = snapshot.docs.first;
          previousAttendanceDoc = latestRecord;

          var documentId = latestRecord.id;
          logger.d('Document ID: $documentId');
          
          var data = latestRecord.data();
          previousAttendanceData = data as Map<String, dynamic>;

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
        if (expectedStatus != null){
          _checkLatestRecordStatus(expectedStatus: expectedStatus);
        }
      }catch(e){
        logger.e('Error listenining to attendance changes: $e');
      }
    },
    onError: (error){
      logger.e('Error fetching user data: $error'); // Error level log for errors
    }
    );
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

  //getCurrentDateTime
  Future<void> _getCurrentDate() async {
    DateTime now = DateTime.now();
    _currentDate = '${now.day}-${now.month}-${now.year}';
  }

  Future<void> _getCurrentTime() async {
    // Method to fetch the current time
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('hh:mm:ss').format(now);
    setState(() {
      _currentTime = formattedTime;
    });
  }

  void _updateDateTime() {
    // Fetch and update date/time every second
    _dateTimeTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      DateTime now = DateTime.now();
      setState(() {
        _currentDate = '${now.day}-${now.month}-${now.year}';
        _currentTime = DateFormat('hh:mm:ss').format(now);
      });
    });
  }

  void _stopDateTimeUpdates() {
    // Cancel the timer to stop updating date/time
    _dateTimeTimer.cancel();
  }

//getCurrentLocation
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

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

//Permission
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

//CheckInOut
  Future<void> _checkInOut() async {
    try {
      // Set initial button state
      initialButtonState = _isCheckedIn;
      _showCircle = true;

      // Timer to hide the circle after 1 second
      Timer(Duration(milliseconds: 100), () {
        setState(() {
          _showCircle = false;
        });
      });
      
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

      bool isCheckIn = await _getLastAttendanceType();

      DocumentReference latestAttendanceDoc;

      if (!isCheckIn) {
        final checkInDocRef = _firestore
            .collection('Attendance')
            .doc(widget.companyId)
            .collection(_currentDate)
            .doc();

        await checkInDocRef.set({
          'CheckInLocation': geoPoint,
          'CheckInTime': timeKey,
        });

        _recentlyCheckInDoc = checkInDocRef;

        latestAttendanceDoc = await _getLatestAttendanceDoc();

        // Post check-in success announcement
        String announcementTitle = 'Check-In Success';
        String announcementContent = 'User ${widget.companyId} has successfully checked in at ${DateFormat('hh:mm:ss a').format(DateTime.now())}.';
        await _postCheckInOutAnnouncement(announcementTitle, announcementContent,widget.companyId);
      } else {
        latestAttendanceDoc = await _getLatestAttendanceDoc();

        _recentlyCheckOutDoc = await latestAttendanceDoc.get();

        await latestAttendanceDoc.update({
          'CheckOutLocation': geoPoint,
          'CheckOutTime': timeKey,
        });

        latestAttendanceDoc = await _getLatestAttendanceDoc();

        // Post check-in success announcement
        String announcementTitle = 'Check-Out Success';
        String announcementContent = 'User ${widget.companyId} has successfully checked out at ${DateFormat('hh:mm:ss a').format(DateTime.now())}.';
        await _postCheckInOutAnnouncement(announcementTitle, announcementContent,widget.companyId);
      }

      var latestDocId = latestAttendanceDoc.id;
      var latestDocData = (await latestAttendanceDoc.get()).data();
      var metadata = (await latestAttendanceDoc.get()).metadata;

      // Check metadata for source information
      if (metadata.isFromCache) {
        logger.d('Data retrieved from local cache');
      } else {
        logger.d('Data retrieved from server');
      }

      expectedStatus = !isCheckIn;
      bool latestRecordStatus = !(latestDocData != null &&
          latestDocData is Map<String, dynamic> &&
          latestDocData.containsKey('CheckOutTime'));

      if (latestRecordStatus != expectedStatus) {
        setState(() {
          _isProcessing = true;
        });
      } else {
        if(_isCheckedIn != initialButtonState){
          setState(() {
          _isProcessing = false;
          _recentlyCheckInDoc = null;
          _recentlyCheckOutDoc = null;
        });}
        
      }

      // Stop the processing/loading indicator immediately if the button state changes
      if (initialButtonState != _isCheckedIn) {
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      print("Error checking in/out: $e");
      _revertOrRemoveDocuments(); // Revert or remove documents on error

      // Stop the processing/loading indicator in case of an error
      /*setState(() {
        _isProcessing = false;
      });*/
    }
  }

  @override
  void initState() {
    super.initState();
    //Personal
    _fetchUserData();
    //Current
    _getCurrentDate();
    _getCurrentTime();
    //Animation
     _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        curve: Curves.easeInOut,
        parent: _slideController,
      ),
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = AlwaysStoppedAnimation<double>(1);
    // Start the animations
    _slideController.forward();
    _fadeController.forward();
    _updateDateTime(); // Fetch and start updating date/time
    _requestLocationPermission();//LocationPermission
    _listenToAttendanceChanges();
  }

  

  @override
  void dispose() {
    // Stop listening to position updates when the widget is disposed
    // This prevents calling setState() on a disposed widget
    Geolocator.getPositionStream().listen((Position position) {}).cancel();
    _stopListenerRefresh(); // Stop the timer when the widget is disposed
    _attendanceStream?.cancel(); // Cancel the stream subscription;
    _validateTimer?.cancel();
    _stopDateTimeUpdates(); // Stop the timer when the widget is disposed
    _slideController.dispose();
    _fadeController.dispose();
    // Revert database changes if the process is still ongoing when the user exits the page
    if(_isProcessing){
      _revertOrRemoveDocuments();
    }
    super.dispose();
  }




  



 void _revertOrRemoveDocuments() async {
    if (_recentlyCheckInDoc != null) {
      // Remove the recently added document
      await _recentlyCheckInDoc!.delete();
      _recentlyCheckInDoc = null; // Reset reference after removal
    }
    if (_recentlyCheckOutDoc != null) {
      // Revert the recently changed document
      await _recentlyCheckOutDoc!.reference.set(_recentlyCheckOutDoc!.data()!);
      _recentlyCheckOutDoc = null; // Reset reference after revert
    }
  }
 
 /*void _checkLatestRecordStatus({required bool expectedStatus}) {
    _validateTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      DocumentReference latestAttendanceDoc = await _getLatestAttendanceDoc();
      
      var latestDocData = (await latestAttendanceDoc.get()).data();
      
      // Log the latest attendance document after check-in or check-out
      var metadata = (await latestAttendanceDoc.get()).metadata;
     // Check metadata for source information
    if (metadata.isFromCache) {
      logger.d('Data retrieved from local cache');
    } else {
      logger.d('Data retrieved from server');
    }

      bool latestRecordStatus = !(latestDocData != null &&
          latestDocData is Map<String, dynamic> &&
          latestDocData.containsKey('CheckOutTime'));

      if (latestRecordStatus == expectedStatus) {
        timer.cancel(); // Stop the timer if the expected status is reached
        setState(() {
          _isProcessing = false; // Reset the processing flag
          _recentlyCheckInDoc = null;
          _recentlyCheckOutDoc = null;
        });
      } else {
        print('Latest record status does not match the expected status');
        // Optionally add a delay before the next check
        // await Future.delayed(Duration(seconds: 5));
      }
    });
  }*/



Future<void> _checkLatestRecordStatus({required bool? expectedStatus}) async {
  //while (true) {
    // Compare the global variable directly with the expected status
      if (_isCheckedIn == expectedStatus) {
        setState(() {
          _isProcessing = false; // Reset the processing flag
          _recentlyCheckInDoc = null;
          _recentlyCheckOutDoc = null;
          expectedStatus = null;
        });
      } else {
        print('Latest record status does not match the expected status');
        // Optionally add a delay before the next check
        // await Future.delayed(Duration(seconds: 5));
      }
 // }
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
        centerTitle: true, // this is all you ne
        title: Text(
        'Attendance',
        ),
        backgroundColor: Colors.purpleAccent, // Customize app bar color
        elevation: 0, // Remove app bar shadow
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
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 500),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:[
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(width: 4),
                                            Text(
                                              'CURRENT',
                                              style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              letterSpacing: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children:[
                                            Icon(
                                              Icons.calendar_today, // Calendar icon
                                              color: Colors.grey,
                                              size: 18,
                                            ),
                                            Text(
                                              _currentDate,
                                              key: Key(_currentDate), // Needed for AnimatedSwitcher
                                              style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                                shadows: [
                                                  Shadow(
                                                    blurRadius: 4,
                                                    color: Colors.black.withOpacity(0.2),
                                                    offset: Offset(2, 2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                            ),
                                              FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child:Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                                children:[
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.access_time, // Time icon
                                        color: Colors.grey,
                                        size: 18,
                                      ),
                                      SizedBox(width: 4),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text(
                                          _currentTime,
                                          key: Key(_currentDate), // Needed for AnimatedSwitcher
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 4,
                                                color: Colors.black.withOpacity(0.2),
                                                offset: Offset(2, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]   
                                  )
                                ],
                              ),
                            )
                          )
                        ]
                      )
                    ),
                  Container(
                    height: 200.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
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
                  Text(
                    'Location: $_locationName',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Address: $_address',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  userData != null?
                    _buildEmployeeRectangle(context):
                    CircularProgressIndicator(),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children:[
                        //Transparent circle that appears briefly when the button is clicked
                        AnimatedOpacity(
                          opacity: _showCircle ?1.0:0.0,
                          duration: Duration(milliseconds: 500),
                          child: Container(
                            width: 210.0,
                            height: 210.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:  _isCheckedIn ? Colors.red.withOpacity(0.5):Colors.green.withOpacity(0.5)
                            ),
                          ),
                        ),
                        SizedBox(
                        width: 200.0,
                        height: 200.0,
                        child: ElevatedButton(
                          onPressed: _checkInOut,
                          child: Text(
                            _isCheckedIn ? 'Check Out' : 'Check In',
                            style: TextStyle(fontSize: 28.0),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(24.0),
                            elevation: 5.0, // Add elevation for a shadow effect
                            primary: _isCheckedIn ? Color.fromARGB(255, 150, 57, 57) : Color.fromARGB(255, 51, 147, 92) , // Transparent background
                            onPrimary: _isCheckedIn ? Colors.white : Colors.white, // Text color
                            shadowColor: Colors.black, // Shadow color
                            side: BorderSide(
                              width: 1.0, // Border width
                              color: _isCheckedIn ? const Color.fromARGB(255, 241, 91, 80) : const Color.fromARGB(255, 73, 186, 77), // Border color
                            ),
                          ),
                        ),
                      ),
                      ]
                    )
                      
                    ),
                  SizedBox(height: 20),
                  // Add other widgets and components as needed
                ],//Column Children
              ),
            ),
          ),
          if (_isProcessing && (initialButtonState == _isCheckedIn))
            DarkOverlay(), // Your processing overlay widget
        ],
      ),
    );
  }

Widget _buildDarkOverlay() {
  bool _Error = false;
  //Timer to handle the duration of the progress indicator
  Timer(Duration(seconds: 10),(){
    setState(){
      _Error = true;
    }
  });
  return Container(
    color: Colors.black.withOpacity(0.5),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 20), // Adjust the spacing as needed
        if (_Error)
            Text(
              'Feature is currently unavailable.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          if (!_Error)
            Text(
              'Recording in progress...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
      ],
    ),
  );
}

Widget _buildEmployeeRectangle(BuildContext context) {
        return Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    userData!['image'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey,
                          ),
                          Text(
                            'No Image',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 10), // Spacer
              // Gray round board with user's name
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300], // Gray color
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                padding: EdgeInsets.all(10), // Padding around the text
                child: Text(
                  userData!['name']!, // Assuming 'name' exists in userData
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
buildAttendanceTable(previousAttendanceData)
            ],
          ),
        );
      }

/*Container buildTableCell(String text, Color textColor, Color bgColor) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          bgColor.withOpacity(0.9),
          bgColor.withOpacity(0.7),
        ],
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 16,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}*/

Widget buildAttendanceTable(Map<String, dynamic>? attendanceData) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: attendanceData?.isNotEmpty == true
        ? [
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Check In',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'Check Out',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                },
                border: TableBorder.all(color: Colors.transparent),
                children: [
                  TableRow(
                    children: [
                      buildTableCheckInCell(
                        '${attendanceData!['CheckInTime']}',
                        Colors.white,
                        Color.fromARGB(255, 87, 178, 118),
                      ),
                      buildTableCheckOutCell(
                        '${attendanceData['CheckOutTime']}',
                        Colors.white,
                        Color.fromARGB(255, 183, 90, 97),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ]
        : [Text('No previous attendance data')],
  );
}

Container buildTableCheckInCell(String text, Color textColor, Color bgColor) {
  return Container(
    padding: EdgeInsets.only(right:16),
    decoration: BoxDecoration(
      color: bgColor.withOpacity(0.5),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        textAlign: TextAlign.left,
      ),
    ),
  );
}

Container buildTableCheckOutCell(String text, Color textColor, Color bgColor) {
  return Container(
    padding: EdgeInsets.only(left:16),
    decoration: BoxDecoration(
      color: bgColor.withOpacity(0.5),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        textAlign: TextAlign.left,
      ),
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

class DarkOverlay extends StatefulWidget {
  @override
  _DarkOverlayState createState() => _DarkOverlayState();
}

class _DarkOverlayState extends State<DarkOverlay> {
  bool _error = false;

  @override
  void initState() {
    super.initState();
    // Timer to handle the duration of the progress indicator
    Timer(Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _error = true;
        });
      }
    });
  }

  void _restartApp() {
    // Your logic to restart the app
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  void _leavePage() {
    // Your logic to leave the current page
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
             valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Customize color
          ),
          SizedBox(height: 20), // Adjust the spacing as needed
          if (_error)
            Column(
              children: [
                Text(
                  'Feature is currently unavailable.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _restartApp,
                  child: Text('Restart the App'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // Change button color
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _leavePage,
                  child: Text('Leave the Page'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue, // Change button color
                  ),
                ),
              ],
            ),
          if (!_error)
            Text(
              'Recording in progress...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }
}
