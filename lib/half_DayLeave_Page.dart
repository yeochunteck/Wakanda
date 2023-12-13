import 'package:flutter/material.dart';
import 'package:flutter_application_1/main_page.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_application_1/Apply_FullLeave_page.dart';

class HalfDayLeave extends StatelessWidget {
  final String companyId;

  HalfDayLeave({Key? key, required this.companyId}) : super(key: key);
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
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                print('switched to: $index');
              },
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                    MaterialPageRoute(builder: (context) => ApplyLeave(companyId: companyId,)),
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
                    height: 35, // Set the height as per your requirement
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 238, 238, 238),
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter date',
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
                    height: 35, // Set the height as per your requirement
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 238, 238, 238),
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Text',
                        ),
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
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'remark (optimal)',
                  ),
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20.0), // Set the corner radius
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
    );
  }
}