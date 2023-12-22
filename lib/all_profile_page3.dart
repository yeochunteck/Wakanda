import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_application_1/data/repositories/profile_repository.dart';
import 'package:flutter_application_1/profile_page.dart';

class SalaryPage extends StatelessWidget {
  final logger = Logger();

  @override
  Widget build(BuildContext context) {
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
          'Salary Page',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ProfileRepository().getAllUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While data is being fetched
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // If there's an error
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // If there's no data
            return Center(child: Text('No users found'));
          } else {
            // If data is available
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final userData = snapshot.data![index];
                return buildEmployeeRectangle(context, userData);
              },
            );
          }
        },
      ),
    );
  }

  Widget buildEmployeeRectangle(
      BuildContext context, Map<String, dynamic> userData) {
    return GestureDetector(
      onTap: () {
        // Navigate to the ProfilePage with the selected companyId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(companyId: userData['companyId']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Left side: Employee details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ${userData['name']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Email: ${userData['email']}'),
                  // Add more details as needed
                ],
              ),
            ),

            // Right side: Profile image
            SizedBox(width: 16),
            CircleAvatar(
              radius: 50,
              // backgroundColor: Colors.grey[300],
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  userData['image'] ??
                      '', // Use the image URL if available, otherwise an empty string
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Handle errors, e.g., display a default icon
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // Person Icon
                      children: const [
                        Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        ),
                        Text(
                          'No Image',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
