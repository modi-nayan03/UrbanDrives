// brand_vehiclelist_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'car_details_screen.dart'; // Import the CarDetailsScreen
import 'package:http/http.dart' as http;

class BrandVehicleListScreen extends StatefulWidget {
  final String brandName; // The brand name passed from the home screen
  final String userId;

  const BrandVehicleListScreen({Key? key, required this.brandName, required this.userId}) : super(key: key);

  @override
  State<BrandVehicleListScreen> createState() => _BrandVehicleListScreenState();
}

class _BrandVehicleListScreenState extends State<BrandVehicleListScreen> {
  List<Map<String, dynamic>> _carList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, double> _averageRatings = {};

  @override
  void initState() {
    super.initState();
    _fetchCarsByBrand();
  }


  Future<void> _fetchCarsByBrand() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _averageRatings = {};
    });

    final url = Uri.parse('http://127.0.0.1:5000/get-cars-by-brand'); // Create a new endpoint in backend
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'brandName': widget.brandName}),
      );

      print('get-cars-by-brand response status: ${response.statusCode}');
      print('get-cars-by-brand response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _carList = data.cast<Map<String, dynamic>>();
          _isLoading = false;
          _fetchAverageRatings(); // Fetch ratings after getting cars
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to fetch cars: ${response.statusCode}';
        });
        print('Failed to fetch cars: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching cars: $e';
      });
      print('Error fetching cars: $e');
    }
  }

    Future<void> _fetchAverageRatings() async {
    Map<String, double> fetchedRatings = {};
    for (var car in _carList) {
      final carId = car['_id'];
      try {
        final url = Uri.parse('http://127.0.0.1:5000/get-average-rating');
        print('Fetching average rating for carId: $carId');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'carId': carId}),
        );

        if (response.statusCode == 200) {
          final decodedBody = json.decode(response.body);
          print('Average rating response for carId $carId: $decodedBody');
          fetchedRatings[carId] = decodedBody['averageRating'].toDouble();
        } else {
          print(
              'Failed to fetch average rating for car $carId: ${response.statusCode}');
           fetchedRatings[carId] = 0.0; // Default rating if fetch fails
        }
      } catch (e) {
        print('Error fetching average rating for car $carId: $e');
         fetchedRatings[carId] = 0.0; // Default rating if fetch fails
      }
    }
    setState(() {
      _averageRatings = fetchedRatings;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.brandName} Vehicles'), // Display the brand name in the app bar
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _carList.isEmpty
                  ? const Center(child: Text('No cars found for this brand.'))
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder( // Changed from GridView to ListView
                        itemCount: _carList.length,
                        itemBuilder: (context, index) {
                          final carDetails = _carList[index];
                            final carId = carDetails['_id'];
                            final averageRating = _averageRatings[carId] ?? 0.0;
                          return _buildCarCard(context, carDetails,averageRating);
                        },
                      ),
                    ),
    );
  }

  Widget _buildCarCard(BuildContext context, Map<String, dynamic> carDetails, double rating) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
//Get screen Width

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailsScreen(
              carId: carDetails['_id'],
              userId: widget.userId, // Pass the correct userId
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0), // Added padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: carDetails['coverImageBytes'] != null
                    ? Image.memory(
                        base64Decode(carDetails['coverImageBytes']),
                        width: double.infinity,
                        height: 150, // set a fixed height for the image
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/cars.jpeg',
                        width: double.infinity,
                        height: 150, // set a fixed height for the image
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                carDetails['carModel'] ?? 'N/A',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), // Increased font size
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 16, // Increased item size
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    ignoreGestures: true,
                    onRatingUpdate: (rating) {
                      print(rating);
                    },
                  ),
                  Text(
                    currencyFormat.format(
                        int.parse(carDetails['pricePerHour'] ?? '0')),
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 16), // Increased font size
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}