import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum TripStatus { ongoing, completed, cancelled }

class Trip {
  final String carModel;
  final String pickUpPoint;
  final String pickUpTime;
  final String dropPoint;
  final String dropTime;
  final String totalTime;
  final String amountPaid;
  TripStatus status;
  final String totalAmount;
  final String carId;
  final String tripId;
  final String tripStatus;
  final String createdAt; // Add created at to Trip Model

  Trip({
    required this.carModel,
    required this.pickUpPoint,
    required this.pickUpTime,
    required this.dropPoint,
    required this.dropTime,
    required this.totalTime,
    required this.amountPaid,
    required this.status,
    required String imagePath,
    required this.totalAmount,
    required this.carId,
    required this.tripId,
    required this.tripStatus,
    required this.createdAt, // initialize in constructor
  });
}

class MyTripsScreen extends StatefulWidget {
  final Trip? newTrip;
  final String userId;

  const MyTripsScreen({Key? key, this.newTrip, required this.userId})
      : super(key: key);

  @override
  MyTripsScreenState createState() => MyTripsScreenState();
}

class MyTripsScreenState extends State<MyTripsScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _tripDetailsList = [];
  bool _isLoading = true;
  late TabController _tabController;
  List<Trip> _ongoingTrips = [];
  List<Trip> _completedTrips = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    print('MyTripsScreen - Retrieved userId: ${widget.userId}');
    _tabController = TabController(length: 2, vsync: this);
    _fetchTrips();

    if (widget.newTrip != null) {
      _processNewTrip(widget.newTrip!);
    }
    Future.delayed(Duration(seconds: 30), () {
      _checkAndMoveExpiredTrips();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _processNewTrip(Trip newTrip) {
    setState(() {
      _ongoingTrips.add(newTrip);
    });
  }

  Future<void> _fetchTrips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final url = Uri.parse('http://127.0.0.1:5000/get-trips');
    try {
      print(json.encode({
        'userId': widget.userId,
      }));
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': widget.userId,
        }),
      );
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _tripDetailsList = data.cast<Map<String, dynamic>>();
          _isLoading = false;
          _processTrips(_tripDetailsList);
        });

      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to fetch trips: ${response.statusCode}';
        });
        print('Failed to fetch trips: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('Error fetching trips: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching trips: $e';
      });
    }
  }

  void _processTrips(List<Map<String, dynamic>> tripDataList) {
    List<Trip> ongoingTrips = [];
    List<Trip> completedTrips = [];

    for (var tripData in tripDataList) {
      print('Trip Data: $tripData');

      final pickupTime = DateTime.parse(tripData['pickupTime']).toLocal();
      final returnTime = DateTime.parse(tripData['returnTime']).toLocal();
      final numberOfHours = returnTime.difference(pickupTime).inHours;
      final paymentStatus = tripData['paymentStatus'] as String?;
      final tripAmount = tripData['amount'].toString();
      final tripStatusValue = tripData['tripStatus'] as String? ?? 'Ongoing';

      TripStatus status;
      if (paymentStatus != null) {
        status = (paymentStatus as String?)?.toLowerCase() == 'success'
            ? TripStatus.ongoing
            : TripStatus.completed;
      } else {
        print("Warning: paymentStatus is null for a trip. Assuming completed.");
        status = TripStatus.completed;
      }

      final trip = Trip(
        carModel: tripData['carModel'] ?? 'Car Model',
        pickUpPoint: tripData['pickupLocation'] ?? 'Pickup Location',
        pickUpTime: DateFormat("EEE d MMM yyyy, h:mm a").format(pickupTime),
        dropPoint: 'Drop Location',
        dropTime: DateFormat("EEE d MMM yyyy, h:mm a").format(returnTime),
        totalTime: '$numberOfHours Hour',
        amountPaid: tripAmount,
        totalAmount: (numberOfHours * int.parse(tripAmount)).toString(),
        status: status,
        imagePath: '',
        carId: tripData['carId'] ?? 'No Car Id',
        tripId: tripData['_id'],
        tripStatus: tripStatusValue,
        createdAt: tripData['created_at'] ?? DateTime.now().toString(), // Add created at
      );

      if (trip.tripStatus == 'Ongoing') {
        ongoingTrips.add(trip);
      } else {
        completedTrips.add(trip);
      }
    }
    // Sort the ongoingTrips by created_at in descending order
    ongoingTrips.sort((a, b) {
      DateTime dateA;
      DateTime dateB;

      try {
        dateA = DateTime.parse(a.createdAt).toLocal();
      } catch (e) {
        print('Error parsing date A: $e');
        dateA = DateTime.now().toLocal(); // Default if parsing fails
      }

      try {
        dateB = DateTime.parse(b.createdAt).toLocal();
      } catch (e) {
        print('Error parsing date B: $e');
        dateB = DateTime.now().toLocal(); // Default if parsing fails
      }

      return dateB.compareTo(dateA); // Sort in descending order
    });

    // Sort the completedTrips by created_at in descending order
    completedTrips.sort((a, b) {
      DateTime dateA;
      DateTime dateB;

      try {
        dateA = DateTime.parse(a.createdAt).toLocal();
      } catch (e) {
        print('Error parsing date A: $e');
        dateA = DateTime.now().toLocal(); // Default if parsing fails
      }

      try {
        dateB = DateTime.parse(b.createdAt).toLocal();
      } catch (e) {
        print('Error parsing date B: $e');
        dateB = DateTime.now().toLocal(); // Default if parsing fails
      }

      return dateB.compareTo(dateA); // Sort in descending order
    });

    setState(() {
      _ongoingTrips = ongoingTrips;
      _completedTrips = completedTrips;
    });

    // At this point, all trips should be processed and you can clear tripsToMove list
  }


  void _moveTripToCompleted(Trip trip) async {
    final ratingData = await _showRatingDialog(context);

    if (ratingData != null) {
      final int rating = ratingData['rating'];
      final String comment = ratingData['comment'];

      // Submit review to backend
      final success = await _submitReview(trip, rating, comment);

      if (success) {
        await _updateTripStatus(trip.tripId);
         // Refresh the trip list before moving
        _fetchTrips();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Trip moved to completed')));
      } else {
        if (mounted) {
          // Check if the widget is still in the tree before showing the SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit review.')),
          );
        }
      }
    }
  }

  Future<Map<String, dynamic>?> _showRatingDialog(BuildContext context) async {
    int rating = 0;
    String comment = '';

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rate Your Trip'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Star Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 10),

                  // Comment Text Field
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Add a comment (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      comment = value;
                    },
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                Navigator.of(context)
                    .pop({'rating': rating, 'comment': comment});
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _submitReview(Trip trip, int rating, String comment) async {
    final url = Uri.parse('http://127.0.0.1:5000/submit-review');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'carId': trip.carId,
          'userId': widget.userId,
          'rating': rating,
          'comment': comment,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(
            'Review submitted successfully! Response code: ${response.statusCode}');
        return true;
      } else {
        print('Failed to submit review: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error submitting review: $e');
      return false;
    }
  }

  Future<void> _updateTripStatus(String tripId) async {
    print("Updating trip status called with tripId: $tripId"); // ADD THIS LINE
    final url = Uri.parse('http://127.0.0.1:5000/update-trip-status');
    try {
      print('Updating trip status for tripId: $tripId'); // Log tripId
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'tripId': tripId,
          'paymentStatus': 'completed',
          'tripStatus': 'Completed',
        }),
      );
      print('Update Trip Status Response status code: ${response.statusCode}'); // Log the status code
      print('Update Trip Status Response body: ${response.body}'); // Log the response body
      if (response.statusCode == 200) {
        print("Updated the trip status successfully");
      } else {
        print("Failed to update the status: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print('Error updating the status: $e');
    }
  }

  Future<void> _checkAndMoveExpiredTrips() async {
    if (mounted) {
      final now = DateTime.now();
      print("Current time: $now");

      List<Trip> tripsToMove = []; // Create a list to store trips that need to be moved

      for (var trip in List<Trip>.from(_ongoingTrips)) {
        try {
          print("Processing trip: ${trip.tripId}, Drop Time: ${trip.dropTime}");

          // Parse dropTime using the correct format and UTC
          DateTime returnTime =
              DateFormat("EEE d MMM yyyy, h:mm a").parse(trip.dropTime).toUtc();

          print("Parsed returnTime: $returnTime");

          if (returnTime.isBefore(now.toUtc())) {
            print("Trip ${trip.tripId} is expired.");
            tripsToMove.add(trip); // Add the trip to the list to be moved
          } else {
            print("Trip ${trip.tripId} is not expired.");
          }
        } catch (e) {
          print("Error processing return time: $e");
        }
      }

      // Process the trips that need to be moved after the loop
      for (var trip in tripsToMove) {
        final ratingData = await _showRatingDialog(context);
        if (ratingData != null) {
          final int rating = ratingData['rating'];
          final String comment = ratingData['comment'];

          final success = await _submitReview(trip, rating, comment);
          if (success) {
            await _updateTripStatus(trip.tripId);
          }
        }
        // Fetch the trips again after updating the status
        _fetchTrips();
      }
    }

    print('After first timer');
    // Call the method again after 30 seconds
    Future.delayed(Duration(seconds: 30), () {
      _checkAndMoveExpiredTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.9;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ongoing'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTripList(_ongoingTrips, cardWidth, true),
                    _buildTripList(_completedTrips, cardWidth, false),
                  ],
                ),
    );
  }

 Widget _buildTripList(
      List<Trip> trips, double cardWidth, bool isOngoingTab) {
    List<Trip> filteredTrips = trips;
    return filteredTrips.isEmpty
        ? const Center(child: Text('No Trips yet'))
        : ListView.builder(
            itemCount: filteredTrips.length,
            itemBuilder: (context, index) {
              final trip = filteredTrips[index];
              return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Dismissible(
                    key: Key(trip.pickUpTime),
                    direction: DismissDirection.endToStart,
                    background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.check, color: Colors.white)),
                    onDismissed: (direction) async {
                      _moveTripToCompleted(trip);
                    },
                    child: _buildTripCard(trip, cardWidth, context),
                  ));
            },
          );
  }
  Widget _buildTripCard(Trip trip, double cardWidth, BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        trip.carModel,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: trip.status == TripStatus.ongoing
                              ? Colors.blue.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          trip.tripStatus,
                          style: TextStyle(
                              color: trip.status == TripStatus.ongoing
                                  ? Colors.blue
                                  : Colors.green),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        trip.pickUpPoint,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                   //In MyTripsScreen, inside _buildTripCard method,
Text(trip.pickUpTime,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.grey))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        trip.dropPoint,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(trip.dropTime,
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey))
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Time: ${trip.totalTime}",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "₹ ${trip.totalAmount}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}