import 'package:flutter/material.dart';
import 'package:flutter_application_1/main_page.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_application_1/managerPart/checkPendingLeave.dart';
import 'package:flutter_application_1/managerPart/checkRejectedLeave.dart';
import 'package:logger/logger.dart';
import 'package:flutter_application_1/models/data_model.dart';

class CheckApprovedLeave extends StatefulWidget {
  final String companyId;
  final String userPosition;

  CheckApprovedLeave(
      {Key? key, required this.companyId, required this.userPosition})
      : super(key: key);

  @override
  _CheckApprovedLeave createState() => _CheckApprovedLeave();
}

class _CheckApprovedLeave extends State<CheckApprovedLeave> {
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
          await LeaveModel().getUsersWithApprovedLeave();

      setState(() {
        if (allUsersData.isNotEmpty) {
          userNameList = allUsersData.map((user) {
            final String companyId = user['userData']['companyId'].toString();
            final String name = user['userData']['name'].toString();
            final String leaveType = user['leaveType'].toString();
            final double leaveDay = user['leaveDay'] as double;
            final DateTime startDate = user['startDate'] as DateTime;
            final DateTime? endDate = user['endDate'] as DateTime?;
            final String fullORHalf = user['fullORHalf'].toString();
            final String reason = user['reason'].toString();
            final String documentId = user['documentId'].toString();
            final String remark = user['remark'].toString();

            final formattedStartDate =
                "${startDate.year}-${startDate.month}-${startDate.day}";
            final formattedEndDate = endDate != null
                ? "${endDate.year}-${endDate.month}-${endDate.day}"
                : '';

            return {
              'companyId': companyId,
              'name': name,
              'leaveType': leaveType,
              'leaveDay': leaveDay,
              'startDate': formattedStartDate,
              'endDate': formattedEndDate,
              'fullORHalf': fullORHalf,
              'reason': reason,
              'remark': remark,
              'documentId': documentId,
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
      body: Center(
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
                [Color.fromARGB(255, 224, 45, 255)],
                [Color.fromARGB(255, 224, 45, 255)]
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
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CheckRejectedLeave(
                              companyId: widget.companyId,
                              userPosition: widget.userPosition,
                            )),
                  );
                }
              },
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: userNameList.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 160,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: ListTile(
                      title: Text(
                        userNameList[index]['name'],
                        style: const TextStyle(
                          color: Color.fromARGB(255, 224, 45, 255),
                          fontSize: 21.0, // or your preferred font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          const Text(
                            'Leave Type:',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0, // or your preferred font size
                              fontWeight: FontWeight.bold,
                            ), // Set label color
                          ),
                          Text(
                            '${userNameList[index]['leaveType']}',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 224, 45, 255),
                              fontSize: 16.0, // or your preferred font size
                              fontWeight: FontWeight.bold,
                            ), // Set data color
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Days:',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${userNameList[index]['leaveDay']}',
                                      style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 224, 45, 255),
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Date:',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${userNameList[index]['startDate']}',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 224, 45, 255),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.fromLTRB(60, 0, 10, 10),
                                child: ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Center(
                                          child: Text('Leave Details'),
                                        ),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Type: ',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold, 
                                                    ),
                                                  ),
                                                  Text('${userNameList[index]['leaveType']}'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Full/Half: ',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold, 
                                                    ),
                                                  ),
                                                  Text('${userNameList[index]['fullORHalf']}'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Start Date: ',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold, 
                                                    ),
                                                  ),
                                                  Text('${userNameList[index]['startDate']}'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Text(
                                                    'End Date: ',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold, 
                                                    ),
                                                  ),
                                                  Text('${userNameList[index]['endDate']}'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Leave Days: ',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold, 
                                                    ),
                                                  ),
                                                  Text('${userNameList[index]['leaveDay']}'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Reason: ',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold, 
                                                    ),
                                                  ),
                                                  Text('${userNameList[index]['reason']}'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Remark: ',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold, 
                                                    ),
                                                  ),
                                                  Text('${userNameList[index]['remark']}'),
                                                ],
                                              ),
                                              const Row(
                                                children: [
                                                  Text(
                                                    'Status: ',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold, 
                                                    ),
                                                  ),
                                                  Text('Approved'),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
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
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            20.0), // Set the corner radius
                                      ),
                                    ),
                                    fixedSize: MaterialStateProperty.all<Size>(
                                      const Size(
                                          100, 50), // Set the width and height
                                    ),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                      Color.fromARGB(255, 55, 142,
                                          242), // Set the background color to blue
                                    ),
                                  ),
                                  child: const Text('Details'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Add any other information you want to display for each user
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
