import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Employement extends StatefulWidget {
  const Employement({super.key});

  @override
  State<Employement> createState() => _EmployementState();
}

class _EmployementState extends State<Employement> {
  List<dynamic> _employmentList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmploymentData();
  }

  Future<void> _fetchEmploymentData() async {
    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/DisplayEmployeeEmployement'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "CollegeId": "1",
        "UserId": "1",
        "EmployeeId": "1088",
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: Text('Employee Details',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [

        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: _employmentList.length,
        itemBuilder: (context, index) {
          final item = _employmentList[index];
          return _buildEmploymentCard(item);
        },
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildEmploymentCard(dynamic item) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            offset: Offset(4, 4),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            offset: Offset(-4, -4),
            blurRadius: 10,
          ),
        ],
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[200]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item['employeeName'] ?? 'N/A', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0, color: Colors.blue)),
          SizedBox(height: 8.0),
          Text('Department: ${item['departmentName'] ?? 'N/A'}', style: TextStyle(fontSize: 16.0, color: Colors.black,fontWeight: FontWeight.bold)),
          Text('Designation: ${item['designationName'] ?? 'N/A'}', style: TextStyle(fontSize: 16.0, color: Colors.black,fontWeight: FontWeight.bold)),
          Text('Employee Type: ${item['employeeTypeName'] ?? 'N/A'}', style: TextStyle(fontSize: 16.0, color: Colors.black,fontWeight: FontWeight.bold)),
          SizedBox(height: 12.0),
          Divider(color: Colors.grey[300]),
          SizedBox(height: 8.0),
          _buildDetailRow('Start Date:', item['startDate'] ?? 'N/A'),
          _buildDetailRow('End Date:', item['endDate'] ?? 'N/A'),
          _buildDetailRow('Work Schedule:', item['workSchedule'] ?? 'N/A'),
          _buildDetailRow('Effective Date:', item['effectiveDate'] ?? 'N/A'),
          _buildDetailRow('Change Reason:', item['changeReason'] ?? 'N/A'),
          _buildDetailRow('Supervisor:', item['supervisor'] ?? 'N/A'),
          _buildDetailRow('Pay Status:', item['payStatus'].toString() ?? 'N/A'),
          _buildDetailRow('Building:', item['building'] ?? 'N/A'),
          _buildDetailRow('Floor:', item['floor'].toString() ?? 'N/A'),
          _buildDetailRow('Full Time or Part Time:', item['fullTimeorPartTime'] ?? 'N/A'),
          _buildDetailRow('Employment Type:', item['employmentTypeName'] ?? 'N/A'),
          _buildDetailRow('Working Hours Per Month:', item['workingHoursPerMonth'].toString() ?? 'N/A'),
          _buildDetailRow('Pay Type:', item['payType'].toString() ?? 'N/A'),
          _buildDetailRow('Probation Start Date:', item['probationStartDate'] ?? 'N/A'),
          _buildDetailRow('Probation End Date:', item['probationEndDate'] ?? 'N/A'),
          _buildDetailRow('Employment Commitment Start Date:', item['employmentCommitmentStartDate'] ?? 'N/A'),
          _buildDetailRow('Employment Commitment End Date:', item['employmentCommitmentEndDate'] ?? 'N/A'),
          _buildDetailRow('Designation At The Time Of Appointment:', item['designationAtTheTimeOfAppointment'].toString() ?? 'N/A'),
          _buildDetailRow('Regularization Date:', item['regularizationDate'] ?? 'N/A'),
          _buildDetailRow('Confirmation Date:', item['confirmationDate'] ?? 'N/A'),
          _buildDetailRow('Superannuation Date:', item['superannuationDate'] ?? 'N/A'),
          _buildDetailRow('Termination Date:', item['terminationDate'] ?? 'N/A'),
          _buildDetailRow('Notice Date:', item['noticeDate'] ?? 'N/A'),
          _buildDetailRow('Termination Reason:', item['terminationReason'] ?? 'N/A'),
          _buildDetailRow('User Access Revocation:', item['userAccessRevocation'] ?? 'N/A'),
          _buildDetailRow('Recommended For Rehire:', item['recommendedForRehire'] ?? 'N/A'),
          _buildDetailRow('Login IP Address:', item['loginIpAddress'] ?? 'N/A'),
          _buildDetailRow('Login System Name:', item['loginSystemName'] ?? 'N/A'),
          _buildDetailRow('Week 1:', item['week1'].toString() ?? 'N/A'),
          _buildDetailRow('Week 2:', item['week2'].toString() ?? 'N/A'),
          _buildDetailRow('Week 3:', item['week3'].toString() ?? 'N/A'),
          _buildDetailRow('Week 4:', item['week4'].toString() ?? 'N/A'),
          _buildDetailRow('Week 5:', item['week5'].toString() ?? 'N/A'),
          _buildDetailRow('Work Location:', item['workLocationName'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: TextStyle(fontSize: 16.0, color: Colors.grey[700]))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 16.0, color: Colors.black))),
        ],
      ),
    );
  }
}
