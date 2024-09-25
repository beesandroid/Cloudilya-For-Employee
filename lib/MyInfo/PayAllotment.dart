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
        title: Text(
          'Pay Allotment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: _payAllotmentList.map((item) => ExpandableCard(item: item)).toList(),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class ExpandableCard extends StatefulWidget {
  final dynamic item;

  const ExpandableCard({super.key, required this.item});

  @override
  _ExpandableCardState createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return
      AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        margin: EdgeInsets.all(16.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 15.0, // Increased blur radius for more pronounced shadow
              spreadRadius: 5.0, // Spread the shadow outwards
              offset: Offset(0, 5), // Shadow offset
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['payTypeName'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                      color: Colors.black,
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            if (_isExpanded) ...[
              SizedBox(height: 12.0),
              _buildDetailRow('Amount/Percentage:', item['amountOrPercentageName']),
              _buildDetailRow('Calculation Type:', item['calculationTypeName']),
              _buildDetailRow('Percentage Calculated On:', item['percentageCalculatedOnName']),
              _buildDetailRow('Start Date:', item['startDate']),
              _buildDetailRow('End Date:', item['endDate']),
            ],
          ],
        ),

      );}

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            value ?? 'N/A',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
