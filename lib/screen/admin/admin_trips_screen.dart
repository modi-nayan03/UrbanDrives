import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class AdminTripsScreen extends StatefulWidget {
  @override
  _AdminTripsScreenState createState() => _AdminTripsScreenState();
}

class _AdminTripsScreenState extends State<AdminTripsScreen> {
  List<dynamic> _trips = [];
  bool _isLoading = true;
  String _selectedTripType = 'All'; // 'All', 'Ongoing', 'Completed'
  int _currentPage = 1; // Track current page
  int _tripsPerPage = 20; // Number of trips per page

  @override
  void initState() {
    super.initState();
    _fetchTrips();
  }

  Future<void> _fetchTrips() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:5000/get-trips-by-admin')); // Use admin trips API
      if (response.statusCode == 200) {
        setState(() {
          _trips = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        print('Failed to load trips: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load trips. Please try again.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching trips: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while fetching trips.')),
      );
      setState(() {
        _isLoading = false;
        });
    }
  }

  // Method to Get Paginated Trips
  List<dynamic> getPaginatedTrips() {
    List<dynamic> filteredTrips = getFilteredTrips();  //Filtering from  "Ongoing", "Completed"
    final startIndex = (_currentPage - 1) * _tripsPerPage; //Gets the data in each Page
    final endIndex = (startIndex + _tripsPerPage).clamp(0, filteredTrips.length); // Gets length to  "go over total values"
    return filteredTrips.sublist(startIndex, endIndex); // returns it back for it to use
  }

  List<dynamic> getFilteredTrips() {
    if (_selectedTripType == 'All') {
      return _trips;
    } else if (_selectedTripType == 'Ongoing') {
      return _trips.where((trip) => trip['tripStatus'] == 'Ongoing').toList();
    } else if (_selectedTripType == 'Completed') {
      return _trips.where((trip) => trip['tripStatus'] == 'Completed').toList();
    }
    return _trips;
  }

  int getOngoingTripsCount() {
    return _trips.where((trip) => trip['tripStatus'] == 'Ongoing').length;
  }

  int getCompletedTripsCount() {
    return _trips.where((trip) => trip['tripStatus'] == 'Completed').length;
  }

  // Method to Go to page
  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {

    final filteredTrips = getFilteredTrips();
    final paginatedTrips = getPaginatedTrips();
    final totalPages = (filteredTrips.length / _tripsPerPage).ceil();

    return Scaffold(
      backgroundColor: Color(0xFFF8F8FF),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(  // Changed to Column to Stack UserMainContent and Pagination
          children: [
            Expanded(
              child: TripsMainContent(
                trips: paginatedTrips,
                onTripTypeSelected: (type) {
                  setState(() {
                    _selectedTripType = type;
                    _currentPage = 1; // Reset to first page when changing tab
                  });
                },
                selectedTripType: _selectedTripType,
                allTripsCount: _trips.length,
                ongoingTripsCount: getOngoingTripsCount(),
                completedTripsCount: getCompletedTripsCount(),
                currentPage: _currentPage, // ADDED:  currentPage to navigate to correct value
                totalPages: totalPages,   //ADded page to find correct values
                onPageChanged: _goToPage,
              ),
            ),
            if (totalPages > 1)
              Container(  // Sticky Pagination Container
                color: Colors.white, // or any other color
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Pagination( //Added component to show at the buttom
                  currentPage: _currentPage,
                  totalPages: totalPages,
                  onPageChanged: _goToPage,
                ),
              ),
          ],
        ),
    );
  }
}

class TripsMainContent extends StatefulWidget {  //Changed stateless to stateful
  final List<dynamic> trips;
  final Function(String) onTripTypeSelected;
  final String selectedTripType;
  final int allTripsCount;
  final int ongoingTripsCount;
  final int completedTripsCount;

  // ADDED: Pagination variables
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  TripsMainContent({
    Key? key, //ADDED key to the class
    required this.trips,
    required this.onTripTypeSelected,
    required this.selectedTripType,
    required this.allTripsCount,
    required this.ongoingTripsCount,
    required this.completedTripsCount,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  _TripsMainContentState createState() => _TripsMainContentState();
}

class _TripsMainContentState extends State<TripsMainContent> {  //  StateClass added
   ScrollController _scrollController = ScrollController();  //ADD Scroll Controller
   @override
  void initState() {  //ADDED InitState to the Stateful Widget
    super.initState();
  }


  @override
  void didUpdateWidget(covariant TripsMainContent oldWidget) { // Added: didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.currentPage != oldWidget.currentPage) {
      // Scroll to top after the new data loads
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
         _scrollController.jumpTo(0.0);
        }
      });
    }
  }

   @override
  void dispose() { //Add the method to dispose the controller to clear memory
    _scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 600;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trips',
                style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onTripTypeSelected('All'),
                        child: TripSummaryCard(
                          title: 'All Trips',
                          value: widget.allTripsCount.toString(),
                          isSelected: widget.selectedTripType == 'All',
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onTripTypeSelected('Ongoing'),
                        child: TripSummaryCard(
                          title: 'Ongoing Trips',
                          value: widget.ongoingTripsCount.toString(),
                          isSelected: widget.selectedTripType == 'Ongoing',
                        ),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onTripTypeSelected('Completed'),
                        child: TripSummaryCard(
                          title: 'Completed Trips',
                          value: widget.completedTripsCount.toString(),
                          isSelected: widget.selectedTripType == 'Completed',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.0),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController, // ADDED: Scroll controller
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        AllTripsSection(
                          isDesktop: isDesktop,
                          trips: widget.trips,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AllTripsSection extends StatelessWidget {
  final bool isDesktop;
  final List<dynamic> trips;

  AllTripsSection({
    required this.isDesktop,
    required this.trips,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Trips',
          style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
        SizedBox(height: 10.0),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,  //4, to follow that requirement
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 1.5,
          ),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            return TripCard(trip: trips[index]);
          },
        ),
      ],
    );
  }
}

class TripCard extends StatelessWidget {
  final dynamic trip;

  TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    print("Trip Data: $trip");
    // Define DateFormat object for date formatting
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    // Safely access and format pickup and return times
    DateTime? pickupTime = trip['pickupTime'] != null ? DateTime.tryParse(trip['pickupTime']) : null;
    DateTime? returnTime = trip['returnTime'] != null ? DateTime.tryParse(trip['returnTime']) : null;

    // Format the time range string
    String timeRange = 'N/A';
    if (pickupTime != null && returnTime != null) {
      timeRange = '${dateFormat.format(pickupTime)} - ${dateFormat.format(returnTime)}';
    }


    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Car: ${trip['carBrand'] ?? 'N/A'} ${trip['carModel'] ?? 'N/A'}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            'Customer Name: ${trip['customerName'] ?? 'N/A'}',
            style: TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            'Contact: ${trip['phoneNumber'] ?? 'N/A'}',
            style: TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            'Email: ${trip['email'] ?? 'N/A'}',
            style: TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            'Host Name: ${trip['hostName'] ?? 'N/A'}',
            style: TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            'Time: $timeRange', //Use the fomratted  timeRange string here
            style: TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            'Pickup: ${trip['pickupLocation'] ?? 'N/A'}',
            style: TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            'Status: ${trip['tripStatus'] ?? 'N/A'}',
            style: TextStyle(
              fontSize: 12,
              color: trip['tripStatus'].toString().toLowerCase().trim() ==
                      'completed'
                  ? Colors.green
                  : Colors.blue,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class TripSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isSelected;

  TripSummaryCard({
    required this.title,
    required this.value,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Colors.blue[100] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: isSelected
            ? BorderSide(color: Colors.blue, width: 2.0)
            : BorderSide.none,
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 110,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.lightGreen[50],
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Icon(Icons.local_taxi_outlined,
                    size: 24.0,
                    color: Colors.green),
              ),
              SizedBox(height: 5.0),
              Text(title,
                  style: TextStyle(fontSize: 12.0, color: Colors.black54)),
              Text(
                value,
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//  Added: Pagination Widget ***************************************
class Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed:
              currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        ),
        for (int i = 1; i <= totalPages; i++)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onPageChanged(i),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: currentPage == i ? Color(0xFF3F51B5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '$i',
                  style: TextStyle(
                      color: currentPage == i ? Colors.white : Colors.black87),
                ),
              ),
            ),
          ),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed:
              currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
        ),
      ],
    );
  }
}