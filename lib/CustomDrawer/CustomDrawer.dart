import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Dashboard/Dahboard.dart';
import '../MyInfo/Employment.dart';
import '../MyInfo/PayAllotment.dart';
import '../MyInfo/Salarypayout.dart';
import '../MyInfo/benefits.dart';
import '../MyInfo/empInfo.dart';
import '../TimeSheet/TimeSheet.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/image.png'),
                ),
                SizedBox(height: 10),
                Text(
                  'John Doe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                _buildDrawerItem(
                  context,
                  Icons.info,
                  'Employee Info',
                  EmployeeInfo(),
                ),
                _buildDrawerItem(
                  context,
                  Icons.bento,
                  'Benefits',
                  Benefits(),
                ),
                _buildDrawerItem(
                  context,
                  Icons.payment,
                  'Pay Allotment',
                  Payallotment(),
                ),
                _buildDrawerItem(
                  context,
                  Icons.work,
                  'Employment',
                  Employement(),
                ),
                _buildDrawerItem(
                  context,
                  Icons.timeline,
                  'TimeSheet',
                  TimeSheet(),
                ),
                _buildDrawerItem(
                  context,
                  Icons.money,
                  'Salary Breakup',
                  SalaryBreakupScreen(),
                ),
                _buildDrawerItem(
                  context,
                  Icons.logout,
                  'Logout',
                  TimeSheet(), // Assuming this should navigate to a logout function or screen
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, Widget destination) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => destination));
      },
    );
  }
}
