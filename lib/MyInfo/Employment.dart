import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Employment extends StatefulWidget {
  const Employment({super.key});

  @override
  State<Employment> createState() => _EmploymentState();
}

class _EmploymentState extends State<Employment> {
  List<dynamic> _employmentList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmploymentData();
  }

  Future<void> _fetchEmploymentData() async {
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
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayEmployeeEmployement'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "Beesdev",
        "ColCode": colCode,
        "CollegeId": collegeId,
        "UserId": adminUserId,
        "EmployeeId": employeeId,
        "EmploymentId": "0",
        "Department": "0",
        "StartDate": "",
        "EffectiveDate": "",
        "EndDate": "",
        "ChangeReason": "",
        "Designation": "0",
        "PayScale": "0",
        "Supervisor": "",
        "PayStatus": "0",
        "Building": "",
        "Floor": "0",
        "FullTimeorPartTime": "",
        "EmploymentType": "0",
        "WorkingHoursPerMonth": "0",
        "PayType": "0",
        "WorkSchedule": "",
        "ProbationStartDate": "",
        "ProbationEndDate": "",
        "EmploymentCommitmentStartDate": "",
        "EmploymentCommitmentEndDate": "",
        "DesignationAtTheTimeOfAppointment": "0",
        "RegularizationDate": "",
        "ConfirmationDate": "",
        "SuperannuationDate": "",
        "TerminationDate": "",
        "NoticeDate": "",
        "TerminationReason": "",
        "UserAccessRevocation": "",
        "RecommendedForRehire": "",
        "LoginIpAddress": "",
        "LoginSystemName": "",
        "Flag": "DISPLAY",
        "Week1": "0",
        "Week2": "0",
        "Week3": "0",
        "Week4": "0",
        "Week5": "0",
        "WorkLocation": "0"
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _employmentList = data['displayEmployeeEmployementList'];
        _isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load employment data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Employee Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          strokeWidth: 6.0,
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchEmploymentData,
        child: ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: _employmentList.length,
          itemBuilder: (context, index) {
            final item = _employmentList[index];
            return _buildEmploymentCard(item);
          },
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildEmploymentCard(dynamic item) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: 16.0),
      child: Card(color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        elevation: 5,
        // shadowColor: Colors.blue,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: ExpansionTile(
            title: Text(
              item['employeeName'] ?? 'N/A',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.blue.shade900,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4.0),
                Text(
                  'Department: ${item['departmentName'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14.0, color: Colors.black,fontWeight: FontWeight.bold),
                ),
                Text(
                  'Designation: ${item['designationName'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14.0, color: Colors.black,fontWeight: FontWeight.bold),
                ),
                Text(
                  'Employee Type: ${item['employeeTypeName'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14.0, color: Colors.black,fontWeight: FontWeight.bold),
                ),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
            children: [
              Divider(),
              _buildDetailRow(Icons.calendar_today, 'Start Date:', item['startDate'] ?? 'N/A'),
              _buildDetailRow(Icons.calendar_today, 'End Date:', item['endDate'] ?? 'N/A'),
              _buildDetailRow(Icons.schedule, 'Work Schedule:', item['workSchedule'] ?? 'N/A'),
              _buildDetailRow(Icons.date_range, 'Effective Date:', item['effectiveDate'] ?? 'N/A'),
              _buildDetailRow(Icons.person, 'Change Reason:', item['changeReason'] ?? 'N/A'),
              _buildDetailRow(Icons.supervisor_account, 'Supervisor:', item['supervisor'] ?? 'N/A'),
              _buildDetailRow(Icons.payment, 'Pay Status:', item['payStatus'].toString() ?? 'N/A'),
              _buildDetailRow(Icons.location_city, 'Building:', item['building'] ?? 'N/A'),
              _buildDetailRow(Icons.filter_center_focus, 'Floor:', item['floor'].toString() ?? 'N/A'),
              _buildDetailRow(Icons.access_time, 'Full Time or Part Time:', item['fullTimeorPartTime'] ?? 'N/A'),
              _buildDetailRow(Icons.work, 'Employment Type:', item['employmentTypeName'] ?? 'N/A'),
              _buildDetailRow(Icons.timer, 'Working Hours Per Month:', item['workingHoursPerMonth'].toString() ?? 'N/A'),
              _buildDetailRow(Icons.money, 'Pay Type:', item['payType'].toString() ?? 'N/A'),
              _buildDetailRow(Icons.assignment, 'Probation Start Date:', item['probationStartDate'] ?? 'N/A'),
              _buildDetailRow(Icons.assignment, 'Probation End Date:', item['probationEndDate'] ?? 'N/A'),
              _buildDetailRow(Icons.date_range, 'Employment Commitment Start Date:', item['employmentCommitmentStartDate'] ?? 'N/A'),
              _buildDetailRow(Icons.data_exploration, 'Employment Commitment End Date:', item['employmentCommitmentEndDate'] ?? 'N/A'),
              _buildDetailRow(Icons.badge, 'Designation At Appointment:', item['designationAtTheTimeOfAppointment'].toString() ?? 'N/A'),
              _buildDetailRow(Icons.check_circle, 'Regularization Date:', item['regularizationDate'] ?? 'N/A'),
              _buildDetailRow(Icons.confirmation_num, 'Confirmation Date:', item['confirmationDate'] ?? 'N/A'),
              _buildDetailRow(Icons.security, 'Superannuation Date:', item['superannuationDate'] ?? 'N/A'),
              _buildDetailRow(Icons.terminal, 'Termination Date:', item['terminationDate'] ?? 'N/A'),
              _buildDetailRow(Icons.note, 'Notice Date:', item['noticeDate'] ?? 'N/A'),
              _buildDetailRow(Icons.person, 'Termination Reason:', item['terminationReason'] ?? 'N/A'),
              _buildDetailRow(Icons.lock, 'User Access Revocation:', item['userAccessRevocation'] ?? 'N/A'),
              _buildDetailRow(Icons.recommend, 'Recommended For Rehire:', item['recommendedForRehire'] ?? 'N/A'),
              _buildDetailRow(Icons.location_on, 'Work Location:', item['workLocationName'] ?? 'N/A'),
              SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20.0, color: Colors.blue),
          SizedBox(width: 10.0),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 14.0, color: Colors.grey[700],fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontSize: 14.0, color: Colors.black,fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
