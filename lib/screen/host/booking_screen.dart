import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HostBookingScreen extends StatefulWidget {
  const HostBookingScreen({Key? key, required String userId}) : super(key: key);

  @override
  _HostBookingScreenState createState() => _HostBookingScreenState();
}

class _HostBookingScreenState extends State<HostBookingScreen> {
  List<dynamic> _bookings = [];
  bool _isLoading = false;
  String? _userId; // Make userId nullable

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserIdAndBookings();
    });// Load userId first
  }

  // Separate function to load userId and then bookings
  Future<void> _loadUserIdAndBookings() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId'); // Retrieve userId

    if (_userId != null && _userId!.isNotEmpty) {
      print('HostBookingScreen - Retrieved userId: $_userId');
      await _loadBookings(); // Load bookings if userId is valid
    } else {
      print('HostBookingScreen - Error: userId is null or empty.');
      // Handle the error appropriately:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Could not retrieve user ID. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      // Optionally, navigate back to the login screen:
      // Navigator.pushReplacementNamed(context, '/login');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadBookings() async {
    if (_userId == null || _userId!.isEmpty) {
      print("Won't call the backend: userId is still not loaded");
      return; //Don't call backend
    }
    final url = Uri.parse('http://127.0.0.1:5000/get-host-bookings');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': _userId}), // Send the userId
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _bookings = data;

         _bookings.sort((a, b) {
            DateTime dateA;
            DateTime dateB;
            try {
              dateA = DateTime.parse(a['created_at']).toLocal();
            } catch (e) {
              print('Error parsing date A: $e');
              dateA = DateTime.now().toLocal(); // Default to now in case of parsing error
            }

            try {
              dateB = DateTime.parse(b['created_at']).toLocal();
            } catch (e) {
              print('Error parsing date B: $e');
              dateB = DateTime.now().toLocal(); // Default to now in case of parsing error
            }

            return dateB.compareTo(dateA); //Sort in descending order
          });
        });
      } else {
        print('Failed to load bookings: ${response.statusCode}');
        // Handle error appropriately (show message to user, etc.)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load bookings: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error loading bookings: $e');
      // Handle exception appropriately
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading bookings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Add this if loading in booking page
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_userId == null || _userId!.isEmpty) // Check _userId before showing
              ? const Center(child: Text('User ID not found. Please log in.')) // Alternative message
              : _bookings.isEmpty
                  ? const Center(child: Text('No bookings yet.'))
                  : ListView.builder(
                      itemCount: _bookings.length,
                      itemBuilder: (context, index) {
                        final booking = _bookings[index];
                         String formattedPickupTime = 'Invalid Date';
                          String formattedReturnTime = 'Invalid Date';

    try {
      // Try parsing as RFC format first
      // DateFormat rfcFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      DateTime pickupDateTime = DateTime.parse(booking['pickupTime']).toLocal();
       formattedPickupTime = DateFormat('MMM d, yyyy - h:mm a').format(pickupDateTime);
    } catch (e) {
      print('Error parsing date (RFC Format): $e');
    }

    try {
      // Try parsing as RFC format first
      // DateFormat rfcFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      DateTime returnDateTime = DateTime.parse(booking['returnTime']).toLocal();
       formattedReturnTime = DateFormat('MMM d, yyyy - h:mm a').format(returnDateTime);
    } catch (e) {
      print('Error parsing date (RFC Format): $e');
    }

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.all(8),
                          child: InkWell(
                            onTap: () {
                              _showBookingDetails(context, booking);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Car: ${booking['carRegNumber']}",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                      Text(
                                        '₹${booking['totalAmount'] ?? booking['amount']}', // Display totalAmount here
                                         style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                    Text(
                                        ' Pickup Time: $formattedPickupTime \n Return Time: $formattedReturnTime'),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
    );
  }

  void _showBookingDetails(BuildContext context, Map<String, dynamic> booking) {
      String formattedPickupTime = 'Invalid Date';
      String formattedReturnTime = 'Invalid Date';
      //String formattedCreatedAt = 'Invalid Date';

    try {
      // Try parsing as RFC format first
      // DateFormat rfcFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      DateTime pickupDateTime = DateTime.parse(booking['pickupTime']).toLocal();
       formattedPickupTime = DateFormat('MMM d, yyyy - h:mm a').format(pickupDateTime);
    } catch (e) {
      print('Error parsing date (RFC Format): $e');
    }

    try {
      // Try parsing as RFC format first
      // DateFormat rfcFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      DateTime returnDateTime = DateTime.parse(booking['returnTime']).toLocal();
      formattedReturnTime = DateFormat('MMM d, yyyy - h:mm a').format(returnDateTime);
    } catch (e) {
      print('Error parsing date (RFC Format): $e');
    }

    bool showFront = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Booking Details',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.close))
                      ]),
                  const SizedBox(height: 16),
                  Text('Car Number: ${booking['carRegNumber']}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    'Booking Time: \n Pickup Time: $formattedPickupTime\n Return Time: $formattedReturnTime',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text('Amount: ₹${booking['totalAmount'] ?? booking['amount']}', // Show totalAmount here
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 10),
                  Text('Renter Details',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Email: ${booking['renter_email'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.bodyLarge),
                  Text('Phone: ${booking['renter_mobile'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 20),
                  Text('License Images',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showFront = !showFront;
                      });
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: showFront
                          ? _buildBase64LicenseImage(
                              booking['frontImage'], 'Front')
                          : _buildBase64LicenseImage(
                              booking['backImage'], 'Back'),
                    ),
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildBase64LicenseImage(String base64Image, String side) {
    if (base64Image == null || base64Image.isEmpty) {
      return Text('No $side License Image Available');
    }

    try {
      Uint8List bytes = base64Decode(base64Image);
      return Column(
        key: ValueKey(base64Image),
        children: [
          Text('$side Side:',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          InteractiveViewer(
            clipBehavior: Clip.none,
            panEnabled: true,
            minScale: 0.5,
            maxScale: 5.0,
            child: Image.memory(
              bytes,
              height: 150,
              width: 200,
              fit: BoxFit.cover,
            ),
          ),
        ],
      );
    } catch (e) {
      print('Error decoding base64 image: $e');
      return Text('Error displaying $side License Image'); // Handle decoding errors
    }
  }
}