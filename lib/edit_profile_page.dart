import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

import 'package:flutter_application_1/data/repositories/profile_repository.dart';

enum Gender { male, female }

final List<String> positions = ['Sales', 'Account', 'Customer Services'];
final List<String> banks = [
  'Bank A',
  'Bank B',
  'Bank C'
]; // Add your bank names here

class EditProfilePage extends StatefulWidget {
  final String companyId;

  EditProfilePage({Key? key, required this.companyId}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final logger = Logger();
  bool isEditing = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController basicSalaryController = TextEditingController();
  TextEditingController epfNoController = TextEditingController();
  TextEditingController socsoNoController = TextEditingController();

  String name = '';
  String email = '';
  String phone = '';
  Gender? selectedGender;
  DateTime? dateOfBirth;
  String? selectedPosition;
  String? pickedImagePath;
  String imageUrl = '';
  DateTime? joiningDate;
  bool status = true;
  String accountNumber = '';
  String? selectedBank;
  num basicSalary = 0.0;
  String epfNo = '';
  String socsoNo = '';

  void updateSelectedGender(Gender? value) {
    setState(() {
      selectedGender = value;
    });
  }

  @override
  void initState() {
    super.initState();

    // Fetch user data when the page is initialized
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final userData = await ProfileRepository().getUserData(widget.companyId);
      // Convert Timestamp to DateTime for date fields
      // DateTime? dateOfBirth = userData['dateOfBirth']?.toDate();
      // DateTime? joiningDate = userData['joiningDate']?.toDate();

      if (userData != null) {
        // Set the fetched user data to the state variables
        setState(() {
          name = userData['name'] ?? '';
          email = userData['email'] ?? '';
          phone = userData['phone'] ?? '';
          String genderFromFirestore =
              userData['gender']; // Assuming the field is stored as a String
          selectedGender =
              genderFromFirestore == 'Male' ? Gender.male : Gender.female;
          selectedPosition = userData['position'] ?? '';
          pickedImagePath = userData['image'];
          dateOfBirth = userData['dateofbirth'].toDate() ?? '';
          joiningDate = userData['joiningdate'].toDate() ?? '';
          selectedBank = userData['bankName'] ?? '';
          accountNumber = userData['accountNumber'] ?? '';
          basicSalary = userData['basicSalary'] ?? '';
          epfNo = userData['epfNo'] ?? '';
          socsoNo = userData['socsoNo'] ?? '';

          nameController.text = name;
          emailController.text = email;
          phoneController.text = phone;
          accountNumberController.text = accountNumber;
          basicSalaryController.text = basicSalary.toString();
          epfNoController.text = epfNo;
          socsoNoController.text = socsoNo;
          // logger.i('This is selectedbank' + selectedBank1);
          logger.i('This is' + nameController.text);
          logger.i('This is imageURl $pickedImagePath');
          // ... (populate other fields accordingly)
        });
      } else {
        // Handle the case when user data is not found
        logger.e('User data not found for companyId: ${widget.companyId}');
      }
    } catch (e) {
      // Handle errors during data fetching
      logger.e('Error fetching user data: $e');
    }
  }

  Future<void> _selectDateofBirth(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime.now(),
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
      initialDate: joiningDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        joiningDate = pickedDate;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      if (pickedImagePath != null && pickedImagePath!.startsWith('http')) {
        // If it's an HTTP URL, set imageUrl directly
        imageUrl = pickedImagePath!;
        logger.i("Using existing imageUrl: $imageUrl");
      } else if (pickedImagePath != null) {
        // If it's a local file path, upload the image and get the imageUrl
        imageUrl = await ProfileRepository()
            .uploadImage(pickedImagePath!, widget.companyId);
        logger.i("Uploaded imageUrl: $imageUrl");
      } else {
        // Handle the case where pickedImagePath is null
        logger.i("Error: pickedImagePath is null");
      }

      // Update the user data with the collected data
      await ProfileRepository().updateUser(
        widget.companyId,
        {
          'name': name,
          'email': email,
          'phone': phone,
          'gender': selectedGender?.toString().split('.').last,
          'dateofbirth': dateOfBirth,
          'joiningdate': joiningDate,
          'position': selectedPosition,
          'image': imageUrl,
          'status': status,
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

      Map<String, dynamic> result = {
        'name': name,
        'email': email,
        'phone': phone,
      };

      // Navigate back to the profile page
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.i('Line144: $name');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(229, 63, 248, 1),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
          size: 30,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          isEditing ? 'Edit Profile' : 'View Profile',
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(isEditing ? null : Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing; // Toggle between edit and view mode
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // GestureDetector for image upload
              GestureDetector(
                onTap: isEditing
                    ? () async {
                        // Open the image picker
                        final pickedFile = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);

                        if (pickedFile != null) {
                          // Handle the picked image (you may want to save it to Firebase Storage)
                          logger.i('Image picked: ${pickedFile.path}');
                          setState(() {
                            pickedImagePath = pickedFile.path;
                            logger.i('New image path: $pickedImagePath');
                          });
                        }
                      }
                    : null, // Disable onTap when not editing

                // CircleAvatar for image upload indication
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey[300],
                  child: pickedImagePath != null && pickedImagePath != ""
                      ? pickedImagePath!
                              .startsWith('http') // Check if the path is a URL
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(70),
                              child: Image.network(
                                pickedImagePath!,
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Handle errors for network images
                                  return Icon(
                                    Icons.error,
                                    size: 45,
                                    color: Colors.red,
                                  );
                                },
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(70),
                              child: Image.file(
                                File(pickedImagePath!),
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Handle errors for local images
                                  return Icon(
                                    Icons.error,
                                    size: 45,
                                    color: Colors.red,
                                  );
                                },
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
                readOnly: !isEditing,
                decoration: InputDecoration(labelText: 'Name'),
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) => name = value ?? '',
                // initialValue: name, // Set the initial value;
              ),
              TextFormField(
                readOnly: !isEditing,
                decoration: InputDecoration(labelText: 'Email'),
                controller: emailController,
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
                readOnly: !isEditing,
                decoration: InputDecoration(labelText: 'Phone'),
                controller: phoneController,
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
                child: IgnorePointer(
                  ignoring: !isEditing,
                  child: Row(
                    children: [
                      const Text('Gender:'),
                      Radio<Gender>(
                        value: Gender.male,
                        groupValue: selectedGender,
                        onChanged: (value) {
                          updateSelectedGender(value);
                        },
                      ),
                      const Text('Male'),
                      Radio<Gender>(
                        value: Gender.female,
                        groupValue: selectedGender,
                        onChanged: (value) {
                          updateSelectedGender(value);
                        },
                      ),
                      const Text('Female'),
                    ],
                  ),
                ),
              ),

              GestureDetector(
                onTap: isEditing ? () => _selectDateofBirth(context) : null,
                child: AbsorbPointer(
                  absorbing: !isEditing, // Set this based on your condition
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
                onTap: isEditing ? () => _selectJoiningDate(context) : null,
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
                  onChanged: isEditing
                      ? (String? value) {
                          setState(() {
                            selectedPosition = value;
                          });
                        }
                      : null,
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
                readOnly: !isEditing,
                decoration: InputDecoration(labelText: 'Account Number'),
                controller: accountNumberController,
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
                  onChanged: isEditing
                      ? (String? value) {
                          setState(() {
                            selectedBank = value;
                          });
                        }
                      : null,
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
                readOnly: !isEditing,
                decoration: InputDecoration(labelText: 'Basic Salary (RM)'),
                controller: basicSalaryController,
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
                onSaved: (value) => basicSalary = num.parse(value ?? '0'),
              ),

              // EPF No
              TextFormField(
                readOnly: !isEditing,
                decoration: InputDecoration(labelText: 'EPF No (Optional)'),
                controller: epfNoController,
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
                readOnly: !isEditing,
                decoration: InputDecoration(labelText: 'SOCSO No (Optional)'),
                controller: socsoNoController,
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
              Visibility(
                visible: isEditing,
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(229, 63, 248, 1),
                  ),
                  child: const Text('Update User'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
