import 'package:flutter/material.dart';
import 'package:flutter_application_1/main_page.dart';
import 'package:flutter_application_1/half_DayLeave_Page.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:flutter_application_1/models/data_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class processFullLeave extends StatefulWidget {
  final String companyId;
  final String userPosition;

  processFullLeave({Key? key, required this.companyId, required this.userPosition})
      : super(key: key);

  @override
  _processFullLeave createState() => _processFullLeave();
}

// ignore: must_be_immutable
class _processFullLeave extends State<processFullLeave> {
  final logger = Logger();

  List<dynamic> userNameList = [];

  @override
  void initState() {
    super.initState();

    // Fetch user data when the page is initialized
    fetchAllUsersWithLeaveHistory();
  }

  Future<void> fetchAllUsersWithLeaveHistory() async {
    try {
      final List<Map<String, dynamic>> allUsersData =
          await LeaveModel().getUsersWithPendingLeave();

      setState(() {
        if (allUsersData.isNotEmpty) {
          userNameList = allUsersData.map((user) {
            final String name = user['userData']['name'].toString();
            final String leaveType = user['leaveType'].toString();
            final double leaveDay = user['leaveDay'] as double;
            final DateTime startDate = user['startDate'] as DateTime;
            final String reason = user['reason'].toString();
            final String remark = user['remark'].toString();
            final String fullORHalf = user['fullORHalf'].toString();
            final DateTime endDate = user['endDate'] as DateTime;

            final formattedStartDate =
                "${startDate.year}-${startDate.month}-${startDate.day}";
            final formattedEndDate =
                "${endDate.year}-${endDate.month}-${endDate.day}";

            return {
              'name': name,
              'leaveType': leaveType,
              'leaveDay': leaveDay,
              'startDate': formattedStartDate,
              'endDate': formattedEndDate,
            };
          }).toList();
        }
      });
    } catch (e) {
      logger.e('Error fetching all users with leave history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 224, 45, 255),
          title: const Text(
            'Leave Application',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MainPage(
                          companyId: widget.companyId,
                          userPosition: widget.userPosition,
                        )),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: const Text(
                    "Leave Type",
                    style: TextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(255, 224, 45, 255),
                        fontWeight: FontWeight.bold),
                  ),
                ),

                ToggleSwitch(
                  minWidth: 150.0,
                  initialLabelIndex: 0,
                  cornerRadius: 20.0,
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.white,
                  inactiveFgColor: const Color.fromARGB(255, 224, 45, 255),
                  borderColor: const [Colors.grey],
                  borderWidth: 0.5,
                  totalSwitches: 2,
                  labels: const ['Annual', 'Unpaid'],
                  customTextStyles: const [
                    TextStyle(fontSize: 16.0, fontWeight: FontWeight.w900),
                    TextStyle(fontSize: 16.0, fontWeight: FontWeight.w900),
                  ],
                  activeBgColors: const [
                    [Color.fromARGB(255, 224, 45, 255)],
                    [Color.fromARGB(255, 224, 45, 255)]
                  ],
                  // onToggle: (index) {
                  //   if (index == 0) {
                  //     String selectedLabel = 'Annual';
                  //     leaveType = selectedLabel;
                  //   } else if (index == 1) {
                  //     String selectedLabel = 'Unpaid';
                  //     leaveType = selectedLabel;
                  //   }
                  // },
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: const Text(
                    "Full/Half",
                    style: TextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(255, 224, 45, 255),
                        fontWeight: FontWeight.bold),
                  ),
                ),

                ToggleSwitch(
                  minWidth: 150.0,
                  initialLabelIndex: 0,
                  cornerRadius: 20.0,
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.white,
                  inactiveFgColor: const Color.fromARGB(255, 224, 45, 255),
                  borderColor: const [Colors.grey],
                  borderWidth: 0.5,
                  totalSwitches: 2,
                  labels: const ['Full', 'Half'],
                  customTextStyles: const [
                    TextStyle(fontSize: 16.0, fontWeight: FontWeight.w900),
                    TextStyle(fontSize: 16.0, fontWeight: FontWeight.w900),
                  ],
                  activeBgColors: const [
                    [Color.fromARGB(255, 224, 45, 255)],
                    [Color.fromARGB(255, 224, 45, 255)]
                  ],
                  onToggle: (index) {
                    print('switched to: $index');
                    if (index == 1) {
                      // Navigate to the 'Half' page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HalfDayLeave(
                                  companyId: widget.companyId,
                                  userPosition: widget.userPosition,
                                )),
                      );
                    }
                  },
                ),

                // Balance Leaves
                Container(
                  margin: const EdgeInsets.fromLTRB(35, 20, 35, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        'Balance Annual',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 224, 45, 255),
                        ),
                      ),
                      Container(
                        width: 150, // Set the width as per your requirement
                        height: 40, // Set the height as per your requirement
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 238, 238, 238),
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        // child: isDataLoaded
                        //     ? Center(
                        //         child: Text(
                        //           '${annualLeaveBalance ?? "N/A"}',
                        //           style: const TextStyle(fontSize: 18),
                        //         ),
                        //       )
                        //     : const Center(
                        //         child: Text(
                        //           ' ', // or any other loading message
                        //           style: TextStyle(fontSize: 18),
                        //         ),
                        //       ),
                      ),
                    ],
                  ),
                ),

                // Start Date
                Container(
                  margin: const EdgeInsets.fromLTRB(35, 10, 35, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        'Start Date          ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 224, 45, 255),
                        ),
                      ),
                      Container(
                        width: 150, // Set the width as per your requirement
                        height: 40, // Set the height as per your requirement
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 238, 238, 238),
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text('startDate'),
                        // child: Padding(
                        //   padding:
                        //       EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        //   child: TextField(
                        //     controller: _startDateController,
                        //     decoration: InputDecoration(
                        //       border: InputBorder.none,
                        //       hintText: 'DD/MM/YYYY',
                        //     ),
                        //   ),
                        // ),
                      ),
                    ],
                  ),
                ),

                // End Date
                Container(
                  margin: const EdgeInsets.fromLTRB(35, 10, 35, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        'End Date          ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 224, 45, 255),
                        ),
                      ),
                      Container(
                        width: 150, // Set the width as per your requirement
                        height: 40, // Set the height as per your requirement
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 238, 238, 238),
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text('endDate'),
                      ),
                    ],
                  ),
                ),

                // Leave Days
                Container(
                  margin: const EdgeInsets.fromLTRB(35, 10, 35, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        'Leave Days      ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 224, 45, 255),
                        ),
                      ),
                      Container(
                        width: 150, // Set the width as per your requirement
                        height: 40, // Set the height as per your requirement
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 238, 238, 238),
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        // child: Center(
                        //   child: Text(
                        //     '${leaveDay ?? 0}',
                        //     style: const TextStyle(fontSize: 18),
                        //   ),
                        // ),
                      ),
                    ],
                  ),
                ),

                // Reasons
                Container(
                  margin: const EdgeInsets.fromLTRB(35, 10, 35, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        'Reason              ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 224, 45, 255),
                        ),
                      ),
                      Container(
                        width: 150, // Set the width as per your requirement
                        height: 40, // Set the height as per your requirement
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 238, 238, 238),
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text('MYreason'),
                      ),
                    ],
                  ),
                ),

                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.fromLTRB(55, 20, 10, 20),
                  child: const Text(
                    'Remarks',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 224, 45, 255),
                    ),
                  ),
                ),

                Container(
                    width: 300, // Set the width as per your requirement
                    height: 100, // Set the height as per your requirement
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 238, 238, 238),
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text('Remarkssss')),

                // Container(
                //   margin: const EdgeInsets.all(20.0),
                // ElevatedButton(
                //   onPressed: () {
                //     if (startDate == null ||
                //         endDate == null ||
                //         reason == null) {
                //       showDialog(
                //         context: context,
                //         builder: (context) => AlertDialog(
                //           title: const Text('Empty Space Detected'),
                //           content: const Text(
                //               'Please fill in all the required information'),
                //           actions: [
                //             TextButton(
                //               onPressed: () {
                //                 Navigator.pop(context);
                //               },
                //               child: const Text('OK'),
                //             ),
                //           ],
                //         ),
                //       );
                //     } else if (leaveDay! > annualLeaveBalance!) {
                //       showDialog(
                //         context: context,
                //         builder: (context) => AlertDialog(
                //           title: const Text('Invalid Date'),
                //           content: const Text('Your have exceeeded the limit'),
                //           actions: [
                //             TextButton(
                //               onPressed: () {
                //                 Navigator.pop(context);
                //               },
                //               child: const Text('OK'),
                //             ),
                //           ],
                //         ),
                //       );
                //     } else {
                //       reason = _reasonController.text;
                //       remark = _remarkController.text;
                //       _createLeave();
                //       setState(() {});
                //     }
                //   },
                //   style: ButtonStyle(
                //     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                //       RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(
                //             20.0), // Set the corner radius
                //       ),
                //     ),
                //     fixedSize: MaterialStateProperty.all<Size>(
                //       const Size(120, 40), // Set the width and height
                //     ),
                //     backgroundColor: MaterialStateProperty.all<Color>(
                //       const Color.fromARGB(255, 224, 45,
                //           255), // Set the background color to purple
                //     ),
                //   ),
                //   child: const Text('Confirm'),
                // ),
              ],
            ),
          ),
        ));
  }
}
