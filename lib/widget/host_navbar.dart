import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../screen/host/booking_screen.dart';
import '../screen/host/mycars_screen.dart';

import '../screen/notification_screen.dart';
import '../screen/profile_screen.dart';

class HostNavBar extends StatefulWidget {
  final String userName;
  final Map<String, dynamic>? carDetails;
    final String userEmail;
      final String userId;
  const HostNavBar({super.key, required this.userName, this.carDetails, required this.userEmail, required this.userId});

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<HostNavBar> {
  int _currentIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
     MyCarsScreen(userName: widget.userName, userEmail: widget.userEmail,userId: widget.userId,),
      const HostBookingScreen(userId: '',),
      const NotificationScreen(),
       ProfileScreen(userName: widget.userName, email: widget.userEmail,userId:widget.userId,),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const navBarColor = Color.fromARGB(255, 91, 172, 238); // Defined color

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBarColor, // Using defined color
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: GNav(
            gap: 8,
            backgroundColor: navBarColor, // Using the same color
            color: Colors.white70,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.blue.shade800,
            padding: const EdgeInsets.all(12),
            selectedIndex: _currentIndex,
            onTabChange: _onItemTapped,
            tabs: const [
              GButton(
                icon: Icons.home_outlined, // Changed to simple icon
                text: 'My Cars',
              ),
              GButton(
                icon: Icons.directions_car_outlined, // Changed to simple icon
                text: 'Bookings',
              ),
              GButton(
                icon: Icons.notifications_outlined, // Changed to simple icon
                text: 'Notification',
              ),
              GButton(
                icon: Icons.person_outline, // Changed to simple icon
                text: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}