import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_application_1/login_page.dart';
import 'package:flutter_application_1/create_user_page.dart';
import 'package:flutter_application_1/profile_page.dart';
import 'package:flutter_application_1/Apply_FullLeave_page.dart';
import 'package:flutter_application_1/managerPart/checkPendingLeave.dart';
import 'package:flutter_application_1/Apply_Claim_page.dart';
import 'package:flutter_application_1/managerPart/checkPendingClaim.dart';

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
        iconTheme: IconThemeData(
            color: Colors.black, size: 30), // Set the icon color to black

        actions: [
          // Profile icon on the right
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              logger.i('companyID:' + widget.companyId);
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
              icon: Icon(Icons.settings), // Settings icon on the left
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
            if (widget.userPosition != 'Manager')
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ApplyLeave(
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
            if (widget.userPosition != 'Manager')
              ElevatedButton(
                onPressed: () {
                  // logger.i('companyID:' + widget.companyId);
                  //Use navigator push to link to profile page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ApplyClaim(
                              companyId: widget.companyId,
                              userPosition: widget.userPosition,
                            )),
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 10),
                    Text('Apply Claim'),
                  ],
                ),
              ),

            //Profile Page
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                logger.i('companyID:' + widget.companyId);
                //Use navigator push to link to profile page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(companyId: widget.companyId)),
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

            const SizedBox(height: 20),
            //If userPosition is Manager then show
            if (widget.userPosition == 'Manager')
              ElevatedButton(
                onPressed: () {
                  // Navigate to the create new user page
                  // Replace `CreateNewUserPage` with the actual name of your page
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
            if (widget.userPosition == 'Manager')
              ElevatedButton(
                onPressed: () {
                  // Navigate to the create new user page
                  // Replace `CreateNewUserPage` with the actual name of your page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CheckPendingClaim(
                            companyId: widget.companyId,
                            userPosition: widget.userPosition)),
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 10),
                    Text('Check Claim'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
