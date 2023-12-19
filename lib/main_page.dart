import 'package:flutter/material.dart';
import 'package:flutter_application_1/Leave_main_page.dart';
import 'package:flutter_application_1/making_attendance.dart';
import 'package:logger/logger.dart';
import 'package:flutter_application_1/salary_page.dart';
import 'package:flutter_application_1/login_page.dart';
import 'package:flutter_application_1/profile_page.dart';
import 'package:flutter_application_1/create_user_page.dart';
//import 'package:flutter_application_1/Leave_main_page.dart';
import 'package:flutter_application_1/Apply_FullLeave_page.dart';
import 'package:flutter_application_1/managerPart/checkPendingLeave.dart';
import 'package:flutter_application_1/Announcement.dart';

class MainPage extends StatefulWidget {
  final String companyId;
  final String userPosition;

  const MainPage(
      {Key? key, required this.companyId, required this.userPosition})
      : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('Main Page'),
        // title: Container(
        //   margin: EdgeInsets.only(top: 10), // Adjust the top margin as needed
        //   child: Image.asset(
        //     'assets/images/logo.png',
        //     width: 50,
        //     height: 50,
        //   ),
        // ),
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
            Colors.transparent, // Set the background color to transparent
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
              icon: const Icon(Icons.settings), // Settings icon on the left
              onPressed: () {
                // Handle settings icon pressed
              },
            );
          },
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Add more widgets and functionality for your main page here
            if (widget.userPosition != 'Manager')
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LeavePage(
                            companyId: widget.companyId,
                            userPosition: widget.userPosition)),
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.article),
                    SizedBox(width: 10),
                    Text('Apply Leave'),
                  ],
                ),
              ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 10),
                  Text('Logout'),
                ],
              ),
            ),

            const SizedBox(height: 20),
            if (widget.userPosition == 'Manager')
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CheckPendingLeave(
                            companyId: widget.companyId,
                            userPosition: widget.userPosition)),
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 10),
                    Text('Check Leave'),
                  ],
                ),
              ),
            const SizedBox(height: 20),
                        ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SalaryPage()),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.money),
                  SizedBox(width: 10),
                  Text('Salary Page'),
                ],
              ),
            ),
            const SizedBox(height: 20),
           ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnnouncementPage(userPosition: widget.userPosition, companyId: widget.companyId,)),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.announcement),
                  SizedBox(width: 10),
                  Text('Announcement'),
                ],
              ),
            ),  
          // Using ternary operator to conditionally render the 'Create New User' button
          widget.userPosition == 'Manager'
              ? ElevatedButton(
                  onPressed: () {
                    // Navigate to the create new user page
                    // Replace `CreateNewUserPage` with the actual name of your page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateUserPage()),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 10),
                      Text('Create New User'),
                    ],
                  ),
                )
              :ElevatedButton(
                  onPressed: () {
                    // Navigate to the create new user page
                    // Replace `CreateNewUserPage` with the actual name of your page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AttendancePage(companyId: widget.companyId)),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 10),
                      Text('Making Attendance'),
                    ],
                  ),
                ), // Return an empty container if not a Manager
          ],
        ),
      ),
    );
  }
}
