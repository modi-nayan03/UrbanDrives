import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zoomwheels/widget/updatecarform/updateadditional_details_screen.dart';
import 'package:zoomwheels/widget/updatecarform/updatedate_time_screen.dart';
import 'package:zoomwheels/widget/updatecarform/updateeligibility_screen.dart';
import 'package:zoomwheels/widget/updatecarform/updatepickup_location_screen.dart';
import 'package:zoomwheels/widget/updatecarform/updateupload_images_screen.dart';
import 'dart:convert';

class UpdateCarForm extends StatefulWidget {
  final Map<String, dynamic> carDetails;
  final String userName;
  final String carId;

  const UpdateCarForm({
    Key? key,
    required this.carDetails,
    required this.userName,
    required this.carId,
  }) : super(key: key);

  @override
  UpdateCarFormState createState() => UpdateCarFormState();
}

class UpdateCarFormState extends State<UpdateCarForm> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  // Form Keys for validation
  final _formKeyEligibility = GlobalKey<FormState>();
  final _formKeyAdditional = GlobalKey<FormState>();
  final _formKeyLocation = GlobalKey<FormState>();

  // Form Variables
  String? _CarRegistrationNumber;
  String? _carBrand;
  String? _carModel;
  String? _yearOfRegistration;
  String? _city;
  String? _kmDriven;
  String? _chassisNumber;
  String? _fuelType;
  String? _transmissionType;
  String? _pricePerHour;
  String? _pickupLocation;
  String? _seatingCapacity;
  String? _bodyType;

  //Location Variables
  // double? _latitude;
  // double? _longitude;

  //Date and Time Variables
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  Map<String, dynamic> _carDetails = {}; // Store car details
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCarDetails();
  }

  Future<void> _fetchCarDetails() async {
    setState(() {
      _isLoading = true;
    });
    final url = Uri.parse('http://127.0.0.1:5000/get-car-by-id');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'carId': widget.carId}),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        _CarRegistrationNumber = data['CarRegistrationNumber'];
        _carBrand = data['carBrand'];
        _carModel = data['carModel'];
        _yearOfRegistration = data['yearOfRegistration'];
        _city = data['city'];
        _kmDriven = data['kmDriven'];
        _chassisNumber = data['chassisNumber'];
        _fuelType = data['fuelType'];
        _transmissionType = data['transmissionType'];
        _pricePerHour = data['pricePerHour'];
        _pickupLocation = data['pickupLocation'];
        _seatingCapacity = data['seatingCapacity'];
        _bodyType = data['bodyType'];

        _startDate = data['startDate'] != null
            ? DateTime.tryParse(data['startDate'])
            : null;

        _startTime = data['startTime'] != null
            ? _parseTimeOfDay(data['startTime'])
            : null;

        _endDate =
            data['endDate'] != null ? DateTime.tryParse(data['endDate']) : null;

        _endTime =
            data['endTime'] != null ? _parseTimeOfDay(data['endTime']) : null;
        _carDetails = {...data};
        setState(() {
          _isLoading = false;
        });
      } else {
        print('Failed to fetch car details ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching car details : $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  TimeOfDay? _parseTimeOfDay(String timeString) {
    try {
      final parts = timeString.split(":");
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
    setState(() {
      _currentPage++;
    });
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
    setState(() {
      _currentPage--;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
              )
            : null,
        title: const Text('Update Car Details'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                UpdateEligibilityScreen(
                  formKey: _formKeyEligibility,
                  onNext: _nextPage,
                  onCarRegistrationNumberChanged: (value) {},
                  onCarBrandChanged: (value) {},
                  onCarModelChanged: (value) {},
                  onYearOfRegistrationChanged: (value) {},
                  onCityChanged: (value) => _city = value,
                  onKmDrivenChanged: (value) => _kmDriven = value,
                  onSeatingCapacityChanged: (value) {},
                  onBodyTypeChanged: (value) {},
                  CarRegistrationNumber: _CarRegistrationNumber,
                  carBrand: _carBrand,
                  carModel: _carModel,
                  yearOfRegistration: _yearOfRegistration,
                  city: _city,
                  kmDriven: _kmDriven,
                  seatingCapacity: _seatingCapacity,
                  bodyType: _bodyType,
                   enabled: false,

                ),
                UpdateAdditionalDetailsScreen(
                  formKey: _formKeyAdditional,
                  onNext: _nextPage,
                  onChassisNumberChanged: (value) {},
                  onFuelTypeChanged: (value) => _fuelType = value,
                  onTransmissionTypeChanged: (value) {},
                  onPricePerHourChanged: (value) => _pricePerHour = value,
                  chassisNumber: _chassisNumber,
                  fuelType: _fuelType,
                  transmissionType: _transmissionType,
                  pricePerHour: _pricePerHour,
                   enabled: false,
                ),
                UpdatePickupLocationScreen(
                  formKey: _formKeyLocation,
                  onNext: _nextPage,
                  onPickupLocationChanged: (value) {
                    _pickupLocation = value;
                  },
                  pickupLocation: _pickupLocation,
                ),
                UpdateDateTimeScreen(
                  onNext: _nextPage,
                  onStartDateChanged: (value) => _startDate = value,
                  onStartTimeChanged: (value) => _startTime = value,
                  onEndDateChanged: (value) => _endDate = value,
                  onEndTimeChanged: (value) => _endTime = value,
                  startDate: _startDate,
                  startTime: _startTime,
                  endDate: _endDate,
                  endTime: _endTime,
                ),
                 UpdateUploadImagesScreen(
                    onNext: _nextPage,
                    carData: _carDetails,
                    uploadCarDetails: (imageDetails) async {
                       _carDetails = {
                        ..._carDetails,
                         'city': _city,
                         'kmDriven': _kmDriven,
                        'fuelType': _fuelType,
                         'pricePerHour': _pricePerHour,
                         'pickupLocation': _pickupLocation,
                        'startDate': _startDate?.toIso8601String(),
                        'startTime': _startTime?.format(context),
                        'endDate': _endDate?.toIso8601String(),
                        'endTime': _endTime?.format(context),
                          ...imageDetails,
                     };
                      final url = Uri.parse('http://127.0.0.1:5000/update-car');
                      try{
                       final response = await http.post(
                        url,
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode({..._carDetails, 'carId':widget.carId}),
                     );
                      if (response.statusCode == 200){
                        _showSnackBar('Car details updated successfully');
                           Navigator.pop(context, _carDetails);

                      }else{
                        _showSnackBar('Failed to update car');
                         print('Failed to update car ${response.statusCode}');
                      }
                   }catch(e){
                     _showSnackBar('Error updating car');
                      print('Error updating car $e');
                  }
                    }),
              ],
            ),
    );
  }
}