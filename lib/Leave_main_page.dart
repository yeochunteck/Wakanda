import 'package:flutter/material.dart';
import 'package:flutter_application_1/main_page.dart';
import 'package:flutter_application_1/models/data_model.dart';
import 'package:logger/logger.dart';
import 'package:flutter_application_1/Apply_FullLeave_page.dart';

class LeavePage extends StatefulWidget {
  final String userPosition;
  final String companyId; // Unique user ID

  LeavePage({Key? key, required this.userPosition, required this.companyId}) : super(key: key);

  @override
  _LeavePageState createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  final logger = Logger();
  String currentCategory = 'Pending';
  late String companyId;
  List<dynamic> pendingLeaveList = [];
  List<dynamic> approvedLeaveList = [];
  List<dynamic> rejectedLeaveList = [];
  @override
  void initState() {
    super.initState();
    companyId = widget.companyId;

    // Fetch user data when the page is initialized
    fetchSpecificUsersWithLeaveHistory();
  }

  Future<void> fetchSpecificUsersWithLeaveHistory() async {
    try {
      print('Fetching data for companyId: $companyId');
      final List<Map<String, dynamic>> specificUsersData =
          await LeaveModel().getLeaveDataForUser(companyId);

      setState(() {
        if (specificUsersData.isNotEmpty) {
          //Pending list Data
          pendingLeaveList = specificUsersData
            .where((user) {
              print('User status: ${user['status']}');
              return user['status'] == 'pending';
            })
            .map((user) {
            return {
              'name': user['userData']['name'].toString(),
              'leaveType': user['leaveType'].toString(),
              'leaveDay': user['leaveDay'] as double,
              'startDate': "${user['startDate'].year}-${user['startDate'].month}-${user['startDate'].day}",
            };
          }).toList();
          //Approved list data
          approvedLeaveList = specificUsersData
              .where((user) => user['status'] == 'Approved')
              .map((user) {
            return {
              'name': user['userData']['name'].toString(),
              'leaveType': user['leaveType'].toString(),
              'leaveDay': user['leaveDay'] as double,
              'startDate': "${user['startDate'].year}-${user['startDate'].month}-${user['startDate'].day}",
            };
          }).toList();
          rejectedLeaveList = specificUsersData
              .where((user) => user['status'] == 'Rejected')
              .map((user) {
            return {
              'name': user['userData']['name'].toString(),
              'leaveType': user['leaveType'].toString(),
              'leaveDay': user['leaveDay'] as double,
              'startDate': "${user['startDate'].year}-${user['startDate'].month}-${user['startDate'].day}",
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
    List<dynamic> currentLeaveList = [];
    if (currentCategory == 'Pending') {
      currentLeaveList = pendingLeaveList;
    } else if (currentCategory == 'Approved') {
      currentLeaveList = approvedLeaveList;
    } else if (currentCategory == 'Rejected') {
      currentLeaveList = rejectedLeaveList;
    } 

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 224, 45, 255),
        title: const Text(
          'Leave',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
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
                  builder: (context) => MainPage(companyId: widget.companyId, userPosition: widget.userPosition,),
                ),
              );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.black,
            ),
            onPressed: () {
              // Navigate to the Apply_FullLeave_page.dart when the plus icon is clicked
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ApplyLeave(companyId: widget.companyId, userPosition: widget.userPosition,),
                ),
              );
            },
          ),
        ],
        
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentCategory = 'Pending';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(50, 43),
                    backgroundColor: currentCategory == 'Pending'
                        ? const Color.fromARGB(255, 224, 45, 255)
                        : Colors.white,
                    foregroundColor: currentCategory == 'Pending'
                        ? Colors.white
                        : const Color.fromARGB(255, 224, 45, 255),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0),
                      ),
                      side: BorderSide(
                        color: Color.fromARGB(255, 158, 158, 158),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentCategory = 'Approved';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(50, 43),
                    backgroundColor: currentCategory == 'Approved'
                        ? const Color.fromARGB(255, 224, 45, 255)
                        : Colors.white,
                    foregroundColor: currentCategory == 'Approved'
                        ? Colors.white
                        : const Color.fromARGB(255, 224, 45, 255),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(0.0),
                        bottomRight: Radius.circular(0.0),
                      ),
                      side: BorderSide(
                        color: Color.fromARGB(255, 158, 158, 158),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Approved',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentCategory = 'Rejected';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(50, 43),
                    backgroundColor: currentCategory == 'Rejected'
                        ? const Color.fromARGB(255, 224, 45, 255)
                        : Colors.white,
                    foregroundColor: currentCategory == 'Rejected'
                        ? Colors.white
                        : const Color.fromARGB(255, 224, 45, 255),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                      side: BorderSide(
                        color: Color.fromARGB(255, 158, 158, 158),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Rejected',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: currentLeaveList.length,
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
                      currentLeaveList[index]['name'],
                      style: const TextStyle(
                        color: Color.fromARGB(255, 224, 45, 255),
                        fontSize: 21.0,
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
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currentLeaveList[index]['leaveType'],
                          style: const TextStyle(
                            color: Color.fromARGB(255, 224, 45, 255),
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
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
                                    currentLeaveList[index]['leaveDay']
                                        .toString(),
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 224, 45, 255),
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
                                  currentLeaveList[index]['startDate'],
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 224, 45, 255),
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
