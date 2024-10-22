import 'package:cloudilyaemployee/Attendence/Attendence.dart';
import 'package:cloudilyaemployee/biometric/Biometric.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Absence/Absence.dart';
import '../Awards/Awards.dart';
import '../MApplications/MyApplications.dart';
import '../MaterialUploading/view.dart';
import '../Requests/requests.dart';

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
            mainAxisSize: MainAxisSize.min,
            // Ensure Column only takes as much height as needed
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: _buildStudentInfoCard(),
              ),
              SizedBox(height: 16.0),
              // Use Container with fixed height
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                child: GridView.count(
                  crossAxisCount: 3,
                  padding: const EdgeInsets.all(16.0),
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 1.0,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    _buildGridTile(
                      context,
                      'Attendance',
                      Icons.school,
                      AttendanceScreen(),
                    ),
                    _buildGridTile(
                      context,
                      'MyApplication',
                      Icons.settings_applications,
                      Myapplications(),
                    ),
                    _buildGridTile(
                      context,
                      'Requests',
                      Icons.view_array,
                      Requests(),
                    ),
                    _buildGridTile(
                      context,
                      'Material',
                      Icons.format_textdirection_r_to_l,
                      EmployeeMaterialScreen(),
                    ),
                    _buildGridTile(
                      context,
                      'Absence',
                      Icons.holiday_village,
                      Absence(),
                    ),

                    _buildGridTile(
                      context,
                      'Biometrics',
                      Icons.fingerprint,
                      BiometricDisplayScreen(),
                    ),
                    SizedBox(height: 40),
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
            width: double.infinity,
            // Adjust width to take full width
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
                  'R Jagadeesh',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],

                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Bio Technology',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'GIET College',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Hall Ticket: 05MT2018',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Batch: 2018-Present',
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
                    'assets/profilepic.jpeg',
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridTile(
      BuildContext context, String title, IconData icon, Widget? screen) {
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
