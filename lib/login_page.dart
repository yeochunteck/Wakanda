import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import 'package:flutter_application_1/main_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _companyIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  var logger = Logger();
  Icon icon = Icon(Icons.visibility_off);
  bool obscure = true;

  Future<bool> checkCredentials(String companyId, String password) async {
    try {
      final querySnapshot = await _users.get();

      for (final doc in querySnapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;

        logger.i('companyID:' + companyId);
        logger.i(userData['companyId']);
        logger.i(userData['password']);

        if (userData['companyId'] == companyId &&
            userData['password'] == password) {
          return true; // Credentials match a user document
        }
      }

      return false; // Credentials do not match any user document
    } catch (e) {
      logger.e('Error retrieving data from Firestore: $e');
      return false; // An error occurred
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, //Solve Bottom overflow
      appBar: AppBar(
        title: Text('Login Page'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Align to the top
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center horizontally

            children: <Widget>[
              // Logo
              Image.asset('assets/images/logo.png', width: 240, height: 240),
              const SizedBox(height: 10),
              // Text Inform user
              Text(
                'Please fill up the form to login',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              // Company ID Text Field
              Container(
                // margin: EdgeInsets.symmetric(horizontal: 50),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.purple[300]!, width: 2.5),
                ),
                child: TextFormField(
                  controller: _companyIdController,
                  style: TextStyle(color: Colors.black),
                  obscureText: false,
                  decoration: InputDecoration(
                    border: InputBorder.none, //Remove default line
                    hintText: "Enter Company ID",
                    labelText: "Company ID",
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.purple[300]!, width: 2.5),
                ),
                child: TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: Colors.black),
                  obscureText: obscure,
                  decoration: InputDecoration(
                    border: InputBorder.none, //Remove default line
                    hintText: "Enter Password",
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            if (obscure == true) {
                              obscure = false;
                              icon = Icon(Icons.visibility);
                            } else {
                              obscure = true;
                              icon = Icon(Icons.visibility_off);
                            }
                          });
                        },
                        icon: icon),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              // Confirm Button
              ElevatedButton(
                onPressed: () async {
                  final String companyId = _companyIdController.text;
                  final String password = _passwordController.text;

                  final isValidCredentials =
                      await checkCredentials(companyId, password);
                  if (isValidCredentials) {
                    // User authentication successful
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainPage(companyId: companyId),
                      ),
                    );
                  } else {
                    logger.w('Invalid Company ID or Password');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid Company ID or Password'),
                      ),
                    );
                  }
                },
                child: Text('Login',
                    style: TextStyle(color: Colors.white, fontSize: 15.0)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[300],
                  elevation: 4.0,
                  shadowColor: Colors.purple,
                  minimumSize: Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
