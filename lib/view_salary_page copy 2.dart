import 'package:flutter/material.dart';
import 'package:flutter_application_1/create_user_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/data/repositories/profile_repository.dart';
import 'package:flutter_application_1/data/repositories/bonus_repository.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'dart:math';
import 'package:open_file/open_file.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_application_1/main.dart';

class ViewSalaryPage extends StatefulWidget {
  final String companyId;
  final DateTime selectedMonth;

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

  String pdfPath = '';
  String pdfName = '';
  final Set<int> usedNotificationIds = {};

  num bonusAmount = 0;
  String formattedBonusAmount = '';
  Future<void>? userDataFuture; // Declare the future variable

  @override
  void initState() {
    super.initState();

    // Fetch user data when the page is initialized
    userDataFuture = fetchUserData();
    // bonusFunction();
  }

  // Future<num> bonusFunction() async {}

  Future<void> fetchUserData() async {
    try {
      final userData = await ProfileRepository()
          .getPreviousUserData(widget.companyId, widget.selectedMonth);

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
        bonusAmount =
            await getBonus('${widget.companyId}', widget.selectedMonth);
        formattedBonusAmount = bonusAmount.toStringAsFixed(2);
      } else {
        // Handle the case when user data is not found
        logger.e('User data not found for companyId: ${widget.companyId}');
      }
    } catch (e) {
      // Handle errors during data fetching
      logger.e('Error fetching user data: $e');
    }
  }

  // Future<String> getUniqueFileName(String baseName, String extension) async {
  //   final directory = await getExternalStorageDirectory();
  //   final basePath = directory!.path;
  //   int suffix = 0;

  //   while (await File(
  //           '$basePath/$baseName${suffix == 0 ? '' : '($suffix)'}.$extension')
  //       .exists()) {
  //     suffix++;
  //   }

  //   return '$basePath/$baseName${suffix == 0 ? '' : '($suffix)'}.$extension';
  // }

  Future<String> getUniqueFileName(String baseName, String extension) async {
    final directory = '/storage/emulated/0/Download';
    final basePath = directory;
    int suffix = 0;

    while (await File(
            '$basePath/$baseName${suffix == 0 ? '' : '($suffix)'}.$extension')
        .exists()) {
      suffix++;
    }

    // pdfPath = '$basePath/$baseName${suffix == 0 ? '' : '($suffix)'}.$extension';
    pdfName = '$baseName${suffix == 0 ? '' : '($suffix)'}.$extension';
    return '$basePath/$baseName${suffix == 0 ? '' : '($suffix)'}.$extension';
  }

  // Future<void> showNotification() async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     'your_channel_id',
  //     'your_channel_name',
  //     channelDescription: 'your_channel_description',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);

  //   // Change 'pdf_path' to the actual path of your PDF file
  //   // String pdfPath = 'pdf_path';

  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     '${name}_SalarySlip_${DateFormat('MMMMyyyy').format(widget.selectedMonth!)}.pdf Download Complete',
  //     'Tap to open the PDF',
  //     platformChannelSpecifics,
  //     payload: pdfPath,
  //   );
  // }

  // Future<bool> saveAsPDF() async {
  //   final pdf = pw.Document();

  //   // Use the font in the document
  //   final font = await PdfGoogleFonts.nunitoExtraLight();

  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) => pw.Center(
  //         child: pw.Text('Hello World',
  //             style: pw.TextStyle(font: font, fontSize: 40)),
  //       ),
  //     ),
  //   );

  //   try {
  //     final downloadPath = '/storage/emulated/0/Download';

  //     // Create a unique file name within the "Download" directory
  //     // final uniqueFileName = await getUniqueFileName(
  //     //     '${name}_SalarySlip_${DateFormat('MMMMyyyy').format(widget.selectedMonth!)}',
  //     //     'pdf');
  //     final uniqueFileName =
  //         '$downloadPath/${name}_SalarySlip_${DateFormat('MMMMyyyy').format(widget.selectedMonth!)}.pdf';

  //     // Create a File object with the unique PDF file name
  //     final file = File(uniqueFileName);

  //     // Write the PDF content to the file
  //     await file.writeAsBytes(await pdf.save());

  //     logger.i('PDF file path: ${file.path}');

  //     // Open the file only if the download was successful
  //     OpenFile.open(file.path);
  //     // showNotification();

  //     // TODO: Implement logic to handle the saved PDF file

  //     return true; // Download successful
  //   } catch (e) {
  //     logger.e('Error saving PDF: $e');
  //     return false; // Download failed
  //   }
  // }

  Future<void> showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Change 'pdf_path' to the actual path of your PDF file
    // String pdfPath = 'pdf_path';
    final Set<int> usedNotificationIds = {};
    Random random = Random();
    int notificationId;

    // Generate a unique notification ID
    do {
      notificationId = random.nextInt(999999);
    } while (usedNotificationIds.contains(notificationId));

    // Add the used ID to the set
    usedNotificationIds.add(notificationId);

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      '$pdfName Download Complete',
      'Tap to open the PDF',
      platformChannelSpecifics,
      payload: pdfPath,
    );
  }

  Future<bool> saveAsPDF() async {
    final pdf = pw.Document();

    // Use the font in the document
    final font = await PdfGoogleFonts.nunitoExtraLight();

    // pw.Row _buildInfoRow(String label, num value, {bool isInteger = false}) {
    //   final pw.BorderSide borderSide = pw.BorderSide(
    //     color: PdfColors.black, // You can customize the color
    //     width: 1.0, // Adjust the border width as needed
    //   );

    //   return pw.Row(
    //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    //     children: [
    //       pw.Container(
    //         decoration: pw.BoxDecoration(
    //           border: pw.Border(bottom: borderSide),
    //         ),
    //         child: pw.Text(label, style: pw.TextStyle(fontSize: 14)),
    //       ),
    //       pw.Container(
    //         decoration: pw.BoxDecoration(
    //           border: pw.Border(bottom: borderSide),
    //         ),
    //         child: pw.Text(
    //           'RM ${isInteger ? value.toInt() : value.toStringAsFixed(2)}',
    //           style: pw.TextStyle(fontSize: 14),
    //         ),
    //       ),
    //     ],
    //   );
    // }
    // pw.Table _buildInfoTable(String label, num value,
    //     {bool isInteger = false}) {
    //   final pw.TableBorder border = pw.TableBorder.all(
    //     color: PdfColors.grey, // Customize the color
    //     width: 0.5, // Adjust the border width as needed
    //   );

    //   return pw.Table(
    //     border: border,
    //     children: [
    //       pw.TableRow(
    //         children: [
    //           pw.Container(
    //             width: 150,
    //             padding: const pw.EdgeInsets.all(8),
    //             child: pw.Text(label, style: pw.TextStyle(fontSize: 14)),
    //           ),
    //           pw.Container(
    //             width: 150,
    //             padding: const pw.EdgeInsets.all(8),
    //             child: pw.Text(
    //               'RM ${isInteger ? value.toInt() : value.toStringAsFixed(2)}',
    //               style: pw.TextStyle(fontSize: 14),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ],
    //   );
    // }

    pw.Table _buildInfoTable(String label, String value, bool alignRight) {
      final pw.TableBorder border = pw.TableBorder.all(
        color: PdfColors.grey, // Customize the color
        width: 0.5, // Adjust the border width as needed
      );

      return pw.Table(
        border: border,
        children: [
          pw.TableRow(
            children: [
              pw.Container(
                width: 140,
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(label, style: pw.TextStyle(fontSize: 12)),
              ),
              pw.Container(
                width: 360,
                padding: const pw.EdgeInsets.all(5),
                alignment: alignRight
                    ? pw.Alignment.centerRight
                    : pw.Alignment.centerLeft,
                child: pw.Text(
                  value,
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      );
    }

    pw.Table _build4ColumnTable(
        String label, num hour, num rate, String inputString, bool alignRight) {
      final pw.TableBorder border = pw.TableBorder.all(
        color: PdfColors.grey, // Customize the color
        width: 0.5, // Adjust the border width as needed
      );

      return pw.Table(
        border: border,
        children: [
          pw.TableRow(
            children: [
              pw.Container(
                width: 140,
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(label, style: pw.TextStyle(fontSize: 12)),
              ),
              pw.Container(
                width: 120,
                padding: const pw.EdgeInsets.all(5),
                alignment: alignRight
                    ? pw.Alignment.centerRight
                    : pw.Alignment.centerLeft,
                child: pw.Text(
                  hour.toStringAsFixed(2),
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.Container(
                width: 120,
                padding: const pw.EdgeInsets.all(5),
                alignment: alignRight
                    ? pw.Alignment.centerRight
                    : pw.Alignment.centerLeft,
                child: pw.Text(
                  (inputString == "OT")
                      ? (basicSalary / 20 / 8 * rate).toStringAsFixed(2)
                      : (rate).toStringAsFixed(2),
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.Container(
                width: 120,
                padding: const pw.EdgeInsets.all(5),
                alignment: alignRight
                    ? pw.Alignment.centerRight
                    : pw.Alignment.centerLeft,
                child: pw.Text(
                  (inputString == "OT")
                      ? (hour * (basicSalary / 20 / 8 * rate))
                          .toStringAsFixed(2)
                      : (hour + rate).toStringAsFixed(2),
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      );
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                color: PdfColors.grey200, // Set your desired background color
                child: pw.Row(
                  children: [
                    pw.Text(
                      'Pay Slip for Period Ending',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    pw.Positioned(
                      right: 0,
                      bottom: 0,
                      child: pw.Text(
                        ' ${DateFormat('MMMM yyyy').format(widget.selectedMonth)} (Monthly)',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 14,
                          color: PdfColors.blue,
                        ),
                      ),
                    ),
                    pw.Positioned(
                      right: 0,
                      bottom: 0,
                      child: pw.Text(
                        ' (RM)',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 14,
                          color: PdfColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              _buildInfoTable('CompanyID:', '${widget.companyId}', false),
              _buildInfoTable('Name:', '$name', false),
              _buildInfoTable('Payment Method:',
                  '$selectedBank (Account: $accountNumber)', false),
              // Content
              pw.SizedBox(height: 15),
              // pw.Text('Employee Details:',
              //     style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              _buildInfoTable(
                  'Basic Salary', basicSalary.toStringAsFixed(2), true),

              _buildInfoTable('Total Overtime', '5.0', true),

              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey, // Customize the color
                  width: 0.5, // Adjust the border width as needed
                ),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Container(
                          width: 140,
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'Description',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          )),
                      pw.Container(
                        width: 120,
                        padding: const pw.EdgeInsets.all(5),
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'Hours',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 120,
                        padding: const pw.EdgeInsets.all(5),
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'HourlyPay',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 120,
                        padding: const pw.EdgeInsets.all(5),
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'Sub-Total',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              _build4ColumnTable('[OT1.5]', 3, 1.5, 'OT', true),
              _build4ColumnTable('[OT2.0]', 3, 2.0, 'OT', true),
              _buildInfoTable('Medical Claim', '200.0', true),
              _buildInfoTable('Meal Claim', '300.0', true),
              _buildInfoTable('Total No Pay', '-100', true),
              _buildInfoTable('Bonus', formattedBonusAmount, true),
              _buildInfoTable(
                  'Statutory Contribution',
                  '${(calculateEPF('employer') + calculateEPF('employee') + calculateSOCSO('employer') + calculateSOCSO('employee') + (calculateEIS() * 2.0)).toStringAsFixed(2)}',
                  true),

              _buildInfoTable('Net Salary', '-100', true),
              pw.SizedBox(height: 10),
              pw.Text('Statutory Contribution:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              _build4ColumnTable('EPF:', calculateEPF('employer'),
                  calculateEPF('employee'), 'statutory', true),
              _build4ColumnTable('SOCSO:', calculateSOCSO('employer'),
                  calculateSOCSO('employee'), 'statutory', true),
              _build4ColumnTable(
                  'EIS:', calculateEIS(), calculateEIS(), 'statutory', true),
              _build4ColumnTable(
                  'Total:',
                  calculateEPF('employer') +
                      calculateSOCSO('employer') +
                      calculateEIS(),
                  calculateEPF('employee') +
                      calculateSOCSO('employee') +
                      calculateEIS(),
                  'statutory',
                  true),
              // _buildInfoTable(
              //     'EPF (Employee)', '${calculateEPF('employee')}', true),
              // _buildInfoTable(
              //     'EPF (Employer)', '${calculateEPF('employer')}', true),
              // _buildInfoTable('EIS (Employee)', '${calculateEIS()}', true),
              // _buildInfoTable(
              //     'SOCSO (Employee)', '${calculateSOCSO('employee')}', true),
              pw.SizedBox(height: 10),
              // pw.Text(
              //   'Total Deductions: ${calculateEPF('employer') + calculateEPF('employee') + calculateSOCSO('employer') + calculateSOCSO('employee') + (calculateEIS() * 2.0)} ',
              //   style:
              //       pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
              // ),
            ],
          );
        },
      ),
    );

    try {
      // final downloadPath = '/storage/emulated/0/Download';

      // Create a unique file name within the "Download" directory
      final uniqueFileName = await getUniqueFileName(
          '${name}_SalarySlip_${DateFormat('MMMMyyyy').format(widget.selectedMonth)}',
          'pdf');
      // final uniqueFileName =
      //     '$downloadPath/${name}_SalarySlip_${DateFormat('MMMMyyyy').format(widget.selectedMonth!)}.pdf';

      // Create a File object with the unique PDF file name
      final file = File(uniqueFileName);

      // Write the PDF content to the file
      await file.writeAsBytes(await pdf.save());

      logger.i('PDF file path: ${file.path}');

      pdfPath = file.path;
      // Open the file only if the download was successful
      // OpenFile.open(file.path);
      showNotification();

      // TODO: Implement logic to handle the saved PDF file

      return true; // Download successful
    } catch (e) {
      logger.e('Error saving PDF: $e');
      return false; // Download failed
    }
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
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt), // Use the save icon you prefer
            onPressed: saveAsPDF,
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: userDataFuture, // Replace with your data fetching function
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading data: ${snapshot.error}'),
            );
          } else {
            // Continue with your UI when data is available
            return Container(
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
                    'Pay Period: 1 ${DateFormat('MMM yyyy').format(widget.selectedMonth)} - ${DateFormat('dd MMM yyyy').format(DateTime(widget.selectedMonth.year, widget.selectedMonth.month + 1, 0))}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  _buildPayrollDetails(),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildRow('Salary Credited To', selectedBank,
                        bold: true),
                  ),
                  SizedBox(height: 8.0),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildRow('Bank Account', accountNumber, bold: true),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  num calculateEPF(String name) {
    num tempSalary = basicSalary + bonusAmount;

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
    num wages = basicSalary + bonusAmount;
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
    num wages = basicSalary + bonusAmount;
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

  num calculateStatutoryContribution() {
    return calculateEPF('employer') +
        calculateEPF('employee') +
        calculateSOCSO('employer') +
        calculateSOCSO('employee') +
        (calculateEIS() * 2.0);
  }

  num calculateNetSalary() {
    return basicSalary + bonusAmount - calculateStatutoryContribution();
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
            'OT Period(s) 01-${DateFormat('MM-yyyy').format(widget.selectedMonth)} to ${DateFormat('dd-MM-yyyy').format(DateTime(widget.selectedMonth.year, widget.selectedMonth.month + 1, 0))}',
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
          _buildRow('BONUS', formattedBonusAmount),
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
            '[${DateFormat('yyyy-MM').format(widget.selectedMonth)}-01 TO ${DateFormat('yyyy-MM-dd').format(DateTime(widget.selectedMonth.year, widget.selectedMonth.month + 1, 0))}]',
          ),
          Text('- Unpaid Leaves - 1.00 Days = 100.00'),
          Text('- Insufficient Hours Fine - 1.8 Hours = 254.75'),
          SizedBox(height: 8.0),
          _buildRow('STATUTORY CONTRIBUTION',
              (calculateStatutoryContribution().toStringAsFixed(2))),
          SizedBox(height: 8.0),
          _buildRow('- EMPLOYEE EPF',
              '${calculateEPF('employee')}.00'), //11% of the basic salary(after deduct unpaid salary)
          _buildRow('- EMPLOYEE EIS',
              ('${calculateEIS()}0')), //0.2% of the basic salary
          _buildRow('- EMPLOYEE SOCSO',
              ('${calculateSOCSO('employee')}')), //0.5% of the basic salary
          _buildRow('- EMPLOYER EPF',
              '${calculateEPF('employer')}.00'), //13% of the basic salary(after deduct unpaid salary)
          _buildRow(
            '- EMPLOYER EIS',
            ('${calculateEIS()}0'), //0.2% of the basic salary
          ),
          _buildRow('- EMPLOYER SOCSO',
              ('${calculateSOCSO('employer')}')), //1.75% of the basic salary
          SizedBox(height: 16.0),

          _buildRow('NET SALARY',
              (calculateNetSalary().toStringAsFixed(2))), //Net Salary
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
