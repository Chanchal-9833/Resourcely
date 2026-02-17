import 'package:flutter/material.dart';
import 'package:flutter_firebase/FlutterProject/HomePage.dart';
import 'package:flutter_firebase/FlutterProject/admin_dashboard.dart';
import 'package:flutter_firebase/FlutterProject/admin_handle.dart';
import 'package:flutter_firebase/FlutterProject/profile_page.dart';

import 'my_booking_page.dart';
//import 'student_profile_page.dart';
import './resourcely_colors.dart';

class BottomNavigation extends StatefulWidget {
   final String role;
  BottomNavigation({super.key,required this.role});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();

}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();

    if (widget.role == "Admin") {
      pages = const [
        AdminDashboard(),
        AdminHandle(),   // 👈 different page
        ProfilePage(),
      ];
    } else{
      pages = const [
        Homepage(),
        MyBookingsPage(),
        ProfilePage(),
      ];
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,

        selectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Mono',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontFamily: 'Mono',
        ),

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: widget.role == "Admin"
            ? const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: "Admin",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ]
            : const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: "My Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],

      ),
    );
  }
}
