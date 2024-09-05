import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Payallotment extends StatefulWidget {
  const Payallotment({super.key});

  @override
  State<Payallotment> createState() => _PayallotmentState();
}

class _PayallotmentState extends State<Payallotment> {
  List<dynamic> _payAllotmentList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPayAllotmentData();
  }

  Future<void> _fetchPayAllotmentData() async {
    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/PayAllotmentDisplay'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "GrpCode": "Bees",
        "ColCode": "0001",
        "CollegeId": "1",
        "EmployeeId": "1088",
        "EffectiveDate": "",
        "PayAllotId": 0,
        "Flag": "VIEW"
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _payAllotmentList = data['payAllotmentList'];
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
        title: Text(
          'Pay Allotment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            color: Colors.black,
          ),
        ),
backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: _payAllotmentList.map((item) => _buildPayAllotmentCard(item)).toList(),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildPayAllotmentCard(dynamic item) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.2),
            offset: Offset(4, 4),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            offset: Offset(-4, -4),
            blurRadius: 10,
          ),
        ],
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blue[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['payTypeName'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(height: 12.0),
          _buildDetailRow('Amount/Percentage:', item['amountOrPercentageName']),
          _buildDetailRow('Calculation Type:', item['calculationTypeName']),
          _buildDetailRow('Percentage Calculated On:', item['percentageCalculatedOnName']),
          _buildDetailRow('Start Date:', item['startDate']),
          _buildDetailRow('End Date:', item['endDate']),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.blueGrey,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
