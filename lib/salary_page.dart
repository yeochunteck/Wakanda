import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/data/repositories/profile_repository.dart';
import 'package:flutter_application_1/profile_page.dart';
import 'package:flutter_application_1/edit_profile_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:flutter_application_1/view_salary_page.dart';
import 'package:intl/intl.dart';

class SalaryPage extends StatefulWidget {
  @override
  _SalaryPageState createState() => _SalaryPageState();

  // State variable for basicSalary
  // num basicSalary = 0.0;
}

class _SalaryPageState extends State<SalaryPage> {
  final logger = Logger();
  DateTime? _selected = DateTime.now();

  // Define the TextEditingController
  TextEditingController monthYearController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();

    // Set the initial value to the current month and year
    final DateTime now = DateTime.now();
    monthYearController.text = '${now.month}-${now.year}';
  }

  Future<List<Map<String, dynamic>>> _getFilteredUsers() async {
    final List<String> yearMonth = monthYearController.text.split('-');
    final int selectedYear =
        int.parse(yearMonth[1]); // Assuming year comes first in your format
    final int selectedMonth = int.parse(yearMonth[0]);

    final DateTime selectedDate =
        DateTime(selectedYear, selectedMonth + 1, 0, 23, 59, 59);

    logger.i('Selected Month: $selectedMonth');
    logger.i('Selected Year: $selectedYear');
    logger.i('Selected Date: $selectedDate');

    final QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('joiningdate', isLessThanOrEqualTo: selectedDate)
        .get();

    final List<Map<String, dynamic>> filteredUsers = [];

    for (final QueryDocumentSnapshot userDoc in querySnapshot.docs) {
      final Map<String, dynamic> userData =
          userDoc.data() as Map<String, dynamic>;

      // Fetch the 'salaryHistory' subcollection
      final QuerySnapshot salarySnapshot = await _firestore
          .collection('users')
          .doc(userDoc.id)
          .collection('salaryHistory')
          .orderBy('effectiveDate', descending: true)
          .get();

      // Iterate over the 'salaryHistory' documents (if any)
      for (final QueryDocumentSnapshot salaryDoc in salarySnapshot.docs) {
        final Map<String, dynamic> salaryData =
            salaryDoc.data() as Map<String, dynamic>;

        DateTime effectiveDate = salaryData['effectiveDate'].toDate();
        // Change to UTC+8
        effectiveDate = effectiveDate.add(const Duration(hours: 8));
        logger.i('Effective Date: $effectiveDate');
        logger.i('Current Basic Salary: ${salaryData['basicSalary']}');
        logger.i('EPFNo: ${salaryData['epfNo']}');

        logger.i('Selected Date: $selectedDate');
        logger.i('Comparison Result: ${effectiveDate.isBefore(selectedDate)}');

        // Assuming 'effectiveDate' is a DateTime field in your salary document
        if (salaryData['effectiveDate'] != null &&
            effectiveDate.isBefore(selectedDate)) {
          logger.i("salaryData['effectiveDate'] $salaryData['effectiveDate']");
          // This salary entry is effective within the selected month
          final num basicSalaryTemp = salaryData['basicSalary'] ?? 0.0;
          userData['basicSalary'] = basicSalaryTemp;
          // widget.basicSalary = basicSalaryTemp;
          logger.i(userData['image']);
          // Add the user data with basic salary to the result list
          filteredUsers.add(userData);
          break; // Break the loop since we found the relevant salary entry
        }
      }
    }

    return filteredUsers;
  }

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
            child: GestureDetector(
              onTap: () async {
                // Show date picker and update the text when a date is selected
                DateTime? pickedDate = await showMonthYearPicker(
                  context: context,
                  initialDate: _selected ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  setState(() {
                    _selected = pickedDate;
                    monthYearController.text =
                        '${pickedDate.month}-${pickedDate.year}';
                  });
                }
              },
              child: Center(
                child: Container(
                  width: 160, // Adjust the width as needed
                  decoration: BoxDecoration(
                    color: Colors.grey[300], // Set the background color to grey
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Month-Year Text
                      Text(
                        DateFormat('MMM yyyy').format(
                            _selected!), // Format the selected month and year
                        // monthYearController.text, // Show selected month and year
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(229, 63, 248, 1),
                        ),
                      ),
                      SizedBox(width: 10),

                      // Calendar Icon
                      Icon(
                        Icons.calendar_today,
                        size: 30,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Employee Rectangles
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getFilteredUsers(),
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
                      return buildEmployeeRectangle(
                          context, userData, _selected);
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
      BuildContext context, Map<String, dynamic> userData, selected) {
    logger.i("selected :  $selected");
    return GestureDetector(
      onTap: () async {
        // Navigate to the EditProfilePage with the selected companyId
        final updatedBasicSalary = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewSalaryPage(
                companyId: userData['companyId'], selectedMonth: selected),
          ),
        );

        // Check if there is an updated basicSalary and update the UI
        if (updatedBasicSalary != null) {
          setState(() {
            // Update the 'basicSalary' for the specific user in filteredUsers
            userData['basicSalary'] = updatedBasicSalary;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: <Widget>[
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
                    'Basic Salary',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'RM ${userData['basicSalary'].toString()}',
                    // 'RM ${widget.basicSalary.toString()}',
                    // 'RM ${userData['basicSalary']}',
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color.fromRGBO(229, 63, 248, 1),
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
