import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:flutter_application_1/login_page.dart';

class ProfilePage extends StatelessWidget {
  final String companyId;

  ProfilePage({Key? key, required this.companyId}) : super(key: key);

  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(
            229, 63, 248, 1), // Set the background color to transparent
        elevation: 0, // Remove the shadow
        iconTheme: const IconThemeData(
            color: Colors.black, size: 30), // Set the icon color to black
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black), // Set title color to black
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false, // Remove all routes below the new route
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Purple background
          Container(
              height: MediaQuery.of(context).size.height *
                  0.2, // Adjust the height as needed
              color: const Color.fromRGBO(229, 63, 248, 1)),
          // White background
          Container(
            height: MediaQuery.of(context).size.height *
                0.17, // Adjust the height as needed
            color: const Color.fromRGBO(229, 63, 248, 1),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/images/logo.png'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
