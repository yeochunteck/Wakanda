import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/data/repositories/profile_repository.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class ViewSalaryPage extends StatefulWidget {
  final String companyId;

  ViewSalaryPage({Key? key, required this.companyId}) : super(key: key);

  @override
  _ViewSalaryPageState createState() => _ViewSalaryPageState();
}

class _ViewSalaryPageState extends State<ViewSalaryPage> {
  final _formKey = GlobalKey<FormState>();
  final logger = Logger();

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

  @override
  void initState() {
    super.initState();

    // Fetch user data when the page is initialized
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final userData = await ProfileRepository().getUserData(widget.companyId);

      if (userData != null) {
        // Set the fetched user data to the state variables
        setState(() {
          name = userData['name'] ?? '';
          selectedBank = userData['bankName'] ?? '';
          accountNumber = userData['accountNumber'] ?? '';
          basicSalary = userData['basicSalary'] ?? '';
          epfNo = userData['epfNo'] ?? '';
          socsoNo = userData['socsoNo'] ?? '';

          nameController.text = name;
          accountNumberController.text = accountNumber;
          basicSalaryController.text = basicSalary.toString();
          epfNoController.text = epfNo;
          socsoNoController.text = socsoNo;
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

  Future<String> getUniqueFileName(String baseName, String extension) async {
    final directory = await getExternalStorageDirectory();
    final basePath = directory!.path;
    int suffix = 0;

    while (await File(
            '$basePath/$baseName${suffix == 0 ? '' : '($suffix)'}.$extension')
        .exists()) {
      suffix++;
    }

    return '$basePath/$baseName${suffix == 0 ? '' : '($suffix)'}.$extension';
  }

  Future<void> saveAsPDF() async {
    final pdf = pw.Document();

    // Use the font in the document
    final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text('Hello World',
              style: pw.TextStyle(font: font, fontSize: 40)),
        ),
      ),
    );

    // Get a unique file name
    final uniqueFileName = await getUniqueFileName('example', 'pdf');

    // Create a File object with the unique PDF file name
    final file = File(uniqueFileName);

    // Write the PDF content to the file
    await file.writeAsBytes(await pdf.save());

    print('PDF file path: ${file.path}');

    // TODO: Implement logic to handle the saved PDF file
  }

  // Future<void> _updateProfile() async {
  //   if (_formKey.currentState?.validate() ?? false) {
  //     _formKey.currentState?.save();

  //     if (pickedImagePath != null && pickedImagePath!.startsWith('http')) {
  //       // If it's an HTTP URL, set imageUrl directly
  //       imageUrl = pickedImagePath!;
  //       logger.i("Using existing imageUrl: $imageUrl");
  //     } else if (pickedImagePath != null) {
  //       // If it's a local file path, upload the image and get the imageUrl
  //       imageUrl = await ProfileRepository()
  //           .uploadImage(pickedImagePath!, widget.companyId);
  //       logger.i("Uploaded imageUrl: $imageUrl");
  //     } else {
  //       // Handle the case where pickedImagePath is null
  //       logger.i("Error: pickedImagePath is null");
  //     }

  //     // Update the user data with the collected data
  //     // await ProfileRepository().updateUser(

  //     // );
  //     // Navigate back to the profile page
  //     Navigator.pop(context);
  //   }
  // }

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
        title: const Text(
          'View Payroll',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt), // Use the save icon you prefer
            onPressed: saveAsPDF,
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User\nName: Ng Kai Zheng\nCompanyID: PF0001\nPay Period - 1 Apr 2023 to 30 Apr 2023',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            _buildPayrollDetails(),
            SizedBox(height: 16.0),
            Text(
              '//End of the rectangle\nSalary Credited To\nCIMB BANK\nBank Account\n12345567890',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayrollDetails() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BASIC PAY(20 Days x 100.00)                              2000.00',
          ),
          Text(
            'TOTAL OVER TIME                                                  125.25',
          ),
          Text(
            'OT Period(s) 01-04-2023 to 30-04-2023\n[2023-04-01 TO 2023-04-30 CURRENT]',
          ),
          _buildOvertimeDetails(),
          Text(
            'CLAIM\n - MEDICAL CLAIM                                                  200.00\n - TRANSPORTATION CLAIM                                 200.00\n - MEAL CLAIM                                                         200.00\nTOTAL NO PAY                                                        -100.00\n[2023-04-01 TO 2023-04-30 CURRENT]\n - Unpaid Leaves - 1.00 Days = 100.00',
          ),
          Text(
            'EMPLOYEE EPF                                                       11% of the basic salary(after deduct unpaid salary)',
          ),
          Text(
            'EMPLOYEE EIS                                                          0.2% of the basic salary',
          ),
          Text(
            'EMPLOYEE SOCSO                                                   0.5% of the basic salary',
          ),
          Text(
            'EMPLOYER EPF                                                       13% of the basic salary(after deduct unpaid salary)',
          ),
          Text(
            'EMPLOYER EIS                                                          0.2% of the basic salary',
          ),
          Text(
            'EMPLOYER SOCSO                                                   1.75% of the basic salary',
          ),
        ],
      ),
    );
  }

  Widget _buildOvertimeDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ' - [OT 1.5] 3.00 Hrs x (2000/20/8*1.5) = (2000/20/8*1.5*3.00Hrs)',
        ),
        Text(
          ' - [OT 2.0] 4.00 Hrs x (2000/20/8*2) = (2000/20/8*2*4.00Hrs)',
        ),
      ],
    );
  }
}
