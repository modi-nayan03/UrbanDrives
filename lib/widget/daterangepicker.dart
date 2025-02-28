// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';


// class DateRangePicker extends StatefulWidget {
//   const DateRangePicker({Key? key}) : super(key: key);


//   @override
//   State<DateRangePicker> createState() => _DateRangePickerState();
// }


// class _DateRangePickerState extends State<DateRangePicker> {
//   DateTime? _startDate;
//   DateTime? _endDate;
//   DateTime _focusedDay = DateTime.now();
//   int _selectedPickupHour = 14; // Default 2 PM
//   int _selectedDropoffHour = 8; // Default 8 AM


//   final List<int> _pickupHours = [
//     1,
//     2,
//     3,
//     4,
//     5,
//     6,
//     7,
//     8,
//     9,
//     10,
//     11,
//     12,
//     13,
//     14,
//     15,
//     16,
//     17,
//     18,
//     19,
//     20,
//     21,
//     22,
//     23,
//     24
//   ]; // 24-hour format
//   final List<int> _dropoffHours = [
//     1,
//     2,
//     3,
//     4,
//     5,
//     6,
//     7,
//     8,
//     9,
//     10,
//     11,
//     12,
//     13,
//     14,
//     15,
//     16,
//     17,
//     18,
//     19,
//     20,
//     21,
//     22,
//     23,
//     24
//   ]; // 24-hour format


//   void _sendDataBack() {
//     // Convert selected hours back to TimeOfDay
//     TimeOfDay pickupTime = TimeOfDay(hour: _selectedPickupHour, minute: 0);
//     TimeOfDay dropoffTime = TimeOfDay(hour: _selectedDropoffHour, minute: 0);


//     Navigator.of(context).pop({
//       'startDate': _startDate,
//       'endDate': _endDate,
//       'pickupTime': pickupTime,
//       'dropoffTime': dropoffTime,
//     });
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width * 0.9,
//       constraints: const BoxConstraints(
//         maxHeight: 600.0, // set an maximum height for the DateRangePicker
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.3),
//             spreadRadius: 2,
//             blurRadius: 7,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Material(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.arrow_back, color: Colors.black),
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                   Text('Select Dates',
//                       style: Theme.of(context).textTheme.titleLarge),
//                   // Adjust style
//                   TextButton(
//                     onPressed: () {
//                       setState(() {
//                         _startDate = null;
//                         _endDate = null;
//                         _focusedDay = DateTime.now();
//                       });
//                     },
//                     child: const Text('CLEAR',
//                         style:
//                             TextStyle(color: Color.fromARGB(255, 0, 175, 219))),
//                   ),
//                 ],
//               ),
//             ),
//             Text(_startDate != null && _endDate != null
//                 ? '${DateFormat('EEE, dd MMM').format(_startDate!)} - ${DateFormat('EEE, dd MMM').format(_endDate!)}'
//                 : 'Wed, 19 Feb - Wed, 19 Feb'),
//             _buildCalendarHeader(),
//             Expanded(
//               // Wrap month selector in an Expanded widget
//               child: SingleChildScrollView(
//                 // Use SingleChildScrollView for vertical scrolling
//                 child: Column(
//                   children: [
//                     for (int month =
//                             DateTime.now().month; // Start from current Month
//                         month <= 12;
//                         month++) //Loop to show all the month in the calendar
//                       _buildMonthView(month),
//                   ],
//                 ),
//               ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildTimeSpinnerColumn(
//                     'Pickup Time', _pickupHours, _selectedPickupHour, (hour) {
//                   setState(() {
//                     _selectedPickupHour = hour;
//                   });
//                 }),
//                 _buildTimeSpinnerColumn(
//                     'Dropoff Time', _dropoffHours, _selectedDropoffHour,
//                     (hour) {
//                   setState(() {
//                     _selectedDropoffHour = hour;
//                   });
//                 }),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ElevatedButton(
//                 onPressed: () {
//                   if (_startDate != null && _endDate != null) {
//                     _sendDataBack();
//                   } else {
//                     print("Please select a start and end date.");
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color.fromARGB(255, 0, 162, 236),
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//                 child: const Text('CONTINUE',
//                     style: TextStyle(color: Colors.white)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }


//   Widget _buildCalendarHeader() {
//     return Column(
//       children: [
//         const Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Expanded(
//                 child: Text('M',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Color.fromARGB(255, 212, 0, 0)),
//                     textAlign: TextAlign.center)),
//             Expanded(
//                 child: Text('T',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Color.fromARGB(255, 212, 0, 0)),
//                     textAlign: TextAlign.center)),
//             Expanded(
//                 child: Text('W',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Color.fromARGB(255, 212, 0, 0)),
//                     textAlign: TextAlign.center)),
//             Expanded(
//                 child: Text('T',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Color.fromARGB(255, 212, 0, 0)),
//                     textAlign: TextAlign.center)),
//             Expanded(
//                 child: Text('F',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Color.fromARGB(255, 212, 0, 0)),
//                     textAlign: TextAlign.center)),
//             Expanded(
//                 child: Text('S',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Color.fromARGB(255, 212, 0, 0)),
//                     textAlign: TextAlign.center)),
//             Expanded(
//                 child: Text('S',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Color.fromARGB(255, 212, 0, 0)),
//                     textAlign: TextAlign.center)),
//           ],
//         ),
//       ],
//     );
//   }


//   Widget _buildMonthView(int month) {
//     DateTime firstDayOfMonth = DateTime(_focusedDay.year, month, 1);
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//           child: Text(
//             DateFormat('MMMM').format(firstDayOfMonth), // Display month name
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//         ),
//         LayoutBuilder(
//           builder: (context, constraints) {
//             final double itemWidth = constraints.maxWidth / 7;
//             final double itemHeight = itemWidth * 0.8; // Reduce cell height


//             return GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 7,
//                 childAspectRatio: 1,
//               ),
//               itemCount: _getDaysInMonth(_focusedDay.year, month) +
//                   firstDayOfMonth.weekday -
//                   1, // Add offset
//               itemBuilder: (context, index) {
//                 int day = index + 1 - firstDayOfMonth.weekday % 7;
//                 if (day <= 0) {
//                   return const SizedBox(); // Hide days from the previous month
//                 }


//                 DateTime currentDate = DateTime(_focusedDay.year, month, day);
//                 bool isCurrentDate = currentDate.year == DateTime.now().year &&
//                     currentDate.month == DateTime.now().month &&
//                     currentDate.day == DateTime.now().day;


//                 return _buildCalendarDay(currentDate, isCurrentDate);
//               },
//             );
//           },
//         ),
//       ],
//     );
//   }


//   Widget _buildCalendarDay(DateTime date, bool isCurrentDate) {
//     // Add isCurrentDate parameter
//     bool isSelected = false;
//     final now = DateTime.now();
//     bool isBeforeToday = date.isBefore(DateTime(now.year, now.month, now.day));


//     if (_startDate != null && _endDate != null) {
//       isSelected =
//           (date.isAfter(_startDate!) || date.isAtSameMomentAs(_startDate!)) &&
//               (date.isBefore(_endDate!) || date.isAtSameMomentAs(_endDate!));
//     }


//     bool isStartDate = _startDate != null && date.isAtSameMomentAs(_startDate!);
//     bool isEndDate = _endDate != null && date.isAtSameMomentAs(_endDate!);


//     Color? boxColor;
//     TextStyle textStyle = const TextStyle(color: Colors.black);


//     if (isBeforeToday) {
//       textStyle = const TextStyle(color: Colors.grey);
//     } else if (isCurrentDate) {
//       boxColor = const Color.fromRGBO(
//           255, 192, 203, 0.5); // Light pink with transparency
//       textStyle = const TextStyle(color: Color.fromARGB(255, 212, 0, 0));
//     }


//     if (isStartDate) {
//       boxColor = const Color.fromRGBO(
//           255, 192, 203, 0.5); // Light pink with transparency
//       textStyle =
//           const TextStyle(color: Color.fromARGB(255, 212, 0, 0)); //Pink Text
//     } else if (isEndDate) {
//       boxColor = const Color.fromRGBO(
//           255, 192, 203, 0.5); // Light pink with transparency
//       textStyle =
//           const TextStyle(color: Color.fromARGB(255, 212, 0, 0)); // Pink Text
//     } else if (isSelected) {
//       boxColor =
//           const Color.fromRGBO(225, 231, 255, 1); // Light Blue transparancy
//       textStyle = const TextStyle(color: Colors.black);
//     }


//     return GestureDetector(
//       onTap: isBeforeToday
//           ? null
//           : () {
//               // Disable tap if before today
//               _selectDate(date);
//             },
//       child: Container(
//         margin: const EdgeInsets.all(2.0),
//         decoration: BoxDecoration(
//           color: boxColor,
//           shape: BoxShape.rectangle,
//           borderRadius: BorderRadius.only(
//             topLeft: isStartDate ? const Radius.circular(20.0) : Radius.zero,
//             bottomLeft: isStartDate ? const Radius.circular(20.0) : Radius.zero,
//             topRight: isEndDate ? const Radius.circular(20.0) : Radius.zero,
//             bottomRight: isEndDate ? const Radius.circular(20.0) : Radius.zero,
//           ),
//         ),
//         child: Center(
//           child: Text(
//             date.day.toString(),
//             style: textStyle,
//           ),
//         ),
//       ),
//     );
//   }


//   Widget _buildTimeSpinnerColumn(String title, List<int> hours,
//       int selectedHour, ValueChanged<int> onChanged) {
//     return Column(
//       children: [
//         Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//         SizedBox(
//           height: 150, // Adjust the height as needed
//           width: 70,
//           child: ListWheelScrollView.useDelegate(
//             itemExtent: 30, // Adjust as needed
//             diameterRatio: 1.2,
//             physics: const FixedExtentScrollPhysics(),
//             childDelegate: ListWheelChildLoopingListDelegate(
//               children: hours
//                   .map((hour) => Center(
//                         child: Text(
//                           _formatHour(hour),
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: hour == selectedHour
//                                 ? Colors.black
//                                 : Colors.grey,
//                           ),
//                         ),
//                       ))
//                   .toList(),
//             ),
//             onSelectedItemChanged: (index) {
//               onChanged(hours[index]);
//             },
//           ),
//         ),
//       ],
//     );
//   }


//   String _formatHour(int hour) {
//     int displayHour = hour % 12;
//     if (displayHour == 0) displayHour = 12; // Midnight
//     return "${displayHour.toString().padLeft(2, '0')} ${hour < 12 || hour == 24 ? 'AM' : 'PM'}";
//   }


//   void _selectDate(DateTime date) {
//     // Get today's date without time components
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);


//     // Disable tap if before today, unless it is today
//     if (date.isBefore(today)) return;


//     setState(() {
//       if (_startDate == null) {
//         _startDate = date;
//         _endDate = null;
//       } else if (_endDate == null) {
//         // Prevent _endDate from being before _startDate
//         if (date.isBefore(_startDate!)) {
//           _startDate = date;
//         } else {
//           _endDate = date;
//         }
//       } else {
//         _startDate = date;
//         _endDate = null;
//       }
//     });
//   }


//   // Helper function to get number of days in a month
//   int _getDaysInMonth(int year, int month) {
//     return DateTime(year, month + 1, 0).day;
//   }
// }






































//by jatin 25/2/25


// daterangepicker.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangePicker extends StatefulWidget {
  const DateRangePicker({
    Key? key,
    this.startDate,
    this.endDate,
    this.minDate,
    this.maxDate,
    this.initialPickupTime,
    this.initialReturnTime,
  }) : super(key: key);

  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final TimeOfDay? initialPickupTime;
  final TimeOfDay? initialReturnTime;

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  List<DateTime?> _selectedDates = [];
  DateTime? _startDate;
  DateTime? _endDate;
  late int _selectedPickupHour; // Use late
  late int _selectedDropoffHour; // Use late

  final List<int> _pickupHours = List.generate(24, (index) => index);
  final List<int> _dropoffHours = List.generate(24, (index) => index);

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;

    // Initialize the times
    _selectedPickupHour = widget.initialPickupTime?.hour ?? 14; // Default 2 PM
    _selectedDropoffHour = widget.initialReturnTime?.hour ?? 8; // Default 8 AM

    if (widget.startDate != null) {
      _selectedDates.add(widget.startDate);
    }
    if (widget.endDate != null) {
      _selectedDates.add(widget.endDate);
    }
    _selectedDates = _selectedDates.whereType<DateTime>().toList();
  }

  void _sendDataBack() {
    // Convert selected hours back to TimeOfDay
    TimeOfDay pickupTime = TimeOfDay(hour: _selectedPickupHour, minute: 0);
    TimeOfDay dropoffTime = TimeOfDay(hour: _selectedDropoffHour, minute: 0);

    print("Sending back pickupTime: $pickupTime");
    print("Sending back dropoffTime: $dropoffTime");

    Navigator.of(context).pop({
      'startDate': _startDate,
      'endDate': _endDate,
      'pickupTime': pickupTime,
      'dropoffTime': dropoffTime,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Select Dates',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedDates.clear();
                _startDate = null;
                _endDate = null;
              });
            },
            child: const Text(
              'CLEAR',
              style: TextStyle(color: Colors.blue),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(_startDate != null && _endDate != null
                ? '${DateFormat('EEE, dd MMM').format(_startDate!)} - ${DateFormat('EEE, dd MMM').format(_endDate!)}'
                : 'Select a Date Range'),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: _buildCalendarMonths(),
            ),
          ),
          _buildTimePickers(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_startDate != null && _endDate != null) {
                  _sendDataBack();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please select a start and end date.')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 162, 236),
                minimumSize: const Size(double.infinity, 50),
              ),
              child:
                  const Text('CONTINUE', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarMonths() {
    List<Widget> monthWidgets = [];
    DateTime currentDate = widget.minDate ?? DateTime.now();
    DateTime lastDate = widget.maxDate ??
        DateTime(
            DateTime.now().year + 1, DateTime.now().month, DateTime.now().day);

    while (currentDate.isBefore(lastDate) ||
        (currentDate.year == lastDate.year &&
            currentDate.month == lastDate.month)) {
      monthWidgets.add(_buildMonthView(currentDate));
      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
    }

    return Column(
      children: monthWidgets,
    );
  }

  Widget _buildMonthView(DateTime monthDate) {
    DateTime firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    int weekdayOffset =
        firstDayOfMonth.weekday - 1; // 0 for Monday, 6 for Sunday
    if (weekdayOffset == -1) weekdayOffset = 6; // Adjust for Sunday
    int daysInMonth = DateUtils.getDaysInMonth(monthDate.year, monthDate.month);
    DateTime now = DateTime.now();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            DateFormat('MMMM yyyy').format(monthDate),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: daysInMonth + weekdayOffset,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            if (index < weekdayOffset) {
              // Empty boxes for days before the first of the month
              return const SizedBox.shrink();
            }

            final day = index - weekdayOffset + 1;
            final date = DateTime(monthDate.year, monthDate.month, day);
            final isStartDate =
                _startDate != null && DateUtils.isSameDay(_startDate!, date);
            final isEndDate =
                _endDate != null && DateUtils.isSameDay(_endDate!, date);
            final isToday = DateUtils.isSameDay(now, date);

            bool isWithinRange = false;
            if (_startDate != null && _endDate != null) {
              isWithinRange =
                  date.isAfter(_startDate!) && date.isBefore(_endDate!);
            }

            bool isDisabled = date.isBefore(
                    DateTime.now().subtract(const Duration(days: 1))) ||
                (widget.maxDate != null && date.isAfter(widget.maxDate!));

            Color? backgroundColor;
            Color textColor = Colors.black;

            if (isStartDate || isEndDate) {
              backgroundColor = Colors.pink;
              textColor = Colors.white;
            } else if (isToday) {
              backgroundColor = Colors.pink.shade100; // Lighter pink for today
              textColor = Colors.black;
            } else if (isWithinRange) {
              backgroundColor = Colors.blue.shade50; // Light blue for range
            }

            return GestureDetector(
              onTap: isDisabled
                  ? null
                  : () {
                      setState(() {
                        if (_selectedDates.contains(date)) {
                          _selectedDates.remove(date);
                          _startDate = null;
                          _endDate = null;
                        } else {
                          if (_selectedDates.isEmpty) {
                            _selectedDates.add(date);
                            _startDate = date;
                            _endDate = null;
                          } else if (_selectedDates.length == 1) {
                            if (date.isBefore(_selectedDates.first!)) {
                              _selectedDates.insert(0, date);
                              _startDate = date;
                              _endDate = _selectedDates.last;
                            } else {
                              _selectedDates.add(date);
                              _endDate = date;
                            }
                          } else {
                            _selectedDates.clear();
                            _selectedDates.add(date);
                            _startDate = date;
                            _endDate = null;
                          }
                        }
                      });
                    },
              child: Container(
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      color: isDisabled ? Colors.grey : textColor,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimePickers() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTimeSpinnerColumn(
            'Pickup Time',
            _pickupHours,
            _selectedPickupHour,
            (hour) {
              setState(() {
                _selectedPickupHour = hour;
              });
            },
          ),
          _buildTimeSpinnerColumn(
            'Dropoff Time',
            _dropoffHours,
            _selectedDropoffHour,
            (hour) {
              setState(() {
                _selectedDropoffHour = hour;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSpinnerColumn(String title, List<int> hours,
      int selectedHour, ValueChanged<int> onChanged) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: 150, // Adjust the height as needed
          width: 70,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 30, // Adjust as needed
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildLoopingListDelegate(
              children: hours
                  .map((hour) => Center(
                        child: Text(
                          _formatHour(hour),
                          style: TextStyle(
                            fontSize: 18,
                            color: hour == selectedHour
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            onSelectedItemChanged: (index) {
              onChanged(hours[index]);
            },
          ),
        ),
      ],
    );
  }

  String _formatHour(int hour) {
    int displayHour = hour % 12;
    if (displayHour == 0) displayHour = 12; // Midnight
    return "${displayHour.toString().padLeft(2, '0')} ${hour < 12 || hour == 24 ? 'AM' : 'PM'}";
  }
}