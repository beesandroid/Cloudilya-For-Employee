
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../ApprovalDisplay/Approvals.dart';
import '../CustomDrawer/CustomDrawer.dart';
import '../Leave/Leave Application.dart';
import '../Notification/Notification.dart';
import '../Timetable/TimeTable.dart';
import 'Dashboard.dart';


class EmpDashboard extends StatefulWidget {
  @override
  _EmpDashboardState createState() => _EmpDashboardState();
}

class _EmpDashboardState extends State<EmpDashboard> {
  late PersistentTabController _controller;

  _EmpDashboardState() : _controller = PersistentTabController(initialIndex: 0);

  List<Widget> _buildScreens() {
    return [
      Approvals(),
      EmployeeTimeTableScreen(),
      DashboardHomePage(),
      LeaveApplicationScreen(),
    ];
  }

  final List<String> _titles = [
    'Approvals',
    'Time Table',
    'Dashboard',
    'Leave',
  ];

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: FaIcon(FontAwesomeIcons.file),
        title: ("Approvals"),
        activeColorPrimary: Colors.blueAccent,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: FaIcon(FontAwesomeIcons.calendar),
        title: ("Time Table"),
        activeColorPrimary: Colors.blueAccent,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: FaIcon(Icons.menu_book),
        title: ("Dashboard"),
        activeColorPrimary: Colors.blueAccent,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.holiday_village),
        title: ("Leave"),
        activeColorPrimary: Colors.blueAccent,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          _titles[_controller.index],
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Noti()));
            },
          ),
        ],
      ),
      drawer: CustomDrawer(), // Use your custom drawer here
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        onItemSelected: (index) {
          setState(() {
            _controller.index = index; // Update the controller index
          });
        },
        navBarStyle: NavBarStyle.style9, // Ensure this style is supported
      ),
    );
  }
}



