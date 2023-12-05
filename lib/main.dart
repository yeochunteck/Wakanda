import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DemoApp(),
    );
  }
}

class DemoApp extends StatefulWidget {
  @override
  _DemoAppState createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {

  List<String> labels = ['Home','Message','Notification','Setting',];
  int counter = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                // Handle backward button press
              },
            ),
            Text('Leave Application'),
            SizedBox(width: 40),
          ],
        ),
        // title: Text('Leave Application'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 224, 45, 255),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: const Text("Leave Type", style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 224, 45, 255), fontWeight: FontWeight.bold),
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
              labels: const ['Annual', 'Unpaid'],
              customTextStyles: const [
                TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w900),
                TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w900),
              ],
              activeBgColors: const [[Color.fromARGB(255, 224, 45, 255)],[Color.fromARGB(255, 224, 45, 255)]],
              onToggle: (index) {
                print('switched to: $index');
              },
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: const Text("Full/Half", style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 224, 45, 255), fontWeight: FontWeight.bold),
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
                TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w900),
                TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w900),
              ],
              activeBgColors: const [[Color.fromARGB(255, 224, 45, 255)],[Color.fromARGB(255, 224, 45, 255)]],
              onToggle: (index) {
                print('switched to: $index');
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
                    height: 35, // Set the height as per your requirement
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 238, 238, 238),
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      child: TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter balance',
                        ),
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
                    height: 35, // Set the height as per your requirement
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 238, 238, 238),
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
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
                    height: 35, // Set the height as per your requirement
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 238, 238, 238),
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
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
                    height: 35, // Set the height as per your requirement
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 238, 238, 238),
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      child: TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter days',
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
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
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
                      borderRadius: BorderRadius.circular(20.0), // Set the corner radius
                    ),
                  ),
                  fixedSize: MaterialStateProperty.all<Size>(
                    const Size(120, 40), // Set the width and height 
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 224, 45, 255), // Set the background color to purple
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