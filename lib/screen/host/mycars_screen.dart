import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zoomwheels/widget/addcarform/add_car_form.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../widget/updatecarform/update_car_form.dart';

class MyCarsScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userId;

  const MyCarsScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userId,
  });

  @override
  State<MyCarsScreen> createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends State<MyCarsScreen> {
  List<Map<String, dynamic>> _carDetailsList = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCars();
  }

  Future<void> _fetchCars() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://127.0.0.1:5000/get-cars-by-host');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': widget.userId}),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _carDetailsList = data.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        print('Failed to fetch cars: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching cars: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addNewCarData() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddCarForm(
              userName: widget.userName,
              userEmail: widget.userEmail,
              userId: widget.userId)),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _carDetailsList.add(result);
        _listKey.currentState?.insertItem(_carDetailsList.length - 1);
      });
    }
  }

  Future<void> _deleteCarData(int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this car?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                final item = _carDetailsList[index];
                final carId = item['_id'];
                setState(() {
                  _carDetailsList.removeAt(index);
                  _listKey.currentState?.removeItem(
                    index,
                    (context, animation) =>
                        _buildCarCard(context, item, animation, index),
                  );
                });
                Navigator.of(context).pop();
                await _deleteCarFromDatabase(carId);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCarFromDatabase(String carId) async {
    final url = Uri.parse('http://127.0.0.1:5000/delete-car');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'carId': carId}),
      );
      if (response.statusCode == 200) {
        print('Car delete successfuly');
      } else {
        print('Failed to delete car ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting car: $e');
    }
  }

  void _updateCarData(int index, Map<String, dynamic> carDetails) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UpdateCarForm(carDetails: carDetails, userName: widget.userName, carId:carDetails['_id'],),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _carDetailsList[index] = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Cars',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: _addNewCarData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _carDetailsList.isEmpty
                ? const Center(
                    child:
                        Text('No cars added yet. Press "+" to add a new car.'))
                : AnimatedList(
                    key: _listKey,
                    initialItemCount: _carDetailsList.length,
                    itemBuilder: (context, index, animation) {
                      final carDetails = _carDetailsList[index];

                      return Dismissible(
                        key: UniqueKey(),
                        background: slideBackground(),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {},
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            _deleteCarData(index);
                            return false;
                          }
                          return false;
                        },
                        child: GestureDetector(
                          onTap: () {
                            _updateCarData(index, carDetails);
                          },
                          child: _buildCarCard(
                              context, carDetails, animation, index),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  /// Widget for swipe background (Update/Delete buttons)
  Widget slideBackground() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      color: Colors.red,
      alignment: Alignment.centerRight,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Delete',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          Icon(Icons.delete, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildCarCard(BuildContext context, Map<String, dynamic> carDetails,
      Animation animation, int index) {
    final controller = PageController(viewportFraction: 1, initialPage: 0);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              child: PageView(
                controller: controller,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: carDetails['coverImageBytes'] != null
                        ? Image.memory(
                            base64Decode(carDetails['coverImageBytes']),
                            fit: BoxFit.cover)
                        : Image.asset("assets/images/cars.jpeg",
                            fit: BoxFit.cover),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: carDetails['exteriorImageBytes'] != null
                        ? Image.memory(
                            base64Decode(carDetails['exteriorImageBytes']),
                            fit: BoxFit.cover)
                        : Image.asset("assets/images/cars.jpeg",
                            fit: BoxFit.cover),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: carDetails['interiorImageBytes'] != null
                        ? Image.memory(
                            base64Decode(carDetails['interiorImageBytes']),
                            fit: BoxFit.cover)
                        : Image.asset("assets/images/cars.jpeg",
                            fit: BoxFit.cover),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SmoothPageIndicator(
              controller: controller,
              count: 3,
              effect: const WormEffect(dotHeight: 8, dotWidth: 8),
            ),
            const SizedBox(height: 8),
            Text(
              carDetails['carModel'] ?? 'N/A',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${carDetails['kmDriven'] ?? "N/A"} kmDriven • ${carDetails['transmissionType'] ?? "N/A"} • ${carDetails['seatingCapacity'] ?? "N/A"} Seater',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Text(
                  carDetails['CarRegistrationNumber'] ?? 'N/A',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
