// // search_screen.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../vehiclelist_screen.dart';

// class SearchScreen extends StatefulWidget {
//   final String userEmail;
//   final String? city;
//   final String? startTime;
//   final String? endTime;
//   final List<String>? availableCarIds; // ADD THIS LINE

//   const SearchScreen({
//     Key? key,
//     required this.userEmail,
//     this.city,
//     this.startTime,
//     this.endTime,
//     this.availableCarIds, // ADD THIS TO THE CONSTRUCTOR
//   }) : super(key: key);

//   @override
//   SearchScreenState createState() => SearchScreenState();
// }

// class SearchScreenState extends State<SearchScreen> {
//   final _cityController = TextEditingController();
//   final _startDateController = TextEditingController();
//   final _endDateController = TextEditingController();
//   DateTime? _selectedStartDate;
//   DateTime? _selectedEndDate;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.city != null) {
//       _cityController.text = widget.city!;
//     }

//     if (widget.startTime != null) {
//       _selectedStartDate = DateTime.parse(widget.startTime!);
//       _startDateController.text = DateFormat('dd MMM yyyy hh:mm a').format(_selectedStartDate!);
//     }

//      if (widget.endTime != null) {
//       _selectedEndDate = DateTime.parse(widget.endTime!);
//       _endDateController.text = DateFormat('dd MMM yyyy hh:mm a').format(_selectedEndDate!);
//     }
//   }

//   @override
//   void dispose() {
//     _cityController.dispose();
//     _startDateController.dispose();
//     _endDateController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDateTime(BuildContext context, bool isStart) async {
//     print('_selectDateTime called with isStart: $isStart'); // Debugging
//     DateTime? selectedDate;
//     TimeOfDay? selectedTime;

//     try {
//       selectedDate = await showDatePicker(
//         context: context,
//         initialDate: isStart
//             ? (_selectedStartDate ?? DateTime.now())
//             : (_selectedEndDate ?? _selectedStartDate ?? DateTime.now()),
//         // Corrected initialDate
//         firstDate: isStart ? DateTime.now() : (_selectedStartDate ?? DateTime.now()),
//         lastDate: DateTime(2100),
//         builder: (BuildContext context, Widget? child) {
//           return Theme(
//             data: ThemeData.light().copyWith(
//               colorScheme: const ColorScheme.light(primary: Colors.blue),
//             ),
//             child: child!,
//           );
//         },
//       );
//       print('Selected Date: $selectedDate');
//     } catch (e) {
//       print('Error during showDatePicker: $e');
//       return;
//     }

//     if (selectedDate != null) {
//       try {
//         selectedTime = await showTimePicker(
//           context: context,
//           initialTime: TimeOfDay.now(),
//           builder: (BuildContext context, Widget? child) {
//             return Theme(
//               data: ThemeData.light().copyWith(
//                 colorScheme: const ColorScheme.light(primary: Colors.blue),
//               ),
//               child: child!,
//             );
//           },
//         );
//         print('Selected Time: $selectedTime');
//       } catch (e) {
//         print('Error during showTimePicker: $e');
//         return;
//       }

//       if (selectedTime != null) {
//         selectedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
//             selectedTime.hour, selectedTime.minute);
//         setState(() {
//           if (isStart) {
//             _selectedStartDate = selectedDate;
//             _startDateController.text =
//                 DateFormat('dd MMM yyyy hh:mm a').format(selectedDate!);
//           } else {
//             _selectedEndDate = selectedDate;
//             _endDateController.text = DateFormat('dd MMM yyyy hh:mm a').format(selectedDate!);
//           }
//         });
//       }
//     }
//   }

//   void _findVehicle() {
//     if (_cityController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter a city")),
//       );
//       return;
//     }
//     if (_selectedStartDate == null || _selectedEndDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select start and end date")),
//       );
//       return;
//     }

//     if (_selectedStartDate!.isAfter(_selectedEndDate!)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("End date can not be before start date")),
//       );
//       return;
//     }
//     final String formattedStartTime =
//         DateFormat("yyyy-MM-dd HH:mm:ss").format(_selectedStartDate!);
//     final String formattedEndTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(_selectedEndDate!);

//     // Capitalize the city
//     final String capitalizedCity = _cityController.text.trim().toUpperCase();

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => VehicleListScreen(
//           city: capitalizedCity,  // Use the capitalized city here
//           startTime: formattedStartTime,
//           endTime: formattedEndTime,
//           userId: widget.userEmail,
//           availableCarIds: widget.availableCarIds, //Pass value in this line
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     const double horizontalPadding = 20;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text('Find a Vehicle',
//             style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
//         backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 20),
//               // City Input
//               Container(
//                   decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(10),
//                       boxShadow: [
//                         BoxShadow(
//                             color: Colors.grey.withOpacity(0.2),
//                             spreadRadius: 1,
//                             blurRadius: 3,
//                             offset: const Offset(0, 2))
//                       ]),
//                   child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
//                       child: TextFormField(
//                         controller: _cityController,
//                         decoration: const InputDecoration(
//                           hintText: 'Enter City',
//                           border: InputBorder.none,
//                         ),
//                       ))),
//               const SizedBox(height: 20),
//               // Start Date & Time
//               InkWell(
//                   onTap: () {
//                     print('Start Date InkWell tapped'); // Debugging
//                     _selectDateTime(context, true);
//                   },
//                   borderRadius: BorderRadius.circular(10),
//                   child: Container(
//                       padding: const EdgeInsets.all(16.0),
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           color: Colors.grey.shade100,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.2),
//                               spreadRadius: 1,
//                               blurRadius: 3,
//                               offset: const Offset(0, 2),
//                             )
//                           ]),
//                       child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Start Date & Time',
//                               style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.grey[700]),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               _startDateController.text.isEmpty
//                                   ? 'Select Start Date & Time'
//                                   : _startDateController.text,
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.bold, fontSize: 18),
//                             ),
//                           ]))),
//               const SizedBox(height: 20),
//               // End Date & Time
//               InkWell(
//                   onTap: () {
//                     print('End Date InkWell tapped'); // Debugging
//                     _selectDateTime(context, false);
//                   },
//                   borderRadius: BorderRadius.circular(10),
//                   child: Container(
//                       padding: const EdgeInsets.all(16.0),
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           color: Colors.grey.shade100,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.2),
//                               spreadRadius: 1,
//                               blurRadius: 3,
//                               offset: const Offset(0, 2),
//                             )
//                           ]),
//                       child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'End Date & Time',
//                               style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.grey[700]),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               _endDateController.text.isEmpty
//                                   ? 'Select End Date & Time'
//                                   : _endDateController.text,
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.bold, fontSize: 18),
//                             ),
//                           ]))),
//               const SizedBox(height: 30),
//               ElevatedButton(
//                 onPressed: _findVehicle,
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10))),
//                 child: const Text(
//                   'Find Vehicle',
//                   style: TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }







































// after change calendar



// // search_screen.dart old
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../widget/daterangepicker.dart';
// import '../vehiclelist_screen.dart';


// class SearchScreen extends StatefulWidget {
//   final String userEmail;
//   final String? city;
//   final String? startTime;
//   final String? endTime;
//   final List<String>? availableCarIds; // ADD THIS LINE

//   const SearchScreen({
//     Key? key,
//     required this.userEmail,
//     this.city,
//     this.startTime,
//     this.endTime,
//     this.availableCarIds, // ADD THIS TO THE CONSTRUCTOR
//   }) : super(key: key);

//   @override
//   SearchScreenState createState() => SearchScreenState();
// }

// class SearchScreenState extends State<SearchScreen> {
//   final _cityController = TextEditingController();
//   DateTime? _startDate;
//   DateTime? _endDate;
//   TimeOfDay? _pickupTime;
//   TimeOfDay? _dropoffTime;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.city != null) {
//       _cityController.text = widget.city!;
//     }

//     if (widget.startTime != null && widget.endTime != null) {
//       try {
//         _startDate = DateTime.parse(widget.startTime!);
//         _endDate = DateTime.parse(widget.endTime!);
//         _pickupTime = TimeOfDay.fromDateTime(_startDate!);
//         _dropoffTime = TimeOfDay.fromDateTime(_endDate!);
//       } catch (e) {
//         print("Error parsing start or end time: $e");
//         // Handle the error, e.g., set default values or show an error message
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _cityController.dispose();
//     super.dispose();
//   }

//   Future<void> _showDateRangePicker(BuildContext context) async {
//     final result = await showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (BuildContext context) {
//         return Padding(
//           padding: MediaQuery.of(context).viewInsets,
//           child: const DateRangePicker(),
//         );
//       },
//     );

//     if (result != null && result is Map<String, dynamic>) {
//       setState(() {
//         _startDate = result['startDate'] as DateTime?;
//         _endDate = result['endDate'] as DateTime?;
//         _pickupTime = result['pickupTime'] as TimeOfDay?;
//         _dropoffTime = result['dropoffTime'] as TimeOfDay?;

//         print("Start Date: $_startDate");
//         print("End Date: $_endDate");
//       });
//     }
//   }

//   void _findVehicle() {
//     if (_cityController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter a city")),
//       );
//       return;
//     }
//     if (_startDate == null || _endDate == null || _pickupTime == null || _dropoffTime == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select start and end date and time")),
//       );
//       return;
//     }

//     if (_startDate!.isAfter(_endDate!)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("End date can not be before start date")),
//       );
//       return;
//     }

//     // Combine date and time
//     DateTime startDateTime = DateTime(_startDate!.year, _startDate!.month, _startDate!.day, _pickupTime!.hour, _pickupTime!.minute);
//     DateTime endDateTime = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, _dropoffTime!.hour, _dropoffTime!.minute);

//     final String formattedStartTime =
//         DateFormat("yyyy-MM-dd HH:mm:ss").format(startDateTime);
//     final String formattedEndTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(endDateTime);

//     // Capitalize the city
//     final String capitalizedCity = _cityController.text.trim().toUpperCase();

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => VehicleListScreen(
//           city: capitalizedCity,
//           startTime: formattedStartTime,
//           endTime: formattedEndTime,
//           userId: widget.userEmail,
//           availableCarIds: widget.availableCarIds, //Pass value in this line
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     const double horizontalPadding = 20;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text('Find a Vehicle',
//             style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
//         backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 20),
//               // City Input
//               Container(
//                   decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(10),
//                       boxShadow: [
//                         BoxShadow(
//                             color: Colors.grey.withOpacity(0.2),
//                             spreadRadius: 1,
//                             blurRadius: 3,
//                             offset: const Offset(0, 2))
//                       ]),
//                   child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
//                       child: TextFormField(
//                         controller: _cityController,
//                         decoration: const InputDecoration(
//                           hintText: 'Enter City',
//                           border: InputBorder.none,
//                         ),
//                       ))),
//               const SizedBox(height: 20),
//               // Date Range Picker
//               InkWell(
//                   onTap: () {
//                     _showDateRangePicker(context);
//                   },
//                   borderRadius: BorderRadius.circular(10),
//                   child: Container(
//                       padding: const EdgeInsets.all(16.0),
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           color: Colors.grey.shade100,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.2),
//                               spreadRadius: 1,
//                               blurRadius: 3,
//                               offset: const Offset(0, 2),
//                             )
//                           ]),
//                       child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Select Date & Time Range',
//                               style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.grey[700]),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               _startDate != null && _endDate != null && _pickupTime != null && _dropoffTime != null
//                                   ? '${DateFormat('dd MMM yyyy').format(_startDate!)} ${_pickupTime!.format(context)} - ${DateFormat('dd MMM yyyy').format(_endDate!)} ${_dropoffTime!.format(context)}'
//                                   : 'Select Date & Time Range',
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.bold, fontSize: 18),
//                             ),
//                           ]))),
//               const SizedBox(height: 30),
//               ElevatedButton(
//                 onPressed: _findVehicle,
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10))),
//                 child: const Text(
//                   'Find Vehicle',
//                   style: TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

















































































// jatin 25/02/25
// search_screen.dart
// search_screen.dart
// search_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widget/daterangepicker.dart';
import '../vehiclelist_screen.dart';

class SearchScreen extends StatefulWidget {
  final String userEmail;
  final String? city;
  final String? startTime;
  final String? endTime;
  final List<String>? availableCarIds; // ADD THIS LINE

  const SearchScreen({
    Key? key,
    required this.userEmail,
    this.city,
    this.startTime,
    this.endTime,
    this.availableCarIds, // ADD THIS TO THE CONSTRUCTOR
  }) : super(key: key);

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final _cityController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _pickupTime;
  TimeOfDay? _dropoffTime;

  @override
  void initState() {
    super.initState();
    if (widget.city != null) {
      _cityController.text = widget.city!;
    }

    if (widget.startTime != null && widget.endTime != null) {
      try {
        _startDate = DateTime.parse(widget.startTime!);
        _endDate = DateTime.parse(widget.endTime!);
        _pickupTime = TimeOfDay.fromDateTime(_startDate!);
        _dropoffTime = TimeOfDay.fromDateTime(_endDate!);
      } catch (e) {
        print("Error parsing start or end time: $e");
        // Handle the error, e.g., set default values or show an error message
      }
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: DateRangePicker(
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _startDate = result['startDate'] as DateTime?;
        _endDate = result['endDate'] as DateTime?;
        _pickupTime = result['pickupTime'] as TimeOfDay?;
        _dropoffTime = result['dropoffTime'] as TimeOfDay?;

        print("Start Date: $_startDate");
        print("End Date: $_endDate");
      });
    }
  }

  void _findVehicle() {
    if (_cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a city")),
      );
      return;
    }
    if (_startDate == null ||
        _endDate == null ||
        _pickupTime == null ||
        _dropoffTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select start and end date and time")),
      );
      return;
    }

    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("End date can not be before start date")),
      );
      return;
    }

    // Combine date and time
    DateTime startDateTime = DateTime(_startDate!.year, _startDate!.month,
        _startDate!.day, _pickupTime!.hour, _pickupTime!.minute);
    DateTime endDateTime = DateTime(_endDate!.year, _endDate!.month, _endDate!.day,
        _dropoffTime!.hour, _dropoffTime!.minute);

    final String formattedStartTime =
        DateFormat("yyyy-MM-dd HH:mm:ss").format(startDateTime);
    final String formattedEndTime =
        DateFormat("yyyy-MM-dd HH:mm:ss").format(endDateTime);

    // Capitalize the city
    final String capitalizedCity = _cityController.text.trim().toUpperCase();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleListScreen(
          city: capitalizedCity,
          startTime: formattedStartTime,
          endTime: formattedEndTime,
          userId: widget.userEmail,
          availableCarIds: widget.availableCarIds, //Pass value in this line
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 20;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Find a Vehicle',
            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // City Input
              Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2))
                      ]),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          hintText: 'Enter City',
                          border: InputBorder.none,
                        ),
                      ))),
              const SizedBox(height: 20),
              // Date Range Picker
              InkWell(
                  onTap: () {
                    _showDateRangePicker(context);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade100,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            )
                          ]),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Date & Time Range',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _startDate != null && _endDate != null
                                  ? '${DateFormat('dd MMM yyyy').format(_startDate!)} ${_pickupTime != null ? _pickupTime!.format(context) : "Select Time"} - ${DateFormat('dd MMM yyyy').format(_endDate!)} ${_dropoffTime != null ? _dropoffTime!.format(context) : _pickupTime != null ? "Select Time" : ""}'
                                  : 'Select Date & Time Range',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ]))),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _findVehicle,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text(
                  'Find Vehicle',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}