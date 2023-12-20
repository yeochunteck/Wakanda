import 'package:flutter/material.dart';
import 'package:flutter_application_1/main_page.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_application_1/Apply_FullLeave_page.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/models/data_model.dart';

class HalfDayLeave extends StatefulWidget {
  final String companyId;
  final String userPosition;

  HalfDayLeave({Key? key, required this.companyId, required this.userPosition})
      : super(key: key);

  @override
  _HalfDayLeave createState() => _HalfDayLeave();
}

class _HalfDayLeave extends State<HalfDayLeave> {
  final logger = Logger();

  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  String leaveType = 'Unpaid';
  String fullORHalf = 'Half';
  double leaveDay = 0.5;
  DateTime? startDate;
  String? reason;
  String remark = '-';
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

  Future<void> _createLeave() async {
    logger.i("123");
    logger.i(widget.companyId);
    await LeaveModel().createLeave(widget.companyId, {
      'leaveType': leaveType,
      'leaveDay': leaveDay,
      'fullORHalf': fullORHalf,
      'startDate': startDate,
      'status' : status,
      'reason': reason,
      'remark': remark
    });

    // Navigate back to the profile page
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MainPage(
                companyId: widget.companyId,
                userPosition: widget.userPosition,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 224, 45, 255),
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
                minWidth: 200.0,
                initialLabelIndex: 0,
                cornerRadius: 20.0,
                activeFgColor: Colors.white,
                inactiveBgColor: Colors.white,
                inactiveFgColor: const Color.fromARGB(255, 224, 45, 255),
                borderColor: const [Colors.grey],
                borderWidth: 0.5,
                totalSwitches: 1, // Set to 1 for only one switch
                labels: const ['Unpaid'], // Provide a single label
                customTextStyles: const [
                  TextStyle(fontSize: 16.0, fontWeight: FontWeight.w900),
                ],
                activeBgColors: const [
                  [Color.fromARGB(255, 224, 45, 255)],
                ],
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
                initialLabelIndex: 1,
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
                  if (index == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ApplyLeave(
                                companyId: widget.companyId,
                                userPosition: widget.userPosition,
                              )),
                    );
                  }
                },
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 0),
                            child: TextFormField(
                              decoration: const InputDecoration(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 0),
                        child: TextField(
                          controller: _reasonController,
                          decoration: const InputDecoration(
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

              //Remark
              Container(
                width: 300, // Set the width as per your requirement
                height: 100, // Set the height as per your requirement
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 238, 238, 238),
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: TextField(
                    controller: _remarkController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'remark (optimal)',
                    ),
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (startDate == null || reason == null) {
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
                    } else {
                      reason = _reasonController.text;
                      remark = _remarkController.text.isNotEmpty ? _remarkController.text : '-';
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}