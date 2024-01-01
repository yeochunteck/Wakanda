import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/all_profile_page.dart';
import 'package:flutter_application_1/Leave_main_page.dart';
import 'package:flutter_application_1/Claim_main_page.dart';
import 'package:flutter_application_1/making_attendance.dart';
import 'package:logger/logger.dart';
import 'package:flutter_application_1/salary_page.dart';
import 'package:flutter_application_1/login_page.dart';
import 'package:flutter_application_1/profile_page.dart';
import 'package:flutter_application_1/create_user_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/data/repositories/profile_repository.dart';
import 'package:flutter_application_1/data/repositories/announcement_repository.dart';

import 'package:flutter_application_1/user_management_page.dart';
//import 'package:flutter_application_1/Leave_main_page.dart';
import 'package:flutter_application_1/Apply_FullLeave_page.dart';
import 'package:flutter_application_1/managerPart/checkPendingLeave.dart';
import 'package:flutter_application_1/managerPart/checkPendingClaim.dart';
import 'package:flutter_application_1/Announcement.dart';
import 'package:flutter_application_1/attendance_view.dart';

import 'package:flutter_application_1/salary_management_page.dart';
import 'package:flutter_application_1/view_salary_page.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainPage extends StatefulWidget {
  final String companyId;
  final String userPosition;
  // final user = FirebaseAuth.instance.currentUser!;

  MainPage({Key? key, required this.companyId, required this.userPosition})
      : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final logger = Logger();
  ProfileRepository profileRepository = ProfileRepository();
  String imageUrl = "";
  String userName = "";
  String companyId = "";
  String userPosition = "";
  Map<String, dynamic>? attendanceDataInMainPage;
  //late AttendancePageManager _attendancePageManager;
  //late AttendancePage _attendancePage;
  StreamSubscription <QuerySnapshot>? _attendanceStream;
  String _currentDate= '';

  

    //getCurrentDateTime
  Future<void> _getCurrentDate() async {
    DateTime now = DateTime.now();
    _currentDate = '${now.day}-${now.month}-${now.year}';
  }
  
  void listenToAttendanceChanges(){
    _attendanceStream = _attendanceStream = FirebaseFirestore.instance
        .collection('Attendance')
        .doc(widget.companyId)
        .collection(_currentDate)
        .orderBy('CheckInTime', descending: true)
        .snapshots(includeMetadataChanges: true)
        .listen((QuerySnapshot snapshot) {

          if(snapshot.docs.isNotEmpty){
            setState((){
            attendanceDataInMainPage = snapshot.docs.first.data() as Map<String, dynamic> ;
            });
            print("data:${attendanceDataInMainPage}");
                if (attendanceDataInMainPage != null &&
          attendanceDataInMainPage!.containsKey('CheckInTime') &&
          attendanceDataInMainPage!.containsKey('CheckOutTime'))
          print("condition is achieved");
            
          }
        });

  }

  @override
  void initState() {
    super.initState();
    /*profileRepository
        .getUserProfileImage(widget.companyId)
        .then((value) => setState(() {
              imageUrl = value;
            }));*/
    
    
    //_attendancePageManager = AttendancePageManager();
    //_attendancePageManager.initialize(); // Initialize _AttendancePageState
    //_attendancePageManager.getAttendanceData();
    //_attendancePage = AttendancePage(companyId: widget.companyId);
    //final attendanceState=_attendancePage.createState();
    _getCurrentDate();
    listenToAttendanceChanges();
  

/*WidgetsBinding.instance!.addPostFrameCallback((_) {
  // Accessing method or variable using the key and checking for null
    var attendanceState = attendancePageKey.currentState!;
    attendanceState.listenToAttendanceChanges();
    print('hahaha');
    attendanceDataInMainPage = attendanceState.previousAttendanceData;
});*/

    print(attendanceDataInMainPage);

    profileRepository
        .getNameByCompanyId(widget.companyId)
        .then((value) => setState(() {
              userName = value;
            }));
    companyId = widget.companyId;
    userPosition = widget.userPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(
          229, 63, 248, 1), // Set your desired background color here,
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Purple',
              style: TextStyle(
                color: Colors.pink,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Fashion',
              style: TextStyle(
                color: Colors.purple,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor:
            Colors.white, // Set the background color to transparent
        elevation: 0, // Remove the shadow
        iconTheme: const IconThemeData(
            color: Colors.black, size: 30), // Set the icon color to black

        actions: [
          // Profile icon on the right
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              logger.i('companyID:${widget.companyId}');
              //Use navigator push to link to profile page
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(companyId: widget.companyId)),
              );
              // Handle profile icon pressed
            },
          ),
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu), // Settings icon on the left
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Open the drawer
              },
            );
          },
        ),
        centerTitle: true,
      ),
      drawer: MyDrawer(
          companyId: widget.companyId,
          nameFuture: ProfileRepository().getNameByCompanyId(widget.companyId),
          userPosition: widget.userPosition),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 16.0), // Add bottom margin
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.start, // Align the column to the bottom
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ), // Add a SizedBox with height for top margin
            Column(
              children: [
                CircleAvatar(
                  radius: 70,
                  /*child: FutureBuilder<String>(
                    future: profileRepository.getUserProfileImage(widget
                        .companyId), // Replace companyId with the actual companyId
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Show a loading indicator while fetching the image
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        // Handle the error state
                        return Text('Error loading image');
                      } else {
                        // Image has been successfully fetched
                        String imageUrl = snapshot.data ??
                            ''; // Default to empty string if null

                        return imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(70),
                                child: Image.network(
                                  '$imageUrl',
                                  width: 140,
                                  height: 140,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  double iconSize = constraints.maxWidth >
                                          constraints.maxHeight
                                      ? constraints.maxHeight * 0.5
                                      : constraints.maxWidth * 0.5;

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: iconSize,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'No Image',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: iconSize * 0.25,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                      }
                    },
                  ),*/
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 5),
                    Icon(
                      Icons.credit_card,
                      size: 20,
                      color: Colors.black,
                    ),
                    SizedBox(width: 5),
                    // Company ID
                    Text(
                      widget.companyId,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.02), // Add spacing between CircleAvatar and Text
            if (widget.userPosition != "Manager")
              Container(
  width: double.infinity,
  padding: EdgeInsets.all(16.0),
  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(32.0),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 2,
        blurRadius: 4,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Attendance Overview',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
      if (attendanceDataInMainPage != null)
        Column(
          children: [
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'In',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Container(
              padding: EdgeInsets.symmetric(horizontal:12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Colors.grey[200],
              ),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    _formatTime(attendanceDataInMainPage!['CheckInTime']),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    _getPeriod(attendanceDataInMainPage!['CheckInTime']),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ), 

          ),
          
        ],
      ),
    ),
    SizedBox(width: 16), 
    // Add spacing between columns
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Out',
            style: TextStyle(
              color: const Color.fromRGBO(229, 63, 248, 1),
              fontSize: 16.0,
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Container(
  padding: EdgeInsets.symmetric(horizontal:12.0),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16.0),
    color: Colors.grey[200],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Text(
        _formatTime(attendanceDataInMainPage!['CheckOutTime']),
        style: TextStyle(
          color: const Color.fromRGBO(229, 63, 248, 1),
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(width: 4),
      Text(
        _getPeriod(attendanceDataInMainPage!['CheckOutTime']),
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12.0,
          fontWeight: FontWeight.normal,
        ),
      ),
    ],
  ),
)

        ],
      ),
    ),
  ],
),






            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          ],
        )
      else
        Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                'Get Ready to Rock!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Text(
                'You haven\'t Clock In Yet!',
                style: TextStyle(
                  color: const Color.fromRGBO(229, 63, 248, 1),
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            ],
          ),
        ),
    ],
  ),
),


            AnnouncementContainer(
              userPosition: widget.userPosition,
              // announcements:
              //     getCompanyAnnouncements(), // Replace with your actual function to fetch announcements
            ),

            // Container(
            //   width: double.infinity,
            //   padding: EdgeInsets.all(16.0),
            //   margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            //   decoration: BoxDecoration(
            //     color: Colors.white, // Adjust the color as needed
            //     border: Border.all(color: Colors.grey), // Border color
            //     borderRadius:
            //         BorderRadius.circular(32.0), // Adjust the border radius
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.grey.withOpacity(0.5), // Shadow color
            //         spreadRadius: 2,
            //         blurRadius: 4,
            //         offset: Offset(0, 4), // Offset in the y-axis
            //       ),
            //     ],
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         'Announcement',
            //         style: TextStyle(
            //           color: Colors.black,
            //           fontSize: 18.0,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //       SizedBox(height: 24.0), // Add vertical space
            //       Row(
            //         children: [
            //           // Left side: Display Time
            //           Text(
            //             '12:00 PM', // Replace with the actual time or use a variable for dynamic time
            //             style: TextStyle(
            //               color: Colors.black,
            //               fontSize: 16.0,
            //               fontWeight: FontWeight.normal,
            //             ),
            //           ),
            //           SizedBox(
            //               width:
            //                   16.0), // Add horizontal space between time and announcement

            //           // Right side: Display announcement title and content
            //           Container(
            //             width: MediaQuery.of(context).size.width *
            //                 0.6, // Adjust the width as needed
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Text(
            //                   "title",
            //                   // announcement['title'],
            //                   style: TextStyle(
            //                     color: Colors.black,
            //                     fontSize: 20.0,
            //                     fontWeight: FontWeight.bold,
            //                   ),
            //                 ),
            //                 SizedBox(height: 8.0), // Add vertical space
            //                 Text(
            //                   "content",
            //                   // announcement['content'],
            //                   style: TextStyle(
            //                     color: const Color.fromRGBO(229, 63, 248, 1),
            //                     fontSize: 16.0,
            //                     fontWeight: FontWeight.normal,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: 16.0), // Add vertical space
            //     ],
            //   ),
            // ),
            // SizedBox(height: MediaQuery.of(context).size.height * 0.15),
            // Row of Rectangles
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      buildRectangle(
                        context,
                        Icon(Icons.notifications),
                        'Notification',
                        widget.companyId,
                        widget.userPosition,
                      ),
                      SizedBox(width: 12),
                      buildRectangle(
                        context,
                        Icon(Icons.calendar_today),
                        'Leave',
                        widget.companyId,
                        widget.userPosition,
                      ),
                      SizedBox(width: 12),
                      if (userPosition != "Manager")
                        buildBiggerRectangle(
                          context,
                          Icon(Icons.qr_code_scanner),
                          'Attendance',
                          widget.companyId,
                          widget.userPosition,
                        ),
                      if (userPosition == "Manager")
                        buildBiggerRectangle(
                          context,
                          Icon(Icons.manage_accounts),
                          'Management',
                          widget.companyId,
                          widget.userPosition,
                        ),
                      SizedBox(width: 12),
                      buildRectangle(
                        context,
                        Icon(Icons.attach_money),
                        'Salary',
                        widget.companyId,
                        widget.userPosition,
                      ),
                      SizedBox(width: 12),
                      buildRectangle(
                        context,
                        Icon(Icons.request_page),
                        'Claim',
                        widget.companyId,
                        widget.userPosition,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildRectangle(BuildContext context, Icon icon, String label,
    String companyId, String userPosition) {
  return GestureDetector(
    onTap: () {
      if (label == 'Notification') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AnnouncementPage(
                  userPosition: userPosition, companyId: companyId)),
        );
      } else if (label == 'Leave') {
        if (userPosition == 'Manager') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CheckPendingLeave(
                    companyId: companyId, userPosition: userPosition)),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LeavePage(
                    companyId: companyId, userPosition: userPosition)),
          );
        }
      } else if (label == 'Salary') {
        if (userPosition == 'Manager') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SalaryManagementPage()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewSalaryPage(
                      companyId: companyId,
                      selectedMonth: DateTime.now(),
                    )),
          );
        }
      } else if (label == 'Claim') {
        if (userPosition == 'Manager') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CheckPendingClaim(
                    companyId: companyId, userPosition: userPosition)),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ClaimPage(
                    companyId: companyId, userPosition: userPosition)),
          );
        }
      }
    },
    child: Column(
      children: [
        Container(
          width: (MediaQuery.of(context).size.width * 0.15),
          height: (MediaQuery.of(context).size.width * 0.15),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: Icon(
              icon.icon,
              size: (MediaQuery.of(context).size.width * 0.11),
            ),
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget buildBiggerRectangle(BuildContext context, Icon icon, String label,
    String companyId, String userPosition) {
  return GestureDetector(
    onTap: () {
      if (label == 'Attendance' && userPosition != "Manager") {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AttendancePage(companyId: companyId)),
        );
      } else if (label == 'Management' && userPosition == "Manager") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserManagementPage()),
        );
      }
    },
    child: Column(
      children: [
        Container(
          width: (MediaQuery.of(context).size.width * 0.15),
          height: (MediaQuery.of(context).size.width * 0.15),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Center(
            child: Icon(
              icon.icon,
              size: (MediaQuery.of(context).size.width * 0.11),
            ),
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

String _formatTime(String? timeString) {
  if (timeString != null && timeString.isNotEmpty) {
    List<String> timeComponents = timeString.split(':');
    if (timeComponents.length >= 2) {
      int hour = int.parse(timeComponents[0]);
      int minute = int.parse(timeComponents[1]);

      String period = 'AM';
      if (hour >= 12) {
        period = 'PM';
        if (hour > 12) {
          hour -= 12;
        }
      }
      if (hour == 0) {
        hour = 12;
      }

      return '$hour:${timeComponents[1]}';
    }
  }
  return '--:--';
}

String _getPeriod(String? timeString) {
  if (timeString != null && timeString.isNotEmpty) {
    List<String> timeComponents = timeString.split(':');
    if (timeComponents.length >= 2) {
      int hour = int.parse(timeComponents[0]);
      return (hour >= 12) ? 'PM' : 'AM';
    }
  }
  return 'AM/PM'; // Display AM if time is null or empty
}



String formatTimestamp(String timestamp) {
  // Assuming timestamp is a String in a standard format
  DateTime dateTime = DateTime.parse(timestamp);

  // Format the DateTime as needed (e.g., 'dd MMM HH:mm')
  return DateFormat('dd MMM').format(dateTime);
}

class MyDrawer extends StatelessWidget {
  final String companyId;
  final Future<String> nameFuture;
  final String userPosition;

  MyDrawer(
      {Key? key,
      required this.companyId,
      required this.nameFuture,
      required this.userPosition})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(229, 63, 248, 1),
            ),
            child: FutureBuilder<String>(
              future: nameFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10), // Adjust the height as needed
                        Text('Loading...'),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error loading name');
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        snapshot.data ?? "Guest",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          ListTile(
            title: const Text(
              'Home',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: const Icon(Icons.home),
            onTap: () {
              // Handle navigation to MainPage()
              Navigator.pop(context); // Close the drawer
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => MainPage(companyId: widget.companyId, )),
              // );
            },
          ),
          ListTile(
            title: const Text(
              'Attendance',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: const Icon(Icons.check_circle_outline),
            onTap: () {
              // Handle navigation to MainPage()
              Navigator.pop(context);
              // Close the drawer
              if (userPosition == 'Manager') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AttendanceView()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AttendancePage(companyId: companyId)),
                );
              }
            },
          ),
          ListTile(
            title: const Text(
              'Leave',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: const Icon(Icons.calendar_today),
            onTap: () {
              // Handle navigation to MainPage()
              Navigator.pop(context); // Close the drawer
              if (userPosition == 'Manager') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CheckPendingLeave(
                          companyId: companyId, userPosition: userPosition)),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LeavePage(
                          companyId: companyId, userPosition: userPosition)),
                );
              }
            },
          ),
          ListTile(
            title: const Text(
              'Claim',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: const Icon(Icons.request_page),
            onTap: () {
              // Handle navigation to MainPage()
              Navigator.pop(context); // Close the drawer
              if (userPosition == 'Manager') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CheckPendingClaim(
                          companyId: companyId, userPosition: userPosition)),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ClaimPage(
                          companyId: companyId, userPosition: userPosition)),
                );
              }
            },
          ),
          ListTile(
            title: const Text(
              'Salary',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: const Icon(Icons.attach_money),
            onTap: () {
              // Handle navigation to MainPage()
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SalaryPage()),
              );
            },
          ),
          ListTile(
            title: const Text(
              'Notification',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: const Icon(Icons.notifications),
            onTap: () {
              // Handle navigation to MainPage()
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AnnouncementPage(
                        userPosition: userPosition, companyId: companyId)),
              );
            },
          ),
          ListTile(
            title: Text(
              'User Management',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: Icon(Icons.manage_accounts),
            onTap: () {
              // Handle navigation to MainPage()
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserManagementPage()),
              );
            },
          ),
          // Divider for visual separation
          Divider(),
          ListTile(),

          ListTile(
            title: Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: Icon(Icons.logout),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AnnouncementContainer extends StatelessWidget {
  final String userPosition;

  AnnouncementContainer({Key? key, required this.userPosition})
      : super(key: key);
  // final Future<List<Map<String, String>>> announcements; // Change the data type

  // AnnouncementContainer({required this.announcements});
  @override
  Widget build(BuildContext context) {
    double containerHeight = 200.0;
    int itemshow = 3;
    if (userPosition == 'Manager') {
      containerHeight = 400.0;
      itemshow = 6;
    }
    return FutureBuilder<List<Map<String, String>>>(
      future: getCompanyAnnouncements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error loading announcements');
        } else {
          List<Map<String, String>> announcementList = snapshot.data ?? [];

          List<Map<String, String>> displayedAnnouncements =
              announcementList.reversed.take(itemshow).toList();

          return Column(
            children: [
              Container(
                height: containerHeight, // Set the fixed height as needed

                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(32.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Announcement',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 24.0),
                      Column(
                        children: displayedAnnouncements.map((announcement) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                formatTimestamp(
                                    announcement['timestamp'] ?? ''),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${announcement['title']}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      '${announcement['content']}',
                                      style: TextStyle(
                                        color: const Color.fromRGBO(
                                            229, 63, 248, 1),
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}


