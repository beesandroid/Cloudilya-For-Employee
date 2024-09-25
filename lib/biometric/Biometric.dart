import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BiometricDisplayScreen extends StatefulWidget {
  const BiometricDisplayScreen({super.key});

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
    if (fromDate == null || toDate == null) return;

    setState(() {
      isLoading = true;
    });

    final String formattedFromDate = DateFormat('yyyy-MM-dd').format(fromDate!);
    final String formattedToDate = DateFormat('yyyy-MM-dd').format(toDate!);

    final url = Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/BiometricDisplay');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "Beesdev",
        "ColCode": "0001",
        "CollegeId": "1",
        "EmployeeId": "49",
        "Fromdate": formattedFromDate,
        "ToDate": formattedToDate,
      }),
    );

    if (response.statusCode == 200) {
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
    return Card(

      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      elevation: 10,
      child: Container(
        decoration: BoxDecoration(color: Colors.white,

          borderRadius: BorderRadius.circular(25),

        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: ${data['date'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              _buildFuturisticDetail('Start Time', data['startTime']),
              _buildFuturisticDetail('End Time', data['endTime']),
              _buildFuturisticDetail('Hours', data['hours'].toString()),
              _buildFuturisticDetail('Description', data['description'] ?? 'N/A'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFuturisticDetail(String title, String? value) {
    return Row(
      children: [
        Text(
          '$title: ',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        Text(
          value ?? 'N/A',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Biometric Data',style: TextStyle(color: Colors.white),),
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
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : Column(
        children: [
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _selectDateRange(context),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),

            ),
            child: Text(
              'Select Date Range',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: biometricData.isEmpty
                ? Center(
              child: Text(
                'No Data Available',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,

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
