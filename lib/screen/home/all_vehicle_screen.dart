import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'car_details_screen.dart'; // Import the CarDetailsScreen

class AllVehicleScreen extends StatefulWidget {
  final List<Map<String, dynamic>> carDetailsList;
  final Map<String, double> averageRatings;
  final String userId; // Add userId here

  const AllVehicleScreen({
    Key? key,
    required this.carDetailsList,
    required this.averageRatings,
    required this.userId, // Add userId here
  }) : super(key: key);

  @override
  State<AllVehicleScreen> createState() => _AllVehicleScreenState();
}

class _AllVehicleScreenState extends State<AllVehicleScreen> {
  List<Map<String, dynamic>> _sortedCarList = [];

  @override
  void initState() {
    super.initState();
    _sortCars();
  }

  void _sortCars() {
    List<Map<String, dynamic>> sortedList = List.from(widget.carDetailsList);
    sortedList.sort((a, b) {
      double ratingA = widget.averageRatings[a['_id']] ?? 0.0;
      double ratingB = widget.averageRatings[b['_id']] ?? 0.0;
      return ratingB.compareTo(ratingA); // Sort in descending order
    });
    setState(() {
      _sortedCarList = sortedList;
    });
  }

  @override
  Widget build(BuildContext context) {
     print("Car Details List: ${widget.carDetailsList}");
      print("Average Ratings: ${widget.averageRatings}");
      print("_sortedCarList: ${_sortedCarList}");

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Vehicles"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: _sortedCarList.length,
          itemBuilder: (context, index) {
            final carDetails = _sortedCarList[index];
            final carId = carDetails['_id'];
            final averageRating = widget.averageRatings[carId] ?? 0.0;
            return _buildCarCard(context, carDetails, averageRating);
          },
        ),
      ),
    );
  }

  Widget _buildCarCard(
      BuildContext context, Map<String, dynamic> carDetails, double rating) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    return InkWell( // Wrap the card with InkWell
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
      child: Card( // The original card widget
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: carDetails['coverImageBytes'] != null
                    ? Image.memory(
                        base64Decode(carDetails['coverImageBytes']),
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/cars.jpeg',
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 5),
              Text(
                carDetails['carModel'] ?? 'N/A',
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 12,
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
                        fontWeight: FontWeight.w500, fontSize: 14),
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