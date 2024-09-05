import 'package:cloudilyaemployee/Attendence/Attendence.dart';
import 'package:cloudilyaemployee/Leave/Leave%20Application.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../MyInfo/Employment.dart';
import '../MyInfo/PayAllotment.dart';
import '../MyInfo/empInfo.dart';
import '../TimeSheet/TimeSheet.dart';


class DashboardHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: _buildStudentInfoCard(),
              ),
              SizedBox(height: 16.0), // Add space between the card and the grid
              // Use Container with fixed height
              Container(
                height: MediaQuery.of(context).size.height * 0.6, // Adjust the height as needed
                child: GridView.count(
                  crossAxisCount: 3,
                  padding: const EdgeInsets.all(16.0),
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 1.0,
                  shrinkWrap: true, // Ensures GridView does not take more space than needed
                  physics: NeverScrollableScrollPhysics(), // Prevents GridView from scrolling independently
                  children: <Widget>[
                    _buildGridTile(
                      context,
                      'EmployeeInfo',
                      Icons.payment,
                      EmployeeInfo(),
                    ),
                    _buildGridTile(
                      context,
                      'Permission',
                      Icons.perm_identity_sharp,
                      Payallotment(),
                    ),
                    _buildGridTile(
                      context,
                      'Leave Req',
                      Icons.beach_access,
                      Employement(),
                    ),
                    _buildGridTile(
                      context,
                      'Transport',
                      Icons.directions_bus,
                      TimeSheet(),
                    ),
                    _buildGridTile(
                      context,
                      'AttendanceScreen',
                      Icons.school,
                      AttendanceScreen(),
                    ),
                    _buildGridTile(
                      context,
                      'LeaveApplicationScreen',
                      Icons.book,
                      LeaveApplicationScreen(),
                    ),



                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 440.0,
            margin: EdgeInsets.symmetric(vertical: 40.0),
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: Offset(0, 10),
                ),
              ],
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 40), // Space for the avatar
                Text(
                  'CH Manikanta',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                    shadows: [
                      Shadow(
                        offset: Offset(1.5, 1.5),
                        blurRadius: 3.0,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'B.Tech, Computer Science',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'XYZ College, Section A',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Hall Ticket: 123456789',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Batch: 2020-2024',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -25,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue[50],
                child: ClipOval(
                  child: Image.asset(
                    'assets/profilepic.png',
                    fit: BoxFit.cover, // Adjusts the image to cover the area of the CircleAvatar without zooming in too much
                    width: 120, // Ensures the image width matches the diameter of the CircleAvatar
                    height: 120, // Ensures the image height matches the diameter of the CircleAvatar
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridTile(BuildContext context, String title, IconData icon, Widget? screen) {
    return GestureDetector(
      onTap: () {
        if (screen != null) {
          Get.to(() => screen);
        }
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[50],
              child: Icon(
                icon,
                size: 30,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
