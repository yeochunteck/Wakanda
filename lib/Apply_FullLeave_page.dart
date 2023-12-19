import 'package:flutter/material.dart';
import 'package:flutter_application_1/main_page.dart';
import 'package:flutter_application_1/Leave_main_page.dart';
import 'package:flutter_application_1/half_DayLeave_Page.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:flutter_application_1/models/data_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ApplyLeave extends StatefulWidget {
  final String companyId;
  final String userPosition;

  ApplyLeave({Key? key, required this.companyId, required this.userPosition})
      : super(key: key);

  @override
  _ApplyLeave createState() => _ApplyLeave();
}

// ignore: must_be_immutable
class _ApplyLeave extends State<ApplyLeave> {
  final logger = Logger();

  // final TextEditingController _startDateController = TextEditingController();
  // final TextEditingController _endDateController = TextEditingController();
  // final TextEditingController _annualBalanceController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  int? annualLeaveBalance;
  String leaveType = 'Annual';
  String fullORHalf = 'Full';
  DateTime? startDate;
  DateTime? endDate;
  double? leaveDay;
  String? reason;
  String? remark;
  DateTime selectedDate = DateTime.now();
  String status = 'pending';
  bool isDataLoaded = false;

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        startDate = pickedDate;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      if (pickedDate.isAfter(startDate!) ||
          pickedDate.isAtSameMomentAs(startDate!)) {
        setState(() {
          endDate = pickedDate;
          leaveDay = calculateDateDifference();
        });
      } else {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Invalid Date'),
            content: Text('End date cannot be earlier than start date.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  double calculateDateDifference() {
    if (startDate != null && endDate != null) {
      final difference = endDate!.difference(startDate!);
      return (difference.inDays.abs() + 1);
    }
    return 0;
  }

  Future<void> _createLeave() async {
    logger.i("123");
    logger.i(widget.companyId);
    await LeaveModel().createLeave(widget.companyId, {
      'leaveType': leaveType,
      'fullORHalf': fullORHalf,
      'startDate': startDate,
      'endDate': endDate,
      'leaveDay': leaveDay,
      'reason': reason,
      'remark': remark,
      'status' : status
    });

    // Navigate back to the profile page
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeavePage(
          userPosition: widget.userPosition,
          companyId: widget.companyId,
        )
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Fetch user data when the page is initialized
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final userData = await LeaveModel().getUserData(widget.companyId);

      // ignore: unnecessary_null_comparison
      if (userData != null) {
        setState(() {
          annualLeaveBalance = userData['annualLeaveBalance'] ?? '';
          isDataLoaded = true;
        });
      }
    } catch (e) {
      logger.e('Error fetching user data: $e');
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
                  builder: (context) => LeavePage(
                    userPosition: widget.userPosition,
                    companyId: widget.companyId,
                  )
                )
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
                  onToggle: (index) {
                    if (index == 0) {
                      String selectedLabel = 'Annual';
                      leaveType = selectedLabel;
                    } else if (index == 1) {
                      String selectedLabel = 'Unpaid';
                      leaveType = selectedLabel;
                    }
                  },
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
                        child: isDataLoaded
                            ? Center(
                                child: Text(
                                  '${annualLeaveBalance ?? "N/A"}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              )
                            : const Center(
                                child: Text(
                                  ' ', // or any other loading message
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
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
                        child: GestureDetector(
                          onTap: () {
                            _selectStartDate(context);
                          },
                          child: AbsorbPointer(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 0),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Select Date',
                                  border: InputBorder.none,
                                ),
                                validator: (value) {
                                  if (startDate == null) {
                                    return 'Please select your date of birth';
                                  }
                                  return null;
                                },
                                onSaved: (value) {},
                                controller: TextEditingController(
                                  text: startDate != null
                                      ? DateFormat('yyyy-MM-dd')
                                          .format(startDate!)
                                      : '',
                                ),
                              ),
                            ),
                          ),
                        ),
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
                        child: GestureDetector(
                          onTap: () {
                            _selectEndDate(context);
                          },
                          child: AbsorbPointer(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 0),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  hintText: 'Select Date',
                                  border: InputBorder.none,
                                ),
                                validator: (value) {
                                  if (endDate == null) {
                                    return 'Please select your date of birth';
                                  }
                                  return null;
                                },
                                onSaved: (value) {},
                                controller: TextEditingController(
                                  text: endDate != null
                                      ? DateFormat('yyyy-MM-dd')
                                          .format(endDate!)
                                      : '',
                                ),
                              ),
                            ),
                          ),
                        ),
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
                        child: Center(
                          child: Text(
                            '${leaveDay ?? 0}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
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
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          child: TextField(
                            controller: _reasonController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Text',
                            ),
                            onSubmitted: (value) => reason = value,
                          ),
                        ),
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    child: TextField(
                      controller: _remarkController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'remark (optimal)',
                      ),
                      onSubmitted: (value) => remark = value,
                    ),
                  ),
                ),

                // Container(
                //   margin: const EdgeInsets.all(20.0),
                ElevatedButton(
                  onPressed: () {
                    if (startDate == null ||
                        endDate == null ||
                        reason == null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Empty Space Detected'),
                          content: const Text(
                              'Please fill in all the required information'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else if (leaveDay! > annualLeaveBalance!) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Invalid Date'),
                          content: const Text('Your have exceeeded the limit'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      reason = _reasonController.text;
                      remark = _remarkController.text;
                      _createLeave();
                      setState(() {});
                    }
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            20.0), // Set the corner radius
                      ),
                    ),
                    fixedSize: MaterialStateProperty.all<Size>(
                      const Size(120, 40), // Set the width and height
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 224, 45,
                          255), // Set the background color to purple
                    ),
                  ),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ),
        ));
  }
}