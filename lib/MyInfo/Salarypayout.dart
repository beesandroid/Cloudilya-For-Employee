import 'package:flutter/material.dart';

class SalaryBreakupScreen extends StatelessWidget {
  const SalaryBreakupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Salary Breakup Details'),
     backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Income From Employer'),
              _buildTable(
                headers: ['Salary BreakUp', 'Total Salary', 'April 2024', 'May 2024', 'June 2024', 'July 2024', 'August 2024', 'September 2024', 'October 2024', 'November 2024', 'December 2025', 'January 2025', 'February 2025', 'March 2025'],
                data: [
                  ['Basic', '3000000', '250000', '250000', '250000', '250000', '250000', '250000', '250000', '250000', '250000', '250000', '250000'],
                  ['HRA', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'],
                  ['DA', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'],
                  ['Special Allowances', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'],
                  ['Total', '3000000', '250000', '250000', '250000', '250000', '250000', '250000', '250000', '250000', '250000', '250000', '250000']
                ],
              ),
              SizedBox(height: 16.0),
              _buildSectionTitle('Less Declarations'),
              _buildTable(
                headers: ['Section', 'Deduction', 'Usage', 'Less'],
                data: [
                  ['PF', 'PF', '0', '0'],
                  ['House Rent Allowances', 'House Rent Allowances', '0', '0'],
                  ['Professional Tax', 'Professional Tax', '2400', '2400']
                ],
              ),
              SizedBox(height: 16.0),
              _buildDetailRow('Total Estimated Earnings:', '3000000'),
              _buildDetailRow('Total Declared Amount:', '2400'),
              _buildDetailRow('Total Taxable Amount:', '2997600'),
              SizedBox(height: 16.0),
              _buildSectionTitle('Income Tax Slab'),
              _buildTable(
                headers: ['Taxable income slabs (for Employees aged under 60 years)', 'TAX AMOUNT'],
                data: [
                  ['0% on income up to 250000', '0'],
                  ['5% Tax on income between 250001 and 500000', '12500'],
                  ['20% Tax on income between 500001 and 1000000', '100000'],
                  ['30% Tax on income between 1000001 and 40000000000', '599280']
                ],
              ),
              SizedBox(height: 16.0),
              _buildSectionTitle('Monthly Income Tax Deduction'),
              _buildTable(
                headers: ['Month', 'Monthly Tax'],
                data: [
                  ['April 2024', '61687.6'],
                  ['May 2024', '61687.6'],
                  ['June 2024', '61687.6'],
                  ['July 2024', '61687.6'],
                  ['August 2024', '61687.6'],
                  ['September 2024', '61687.6'],
                  ['October 2024', '61687.6'],
                  ['November 2024', '61687.6'],
                  ['December 2025', '61687.6'],
                  ['January 2025', '61687.6'],
                  ['February 2025', '61687.6'],
                  ['March 2025', '61687.6']
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTable({required List<String> headers, required List<List<String>> data}) {
    return Table(
      border: TableBorder.all(),
      columnWidths: {0: FlexColumnWidth(1.5)},
      children: [
        TableRow(
          children: headers.map((header) => _buildTableHeader(header)).toList(),
        ),
        ...data.map((row) => TableRow(
            children: row.length == headers.length
                ? row.map((cell) => _buildTableCell(cell)).toList()
                : List.generate(headers.length, (index) => _buildTableCell(''))
        )).toList(),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.blue,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Text(text),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.blueGrey,
              fontWeight: FontWeight.bold,
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
