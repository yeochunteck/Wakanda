import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_application_1/login_page.dart';
import 'package:flutter_application_1/profile_page.dart';
import 'package:flutter_application_1/Apply_FullLeave_page.dart';

class MainPage extends StatefulWidget {
  final String companyId;

  const MainPage({Key? key, required this.companyId}) : super(key: key);

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
        title: Container(
          child: Row(
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
            // Add more widgets and functionality for your main page here
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ApplyLeave(companyId: widget.companyId)),
                );
              },
              child: Row(
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
                logger.i('companyID:' + widget.companyId);
                //Use navigator push to link to profile page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(companyId: widget.companyId)),
                );
              },
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 10),
                  Text('Logout'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
