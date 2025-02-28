import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zoomwheels/screen/home/car_details_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:zoomwheels/screen/home/search_screen.dart';

class VehicleListScreen extends StatefulWidget {
  final String? city;
  final String? startTime;
  final String? endTime;
  final String userId;
  final List<String>? availableCarIds;

  const VehicleListScreen({
    Key? key,
    this.city,
    this.startTime,
    this.endTime,
    required this.userId,
    this.availableCarIds,
  }) : super(key: key);

  @override
  _VehicleListScreenState createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  // State variables
  String? _city;
  String? _startTime;
  String? _endTime;

  List<Map<String, dynamic>> _filteredVehicleList = [];
  Map<String, double> _averageRatings = {};
  bool _isLoading = false;
  String _errorMessage = '';
  String? _selectedSortOption;

  // Filter selections
  Set<String> _selectedBrands = {};
  Set<String> _selectedModels = {};
  Set<dynamic> _selectedKmsDriven = {};
  Set<String> _selectedFuelTypes = {};
  Set<String> _selectedTransmissions = {};
  Set<String> _selectedBodyTypes = {};
  Set<dynamic> _selectedSeatings = {};

  // Filter selection flags
  bool _isBrandFilterSelected = false;
  bool _isModelFilterSelected = false;
  bool _isKmsDrivenFilterSelected = false;
  bool _isFuelTypeFilterSelected = false;
  bool _isTransmissionFilterSelected = false;
  bool _isBodyTypeFilterSelected = false;
  bool _isSeatingFilterSelected = false;
  bool _isSortBySelected = false;

  List<Map<String, dynamic>> _vehicleList = const [];

  @override
  void initState() {
    super.initState();
    _city = widget.city;
    _startTime = widget.startTime;
    _endTime = widget.endTime;
    _fetchVehicles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _averageRatings = {};

      _selectedBrands.clear();
      _selectedModels.clear();
      _selectedKmsDriven.clear();
      _selectedFuelTypes.clear();
      _selectedTransmissions.clear();
      _selectedBodyTypes.clear();
      _selectedSeatings.clear();
      _resetAllFilters();
    });

    final url = Uri.parse('http://127.0.0.1:5000/search-cars');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'city': _city,
          'startTime': _startTime,
          'endTime': _endTime,
          'userId': widget.userId,
        }),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> carList = data.cast<Map<String, dynamic>>();

        // APPLY THE FILTER HERE:  Only keep cars whose _id is in widget.availableCarIds
        if (widget.availableCarIds != null && widget.availableCarIds!.isNotEmpty) {
          carList = carList.where((car) => widget.availableCarIds!.contains(car['_id'])).toList();
        }

        setState(() {
          _vehicleList = carList;  // Assign the FILTRED list to _vehicleList
          _applyFilters();
          _isLoading = false;
        });

        await _fetchAverageRatings(); // call to fetch rating

      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to fetch vehicles: ${response.statusCode}';
        });
        print('Failed to fetch vehicles: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching vehicles: $e';
      });
      print('Error fetching vehicles: $e');
    }
  }

  Future<void> _fetchAverageRatings() async {
    for (var car in _filteredVehicleList) {
      final carId = car['_id'];
      try {
        final url = Uri.parse('http://127.0.0.1:5000/get-average-rating');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'carId': carId}),
        );

        if (response.statusCode == 200) {
          final decodedBody = json.decode(response.body);
          setState(() {
            _averageRatings[carId] = decodedBody['averageRating'].toDouble();
          });
        } else {
          print(
              'Failed to fetch average rating for car $carId: ${response.statusCode}');
          _averageRatings[carId] = 0.0; // Default to 0 if fetch fails
        }
      } catch (e) {
        print('Error fetching average rating for car $carId: $e');
        _averageRatings[carId] = 0.0; // Default to 0 if there's an error
      }
    }
  }

  Widget _buildLocationHeader(String city, String? startTime, String? endTime) {
    String currentCity = _city ?? 'No City';

    String dateTimeDisplay = 'No Date Selected';
    DateTime? startDate;
    // DateTime? endDate;

    if (_startTime != null && _endTime != null) {
      startDate = DateTime.parse(_startTime!);
      // endDate = DateTime.parse(_endTime!);

      final formattedStartTime = DateFormat('dd MMM, hh:mm a').format(startDate);
      final formattedEndTime = DateFormat('dd MMM, hh:mm a').format(DateTime.parse(_endTime!));
      dateTimeDisplay = "$formattedStartTime - $formattedEndTime";
    }
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchScreen(
              userEmail: widget.userId,
              city: _city,
              startTime: _startTime,
              endTime: _endTime,
              availableCarIds: widget.availableCarIds,
            ),
          ),
        );

        if (result != null && result is Map<String, String?>) {
          setState(() {
            _city = result['city'];
            _startTime = result['startTime'];
            _endTime = result['endTime'];
          });

          _fetchVehicles();
        }
      },
      child: Container(
        width: double.infinity, // Make it take full width
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: MediaQuery.of(context).size.width * 0.04), // Add horizontal padding based on screen width
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded( // Use Expanded to take up remaining space
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(currentCity,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(dateTimeDisplay,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(
              Icons.edit_outlined,
              color: Colors.blue,
            )
          ],
        ),
      ),
    );
  }


  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add some padding
      child: Row(
        children: [
          _buildFilterButton(
            label: 'Sort By',
            onTap: () => _showSortOptions(context),
            isSelected: _isSortBySelected,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          _buildFilterButton(
            label: 'Brand',
            onTap: () => _showBrandFilter(context),
            isSelected: _isBrandFilterSelected,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          _buildFilterButton(
            label: 'Model',
            onTap: () => _showModelFilter(context),
            isSelected: _isModelFilterSelected,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          _buildFilterButton(
            label: 'Kms Driven',
            onTap: () => _showKmsDrivenFilter(context),
            isSelected: _isKmsDrivenFilterSelected,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          _buildFilterButton(
            label: 'Fuel Type',
            onTap: () => _showFuelTypeFilter(context),
            isSelected: _isFuelTypeFilterSelected,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          _buildFilterButton(
            label: 'Transmission',
            onTap: () => _showTransmissionFilter(context),
            isSelected: _isTransmissionFilterSelected,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          _buildFilterButton(
            label: 'Body',
            onTap: () => _showBodyTypeFilter(context),
            isSelected: _isBodyTypeFilterSelected,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          _buildFilterButton(
            label: 'Seating',
            onTap: () => _showSeatingFilter(context),
            isSelected: _isSeatingFilterSelected,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          InkWell(
            onTap: () {
              setState(() {
                _selectedSortOption = null;
                _selectedBrands.clear();
                _selectedModels.clear();
                _selectedKmsDriven.clear();
                _selectedFuelTypes.clear();
                _selectedTransmissions.clear();
                _selectedBodyTypes.clear();
                _selectedSeatings.clear();
                _resetAllFilters();
                _applyFilters();
              });
            },
            child: const Icon(Icons.restart_alt),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02), // Use screen width percentage for horizontal padding
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.shade100 : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_outlined),
          ],
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container( // Added Container to set width
          width: MediaQuery.of(context).size.width, // Take full screen width
          child: SingleChildScrollView( //Added Scrollview
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: const Text('All'),
                  onTap: () {
                    setState(() {
                      _selectedSortOption = null;
                      _isSortBySelected = false;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Price Low to High'),
                  onTap: () {
                    setState(() {
                      _selectedSortOption = 'Price Low to High';
                      _isSortBySelected = true;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Price High to Low'),
                  onTap: () {
                    setState(() {
                      _selectedSortOption = 'Price High to Low';
                      _isSortBySelected = true;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBrandFilter(BuildContext context) {
    _showFilterModal(
      context: context,
      title: 'Brand',
      options: _vehicleList.map((vehicle) => vehicle['carBrand'] as String).toSet().toList(),
      selectedOptions: _selectedBrands,
      onOptionSelected: (brand) {
        setState(() {
          // Replace the existing selection with the new brand
          _selectedBrands.clear(); // Clear existing selections
          final String brandLower = brand.toLowerCase();
          _selectedBrands.add(brandLower); // Add the newly selected brand

          _isBrandFilterSelected = _selectedBrands.isNotEmpty;
          _applyFilters();
        });
      },
      onReset: () {
        setState(() {
          _selectedBrands.clear();
          _isBrandFilterSelected = false;
          _applyFilters();
        });
      },
    );
  }

  void _showModelFilter(BuildContext context) {
    _showFilterModal(
      context: context,
      title: 'Model',
      options: _vehicleList.map((vehicle) => vehicle['carModel'] as String).toSet().toList(),
      selectedOptions: _selectedModels,
      onOptionSelected: (model) {
        setState(() {
          // Replace the existing selection with the new model
          _selectedModels.clear(); // Clear existing selections
          final String modelLower = model.toLowerCase();
          _selectedModels.add(modelLower); // Add the newly selected model

          _isModelFilterSelected = _selectedModels.isNotEmpty;
          _applyFilters();
        });
      },
      onReset: () {
        setState(() {
          _selectedModels.clear();
          _isModelFilterSelected = false;
          _applyFilters();
        });
      },
    );
  }

  void _showKmsDrivenFilter(BuildContext context) {
    _showFilterModal(
      context: context,
      title: 'Kms Driven',
      options: _vehicleList.map((vehicle) => vehicle['kmDriven']).toSet().toList(),
      selectedOptions: _selectedKmsDriven,
      onOptionSelected: (kmDriven) {
        setState(() {
          // Replace the existing selection with the new kmDriven
          _selectedKmsDriven.clear(); // Clear existing selections
          _selectedKmsDriven.add(kmDriven); // Add the newly selected kmDriven

          _isKmsDrivenFilterSelected = _selectedKmsDriven.isNotEmpty;
          _applyFilters();
        });
      },
      onReset: () {
        setState(() {
          _selectedKmsDriven.clear();
          _isKmsDrivenFilterSelected = false;
          _applyFilters();
        });
      },
    );
  }

  void _showFuelTypeFilter(BuildContext context) {
    _showFilterModal(
      context: context,
      title: 'Fuel Type',
      options: _vehicleList.map((vehicle) => vehicle['fuelType'] as String).toSet().toList(),
      selectedOptions: _selectedFuelTypes,
      onOptionSelected: (fuelType) {
        setState(() {
          // Replace the existing selection with the new fuelType
          _selectedFuelTypes.clear(); // Clear existing selections
          final String fuelTypeLower = fuelType.toLowerCase();
          _selectedFuelTypes.add(fuelTypeLower); // Add the newly selected fuelType

          _isFuelTypeFilterSelected = _selectedFuelTypes.isNotEmpty;
          _applyFilters();
        });
      },
      onReset: () {
        setState(() {
          _selectedFuelTypes.clear();
          _isFuelTypeFilterSelected = false;
          _applyFilters();
        });
      },
    );
  }

  void _showTransmissionFilter(BuildContext context) {
    _showFilterModal(
      context: context,
      title: 'Transmission',
      options: _vehicleList.map((vehicle) => vehicle['transmissionType'] as String).toSet().toList(),
      selectedOptions: _selectedTransmissions,
      onOptionSelected: (transmission) {
        setState(() {
          // Replace the existing selection with the new transmission
          _selectedTransmissions.clear(); // Clear existing selections
          final String transmissionLower = transmission.toLowerCase();
          _selectedTransmissions.add(transmissionLower); // Add the newly selected transmission

          _isTransmissionFilterSelected = _selectedTransmissions.isNotEmpty;
          _applyFilters();
        });
      },
      onReset: () {
        setState(() {
          _selectedTransmissions.clear();
          _isTransmissionFilterSelected = false;
          _applyFilters();
        });
      },
    );
  }

  void _showBodyTypeFilter(BuildContext context) {
    _showFilterModal(
      context: context,
      title: 'Body Type',
      options: _vehicleList.map((vehicle) => vehicle['bodyType'] as String).toSet().toList(),
      selectedOptions: _selectedBodyTypes,
      onOptionSelected: (bodyType) {
        setState(() {
          // Replace the existing selection with the new bodyType
          _selectedBodyTypes.clear(); // Clear existing selections
          final String bodyTypeLower = bodyType.toLowerCase();
          _selectedBodyTypes.add(bodyTypeLower); // Add the newly selected bodyType

          _isBodyTypeFilterSelected = _selectedBodyTypes.isNotEmpty;
          _applyFilters();
        });
      },
      onReset: () {
        setState(() {
          _selectedBodyTypes.clear();
          _isBodyTypeFilterSelected = false;
          _applyFilters();
        });
      },
    );
  }

  void _showSeatingFilter(BuildContext context) {
    _showFilterModal(
      context: context,
      title: 'Seating Capacity',
      options: _vehicleList.map((vehicle) => vehicle['seatingCapacity']).toSet().toList(),
      selectedOptions: _selectedSeatings,
      onOptionSelected: (seating) {
        setState(() {
          // Replace the existing selection with the new seating
          _selectedSeatings.clear(); // Clear existing selections
          _selectedSeatings.add(seating); // Add the newly selected seating

          _isSeatingFilterSelected = _selectedSeatings.isNotEmpty;
          _applyFilters();
        });
      },
      onReset: () {
        setState(() {
          _selectedSeatings.clear();
          _isSeatingFilterSelected = false;
          _applyFilters();
        });
      },
    );
  }

  void _showFilterModal({
    required BuildContext context,
    required String title,
    required List<dynamic> options,
    required Set<dynamic> selectedOptions,
    required Function(dynamic) onOptionSelected,
    required VoidCallback onReset,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView( // Added ScrollView
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: const Text('All'),
                  onTap: () {
                    onReset();
                    Navigator.pop(context);
                  },
                ),
                ...options.map((option) => ListTile(
                      title: Text(option.toString()),
                      onTap: () {
                        onOptionSelected(option);
                        Navigator.pop(context);
                      },
                    )),
                ListTile(
                  title: const Text('Reset'),
                  onTap: () {
                    onReset();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _resetAllFilters() {
    setState(() {
      _isBrandFilterSelected = false;
      _isModelFilterSelected = false;
      _isKmsDrivenFilterSelected = false;
      _isFuelTypeFilterSelected = false;
      _isTransmissionFilterSelected = false;
      _isBodyTypeFilterSelected = false;
      _isSeatingFilterSelected = false;
      _isSortBySelected = false;
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> result = List.from(_vehicleList);

    if (_selectedSortOption != null) {
      if (_selectedSortOption == 'Price Low to High') {
        result.sort((a, b) => (double.tryParse(a['pricePerHour'].toString()) ?? 0.0)
            .compareTo((double.tryParse(b['pricePerHour'].toString()) ?? 0.0)));
      } else if (_selectedSortOption == 'Price High to Low') {
        result.sort((a, b) => (double.tryParse(b['pricePerHour'].toString()) ?? 0.0)
            .compareTo((double.tryParse(a['pricePerHour'].toString()) ?? 0.0)));
      }
    }

    if (_selectedBrands.isNotEmpty) {
      result = result
          .where((vehicle) => _selectedBrands.contains((vehicle['carBrand'] as String?)?.toLowerCase()))
          .toList();
    }

    if (_selectedModels.isNotEmpty) {
      result = result
          .where((vehicle) => _selectedModels.contains((vehicle['carModel'] as String?)?.toLowerCase()))
          .toList();
    }

    if (_selectedKmsDriven.isNotEmpty) {
      result = result
          .where((vehicle) => _selectedKmsDriven.contains(vehicle['kmDriven']))
          .toList();
    }

    if (_selectedFuelTypes.isNotEmpty) {
      result = result
          .where((vehicle) => _selectedFuelTypes.contains((vehicle['fuelType'] as String?)?.toLowerCase()))
          .toList();
    }

    if (_selectedTransmissions.isNotEmpty) {
      result = result
          .where((vehicle) => _selectedTransmissions.contains((vehicle['transmissionType'] as String?)?.toLowerCase()))
          .toList();
    }

    if (_selectedBodyTypes.isNotEmpty) {
      result = result
          .where((vehicle) => _selectedBodyTypes.contains((vehicle['bodyType'] as String?)?.toLowerCase()))
          .toList();
    }

    if (_selectedSeatings.isNotEmpty) {
      result = result.where((vehicle) => _selectedSeatings.contains(vehicle['seatingCapacity'])).toList();
    }

    setState(() {
      _filteredVehicleList = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04), // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationHeader(_city ?? 'No City', _startTime, _endTime),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01), // Responsive spacing
            _buildFilterBar(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02), // Responsive spacing
            const Text(
              'All Vehicle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01), // Responsive spacing
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage))
                      : ListView.builder(
                          itemCount: _filteredVehicleList.length,
                          itemBuilder: (context, index) {
                            final carDetails = _filteredVehicleList[index];
                            final carModel = carDetails['carModel'] as String?;
                            final coverImageBytes = carDetails['coverImageBytes'] as String?;
                            final carId = carDetails['_id'] as String?;
                            double averageRating = _averageRatings[carId] ?? 0.0;

                            return _VehicleCard(
                              coverImageBytes: coverImageBytes,
                              name: carModel ?? 'N/A',
                              carRegNum: carDetails['CarRegistrationNumber'] ?? '',
                              rentalCostPerHour: double.tryParse(carDetails['pricePerHour']?.toString() ?? '0.0') ?? 0.0,
                              driverCostPerHour: 0.0,
                              carId: carId ?? '',
                              userId: widget.userId,
                              transmissionType: carDetails['transmissionType'] ?? 'N/A',
                              seatingCapacity: (carDetails['seatingCapacity'] is int)
                                  ? carDetails['seatingCapacity'] as int
                                  : int.tryParse(carDetails['seatingCapacity']?.toString() ?? '5') ?? 5,
                              averageRating: averageRating,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final String? coverImageBytes;
  final String name;
  final String carRegNum;
  final double rentalCostPerHour;
  final double driverCostPerHour;
  final String carId;
  final String userId;
  final String transmissionType;
  final int seatingCapacity;
  final double averageRating;

  const _VehicleCard({
    Key? key,
    this.coverImageBytes,
    required this.name,
    required this.carRegNum,
    required this.rentalCostPerHour,
    required this.driverCostPerHour,
    required this.carId,
    required this.userId,
    required this.transmissionType,
    required this.seatingCapacity,
    required this.averageRating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetailsScreen(carId: carId, userId: userId),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02), // Responsive bottom margin
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02), // Responsive padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: coverImageBytes != null
                    ? Image.memory(
                        base64Decode(coverImageBytes!),
                        width: MediaQuery.of(context).size.width * 0.25, // Responsive image width
                        height: MediaQuery.of(context).size.height * 0.1,  // Responsive image height
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/cars.jpeg',
                        width: MediaQuery.of(context).size.width * 0.25, // Responsive image width
                        height: MediaQuery.of(context).size.height * 0.1,  // Responsive image height
                        fit: BoxFit.cover,
                      ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02), // Responsive spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01), // Responsive spacing
                    Text(
                      '$transmissionType • $seatingCapacity Seater',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01), // Responsive spacing
                    Row(
                      children: [
                        // Use a loop to dynamically generate the stars
                        for (int i = 1; i <= 5; i++)
                          Icon(
                            i <= averageRating ? Icons.star : Icons.star_border, // Fill if i <= averageRating
                            color: Colors.amber,
                            size: 16,
                          ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.01), // Responsive spacing
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01), // Responsive spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currencyFormat.format(rentalCostPerHour),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}