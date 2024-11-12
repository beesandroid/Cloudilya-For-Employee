import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/_http/utils/body_decoder.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart'; // For progress indicators
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For icons

class BiometricDisplayScreen extends StatefulWidget {
  const BiometricDisplayScreen({Key? key}) : super(key: key);

  @override
  State<BiometricDisplayScreen> createState() => _BiometricDisplayScreenState();
}

class _BiometricDisplayScreenState extends State<BiometricDisplayScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  List<dynamic> biometricData = [];
  bool isLoading = false;

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      helpText: 'Select Date Range',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,

            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked.start != fromDate && picked.end != toDate) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
      });
      _fetchBiometricData();
    }
  }

  Future<void> _fetchBiometricData() async {
    final prefs = await SharedPreferences.getInstance();
    // Fetch required preferences here...

    if (fromDate == null || toDate == null) return;

    setState(() {
      isLoading = true;
    });

    final String formattedFromDate = DateFormat('yyyy-MM-dd').format(fromDate!);
    final String formattedToDate = DateFormat('yyyy-MM-dd').format(toDate!);

    final requestBody = {
      "GrpCode": "Beesdev",
      "ColCode": prefs.getString('colCode'),
      "CollegeId": prefs.getString('collegeId'),
      "EmployeeId": prefs.getInt('employeeId'),
      "Fromdate": formattedFromDate,
      "ToDate": formattedToDate,
    };

    print("Request body: ${jsonEncode(requestBody)}"); // Print request body here

    final url = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/BiometricDisplay');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    print(response);

    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        biometricData = json.decode(response.body)['biometricDisplayList'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data')),
      );
    }
  }


  Widget _buildBiometricCard(Map<String, dynamic> data) {
    // Parse start and end times, handling possible null values
    String startTimeStr = data['startTime'] ?? '--:--';
    String endTimeStr = data['endTime'] ?? '--:--';
    String date=data['date'];


    // Calculate progress using the 'hours' field
    double progress = 0.0;
    if (data['hours'] != null) {
      double totalHours = double.tryParse(data['hours'].toString()) ?? 0.0;
      progress = totalHours / 8.5;
      progress = progress.clamp(0.0, 1.0);
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date
          Text(
              date,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          // Start and End Times
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeWithIcon(
                FontAwesomeIcons.solidClock,
                'Start Time',
                startTimeStr,
                Colors.green,
              ),
              _buildTimeWithIcon(
                FontAwesomeIcons.solidClock,
                'End Time',
                endTimeStr,
                Colors.redAccent,
              ),
            ],
          ),
          SizedBox(height: 6),
          // Progress Indicator
          LinearPercentIndicator(
            lineHeight: 16.0,
            percent: progress,
            backgroundColor: Colors.grey,
            progressColor: Colors.green,
            barRadius: Radius.circular(3),
            center: progress > 0
                ? Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 10, color: Colors.white),
            )
                : null,
          ),
          SizedBox(height: 6),
          // Total Hours
          Text(
            'Total Hours: ${data['hours'] ?? '0'} hrs',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  Widget _buildTimeWithIcon(
      IconData icon, String label, String time, Color color) {
    return Row(
      children: [
        FaIcon(
          icon,
          color: color,
          size: 14,
        ),
        SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Biometric Data',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.blueAccent,
        ),
      )
          : Column(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => _selectDateRange(context),
                  style: ElevatedButton.styleFrom(
                    padding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Select Date Range',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          Expanded(
            child: biometricData.isEmpty
                ? Center(
              child: Text(
                'Select Date Range',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
            )
                : ListView.builder(
              itemCount: biometricData.length,
              itemBuilder: (context, index) {
                return _buildBiometricCard(biometricData[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
