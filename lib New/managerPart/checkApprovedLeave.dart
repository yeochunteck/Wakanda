import 'package:flutter/material.dart';
import 'package:flutter_application_1/main_page.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_application_1/managerPart/checkPendingLeave.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/models/data_model.dart';

class CheckApprovedLeave extends StatefulWidget {
  final String companyId;
  final String userPosition;

  CheckApprovedLeave({Key? key, required this.companyId, required this.userPosition})
      : super(key: key);

  @override
  _CheckApprovedLeave createState() => _CheckApprovedLeave();
}

class _CheckApprovedLeave extends State<CheckApprovedLeave> {
  final logger = Logger();

  String? userName;
  String? leaveType;
  int? leaveDay;
  DateTime? date;

  @override
  void initState() {
    super.initState();

    // Fetch user data when the page is initialized
    fetchAllUsersWithLeaveHistory();
  }

  Future<void> fetchAllUsersWithLeaveHistory() async {
    try {
      final List<Map<String, dynamic>> allUsersData =
          await LeaveModel().getUsersWithApprovedLeave();

      setState(() {
        // isDataLoaded = true;
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
        backgroundColor: Color.fromARGB(255, 224, 45, 255),
        title: const Text(
          'Check Leave',
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
              const SizedBox(height: 20),
              ToggleSwitch(
                minWidth: 150.0,
                initialLabelIndex: 0,
                cornerRadius: 20.0,
                activeFgColor: Colors.white,
                inactiveBgColor: Colors.white,
                inactiveFgColor: const Color.fromARGB(255, 224, 45, 255),
                borderColor: const [Colors.grey],
                borderWidth: 0.5,
                totalSwitches: 3,
                labels: const ['Approved', 'Pending', 'Rejected'],
                customTextStyles: const [
                  TextStyle(fontSize: 16.0, fontWeight: FontWeight.w900),
                  TextStyle(fontSize: 16.0, fontWeight: FontWeight.w900),
                  TextStyle(fontSize: 16.0, fontWeight: FontWeight.w900),
                ],
                activeBgColors: const [
                  [Color.fromARGB(255, 224, 45, 255)],
                  [Color.fromARGB(255, 224, 45, 255)],[Color.fromARGB(255, 224, 45, 255)]
                ],
                onToggle: (index) {
                  if (index == 1) {
                    // Navigate to the 'Half' page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CheckPendingLeave(
                                companyId: widget.companyId,
                                userPosition: widget.userPosition,
                              )),
                    );
                  }
                },
              ),

              Text(
                'Approved'
              ),
            ],
          ),
        ),
      ),
    );
  }
}
