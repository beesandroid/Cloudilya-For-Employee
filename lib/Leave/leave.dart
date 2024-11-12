import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LeaveService {
  final String _baseUrl =
      'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/SaveEmployeeLeaves';

  Future<List<dynamic>> fetchLeaveTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userType');
    final finYearId = prefs.getInt('finYearId');
    final acYearId = prefs.getInt('acYearId');
    final adminUserId = prefs.getString('adminUserId');
    final acYear = prefs.getString('acYear');
    final finYear = prefs.getString('finYear');
    final employeeId = prefs.getInt('employeeId');
    final collegeId = prefs.getString('collegeId');
    final colCode = prefs.getString('colCode');
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(
          {
        "GrpCode": "beesdev",
        "ColCode": colCode,
        "CollegeId": collegeId,
        "EmployeeId": employeeId,
        "LeaveId": "0",
        "Description": "",
        "Balance": "0",
        "Flag": "DISPLAY",
      }
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('API Response: $data'); // Log the entire response to inspect the structure
      return data['employeeLeavesDisplayList'] as List<dynamic>;
    } else {
      throw Exception('Failed to load leave types');
    }
  }



  Future<Map<String, dynamic>> fetchHostelData() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userType');
    final finYearId = prefs.getInt('finYearId');
    final acYearId = prefs.getInt('acYearId');
    final adminUserId = prefs.getString('adminUserId');
    final acYear = prefs.getString('acYear');
    final finYear = prefs.getString('finYear');
    final employeeId = prefs.getInt('employeeId');
    final collegeId = prefs.getString('collegeId');
    final colCode = prefs.getString('colCode');
    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayHostelRegistration'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": "Beesdev",
        "ColCode": "0001",
        "AcYear": acYear,
        "UserTypeName": userType,
        "RegistrationDate": "",
        "StudentId": "1679",
        "HostelId": "0",
        "RoomTypeId": "0",
        "RoomId": "0"
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

}
