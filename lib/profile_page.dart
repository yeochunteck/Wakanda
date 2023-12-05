import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:flutter_application_1/login_page.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';

import 'package:flutter_application_1/data/repositories/profile_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatelessWidget {
  final String companyId;

  ProfilePage({Key? key, required this.companyId}) : super(key: key);

  final logger = Logger();

  String _formatDate(Timestamp timestamp) {
    // Convert Timestamp to DateTime
    DateTime dateTime = timestamp.toDate();

    // Format DateTime to display only the date
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, //Solve Bottom overflow

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
      body: FutureBuilder<Map<String, dynamic>>(
        future: ProfileRepository().getUserData(companyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading indicator while fetching data
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            // Handle error
            logger.e('Error fetching user data: ${snapshot.error}');
            return const Center(
              child: Text('An error occurred. Please try again later.'),
            );
          }

          // User data found
          final userData = snapshot.data;
          // final imageUrl =
          //     userData?['image']; // Replace 'image' with the actual field name
          final imageUrl = userData?['image'] ?? '';
          logger.i(imageUrl);
          return Stack(
            children: [
              // Purple background
              Container(
                height: MediaQuery.of(context).size.height * 0.2,
                color: const Color.fromRGBO(229, 63, 248, 1),
              ),
              // White background with CircleAvatar

              Container(
                height: MediaQuery.of(context).size.height * 0.17,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(229, 63, 248, 1),
                  // image: DecorationImage(
                  //   fit: BoxFit.cover,
                  //   image: imageUrl!.isNotEmpty
                  //       ? FileImage(File(imageUrl))
                  //       : AssetImage('assets/images/logo.png')
                  //           as ImageProvider<Object>,
                  // ),
                ),
                // child: const Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                    radius: 70,
                    // backgroundColor: Colors.grey[300],
                    child: imageUrl != ''
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(70),
                            child: Image.network('${imageUrl}',
                                width: 140, height: 140, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            //Person Icon
                            children: const [
                              Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              ),
                              Text(
                                'No Image',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          )),
              ),
              // ),

              // Overlay with profile information
              // Wrap the Column with Padding to add top padding
              Container(
                // height: MediaQuery.of(context).size.height * 1,
                // padding: EdgeInsets.all(top: 10),
                // padding: EdgeInsets.all(75),
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height *
                      0.08, // Adjust the vertical padding as needed
                  horizontal: 75, // Adjust the horizontal padding as needed
                ),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Name',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${userData?['name']}',
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      const Divider(
                        thickness: 2,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Email',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${userData?['email']}',
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      const Divider(
                        thickness: 2,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Phone',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${userData?['phone']}',
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      const Divider(
                        thickness: 2,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Gender',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${userData?['gender']}',
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      const Divider(
                        thickness: 2,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Date of Birth',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _formatDate(userData?['dateofbirth']),
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      const Divider(
                        thickness: 2,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Position',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${userData?['position']}',
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      const Divider(
                        thickness: 2,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
