/*import 'dart:convert';
import 'package:http/http.dart' as http;


Future<Map<String, dynamic>> fetchHolidays() async {
  final String apiUrl = 'https://holidayapi.com/v1/holidays';
  final Map<String, String> queryParams = {
    'country': 'MY',
    'year': '2023',
    'pretty': '',
    'key': '211105c6-806d-4149-94b0-71a3caedf9f5',
  };

  final Uri uri = Uri.parse(apiUrl).replace(queryParameters: queryParams);

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    throw Exception('Failed to fetch holidays');
  }
}

// Usage
void getHolidays() async {
  try {
    Map<String, dynamic> holidays = await fetchHolidays();
    print('Fetched holidays: $holidays');
    // Handle the retrieved holiday data here
  } catch (e) {
    print('Error fetching holidays: $e');
    // Handle errors here
  }
}

Future<bool> isPublicHoliday(DateTime currentDate) async {
  final String apiUrl = 'https://holidayapi.com/v1/holidays'; // Replace with your API endpoint

  // Make an API request to fetch holiday data
  final response = await http.get(Uri.parse('$apiUrl/holidays'));
  
  if (response.statusCode == 200) {
    // Parse the response JSON
    final List<dynamic> holidays = json.decode(response.body);

    // Check if the current date matches any holiday date
    String formattedCurrentDate = DateFormat('yyyy-MM-dd').format(currentDate);
    return holidays.any((holiday) => holiday['date'] == formattedCurrentDate);
  } else {
    // Handle API request errors
    throw Exception('Failed to fetch holiday data');
  }
}

// Usage within your check-in/out function
bool isHoliday = await isPublicHoliday(DateTime.now());
if (isHoliday) {
    // Handle the case where it's a public holiday
} else {
    // Proceed with the regular check-in/out logic
}
*/