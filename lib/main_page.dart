import 'package:flutter/material.dart';
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
import 'package:flutter_application_1/user_management_page.dart';
//import 'package:flutter_application_1/Leave_main_page.dart';
import 'package:flutter_application_1/Apply_FullLeave_page.dart';
import 'package:flutter_application_1/managerPart/checkPendingLeave.dart';
import 'package:flutter_application_1/managerPart/checkPendingClaim.dart';
import 'package:flutter_application_1/Announcement.dart';
import 'package:flutter_application_1/attendance_view.dart';


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          nameFuture: ProfileRepository().getNameByCompanyId(
              widget.companyId),
              userPosition: widget.userPosition
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
                FirebaseAuth.instance.signOut();
                logger.i('Sign out');
                Navigator.pushReplacement(
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
            //If userPosition is Manager then show
            if (widget.userPosition == 'Manager')
              ElevatedButton(
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
              ),
          ],
        ),
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  final String companyId;
  final Future<String> nameFuture;
  final String userPosition;

  MyDrawer({Key? key, required this.companyId, required this.nameFuture,required this.userPosition})
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
              if(userPosition == 'Manager'){
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => AttendanceView()),
               );
              }else{
                Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => AttendancePage(companyId: companyId)),
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
              if(userPosition == 'Manager'){
                Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => CheckPendingLeave(
                            companyId: companyId,
                            userPosition: userPosition)),
               );
              }
              else{
                Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => LeavePage(
                            companyId: companyId,
                            userPosition: userPosition)),
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
              if(userPosition == 'Manager'){
                Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => CheckPendingClaim(
                            companyId: companyId,
                            userPosition: userPosition)),
               );
              }
              else{
                Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => ClaimPage(
                            companyId: companyId,
                            userPosition: userPosition)),
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
                 MaterialPageRoute(builder: (context) =>  AnnouncementPage(userPosition: userPosition, companyId: companyId)),
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
          // Add more ListTile widgets for additional pages
        ],
      ),
    );
  }
}
