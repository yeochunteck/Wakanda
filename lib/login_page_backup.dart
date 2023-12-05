// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:logger/logger.dart';

// import 'package:flutter_application_1/main_page.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final TextEditingController _companyIdController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final CollectionReference _users =
//       FirebaseFirestore.instance.collection('users');

//   var logger = Logger();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Login Page'),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start, // Align to the top
//             crossAxisAlignment:
//                 CrossAxisAlignment.center, // Center horizontally

//             children: <Widget>[
//               // Your Logo
//               Image.asset('assets/images/logo.jpg', width: 360, height: 360),
//               const SizedBox(height: 5),
//               // Company ID Text Field
//               TextField(
//                 controller: _companyIdController,
//                 decoration: InputDecoration(
//                   labelText: 'Company ID',
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // Password Text Field
//               TextField(
//                 controller: _passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // Confirm Button
//               ElevatedButton(
//                 onPressed: () async {
//                   final String companyId = _companyIdController.text;
//                   final String password = _passwordController.text;

//                   try {
//                     final userSnapshot = await _users.doc(companyId).get();

//                     final userData =
//                         userSnapshot.data() as Map<String, dynamic>?;

//                     logger.d('User Data: $userData');

//                     if (userSnapshot.exists) {
//                       final userData =
//                           userSnapshot.data() as Map<String, dynamic>?;

//                       if (userData != null &&
//                           userData['password'] == password) {
//                         // User authentication successful
//                         Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => MainPage(
//                                       companyId: companyId,
//                                     )));
//                       } else {
//                         logger.w('Invalid Company ID or Password');
//                         ScaffoldMessenger.of(context)
//                             .showSnackBar(const SnackBar(
//                           content: Text('Invalid Company ID or Password'),
//                         ));
//                       }
//                     } else {
//                       logger.w('User not found');
//                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                         content: Text('User not found'),
//                       ));
//                     }
//                   } catch (e) {
//                     logger.e('Error retrieving data from Firestore: $e');
//                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                       content:
//                           Text('An error occurred. Please try again later.'),
//                     ));
//                   }
//                 },
//                 child: Text('Confirm', style: TextStyle(color: Colors.white)),
//                 style: ElevatedButton.styleFrom(primary: Colors.green),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
