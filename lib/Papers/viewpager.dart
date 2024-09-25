import 'package:cloudilyaemployee/Papers/papers.dart';
import 'package:flutter/material.dart';

import 'manual.dart';

class ViewPager extends StatefulWidget {
  const ViewPager({super.key});

  @override
  State<ViewPager> createState() => _ViewPagerState();
}

class _ViewPagerState extends State<ViewPager> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Employee Papers & Manual',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
      body: PageView(
        controller: _pageController,
        children: [
          EmployeePapersConferencesScreen(),
          ManualScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 0,
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
        selectedItemColor: Colors.black, // Set selected item color to black
        unselectedItemColor: Colors.black54, // Set unselected item color to a lighter shade of black
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note, color: Colors.black),
            label: 'Papers/Conferences',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help, color: Colors.black),
            label: 'Manual',
          ),
        ],
      ),
    );
  }
}
