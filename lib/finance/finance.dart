import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
    final Uri apiUrl = Uri.parse(
        'https://beessoftware.cloud/CoreAPIPreProd/CloudilyaMobileAPP/FinancePayIncometaxDisplay');
    final headers = {
      'Content-Type': 'application/json',
    };
    final requestBody = jsonEncode({
      "GrpCode": "Beesdev",
      "ColCode": colCode,
      "CollegeId": collegeId,
      "EmployeeId": employeeId,
      "Year": "0",
      "Month": "0",
      "FinYear": finYear
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
    return Scaffold(
      appBar: AppBar(iconTheme: IconThemeData(color: Colors.white),
        title: Text('Finance',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 22),),
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
          _buildSection('Income Tax Deduction Details', _buildIncomeTaxDetailList()),
          _buildSection('Tax Slabs', _buildTaxSlabList()),
          _buildSection('Monthly Tax Details', _buildMonthlyTaxDetails()),
          SizedBox(height: 55,)
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text(
            title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        content,
      ],
    );
  }

  Widget _buildIncomeTaxDetails() {
    if (_data.containsKey('financePayIncometaxDisplayList')) {
      var items = _data['financePayIncometaxDisplayList'] as List<dynamic>;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateColor.resolveWith(
                  (states) => Colors.blue.withOpacity(0.1)),
          columns: [
            DataColumn(label: Text('Pay Type')),
            DataColumn(label: Text('Total')),
            for (int i = 1; i <= 12; i++) DataColumn(label: Text('Month $i')),
          ],
          rows: items.map<DataRow>((item) {
            return DataRow(
              cells: [
                DataCell(Text(item['payType'] ?? 'Unknown')),
                DataCell(Text('${item['total'] ?? '0.0'}')),
                for (int i = 1; i <= 12; i++)
                  DataCell(Text('${item['month$i']?.toStringAsFixed(1) ?? '0.0'}')),
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
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateColor.resolveWith(
                  (states) => Colors.blue.withOpacity(0.1)),
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
                    'Usage: ${item['usage'] ?? '0.0'}, Less: ${item['less'] ?? '0.0'}')),
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
      return Column(
        children: items.map<Widget>((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: double.maxFinite,
                    child: Text('Slab: ${item['slab'] ?? 'Unknown'}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),

                  Text('Amount: ${item['amount'] ?? '0.0'}'),
                  Text('Total Tax: ${item['totalTax'] ?? '0.0'}'),
                  Text('Cess: ${item['cess'] ?? '0.0'}'),
                  Text('Gross Income Tax: ${item['grossincomeTax'] ?? '0.0'}'),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }
    return Center(child: Text('No tax slab data available.'));
  }

  Widget _buildMonthlyTaxDetails() {
    if (_data.containsKey('financePayIncometaxDisplayList3')) {
      var items = _data['financePayIncometaxDisplayList3'] as List<dynamic>;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateColor.resolveWith(
                  (states) => Colors.blue.withOpacity(0.1)),
          columns: [
            DataColumn(label: Text('Month')),
            for (int i = 1; i <= 12; i++) DataColumn(label: Text('Month $i')),
          ],
          rows: items.map<DataRow>((item) {
            return DataRow(
              cells: [
                DataCell(Text(item['month'] ?? 'Unknown')),
                for (int i = 1; i <= 12; i++)
                  DataCell(Text('${item['month$i']?.toStringAsFixed(1) ?? '0.0'}')),
              ],
            );
          }).toList(),
        ),
      );
    }
    return SizedBox.shrink();
  }
}
