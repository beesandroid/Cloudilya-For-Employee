// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../ApprovalDisplay/Approvals.dart';
// import '../Attendence/Attendence.dart';
// import '../Leave/Leave Application.dart';
// import '../MyInfo/Employment.dart';
// import '../MyInfo/PayAllotment.dart';
// import '../MyInfo/Salarypayout.dart';
// import '../MyInfo/benefits.dart';
// import '../MyInfo/empInfo.dart';
// import '../TimeSheet/TimeSheet.dart';
// import '../Timetable/TimeTable.dart';
//
// // Import Fee Payments screen
//
// class EmpDashboard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Employee Dashboard'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () {
//               // Handle logout functionality here
//             },
//           ),
//         ],
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//
//       ),
//       drawer:
//       Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             DrawerHeader(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.blue, Colors.lightBlueAccent],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircleAvatar(
//                     radius: 40,
//                     backgroundImage: AssetImage('assets/image.png'),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     'John Doe',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(decoration: BoxDecoration(color: Colors.white),
//
//               child: Column(children: [
//                 _buildDrawerItem(
//                   context,
//                   Icons.info,
//                   'Employee Info',
//                   EmployeeInfo(),
//                 ),
//                 _buildDrawerItem(
//                   context,
//                   Icons.bento,
//                   'Benefits',
//                   Benefits(),
//                 ),
//                 _buildDrawerItem(
//                   context,
//                   Icons.payment,
//                   'Pay Allotment',
//                   Payallotment(),
//                 ),
//                 _buildDrawerItem(
//                   context,
//                   Icons.work,
//                   'Employment',
//                   Employement(),
//                 ),  _buildDrawerItem(
//                   context,
//                   Icons.timeline,
//                   'TimeSheet',
//                   TimeSheet(),
//                 ), _buildDrawerItem(
//                   context,
//                   Icons.timeline,
//                   'SalaryBreakupScreen',
//                   SalaryBreakupScreen(),
//                 ),_buildDrawerItem(
//                   context,
//                   Icons.logout,
//                   'logout',
//                   TimeSheet(),
//                 ),
//               ],),
//             )
//             // Add more ListTiles here for other screens if needed
//           ],
//         ),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.white, Colors.blue[50]!],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: GridView.count(
//           crossAxisCount: 2,
//           padding: const EdgeInsets.all(16.0),
//           childAspectRatio: 1.1,
//           crossAxisSpacing: 16.0,
//           mainAxisSpacing: 16.0,
//           children: <Widget>[
//             _buildGridTile(
//               context,
//               'Attendance',
//               Icons.check_circle,
//               Colors.blueAccent,
//               AttendanceScreen(),
//             ),
//             _buildGridTile(
//               context,
//               'Leave',
//               Icons.attach_email,
//               Colors.greenAccent,
//               LeaveApplicationScreen(),
//             ),   _buildGridTile(
//               context,
//               'Aproval',
//               Icons.approval,
//               Colors.red,
//               Approvals(),
//             ), _buildGridTile(
//               context,
//               'TimeTable',
//               Icons.timeline,
//               Colors.black,
//               EmployeeTimeTableScreen(),
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildGridTile(
//       BuildContext context,
//       String title,
//       IconData icon,
//       Color color,
//       Widget screen, {
//         bool showToast = false,
//       }) {
//     return GestureDetector(
//       onTap: () {
//         try {
//           if (showToast) {
//             Get.snackbar(
//               'Info',
//               'This feature is not available yet.',
//               backgroundColor: Colors.black,
//               colorText: Colors.white,
//               snackPosition: SnackPosition.BOTTOM,
//             );
//           } else {
//             Get.to(() => screen);
//           }
//         } catch (e) {
//           print('Navigation error: $e');
//           Get.snackbar(
//               'Error', 'Unable to navigate to the selected screen');
//         }
//       },
//       child: Material(
//         elevation: 4.0,
//         borderRadius: BorderRadius.circular(12.0),
//         color: Colors.white,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(12.0),
//           onTap: () {
//             try {
//               if (showToast) {
//                 Get.snackbar(
//                   'Info',
//                   'This feature is not available yet.',
//                   backgroundColor: Colors.black,
//                   colorText: Colors.white,
//                   snackPosition: SnackPosition.BOTTOM,
//                 );
//               } else {
//                 Get.to(() => screen);
//               }
//             } catch (e) {
//               print('Navigation error: $e');
//               Get.snackbar(
//                   'Error', 'Unable to navigate to the selected screen');
//             }
//           },
//           child: Container(
//             padding: EdgeInsets.all(16.0),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12.0),
//               gradient: LinearGradient(
//                 colors: [Colors.white, Colors.blue[50]!],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Icon(icon, size: 56.0, color: color),
//                 SizedBox(height: 12.0),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 16.0,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDrawerItem(BuildContext context, IconData icon, String title, Widget screen) {
//     return ListTile(
//       leading: Icon(icon),
//       title: Text(title),
//       onTap: () {
//         Get.to(() => screen);
//       },
//     );
//   }
// }
