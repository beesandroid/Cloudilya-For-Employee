import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PayAllotment extends StatefulWidget {
  const PayAllotment({Key? key}) : super(key: key);

  @override
  State<PayAllotment> createState() => _PayAllotmentState();
}

class _PayAllotmentState extends State<PayAllotment> with SingleTickerProviderStateMixin {
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
        "GrpCode": "Beesdev",
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          'Pay Allotment',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0,color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blue.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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

  const ExpandableCard({Key? key, required this.item}) : super(key: key);

  @override
  _ExpandableCardState createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _heightAnimation = Tween<double>(begin: 0, end: 100).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
          _isExpanded ? _controller.forward() : _controller.reverse();
        });
      },
      child: Card(color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        child: Column(
          children: [
            ListTile(
              title: Text(
                item['payTypeName'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              trailing: AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.expand_more, size: 30, color: Colors.black),
              ),
            ),
            SizeTransition(
              sizeFactor: _controller,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Column(
                  children: [
                    _buildDetailRow('Amount/Percentage:', item['amountOrPercentageName']),
                    _buildDetailRow('Calculation Type:', item['calculationTypeName']),
                    _buildDetailRow('Percentage Calculated On:', item['percentageCalculatedOnName']),
                    _buildDetailRow('Start Date:', item['startDate']),
                    _buildDetailRow('End Date:', item['endDate']),
                  ],
                ),
              ),
            ),
          ],
        ),
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
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          Text(
            value ?? 'N/A',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
