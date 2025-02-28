// import 'package:flutter/material.dart';

// import '../addcarform/form_button.dart';

// class UpdateDateTimeScreen extends StatefulWidget {
//   final Function onNext;
//   final Function(DateTime?) onStartDateChanged;
//   final Function(TimeOfDay?) onStartTimeChanged;
//   final Function(DateTime?) onEndDateChanged;
//   final Function(TimeOfDay?) onEndTimeChanged;
//   final DateTime? startDate;
//   final TimeOfDay? startTime;
//   final DateTime? endDate;
//   final TimeOfDay? endTime;

//   const UpdateDateTimeScreen({
//     super.key,
//     required this.onNext,
//     required this.onStartDateChanged,
//     required this.onStartTimeChanged,
//     required this.onEndDateChanged,
//     required this.onEndTimeChanged,
//     this.startDate,
//     this.startTime,
//     this.endDate,
//     this.endTime,
//   });

//   @override
//   UpdateDateTimeScreenState createState() => UpdateDateTimeScreenState();
// }

// class UpdateDateTimeScreenState extends State<UpdateDateTimeScreen> {
//   DateTime? _selectedStartDate;
//   TimeOfDay? _selectedStartTime;
//   DateTime? _selectedEndDate;
//   TimeOfDay? _selectedEndTime;

//   @override
//   void initState() {
//     super.initState();
//     _selectedStartDate = widget.startDate;
//     _selectedStartTime = widget.startTime;
//     _selectedEndDate = widget.endDate;
//     _selectedEndTime = widget.endTime;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Row(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.arrow_back),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//               ),
//               const SizedBox(width: 8),
//               const Text(
//                 'Car Sharing Dates & Time',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: Colors.blue, width: 2),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Start Date & Time',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, color: Colors.grey),
//                       ),
//                       Text(
//                         _selectedStartDate == null
//                             ? 'Not Selected'
//                             : '${_selectedStartDate!.day} ${_getMonthName(_selectedStartDate!.month)} ${_selectedStartDate!.year}   ${_selectedStartTime?.format(context) ?? 'Not selected'}',
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: screenHeight * 0.01),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       ElevatedButton(
//                         onPressed: () async {
//                           DateTime today = DateTime.now();
//                           DateTime initialDate = _selectedStartDate != null &&
//                                   _selectedStartDate!.isAfter(today)
//                               ? _selectedStartDate!
//                               : today;

//                           final date = await showDatePicker(
//                             context: context,
//                             initialDate: initialDate,
//                             firstDate: today,
//                             lastDate: DateTime(2101),
//                           );

//                           if (date != null) {
//                             final time = await showTimePicker(
//                               context: context,
//                               initialTime:
//                                   _selectedStartTime ?? TimeOfDay.now(),
//                             );
//                             if (time != null) {
//                               setState(() {
//                                 _selectedStartDate = date;
//                                 _selectedStartTime = time;
//                               });
//                               widget.onStartDateChanged(date);
//                               widget.onStartTimeChanged(time);
//                             }
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.grey[100],
//                           foregroundColor: Colors.black,
//                           side: const BorderSide(color: Colors.grey),
//                         ),
//                         child: const Text('Select'),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: screenHeight * 0.02),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text('End Date & Time',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, color: Colors.grey)),
//                       Text(
//                           _selectedEndDate == null
//                               ? 'Not Selected'
//                               : '${_selectedEndDate!.day} ${_getMonthName(_selectedEndDate!.month)} ${_selectedEndDate!.year}   ${_selectedEndTime?.format(context) ?? 'Not selected'}',
//                           style: const TextStyle(fontSize: 16)),
//                     ],
//                   ),
//                   SizedBox(height: screenHeight * 0.01),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       ElevatedButton(
//                         onPressed: () async {
//                           DateTime today = DateTime.now();
//                           DateTime initialStartDate = _selectedStartDate ?? today;
//                           DateTime initialDate = _selectedEndDate != null &&
//                                   _selectedEndDate!.isAfter(initialStartDate)
//                               ? _selectedEndDate!
//                               : initialStartDate;

//                           final date = await showDatePicker(
//                             context: context,
//                             initialDate: initialDate,
//                             firstDate: initialStartDate,
//                             lastDate: DateTime(2101),
//                           );

//                           if (date != null) {
//                             TimeOfDay initialTime = _selectedStartTime ?? TimeOfDay.now();
//                             final time = await showTimePicker(
//                               context: context,
//                               initialTime: _selectedEndTime ?? initialTime,
//                             );
//                             if (time != null) {
//                               setState(() {
//                                 _selectedEndDate = date;
//                                 _selectedEndTime = time;
//                               });
//                               widget.onEndDateChanged(date);
//                               widget.onEndTimeChanged(time);
//                             }
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.grey[100],
//                           foregroundColor: Colors.black,
//                           side: const BorderSide(color: Colors.grey),
//                         ),
//                         child: const Text('Select'),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: screenHeight * 0.04),
//           SizedBox(
//             width: double.infinity,
//             child: FormButton(
//               onPressed: () {
//                 if (_selectedStartDate == null ||
//                     _selectedStartTime == null ||
//                     _selectedEndDate == null ||
//                     _selectedEndTime == null) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text(
//                           'Please select Start Date, Start time, End Date and End time'),
//                     ),
//                   );
//                   return;
//                 }
//                 widget.onNext();
//               },
//               label: 'Set Date & Time',
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   String _getMonthName(int month) {
//     switch (month) {
//       case 1:
//         return "Jan";
//       case 2:
//         return "Feb";
//       case 3:
//         return "Mar";
//       case 4:
//         return "Apr";
//       case 5:
//         return "May";
//       case 6:
//         return "Jun";
//       case 7:
//         return "Jul";
//       case 8:
//         return "Aug";
//       case 9:
//         return "Sep";
//       case 10:
//         return "Oct";
//       case 11:
//         return "Nov";
//       case 12:
//         return "Dec";
//       default:
//         return "";
//     }
//   }
// }


































// after change calendar



// updated_date_time_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../daterangepicker.dart'; // Import the DateRangePicker
import '../addcarform/form_button.dart';

class UpdateDateTimeScreen extends StatefulWidget {
  final Function onNext;
  final Function(DateTime?) onStartDateChanged;
  final Function(TimeOfDay?) onStartTimeChanged;
  final Function(DateTime?) onEndDateChanged;
  final Function(TimeOfDay?) onEndTimeChanged;
  final DateTime? startDate;
  final TimeOfDay? startTime;
  final DateTime? endDate;
  final TimeOfDay? endTime;

  const UpdateDateTimeScreen({
    Key? key,
    required this.onNext,
    required this.onStartDateChanged,
    required this.onStartTimeChanged,
    required this.onEndDateChanged,
    required this.onEndTimeChanged,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
  }) : super(key: key);

  @override
  UpdateDateTimeScreenState createState() => UpdateDateTimeScreenState();
}

class UpdateDateTimeScreenState extends State<UpdateDateTimeScreen> {
  DateTime? _selectedStartDate;
  TimeOfDay? _selectedStartTime;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedEndTime;

  @override
  void initState() {
    super.initState();
    _selectedStartDate = widget.startDate;
    _selectedStartTime = widget.startTime;
    _selectedEndDate = widget.endDate;
    _selectedEndTime = widget.endTime;
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: const DateRangePicker(),
        );
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedStartDate = result['startDate'] as DateTime?;
        _selectedEndDate = result['endDate'] as DateTime?;
        _selectedStartTime = result['pickupTime'] as TimeOfDay?;
        _selectedEndTime = result['dropoffTime'] as TimeOfDay?;

        widget.onStartDateChanged(_selectedStartDate);
        widget.onStartTimeChanged(_selectedStartTime);
        widget.onEndDateChanged(_selectedEndDate);
        widget.onEndTimeChanged(_selectedEndTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(
                width: 8,
              ),
              const Text(
                'Car Sharing Dates & Time',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector( // Added GestureDetector
            onTap: () => _showDateRangePicker(context), //Show DateRangePicker on Tap
            child: Container(
              width: double.infinity, // Take full width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Start Date & Time Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Start Date & Time',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        Text(
                          _selectedStartDate != null && _selectedStartTime != null
                              ? DateFormat('d MMM yyyy h:mm a').format(DateTime(_selectedStartDate!.year, _selectedStartDate!.month, _selectedStartDate!.day, _selectedStartTime!.hour, _selectedStartTime!.minute))
                              : 'Not Selected',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    // End Date & Time Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'End Date & Time',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        Text(
                          _selectedEndDate != null && _selectedEndTime != null
                              ? DateFormat('d MMM yyyy h:mm a').format(DateTime(_selectedEndDate!.year, _selectedEndDate!.month, _selectedEndDate!.day, _selectedEndTime!.hour, _selectedEndTime!.minute))
                              : 'Not Selected',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.04),
          SizedBox(
            width: double.infinity,
            child: FormButton(
              onPressed: () {
                if (_selectedStartDate == null ||
                    _selectedStartTime == null ||
                    _selectedEndDate == null ||
                    _selectedEndTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please select Start Date, Start time, End Date and End time',
                      ),
                    ),
                  );
                  return;
                }
                widget.onNext();
              },
              label: 'Set Date & Time',
            ),
          )
        ],
      ),
    );
  }
}