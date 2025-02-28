import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AdminBookingsScreen extends StatefulWidget {
  @override
  _AdminBookingsScreenState createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  List<dynamic> _bookings = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _bookingsPerPage = 20;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:5000/get-all-admin-bookings'));
      if (response.statusCode == 200) {
        setState(() {
          _bookings = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        print('Failed to load bookings: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load bookings. Please try again.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while fetching bookings.')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to Get Paginated Bookings
  List<dynamic> getPaginatedBookings() {
    final startIndex = (_currentPage - 1) * _bookingsPerPage;
    final endIndex = (startIndex + _bookingsPerPage).clamp(0, _bookings.length);
    return _bookings.sublist(startIndex, endIndex);
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final paginatedBookings = getPaginatedBookings();
    final totalPages = (_bookings.length / _bookingsPerPage).ceil();

    return Scaffold(
      backgroundColor: Color(0xFFF8F8FF),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(  // Changed to Column to Stack BookingsMainContent and Pagination
            children: [
              Expanded(
                child: BookingsMainContent(
                  bookings: paginatedBookings,
                  allBookingsCount: _bookings.length,
                  currentPage: _currentPage,
                  totalPages: totalPages,
                  onPageChanged: _goToPage,
                ),
              ),
              Container(  // Sticky Pagination Container
                color: Colors.white, // or any other color
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Pagination(
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

class BookingsMainContent extends StatefulWidget {  // Changed to StatefulWidget
  final List<dynamic> bookings;
  final int allBookingsCount;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  BookingsMainContent({
    Key? key,  //added key
    required this.bookings,
    required this.allBookingsCount,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  _BookingsMainContentState createState() => _BookingsMainContentState();
}

class _BookingsMainContentState extends State<BookingsMainContent> {  // added code

  ScrollController _scrollController = ScrollController();  // ADDED: Scroll Controller

   @override
  void initState() { //Added InitState
    super.initState();
  }

  @override
  void didUpdateWidget(covariant BookingsMainContent oldWidget) {  //Added didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.currentPage != oldWidget.currentPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {  //Call jump after the new widget is built
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0.0);
        }
      });
    }
  }

  @override
  void dispose() { //Added dispose
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
                'Bookings',
                style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // Align to the start
                  children: [
                    Expanded(
                      child: BookingSummaryCard( //Only Show This Card
                        title: 'All Bookings',
                        value: widget.allBookingsCount.toString(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.0),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,  //ADD Scroll Controller
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        AllBookingsSection(
                          isDesktop: isDesktop,
                          bookings: widget.bookings,
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

class AllBookingsSection extends StatelessWidget {
  final bool isDesktop;
  final List<dynamic> bookings;

  AllBookingsSection({
    required this.isDesktop,
    required this.bookings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Bookings',
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
            crossAxisCount: 4,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 1.5,
          ),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            return BookingCard(booking: bookings[index]);
          },
        ),
      ],
    );
  }
}

class BookingCard extends StatelessWidget {
  final dynamic booking;

  BookingCard({required this.booking});

  String _formatDateTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } catch (e) {
      print('Error parsing or formatting date: $e');
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
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
            'Car: ${booking['carBrand'] ?? 'N/A'} ${booking['carModel'] ?? 'N/A'}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            'Host Name: ${booking['hostName'] ?? 'N/A'}',
            style: TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            'Contact: ${booking['hostMobileNumber'] ?? 'N/A'}',
            style: TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            'Email: ${booking['hostEmail'] ?? 'N/A'}',
            style: TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            'Time: ${_formatDateTime(booking['pickupTime'] ?? '')} - ${_formatDateTime(booking['returnTime'] ?? '')}',
            style: TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            'Total Amount: ₹${booking['totalAmount'] ?? 'N/A'}',
            style: TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            'Status: ${booking['paymentStatus'] ?? 'N/A'}',
            style: TextStyle(
              fontSize: 12,
              color: booking['paymentStatus'].toString().toLowerCase().trim() ==
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

class BookingSummaryCard extends StatelessWidget {
  final String title;
  final String value;

  BookingSummaryCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
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
                child: Icon(Icons.book_online, size: 24.0, color: Colors.green),
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