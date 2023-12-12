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
import 'dart:math';

class ViewSalaryPage extends StatefulWidget {
  final String companyId;
  final DateTime? selectedMonth;

  const ViewSalaryPage(
      {Key? key, required this.companyId, required this.selectedMonth})
      : super(key: key);

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
  String selectedBank = ' ';
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
      final userData = await ProfileRepository()
          .getPreviousUserData(widget.companyId, widget.selectedMonth!);

      logger.i(widget.selectedMonth);

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
              'Name: $name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              'CompanyID: ${widget.companyId}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              'Pay Period: 1 ${DateFormat('MMM yyyy').format(widget.selectedMonth!)} - ${DateFormat('dd MMM yyyy').format(DateTime(widget.selectedMonth!.year, widget.selectedMonth!.month + 1, 0))}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            _buildPayrollDetails(),
            SizedBox(height: 16.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildRow('Salary Credited To', selectedBank, bold: true),
            ),
            SizedBox(height: 8.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildRow('Bank Account', accountNumber, bold: true),
            ),
          ],
        ),
      ),
    );
  }

  num calculateEPF(String name) {
    num tempSalary = basicSalary;

    // // Convert tempSalary to string
    // String tempSalaryString = tempSalary.toString();

    // // Find the index of the decimal point
    // int decimalIndex = tempSalaryString.indexOf('.');

    // logger.i("decimalIndex: $decimalIndex");

    // // Initialize variables for tens place and after decimal
    // String tensPlace = '';
    // String afterDecimal = '';

    if (tempSalary <= 5000) {
      num tempSalaryWithoutHundreds;
      if (tempSalary.truncateToDouble() == tempSalary) {
        tempSalaryWithoutHundreds = tempSalary - (tempSalary % 10);
        if ((tempSalary % 100) % 20 != 0) {
          tempSalaryWithoutHundreds += 10;
        }
      } else {
        tempSalaryWithoutHundreds = tempSalary - (tempSalary % 10) + 10;
        if ((tempSalaryWithoutHundreds % 100) % 20 != 0) {
          tempSalaryWithoutHundreds += 10;
        }
      }
      // Calculate EPF based on the given name (employee or employer)
      if (name == 'employee') {
        // return checkhundred;
        return (tempSalaryWithoutHundreds * 0.11)
            .ceil(); // Round up if not an integer
      } else if (name == 'employer') {
        return (tempSalaryWithoutHundreds * 0.13)
            .ceil(); // Round up if not an integer
      }
      // // Check if tempSalary has a decimal part
      // if (decimalIndex != -1) {
      //   // Extract the two digits before the decimal and all digits after the decimal
      //   int startIndex = decimalIndex - 2 >= 0 ? decimalIndex - 2 : 0;
      //   tensPlace = tempSalaryString.substring(startIndex, decimalIndex);
      //   afterDecimal = tempSalaryString.substring(decimalIndex + 1);
      // } else {
      //   // Handle the case where tempSalary is an integer (no decimal part)
      //   int startIndex =
      //       tempSalaryString.length - 2 >= 0 ? tempSalaryString.length - 2 : 0;
      //   tensPlace = tempSalaryString.substring(startIndex);
      // }

      // logger.i('tensPlace: $tensPlace');
      // logger.i('afterDecimal: $afterDecimal');

      // // Parse the tens place and afterDecimal as doubles
      // double parsedTensPlace = double.parse(tensPlace);
      // double parsedAfterDecimal =
      //     afterDecimal.isNotEmpty ? double.parse(afterDecimal) : 0.0;

      // // Combine the parsed values
      // double lastTwoDigits =
      //     parsedTensPlace + parsedAfterDecimal / pow(10.0, afterDecimal.length);

      // // Adjust tempSalary based on conditions
      // if (lastTwoDigits > 0.0 && lastTwoDigits <= 20.0) {
      //   tempSalary = tempSalary - lastTwoDigits + 20.0;
      // } else if (lastTwoDigits > 20.0 && lastTwoDigits <= 40.0) {
      //   tempSalary = tempSalary - lastTwoDigits + 40.0;
      // } else if (lastTwoDigits > 40.0 && lastTwoDigits <= 60.0) {
      //   tempSalary = tempSalary - lastTwoDigits + 60.0;
      // } else if (lastTwoDigits > 60.0 && lastTwoDigits <= 80.0) {
      //   tempSalary = tempSalary - lastTwoDigits + 80.0;
      // } else if (lastTwoDigits > 80.0 && lastTwoDigits <= 99.99) {
      //   tempSalary = tempSalary - lastTwoDigits + 100;
      // }

      // Calculate EPF based on the given name (employee or employer)
      if (name == 'employee') {
        return (tempSalary * 0.11).ceil(); // Round up if not an integer
      } else if (name == 'employer') {
        return (tempSalary * 0.13).ceil(); // Round up if not an integer
      }
    } else {
      num tempSalaryWithoutHundreds;
      if (tempSalary.truncateToDouble() == tempSalary) {
        tempSalaryWithoutHundreds = tempSalary - (tempSalary % 100);
      } else {
        tempSalaryWithoutHundreds = tempSalary - (tempSalary % 100) + 100;
      }
      // Calculate EPF based on the given name (employee or employer)
      if (name == 'employee') {
        // return checkhundred;
        return (tempSalaryWithoutHundreds * 0.11)
            .ceil(); // Round up if not an integer
      } else if (name == 'employer') {
        return (tempSalaryWithoutHundreds * 0.12)
            .ceil(); // Round up if not an integer
      }
    }

    return 0;
  }

  num calculateEIS() {
    num wages = basicSalary;
    num baseWage = 200; // RM200 as the starting point
    num baseContribution = 0.50; // 50 sen for the base wage
    num increaseRate =
        0.20; // 20 sen increase for every RM100 increase in wages
    if (wages > 5000) wages = 5000; //capped at RM5000

    if (wages <= baseWage) {
      // If wages are RM200 or below, no EIS contribution
      return 0.0;
    } else if (wages == 200) {
      return baseContribution;
    } else if (wages > 200) {
      // Calculate the additional contribution based on the increase in wages
      num additionalContribution =
          ((wages - baseWage) / 100).floor() * increaseRate;

      // Round the result to 2 decimal places
      String totalContribution =
          (baseContribution + additionalContribution).toStringAsFixed(2);

      // Convert the result back to a num
      return num.parse(totalContribution);
    }

    return 0;
  }

  num calculateSOCSO(String name) {
    num wages = basicSalary;
    num baseWage = 200; // RM200 as the starting point
    num baseContribution = (baseWage * 2 + 100) / 2 * 0.0175;
    num rate = 0.0;
    if (wages > 5000) wages = 5000; //capped at RM5000
    if (name == 'employee') {
      rate = 0.005;
    } else if (name == 'employer') {
      rate = 0.0175;
    }

    if (wages <= baseWage) {
      // If wages are RM200 or below, use the base contribution
      return baseContribution;
    } else {
      // Remove the tens place from wages
      num adjustedWages = (wages ~/ 100) * 100;
      // Calculate the contribution based on the formula
      num firstcalculatedContribution = (((adjustedWages * 2) + 100) / 2);
      num calculatedContribution = firstcalculatedContribution * rate;

      calculatedContribution =
          double.parse(calculatedContribution.toStringAsFixed(3));

      // Check the second and third decimal points
      num secondDecimal = ((calculatedContribution * 1000) % 100).toInt();

      // Adjust the contribution based on the conditions
      if (secondDecimal == 50) {
        // If the second decimal is 5 and the third decimal is 0, do nothing
      } else if ((secondDecimal == 25)) {
        // If the second and third decimals are 25, add 0.025
        calculatedContribution += 0.025;
      } else {
        // For other cases, subtract 0.025
        calculatedContribution -= 0.025;
      }

      // Return the adjusted contribution
      return calculatedContribution;
    }
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
          _buildRow(
              'BASIC PAY(20 Days x ${(basicSalary / 20).toStringAsFixed(2)})',
              (basicSalary).toStringAsFixed(2)),
          SizedBox(height: 8.0),
          _buildRow('TOTAL OVER TIME', '125.25'),
          SizedBox(height: 8.0),
          Text(
            'OT Period(s) 01-${DateFormat('MM-yyyy').format(widget.selectedMonth!)} to ${DateFormat('dd-MM-yyyy').format(DateTime(widget.selectedMonth!.year, widget.selectedMonth!.month + 1, 0))}',
          ),
          SizedBox(height: 8.0),
          // _buildOvertimeDetails(),
          _buildRow(
              '[OT 1.5] 3.00 Hrs x ${(basicSalary / 20 / 8 * 1.5).toStringAsFixed(2)}',
              (basicSalary / 20 / 8 * 1.5 * 3.0).toStringAsFixed(2)),
          SizedBox(height: 8.0),

          _buildRow(
              '[OT 2.0] 4.00 Hrs x ${(basicSalary / 20 / 8 * 2.0).toStringAsFixed(2)}',
              (basicSalary / 20 / 8 * 2.0 * 4.0).toStringAsFixed(2)),
          SizedBox(height: 8.0),
          Text(
            'CLAIM',
          ),
          SizedBox(height: 8.0),
          _buildRow(' - MEDICAL CLAIM', '200.00'),
          _buildRow(' - TRANSPORTATION CLAIM', '200.00'),
          _buildRow(' - MEAL CLAIM', '200.00'),
          SizedBox(height: 8.0),
          _buildRow('TOTAL NO PAY', '-100.00'),
          Text(
            '[${DateFormat('yyyy-MM').format(widget.selectedMonth!)}-01 TO ${DateFormat('yyyy-MM-dd').format(DateTime(widget.selectedMonth!.year, widget.selectedMonth!.month + 1, 0))}]',
          ),
          Text('- Unpaid Leaves - 1.00 Days = 100.00'),
          SizedBox(height: 8.0),
          _buildRow('EMPLOYEE EPF',
              '${calculateEPF('employee')}.00'), //11% of the basic salary(after deduct unpaid salary)
          _buildRow('EMPLOYEE EIS',
              ('${calculateEIS()}0')), //0.2% of the basic salary
          _buildRow('EMPLOYEE SOCSO',
              ('${calculateSOCSO('employee')}')), //0.5% of the basic salary
          _buildRow('EMPLOYER EPF',
              '${calculateEPF('employer')}.00'), //13% of the basic salary(after deduct unpaid salary)
          _buildRow(
            'EMPLOYER EIS',
            ('${calculateEIS()}0'), //0.2% of the basic salary
          ),
          _buildRow('EMPLOYER SOCSO',
              ('${calculateSOCSO('employer')}')), //1.75% of the basic salary
        ],
      ),
    );
  }

  Widget _buildOvertimeDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow('[OT 1.5] 3.00 Hrs x ${basicSalary / 20 / 8 * 1.5}',
            (basicSalary / 20 / 8 * 1.5 * 3.0).toStringAsFixed(2)),
        _buildRow('[OT 2.0] 4.00 Hrs x ${basicSalary / 20 / 8 * 2.0}',
            (basicSalary / 20 / 8 * 2.0 * 4.0).toStringAsFixed(2)),
      ],
    );
  }

//   Widget _buildRow(String leftText, String rightText) {
//     return Row(
//       children: [
//         Expanded(
//           flex: 2, // Adjust the flex value as needed

//           child: Text(
//             leftText,
//             textAlign: TextAlign.left,
//           ),
//         ),
//         Expanded(
//           flex: 1,
//           child: Text(
//             rightText,
//             textAlign: TextAlign.right,
//           ),
//         ),
//       ],
//     );
//   }
// }

  Widget _buildRow(String leftText, String rightText, {bool bold = false}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            leftText,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal),
            textAlign: TextAlign.left,
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            rightText,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
