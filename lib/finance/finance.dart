import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FinanceScreen extends StatefulWidget {
  @override
  _FinanceScreenState createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  Map<String, dynamic> _data = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }
  Future<void> _fetchData() async {
    final Uri apiUrl = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/FinancePayIncometaxDisplay');
    final headers = {
      'Content-Type': 'application/json',
    };
    final requestBody = jsonEncode({
      "GrpCode": "Beesdev",
      "ColCode": "0001",
      "CollegeId": "1",
      "EmployeeId": "1088",
      "Year": "0",
      "Month": "0",
      "FinYear": "2024 - 2025"
    });

    try {
      final response = await http.post(apiUrl, headers: headers, body: requestBody);

      if (response.statusCode == 200) {
        setState(() {
          _data = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(

      appBar: AppBar(

        title: Text('Finance', style: TextStyle(color: Colors.white)),

        elevation: 0,

        titleTextStyle: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
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
          ? Center(child: CircularProgressIndicator())
          : ListView(
        padding: EdgeInsets.all(8),
        children: [
          _buildSection('Income Tax Details', _buildIncomeTaxDetails()),
          SizedBox(height: 20),
          _buildSection('Income Tax Deduction Details', _buildIncomeTaxDetailList()),
          SizedBox(height: 20),
          _buildSection('Tax Slabs', _buildTaxSlabList()),
          SizedBox(height: 20),
          _buildSection('Monthly Tax Details', _buildMonthlyTaxDetails()),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: content,
        ),
      ],
    );
  }

  Widget _buildIncomeTaxDetails() {
    if (_data.containsKey('financePayIncometaxDisplayList')) {
      var items = _data['financePayIncometaxDisplayList'] as List<dynamic>;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          headingRowColor: MaterialStateColor.resolveWith(
                  (states) => Colors.blue.withOpacity(0.1)),
          dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
          columns: [
            DataColumn(label: Text('Pay Type')),
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('First Month')),
            DataColumn(label: Text('Second Month')),
            DataColumn(label: Text('Third Month')),
            DataColumn(label: Text('Fourth Month')),
            DataColumn(label: Text('Fifth Month')),
            DataColumn(label: Text('Sixth Month')),
            DataColumn(label: Text('Seventh Month')),
            DataColumn(label: Text('Eighth Month')),
            DataColumn(label: Text('Ninth Month')),
            DataColumn(label: Text('Tenth Month')),
            DataColumn(label: Text('Eleventh Month')),
            DataColumn(label: Text('Twelfth Month')),
          ],
          rows: items.map<DataRow>((item) {
            return DataRow(
              cells: [
                DataCell(Text(item['payType'] ?? 'Unknown')),
                DataCell(Text('${item['total'] ?? '0.0'}')),
                DataCell(Text('${item['firstMonth']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['secondMonth']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['thirdMonth']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['fourthMonth']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['fifthMonth']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['sixthMonth']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['seventhMonth']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['eighthMonth']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['ninthMonth']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['tenthMonth']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['eleventhMonth']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['twelfthMonth']?.toStringAsFixed(1) ?? '0.0'}')),
              ],
            );
          }).toList(),
        ),
      );
    }
    return SizedBox.shrink();
  }
  Widget _buildIncomeTaxDetailList() {
    if (_data.containsKey('financePayIncometaxDisplayList1')) {
      var items = _data['financePayIncometaxDisplayList1'] as List<dynamic>;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Enable horizontal scrolling
        child: DataTable(
          columnSpacing: 16,
          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue.withOpacity(0.1)),
          dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
          columns: [
            DataColumn(label: Text('Section Name')),
            DataColumn(label: Text('Deduction Name')),
            DataColumn(label: Text('Usage / Less')),
          ],
          rows: items.map<DataRow>((item) {
            return DataRow(
              cells: [
                DataCell(Text(item['sectionName'] ?? 'Unknown')),
                DataCell(Text(item['deductionName'] ?? 'Unknown')),
                DataCell(Text(
                    'Usage: ${item['usage'] ?? '0.0'},\n Less: ${item['less'] ?? '0.0'}')),
              ],
            );
          }).toList(),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildTaxSlabList() {
    if (_data.containsKey('financePayIncometaxDisplayList2')) {
      var items = _data['financePayIncometaxDisplayList2'] as List<dynamic>;

      return SingleChildScrollView(
        child: Column(
          children: items.map<Widget>((item) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Slab: ${item['slab'] ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Amount: ${item['amount'] ?? '0.0'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Total Tax: ${item['totalTax'] ?? '0.0'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cess: ${item['cess'] ?? '0.0'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gross Income Tax: ${item['grossincomeTax'] ?? '0.0'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }
    return Center(child: Text('No tax slab data available.', style: TextStyle(color: Colors.grey)));
  }

  Widget _buildMonthlyTaxDetails() {
    if (_data.containsKey('financePayIncometaxDisplayList3')) {
      var items = _data['financePayIncometaxDisplayList3'] as List<dynamic>;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue.withOpacity(0.1)),
          dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
          columns: [
            DataColumn(label: Text('Month')),
            DataColumn(label: Text('First Month')),
            DataColumn(label: Text('Second Month')),
            DataColumn(label: Text('Third Month')),
            DataColumn(label: Text('Fourth Month')),
            DataColumn(label: Text('Fifth Month')),
            DataColumn(label: Text('Sixth Month')),
            DataColumn(label: Text('Seventh Month')),
            DataColumn(label: Text('Eighth Month')),
            DataColumn(label: Text('Ninth Month')),
            DataColumn(label: Text('Tenth Month')),
            DataColumn(label: Text('Eleventh Month')),
            DataColumn(label: Text('Twelfth Month')),
          ],
          rows: items.map<DataRow>((item) {
            return DataRow(
              cells: [
                DataCell(Text(item['month'] ?? 'Unknown')),
                DataCell(Text('${item['firstMonth1']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['secondMonth2']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['thirdMonth3']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['fourthMonth4']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['fifthMonth5']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['sixthMonth6']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['seventhMonth7']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['eighthMonth8']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['ninthMonth9']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['tenthMonth10']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['eleventhMonth11']?.toStringAsFixed(1) ?? '0.0'}')),
                DataCell(Text('${item['twelfthMonth12']?.toStringAsFixed(1) ?? '0.0'}')),
              ],
            );
          }).toList(),
        ),
      );
    }
    return SizedBox.shrink();
  }
}
