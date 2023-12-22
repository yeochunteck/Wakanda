import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_application_1/data/repositories/profile_repository.dart';
import 'package:flutter_application_1/profile_page.dart';

class SalaryPage extends StatelessWidget {
  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(229, 63, 248, 1),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
          size: 30,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Salary Page',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // Month and Calendar Icon
// Padding around the Center widget
          Padding(
            padding: const EdgeInsets.all(16.0), // Adjust the padding as needed
            child: Center(
              child: Container(
                width: 160, // Adjust the width as needed
                decoration: BoxDecoration(
                  color: Colors.grey[300], // Set the background color to grey
                  // border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Month-Year Text
                    Text(
                      'Month-Year',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromRGBO(229, 63, 248, 1),
                      ),
                    ),
                    SizedBox(width: 10),

                    // Calendar Icon
                    GestureDetector(
                      onTap: () {
                        // Handle calendar icon tap
                        // You can implement logic to fetch and display salary details
                        // for the selected month
                        // You may want to navigate to a SalaryDetailsPage or show a dialog
                        // with salary details for the selected month
                      },
                      child: Icon(
                        Icons.calendar_today,
                        size: 30,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Employee Rectangles
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: ProfileRepository().getAllUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No users found'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final userData = snapshot.data![index];
                      return buildEmployeeRectangle(context, userData);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmployeeRectangle(
      BuildContext context, Map<String, dynamic> userData) {
    return GestureDetector(
      onTap: () {
        // Navigate to the ProfilePage with the selected companyId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(companyId: userData['companyId']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Left side: Employee details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${userData['name']}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: const Color.fromRGBO(229, 63, 248, 1)),
                  ),
                  SizedBox(height: 20), // Add space between Name and Position

                  Text(
                    '${userData['position']}',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),

                  // Add more details as needed
                ],
              ),
            ),

            // Right side: Profile image
            SizedBox(width: 16),
            Column(
              children: [
                // Profile image
                CircleAvatar(
                  radius: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      userData['image'] ?? '',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Handle errors, e.g., display a default icon
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
                SizedBox(height: 5),
                // Identity card icon and company ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Identity card icon
                    Icon(
                      Icons.credit_card,
                      size: 20,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 5), // Add space between icon and company ID
                    // Company ID
                    Text(
                      '${userData['companyId']}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
