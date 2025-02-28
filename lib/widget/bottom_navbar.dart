import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../screen/home/home_screen.dart';
import '../screen/my_trips_screen.dart';
import '../screen/notification_screen.dart';
import '../screen/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class BottomNavBar extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userId;
  final int initialIndex;
  const BottomNavBar({super.key, required this.userName, required this.userEmail, required this.userId, required this.initialIndex});

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  late int _currentIndex;
  late List<Widget> _screens;
  String? _userId; // ADD THIS

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // Initialize with the given index
        _loadUserId(); // ADD THIS

  }

   Future<void> _loadUserId() async {  // ADD THIS METHOD
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  @override
  Widget build(BuildContext context) {
    const navBarColor = Color.fromARGB(255, 91, 172, 238);

    return Scaffold(
      body: Builder(
        builder: (context) {
          // Check if _userId is available, otherwise, display a loading or fallback
          if (_userId == null) {
            return const Center(child: CircularProgressIndicator()); // Or a default message
          } else {
            // Now that _userId is available, build the screens
            _screens = [
              HomeScreen(userEmail:widget.userEmail), // pass userID here
              MyTripsScreen(userId: widget.userId), // Pass userId here
              const NotificationScreen(),
              ProfileScreen(userName: widget.userName, email: widget.userEmail, userId: widget.userId),
            ];

            return _screens[_currentIndex];
          }
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBarColor,
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
            backgroundColor: navBarColor,
            color: Colors.white70,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.blue.shade800,
            padding: const EdgeInsets.all(12),
            selectedIndex: _currentIndex,
            onTabChange: _onItemTapped,
            tabs: const [
              GButton(
                icon: Icons.home_outlined,
                text: 'Home',
              ),
              GButton(
                icon: Icons.directions_car_outlined,
                text: 'My Trips',
              ),
              GButton(
                icon: Icons.notifications_outlined,
                text: 'Notification',
              ),
              GButton(
                icon: Icons.person_outline,
                text: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}