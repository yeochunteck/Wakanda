import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

import 'package:flutter_application_1/login_page.dart';
import 'package:flutter_application_1/data/repositories/profile_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';

enum Gender { male, female }

final List<String> positions = ['Sales', 'Account', 'Customer Services'];
final List<String> banks = [
  'Bank A',
  'Bank B',
  'Bank C'
]; // Add your bank names here

class CreateUserPage extends StatefulWidget {
  @override
  _CreateUserPageState createState() => _CreateUserPageState();
}

extension StringExtension on String? {
  String? capitalizeFirstLetter() {
    if (this == null || this!.isEmpty) {
      return this;
    }
    return this![0].toUpperCase() + this!.substring(1);
  }

  String? formatName() {
    if (this == null || this!.isEmpty) {
      return this;
    }
    return this!
        .toLowerCase()
        .split(' ')
        .map((word) => word.capitalizeFirstLetter())
        .join(' ');
  }
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final logger = Logger();
  late String companyId; // User ID with the desired format
  late int counter;

  String name = '';
  String email = '';
  String phone = '';
  Gender? selectedGender;
  DateTime? dateOfBirth;
  String? selectedPosition;
  String? pickedImagePath;
  String imageUrl = '';
  DateTime? joiningDate;

  // Financial Information
  String accountNumber = '';
  String? selectedBank;
  double basicSalary = 0.0;
  String epfNo = '';
  String socsoNo = '';

  Future<void> _selectDateofBirth(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != dateOfBirth) {
      setState(() {
        dateOfBirth = pickedDate;
      });
    }
  }

  Future<void> _selectJoiningDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        joiningDate = pickedDate;
      });
    }
  }

  void generateCompanyId() {
    // Increment the counter to generate the next companyId
    counter++;

    // Use the fetched counter as the sequential part of the ID
    companyId = 'PF${counter.toString().padLeft(4, '0')}';
  }

  Future<void> fetchLatestCounter() async {
    try {
      // Get data from users collection
      final querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      if (querySnapshot.docs.isNotEmpty) {
        // Find the maximum counter value from existing user documents
        final maxCounter = querySnapshot.docs
            .map<int>((doc) =>
                int.parse(doc.get('companyId').toString().substring(2)))
            .reduce((value, element) => value > element ? value : element);

        counter = maxCounter;
      } else {
        counter = 0; // Default to 0 if there are no existing user documents
      }
    } catch (e) {
      print('Error fetching counter: $e');
      counter = 0; // Default to 0 in case of an error
    }
  }

  Future<void> _createUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Check if an image is uploaded
      if (pickedImagePath == null) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Please upload an image.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      await fetchLatestCounter(); // Fetch the latest counter
      generateCompanyId(); // Generate the userId with the desired format

      // Generate the password based on the user's name and phone number
      String firstName = name.split(' ').first.toUpperCase();
      String birthMonth = DateFormat('MM').format(dateOfBirth!);
      logger.i(birthMonth);
      String birthDay = DateFormat('dd').format(dateOfBirth!);
      logger.i(birthDay);
      String generatedPassword = '$firstName$birthMonth$birthDay';
      logger.d(generatedPassword);

      // Upload the image and get the imageUrl
      imageUrl =
          await ProfileRepository().uploadImage(pickedImagePath!, companyId);

      // // Create user with the collected data
      // await ProfileRepository().createUser({
      //   'name': name.formatName(),
      //   'email': email,
      //   'phone': phone,
      //   'gender': selectedGender
      //       ?.toString()
      //       .split('.')
      //       .last // Convert enum to string
      //       .capitalizeFirstLetter(),
      //   'dateofbirth': dateOfBirth,
      //   'position': selectedPosition,
      //   'image': imageUrl,
      //   'companyId': companyId,
      //   'password': generatedPassword, // Include the generated password
      // });
      // Create user with the collected data
      await ProfileRepository().createUser(
        companyId,
        {
          'name': name.formatName(),
          'email': email,
          'phone': phone,
          'gender': selectedGender
              ?.toString()
              .split('.')
              .last // Convert enum to string
              .capitalizeFirstLetter(),
          'dateofbirth': dateOfBirth,
          'joiningdate': joiningDate,
          'position': selectedPosition,
          'image': imageUrl,
          'companyId': companyId,
          'password': generatedPassword, // Include the generated password
        },
        {
          'basicSalary': basicSalary,
          'epfNo': epfNo,
          'socsoNo': socsoNo,
          'effectiveDate': DateTime.now(),
        },
        {
          'accountNumber': accountNumber,
          'bankName': selectedBank,
          'effectiveDate': DateTime.now(),
        },
      );

      // Navigate back to the profile page
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(
            229, 63, 248, 1), // Set the background color to transparent
        elevation: 0, // Remove the shadow
        iconTheme: const IconThemeData(
            color: Colors.black, size: 30), // Set the icon color to black
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Create User',
          style: TextStyle(color: Colors.black), // Set title color to black
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // GestureDetector for image upload
              GestureDetector(
                onTap: () async {
                  // Open the image picker
                  final pickedFile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);

                  if (pickedFile != null) {
                    // Handle the picked image (you may want to save it to Firebase Storage)
                    logger.i('Image picked: ${pickedFile.path}');
                    setState(() {
                      pickedImagePath = pickedFile.path;
                    });
                  }
                },
                // CircleAvatar for image upload indication
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey[300],
                  child: pickedImagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(70),
                          child: Image.file(
                            File(pickedImagePath!),
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 45,
                              color: Colors.grey[600],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Upload Image',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Personal Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              // Personal Information Section
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) => name = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }

                  // Email validation using a regular expression
                  // This example checks for a basic email format
                  // You may want to use a more sophisticated validation logic
                  final emailRegex = RegExp(
                    r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
                  );

                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }

                  return null;
                },
                onSaved: (value) => email = value ?? '',
              ),

              TextFormField(
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(
                      11), // Adjust the limit as needed
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  // You can add additional phone validation logic here if needed
                  return null;
                },
                onSaved: (value) => phone = value ?? '',
              ),
              // Row with radio buttons for gender
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Text('Gender:'),
                    Radio<Gender>(
                      value: Gender.male,
                      groupValue: selectedGender,
                      onChanged: (Gender? value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                    const Text('Male'),
                    Radio<Gender>(
                      value: Gender.female,
                      groupValue: selectedGender,
                      onChanged: (Gender? value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                    const Text('Female'),
                  ],
                ),
              ),

              GestureDetector(
                onTap: () => _selectDateofBirth(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Date of Birth'),
                    validator: (value) {
                      if (dateOfBirth == null) {
                        return 'Please select your date of birth';
                      }
                      return null;
                    },
                    onSaved: (value) {},
                    controller: TextEditingController(
                      text: dateOfBirth != null
                          ? DateFormat('yyyy-MM-dd').format(dateOfBirth!)
                          : '',
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: () => _selectJoiningDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Joining Date'),
                    validator: (value) {
                      if (joiningDate == null) {
                        return 'Please select the Joining Date';
                      }
                      return null;
                    },
                    onSaved: (value) {},
                    controller: TextEditingController(
                      text: joiningDate != null
                          ? DateFormat('yyyy-MM-dd').format(joiningDate!)
                          : '',
                    ),
                  ),
                ),
              ),

              // Dropdown list for position
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Position'),
                  value: selectedPosition,
                  items: positions.map((String position) {
                    return DropdownMenuItem<String>(
                      value: position,
                      child: Text(position),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedPosition = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please choose your position';
                    }
                    return null;
                  },
                  onSaved: (value) => selectedPosition = value ?? '',
                ),
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Bank Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),

              // Bank Details Section
              TextFormField(
                decoration: InputDecoration(labelText: 'Account Number'),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account number';
                  }
                  return null;
                },
                onSaved: (value) => accountNumber = value ?? '',
              ),

              // Dropdown list for bank selection
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Bank Name'),
                  value: selectedBank,
                  items: banks.map((String bank) {
                    return DropdownMenuItem<String>(
                      value: bank,
                      child: Text(bank),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedBank = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please choose your bank';
                    }
                    return null;
                  },
                  onSaved: (value) => selectedBank = value ?? '',
                ),
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Financial Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),

              // Financial Information
              TextFormField(
                decoration: InputDecoration(labelText: 'Basic Salary (RM)'),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter basic salary';
                  }
                  // You can add additional salary validation logic here if needed
                  return null;
                },
                onSaved: (value) => basicSalary = double.parse(value ?? '0'),
              ),

              // EPF No
              TextFormField(
                decoration: InputDecoration(labelText: 'EPF No (Optional)'),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onSaved: (value) => epfNo = value ?? '',
              ),

              // Note for the user
              Text(
                'Note: The EPF No section can be left blank if user don\'t have one.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),

              // SOCSO No
              TextFormField(
                decoration: InputDecoration(labelText: 'SOCSO No (Optional)'),
                keyboardType: TextInputType.text,
                onSaved: (value) => socsoNo = value ?? '',
              ),

              // Note for the user
              Text(
                'Note: The SOCSO No section can be left blank if user don\'t have one.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(229, 63, 248, 1),
                ),
                child: const Text('Create User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
