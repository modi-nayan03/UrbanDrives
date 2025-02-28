
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:http/http.dart' as http;
// import 'package:latlong2/latlong.dart';

// class CityMapScreen extends StatefulWidget {
//   @override
//   _CityMapScreenState createState() => _CityMapScreenState();
// }

// class _CityMapScreenState extends State<CityMapScreen> {
//   final TextEditingController _cityController = TextEditingController();
//   final MapController _mapController = MapController();
//   LatLng _cityLocation = LatLng(20.5937, 78.9629); // Default to India

//   Future<void> _searchCity() async {
//     String cityName = _cityController.text.trim();
//     if (cityName.isEmpty) return;

//     LatLng? cityLocation = await getCityCoordinates(cityName);
//     if (cityLocation != null) {
//       setState(() {
//         _cityLocation = cityLocation;
//       });
//       _mapController.move(_cityLocation, 10.0);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error finding city: Not found')),
//       );
//     }
//   }

//   Future<LatLng?> getCityCoordinates(String cityName) async {
//     try {
//       final url = Uri.parse(
//           "https://nominatim.openstreetmap.org/search?format=json&q=$cityName,India");
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data.isNotEmpty) {
//           final lat = double.parse(data[0]['lat']);
//           final lon = double.parse(data[0]['lon']);
//           return LatLng(lat, lon);
//         }
//       }
//       return null;
//     } catch (e) {
//       print("Error finding city: $e");
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("City Map")),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: TextField(
//               controller: _cityController,
//               decoration: InputDecoration(
//                 hintText: "Enter city in India",
//                 suffixIcon: IconButton(
//                   icon: Icon(Icons.search),
//                   onPressed: _searchCity,
//                 ),
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),
//           Expanded(
//             child: FlutterMap(
//               mapController: _mapController,
//               options: MapOptions(
//                 initialCenter: _cityLocation,
//                 initialZoom: 5.0,
//               ),
//               children: [
//                 TileLayer(
//                   urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                   subdomains: ['a', 'b', 'c'],
//                 ),
//                 MarkerLayer(
//                   markers: [
//                     Marker(
//                       point: _cityLocation,
//                       width: 40.0,
//                       height: 40.0,
//                       child: Icon(
//                         Icons.location_pin,
//                         color: Colors.red,
//                         size: 40,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




































// // after API




// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:http/http.dart' as http;
// import 'package:latlong2/latlong.dart';

// class CityMapScreen extends StatefulWidget {
//   @override
//   _CityMapScreenState createState() => _CityMapScreenState();
// }

// class _CityMapScreenState extends State<CityMapScreen> {
//   final MapController _mapController = MapController();
//   List<Map<String, dynamic>> _cities = [];
//   Map<String, dynamic>? _selectedCityData;
//   LatLng? _selectedCityLocation;

//   @override
//   void initState() {
//     super.initState();
//     _fetchOperationalCities();
//   }

//   Future<void> _fetchOperationalCities() async {
//     try {
//       final response = await http.get(Uri.parse("http://your-backend-url/cities"));
//       if (response.statusCode == 200) {
//         setState(() {
//           _cities = List<Map<String, dynamic>>.from(json.decode(response.body));
//         });
//       }
//     } catch (e) {
//       print("Error fetching cities: $e");
//     }
//   }

//   Future<void> _fetchCityData(String cityName, LatLng cityLocation) async {
//     try {
//       final response = await http.get(Uri.parse("http://your-backend-url/city-data?city=$cityName"));
//       if (response.statusCode == 200) {
//         setState(() {
//           _selectedCityData = json.decode(response.body);
//           _selectedCityLocation = cityLocation;
//         });
//       }
//     } catch (e) {
//       print("Error fetching city data: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("City Map")),
//       body: Stack(
//         children: [
//           FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(
//               initialCenter: LatLng(23.0, 72.0),
//               initialZoom: 6.0,
//               onTap: (_, __) => setState(() => _selectedCityData = null),
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                 subdomains: ['a', 'b', 'c'],
//               ),
//               MarkerLayer(
//                 markers: _cities.map((city) {
//                   return Marker(
//                     point: LatLng(city['lat'], city['lon']),
//                     width: 40.0,
//                     height: 40.0,
//                     child: GestureDetector(
//                       onTap: () => _fetchCityData(city['name'], LatLng(city['lat'], city['lon'])),
//                       child: Icon(Icons.location_pin, color: Colors.red, size: 40),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ],
//           ),
//           if (_selectedCityData != null && _selectedCityLocation != null)
//             Positioned(
//               top: 50,
//               left: 20,
//               right: 20,
//               child: Card(
//                 color: Colors.white,
//                 elevation: 5,
//                 child: Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Column(
//                     children: [
//                       Text("City: ${_selectedCityData!['city']}", style: TextStyle(fontWeight: FontWeight.bold)),
//                       Text("Total Users: ${_selectedCityData!['users']}"),
//                       Text("Total Cars: ${_selectedCityData!['cars']}"),
//                       Text("Total Bookings: ${_selectedCityData!['bookings']}"),
//                       Text("Total Trips: ${_selectedCityData!['trips']}"),
//                       Text("Total Income: ₹${_selectedCityData!['totalIncome']}"),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }





































// small tooltip and data 



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:http/http.dart' as http;
// import 'package:latlong2/latlong.dart';

// class CityMapScreen extends StatefulWidget {
//   @override
//   _CityMapScreenState createState() => _CityMapScreenState();
// }

// class _CityMapScreenState extends State<CityMapScreen> {
//   final TextEditingController _cityController = TextEditingController();
//   final MapController _mapController = MapController();
//   LatLng _cityLocation = LatLng(20.5937, 78.9629); // Default to India
//   Map<String, LatLng> _cityCoordinates = {}; // Store city coordinates
//   List<String> _activeCities = []; // Store active cities from backend
//   Map<String, dynamic> _cityDetails = {}; // Store city details
//   String? _selectedCity; // Currently selected city
//   bool _isLoading = false;
//   Offset? _tapPosition;
//   OverlayEntry? _overlayEntry;

//   @override
//   void initState() {
//     super.initState();
//     _loadActiveCities();
//   }

//   Future<void> _loadActiveCities() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       final response = await http.get(
//           Uri.parse('http://localhost:5000/active-cities')); // Replace with your Flask backend URL
//       if (response.statusCode == 200) {
//         List<dynamic> cities = json.decode(response.body);
//         setState(() {
//           _activeCities = cities.map((e) => e.toString()).toList();
//           // Fetch coordinates for active cities
//           _fetchCityCoordinates();
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load active cities')),
//         );
//       }
//     } catch (e) {
//       print("Error loading active cities: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading active cities: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchCityCoordinates() async {
//     for (var city in _activeCities) {
//       LatLng? coords = await getCityCoordinates(city);
//       if (coords != null) {
//         setState(() {
//           _cityCoordinates[city] = coords;
//         });
//       }
//     }
//   }

//   Future<void> _searchCity() async {
//     String cityName = _cityController.text.trim();
//     if (cityName.isEmpty) return;

//     LatLng? cityLocation = await getCityCoordinates(cityName);
//     if (cityLocation != null) {
//       setState(() {
//         _cityLocation = cityLocation;
//       });
//       _mapController.move(_cityLocation, 10.0);
//       _fetchCityDetails(cityName, Offset.zero); // Provide a default Offset value
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('City not found')),
//       );
//       setState(() {
//         _cityDetails = {}; // Clear details if city not found
//         _selectedCity = null;
//       });
//     }
//   }

//   Future<void> _fetchCityDetails(String city, Offset position) async {
//     // <-- Add position here
//     try {
//       final response = await http.post(
//         Uri.parse('http://localhost:5000/city-details'),
//         // Replace with your Flask backend URL
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'city': city}),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _cityDetails = json.decode(response.body);
//           _selectedCity = city;
//           _tapPosition = position;
//         });
//         _showTooltip();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load city details')),
//         );
//         setState(() {
//           _cityDetails = {};
//           _selectedCity = null;
//           _hideTooltip();
//         });
//       }
//     } catch (e) {
//       print("Error fetching city details: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching city details: $e')),
//       );
//       setState(() {
//         _cityDetails = {};
//         _selectedCity = null;
//         _hideTooltip();
//       });
//     }
//   }

//   Future<LatLng?> getCityCoordinates(String cityName) async {
//     try {
//       final url = Uri.parse(
//           "https://nominatim.openstreetmap.org/search?format=json&q=$cityName,India");
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data.isNotEmpty) {
//           final lat = double.parse(data[0]['lat']);
//           final lon = double.parse(data[0]['lon']);
//           return LatLng(lat, lon);
//         }
//       }
//       return null;
//     } catch (e) {
//       print("Error finding city: $e");
//       return null;
//     }
//   }

//   void _showTooltip() {
//     _overlayEntry = _createOverlayEntry();
//     Overlay.of(context).insert(_overlayEntry!);
//   }

//   void _hideTooltip() {
//     if (_overlayEntry != null) {
//       _overlayEntry!.remove();
//       _overlayEntry = null;
//     }
//   }

//   OverlayEntry _createOverlayEntry() {
//     RenderBox renderBox = context.findRenderObject() as RenderBox;
//     var size = renderBox.size;
//     var offset = _tapPosition!;

//     return OverlayEntry(
//       builder: (context) => Positioned(
//         left: offset.dx + 10, // Adjust as needed
//         top: offset.dy - 50, // Adjust as needed
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.5),
//                   spreadRadius: 2,
//                   blurRadius: 5,
//                   offset: Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   _selectedCity ?? '',
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 4),
//                 Text('Total Users: ${_cityDetails['Total Users'] ?? 'N/A'}'),
//                 Text('Total Cars: ${_cityDetails['Total Cars'] ?? 'N/A'}'),
//                 Text('Total Bookings: ${_cityDetails['Total Bookings'] ?? 'N/A'}'),
//                 Text('Total Trips: ${_cityDetails['Total Trips'] ?? 'N/A'}'),
//                 Text('Total Income: ${_cityDetails['Total Income'] ?? 'N/A'}'),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("City Map")),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: TextField(
//                   controller: _cityController,
//                   decoration: InputDecoration(
//                     hintText: "Enter city in India",
//                     suffixIcon: IconButton(
//                       icon: Icon(Icons.search),
//                       onPressed: _searchCity,
//                     ),
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: FlutterMap(
//                   mapController: _mapController,
//                   options: MapOptions(
//                     initialCenter: _cityLocation,
//                     initialZoom: 5.0,
//                     interactionOptions: const InteractionOptions(
//                       flags: InteractiveFlag.all,
//                     ),
//                   ),
//                   children: [
//                     TileLayer(
//                       urlTemplate:
//                           "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                       subdomains: ['a', 'b', 'c'],
//                     ),
//                     MarkerLayer(
//                       markers: _cityCoordinates.entries.map((entry) {
//                         String city = entry.key;
//                         LatLng location = entry.value;
//                         bool isActive = _activeCities.contains(city);

//                         return Marker(
//                           point: location,
//                           width: 40.0,
//                           height: 40.0,
//                           child: GestureDetector(
//                             onTapDown: (details) {
//                               // Get tap position
//                               _tapPosition = details.globalPosition;
//                               _fetchCityDetails(city, _tapPosition!);
//                             },
//                             child: Icon(
//                               Icons.location_pin,
//                               color: isActive
//                                   ? Colors.blue
//                                   : Colors.grey, // Highlight active cities
//                               size: 40,
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (_isLoading)
//             Container(
//               color: Colors.black54,
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _hideTooltip();
//     super.dispose();
//   }
// }











// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:http/http.dart' as http;
// import 'package:latlong2/latlong.dart';

// class CityMapScreen extends StatefulWidget {
//   @override
//   _CityMapScreenState createState() => _CityMapScreenState();
// }

// class _CityMapScreenState extends State<CityMapScreen> {
//   final TextEditingController _cityController = TextEditingController();
//   final MapController _mapController = MapController();
//   LatLng _cityLocation = LatLng(20.5937, 78.9629); // Default to India
//   Map<String, LatLng> _cityCoordinates = {}; // Store city coordinates
//   List<String> _activeCities = []; // Store active cities from backend
//   Map<String, dynamic> _cityDetails = {}; // Store city details
//   String? _selectedCity; // Currently selected city
//   bool _isLoading = false;
//   Offset? _tapPosition;
//   OverlayEntry? _overlayEntry;

//   @override
//   void initState() {
//     super.initState();
//     _loadActiveCities();
//   }

//   Future<void> _loadActiveCities() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       final response = await http.get(
//           Uri.parse('http://localhost:5000/active-cities')); // Replace with your Flask backend URL
//       if (response.statusCode == 200) {
//         List<dynamic> cities = json.decode(response.body);
//         setState(() {
//           _activeCities = cities.map((e) => e.toString()).toList();
//           // Fetch coordinates for active cities
//           _fetchCityCoordinates();
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load active cities')),
//         );
//       }
//     } catch (e) {
//       print("Error loading active cities: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading active cities: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchCityCoordinates() async {
//     for (var city in _activeCities) {
//       LatLng? coords = await getCityCoordinates(city);
//       if (coords != null) {
//         setState(() {
//           _cityCoordinates[city] = coords;
//         });
//       }
//     }
//   }

//   Future<void> _searchCity() async {
//     String cityName = _cityController.text.trim();
//     if (cityName.isEmpty) return;

//     LatLng? cityLocation = await getCityCoordinates(cityName);
//     if (cityLocation != null) {
//       setState(() {
//         _cityLocation = cityLocation;
//       });
//       _mapController.move(_cityLocation, 10.0);
//       _fetchCityDetails(cityName, null); // Pass null because tap position is not applicable here
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('City not found')),
//       );
//       setState(() {
//         _cityDetails = {}; // Clear details if city not found
//         _selectedCity = null;
//       });
//     }
//   }

//   Future<void> _fetchCityDetails(String city, Offset? position) async {
//     // Check if position is null before using it
//     try {
//       final response = await http.post(
//         Uri.parse('http://localhost:5000/city-details'),
//         // Replace with your Flask backend URL
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'city': city}),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _cityDetails = json.decode(response.body);
//           _selectedCity = city;
//           _tapPosition = position; // Only update if not null
//         });
//         if (position != null) {
//           _showTooltip();
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load city details')),
//         );
//         setState(() {
//           _cityDetails = {};
//           _selectedCity = null;
//           _hideTooltip();
//         });
//       }
//     } catch (e) {
//       print("Error fetching city details: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching city details: $e')),
//       );
//       setState(() {
//         _cityDetails = {};
//         _selectedCity = null;
//         _hideTooltip();
//       });
//     }
//   }

//   Future<LatLng?> getCityCoordinates(String cityName) async {
//     try {
//       final url = Uri.parse(
//           "https://nominatim.openstreetmap.org/search?format=json&q=$cityName,India");
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data.isNotEmpty) {
//           final lat = double.parse(data[0]['lat']);
//           final lon = double.parse(data[0]['lon']);
//           return LatLng(lat, lon);
//         }
//       }
//       return null;
//     } catch (e) {
//       print("Error finding city: $e");
//       return null;
//     }
//   }

//   void _showTooltip() {
//     _hideTooltip(); // Hide any existing tooltip first
//     _overlayEntry = _createOverlayEntry();
//     Overlay.of(context).insert(_overlayEntry!);
//   }

//   void _hideTooltip() {
//     if (_overlayEntry != null) {
//       _overlayEntry!.remove();
//       _overlayEntry = null;
//     }
//   }

//   OverlayEntry _createOverlayEntry() {
//     RenderBox? renderBox = context.findRenderObject() as RenderBox?; // Make it nullable
//     var size = renderBox?.size;
//     var offset = _tapPosition!;

//     return OverlayEntry(
//       builder: (context) => Positioned(
//         left: offset.dx + 10, // Adjust as needed
//         top: offset.dy - 50, // Adjust as needed
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.5),
//                   spreadRadius: 2,
//                   blurRadius: 5,
//                   offset: Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   _selectedCity ?? '',
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 4),
//                 Text('Total Users: ${_cityDetails['Total Users'] ?? 'N/A'}'),
//                 Text('Total Cars: ${_cityDetails['Total Cars'] ?? 'N/A'}'),
//                 Text('Total Bookings: ${_cityDetails['Total Bookings'] ?? 'N/A'}'),
//                 Text('Total Trips: ${_cityDetails['Total Trips'] ?? 'N/A'}'),
//                 Text('Total Income: ${_cityDetails['Total Income'] ?? 'N/A'}'),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("City Map")),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: TextField(
//                   controller: _cityController,
//                   decoration: InputDecoration(
//                     hintText: "Enter city in India",
//                     suffixIcon: IconButton(
//                       icon: Icon(Icons.search),
//                       onPressed: _searchCity,
//                     ),
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: FlutterMap(
//                   mapController: _mapController,
//                   options: MapOptions(
//                     initialCenter: _cityLocation,
//                     initialZoom: 5.0,
//                     interactionOptions: const InteractionOptions(
//                       flags: InteractiveFlag.all,
//                     ),
//                     onMapEvent: (mapEvent) {
//                       // Hide the tooltip when the map is zoomed
//                       if (mapEvent is MapEventMove || mapEvent is MapEventFlingAnimation) {
//                         _hideTooltip();
//                       }
//                     },
//                     onMapReady: () {
//                       print("Map is ready!");
//                     },
//                   ),
//                   children: [
//                     TileLayer(
//                       urlTemplate:
//                           "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                       subdomains: ['a', 'b', 'c'],
//                     ),
//                     MarkerLayer(
//                       markers: _cityCoordinates.entries.map((entry) {
//                         String city = entry.key;
//                         LatLng location = entry.value;
//                         bool isActive = _activeCities.contains(city);

//                         return Marker(
//                           point: location,
//                           width: 40.0,
//                           height: 40.0,
//                           child: GestureDetector(
//                             onTapDown: (details) {
//                               _tapPosition = details.globalPosition;
//                               _fetchCityDetails(city, _tapPosition!);
//                             },
//                             child: Icon(
//                               Icons.location_pin,
//                               color: isActive
//                                   ? Colors.blue
//                                   : Colors.grey, // Highlight active cities
//                               size: 40,
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (_isLoading)
//             Container(
//               color: Colors.black54,
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _hideTooltip();
//     super.dispose();
//   }
// }






















// manav

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:http/http.dart' as http;
// import 'package:latlong2/latlong.dart';

// class CityMapScreen extends StatefulWidget {
//   @override
//   _CityMapScreenState createState() => _CityMapScreenState();
// }

// class _CityMapScreenState extends State<CityMapScreen> {
//   final TextEditingController _cityController = TextEditingController();
//   final MapController _mapController = MapController();
//   LatLng _cityLocation = LatLng(20.5937, 78.9629); // Default to India
//   Map<String, LatLng> _cityCoordinates = {}; // Store city coordinates
//   List<String> _activeCities = []; // Store active cities from backend
//   Map<String, dynamic> _cityDetails = {}; // Store city details
//   String? _selectedCity; // Currently selected city
//   bool _isLoading = false;
//   Offset? _tapPosition;
//   OverlayEntry? _overlayEntry;

//   @override
//   void initState() {
//     super.initState();
//     _loadActiveCities();
//   }

//   Future<void> _loadActiveCities() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       final response = await http.get(
//           Uri.parse('http://localhost:5000/active-cities')); // Replace with your Flask backend URL
//       if (response.statusCode == 200) {
//         List<dynamic> cities = json.decode(response.body);
//         setState(() {
//           _activeCities = cities.map((e) => e.toString()).toList();
//           // Fetch coordinates for active cities
//           _fetchCityCoordinates();
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load active cities')),
//         );
//       }
//     } catch (e) {
//       print("Error loading active cities: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading active cities: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchCityCoordinates() async {
//     for (var city in _activeCities) {
//       LatLng? coords = await getCityCoordinates(city);
//       if (coords != null) {
//         setState(() {
//           _cityCoordinates[city] = coords;
//         });
//       }
//     }
//   }

//   Future<void> _searchCity() async {
//     String cityName = _cityController.text.trim();
//     if (cityName.isEmpty) return;

//     LatLng? cityLocation = await getCityCoordinates(cityName);
//     if (cityLocation != null) {
//       setState(() {
//         _cityLocation = cityLocation;
//       });
//       _mapController.move(_cityLocation, 10.0);
//       _fetchCityDetails(cityName, null); // Pass null because tap position is not applicable here
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('City not found')),
//       );
//       setState(() {
//         _cityDetails = {}; // Clear details if city not found
//         _selectedCity = null;
//       });
//     }
//   }

//   Future<void> _fetchCityDetails(String city, Offset? position) async {
//     // Check if position is null before using it
//     try {
//       final response = await http.post(
//         Uri.parse('http://localhost:5000/city-details'),
//         // Replace with your Flask backend URL
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'city': city}),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _cityDetails = json.decode(response.body);
//           _selectedCity = city;
//           _tapPosition = position; // Only update if not null
//         });
//         if (position != null) {
//           _showTooltip();
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load city details')),
//         );
//         setState(() {
//           _cityDetails = {};
//           _selectedCity = null;
//           _hideTooltip();
//         });
//       }
//     } catch (e) {
//       print("Error fetching city details: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching city details: $e')),
//       );
//       setState(() {
//         _cityDetails = {};
//         _selectedCity = null;
//         _hideTooltip();
//       });
//     }
//   }

//   Future<LatLng?> getCityCoordinates(String cityName) async {
//     try {
//       final url = Uri.parse(
//           "https://nominatim.openstreetmap.org/search?format=json&q=$cityName,India");
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data.isNotEmpty) {
//           final lat = double.parse(data[0]['lat']);
//           final lon = double.parse(data[0]['lon']);
//           return LatLng(lat, lon);
//         }
//       }
//       return null;
//     } catch (e) {
//       print("Error finding city: $e");
//       return null;
//     }
//   }

//   void _showTooltip() {
//     _hideTooltip(); // Hide any existing tooltip first
//     _overlayEntry = _createOverlayEntry();
//     Overlay.of(context).insert(_overlayEntry!);
//   }

//   void _hideTooltip() {
//     if (_overlayEntry != null) {
//       _overlayEntry!.remove();
//       _overlayEntry = null;
//     }
//   }

//   OverlayEntry _createOverlayEntry() {
//     RenderBox? renderBox = context.findRenderObject() as RenderBox?; // Make it nullable
//     var size = renderBox?.size;
//     var offset = _tapPosition!;

//     return OverlayEntry(
//       builder: (context) => Positioned(
//         left: offset.dx + 10, // Adjust as needed
//         top: offset.dy - 50, // Adjust as needed
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.5),
//                   spreadRadius: 2,
//                   blurRadius: 5,
//                   offset: Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   _selectedCity ?? '',
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 4),
//                 Text('Total Cars: ${_cityDetails['Total Cars'] ?? 'N/A'}'),
//                 Text('Total Trips: ${_cityDetails['Total Trips'] ?? 'N/A'}'),
//                 Text('Total Income: ${_cityDetails['Total Income'] ?? 'N/A'}'),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("City Map")),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: TextField(
//                   controller: _cityController,
//                   decoration: InputDecoration(
//                     hintText: "Enter city in India",
//                     suffixIcon: IconButton(
//                       icon: Icon(Icons.search),
//                       onPressed: _searchCity,
//                     ),
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ),
//               // Expanded(
//               //   child: FlutterMap(
//               //     mapController: _mapController,
//               //     options: MapOptions(
//               //       initialCenter: _cityLocation,
//               //       initialZoom: 5.0,
//               //       interactionOptions: const InteractionOptions(
//               //         flags: InteractiveFlag.all,
//               //       ),
//               //       onMapEvent: (mapEvent) {
//               //         // Hide the tooltip when the map is zoomed
//               //         if (mapEvent is MapEventMove || mapEvent is MapEventFlingAnimation) {
//               //           _hideTooltip();
//               //         }
//               //       },
//               //       onMapReady: () {
//               //         print("Map is ready!");
//               //       },
//               //     ),
//               //     children: [
//               //       TileLayer(
//               //         urlTemplate:
//               //             "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//               //         subdomains: ['a', 'b', 'c'],
//               //       ),
//               //       MarkerLayer(
//               //         markers: _cityCoordinates.entries.map((entry) {
//               //           String city = entry.key;
//               //           LatLng location = entry.value;
//               //           bool isActive = _activeCities.contains(city);

//               //           return Marker(
//               //             point: location,
//               //             width: 40.0,
//               //             height: 40.0,
//               //             child: GestureDetector(
//               //               onTapDown: (details) {
//               //                 _tapPosition = details.globalPosition;
//               //                 _fetchCityDetails(city, _tapPosition!);
//               //               },
//               //               child: Icon(
//               //                 Icons.location_pin,
//               //                 color: isActive
//               //                     ? Colors.blue
//               //                     : Colors.grey, // Highlight active cities
//               //                 size: 40,
//               //               ),
//               //             ),
//               //           );
//               //         }).toList(),
//               //       ),
//               //     ],
//               //   ),
//               // ),


//                             Expanded(
//                 child: FlutterMap(
//                   mapController: _mapController,
//                   options: MapOptions(
//                     initialCenter: _cityLocation,
//                     initialZoom: 5.0,
//                     interactionOptions: const InteractionOptions(
//                       flags: InteractiveFlag.all,
//                     ),
//                     onMapEvent: (mapEvent) {
//                       // Hide the tooltip when the map is zoomed
//                       if (mapEvent is MapEventMove || mapEvent is MapEventFlingAnimation) {
//                         _hideTooltip();
//                       }
//                     },
//                     onMapReady: () {
//                       print("Map is ready!");
//                     },
//                   ),
//                   children: [
//                     TileLayer(
//                       urlTemplate:
//                           "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                       subdomains: ['a', 'b', 'c'],
//                     ),
//                     MarkerLayer(
//                       markers: _cityCoordinates.entries.map((entry) {
//                         String city = entry.key;
//                         LatLng location = entry.value;
//                         bool isActive = _activeCities.contains(city);

//                         return Marker(
//                           point: location,
//                           width: 40.0,
//                           height: 40.0,
//                           child: GestureDetector(
//                             onTapDown: (details) {
//                               _tapPosition = details.globalPosition;
//                               _fetchCityDetails(city, _tapPosition!);
//                             },
//                             child: Icon(
//                               Icons.location_pin,
//                               color: isActive
//                                   ? Colors.blue
//                                   : Colors.grey, // Highlight active cities
//                               size: 40,
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (_isLoading)
//             Container(
//               color: Colors.black54,
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _hideTooltip();
//     super.dispose();
//   }
// }
















































// //jatin
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:http/http.dart' as http;
// import 'package:latlong2/latlong.dart';

// class CityMapScreen extends StatefulWidget {
//   @override
//   _CityMapScreenState createState() => _CityMapScreenState();
// }

// class _CityMapScreenState extends State<CityMapScreen> {
//   final TextEditingController _cityController = TextEditingController();
//   final MapController _mapController = MapController();
//   LatLng _cityLocation = LatLng(20.5937, 78.9629); // Default to India
//   Map<String, LatLng> _cityCoordinates = {}; // Store city coordinates
//   List<String> _activeCities = []; // Store active cities from backend
//   Map<String, dynamic> _cityDetails = {}; // Store city details
//   String? _selectedCity; // Currently selected city
//   bool _isLoading = false;
//   String? _hoveredCityName;

//   @override
//   void initState() {
//     super.initState();
//     _loadActiveCities();
//   }

//   Future<void> _loadActiveCities() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       final response = await http.get(
//           Uri.parse('http://localhost:5000/active-cities')); // Replace with your Flask backend URL
//       if (response.statusCode == 200) {
//         List<dynamic> cities = json.decode(response.body);
//         setState(() {
//           _activeCities = cities.map((e) => e.toString()).toList();
//           // Fetch coordinates for active cities
//           _fetchCityCoordinates();
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load active cities')),
//         );
//       }
//     } catch (e) {
//       print("Error loading active cities: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading active cities: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchCityCoordinates() async {
//     for (var city in _activeCities) {
//       LatLng? coords = await getCityCoordinates(city);
//       if (coords != null) {
//         setState(() {
//           _cityCoordinates[city] = coords;
//         });
//       }
//     }
//   }

//   Future<void> _searchCity() async {
//     String cityName = _cityController.text.trim();
//     if (cityName.isEmpty) return;

//     LatLng? cityLocation = await getCityCoordinates(cityName);
//     if (cityLocation != null) {
//       setState(() {
//         _cityLocation = cityLocation;
//       });
//       _mapController.move(_cityLocation, 10.0);
//       _fetchCityDetails(cityName);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('City not found')),
//       );
//       setState(() {
//         _cityDetails = {};
//         _selectedCity = null;
//       });
//     }
//   }

//   Future<void> _fetchCityDetails(String city) async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://localhost:5000/city-details'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'city': city}),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _cityDetails = json.decode(response.body);
//           _selectedCity = city;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load city details')),
//         );
//         setState(() {
//           _cityDetails = {};
//           _selectedCity = null;
//         });
//       }
//     } catch (e) {
//       print("Error fetching city details: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching city details: $e')),
//       );
//       setState(() {
//         _cityDetails = {};
//         _selectedCity = null;
//       });
//     }
//   }

//   Future<LatLng?> getCityCoordinates(String cityName) async {
//     try {
//       final url = Uri.parse(
//           "https://nominatim.openstreetmap.org/search?format=json&q=$cityName,India");
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data.isNotEmpty) {
//           final lat = double.parse(data[0]['lat']);
//           final lon = double.parse(data[0]['lon']);
//           return LatLng(lat, lon);
//         }
//       }
//       return null;
//     } catch (e) {
//       print("Error finding city: $e");
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("City Map")),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: TextField(
//                   controller: _cityController,
//                   decoration: InputDecoration(
//                     hintText: "Enter city in India",
//                     suffixIcon: IconButton(
//                       icon: Icon(Icons.search),
//                       onPressed: _searchCity,
//                     ),
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: FlutterMap(
//                   mapController: _mapController,
//                   options: MapOptions(
//                     initialCenter: _cityLocation,
//                     initialZoom: 5.0,
//                     minZoom: 3,    // Set the minimum zoom level
//                     maxZoom: 18,   // Set the maximum zoom level
//                     interactionOptions: const InteractionOptions(
//                       flags: InteractiveFlag.all,
//                     ),
//                     onMapEvent: (mapEvent) {
//                       // Hide the tooltip when the map is zoomed
//                       if (mapEvent is MapEventMove ||
//                           mapEvent is MapEventFlingAnimation) {
//                         setState(() {
//                           _hoveredCityName = null; // Hide tooltip on map move
//                         });
//                       }
//                     },
//                     onMapReady: () {
//                       print("Map is ready!");
//                     },
//                   ),
//                   children: [
//                     TileLayer(
//                       urlTemplate:
//                           "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                       subdomains: ['a', 'b', 'c'],
//                     ),
//                     MarkerLayer(
//                       markers: _cityCoordinates.entries.map((entry) {
//                         String city = entry.key;
//                         LatLng location = entry.value;
//                         bool isActive = _activeCities.contains(city);

//                         return Marker(
//                           point: location,
//                           width: 150.0,
//                           height: 70.0,
//                           child: MouseRegion(
//                             cursor: SystemMouseCursors.click,
//                             onEnter: (event) {
//                               _fetchCityDetails(city);
//                               setState(() {
//                                 _hoveredCityName = city;
//                               });
//                             },
//                             onExit: (event) {
//                               setState(() {
//                                 _hoveredCityName = null;
//                               });
//                             },
//                             child: Stack(
//                               alignment: Alignment.bottomCenter,
//                               clipBehavior: Clip.none,
//                               children: [
//                                 Icon(
//                                   Icons.location_pin,
//                                   color: isActive ? Colors.blue : Colors.grey,
//                                   size: 30,
//                                 ),
//                                 if (_hoveredCityName == city)
//                                   AnimatedPositioned(
//                                   duration: const Duration(milliseconds: 200),
//                                   curve: Curves.easeInOut,
//                                   bottom: -55,
//                                   child: LayoutBuilder(
//                                     builder: (context, constraints) {
//                                       return Container(
//                                         constraints: BoxConstraints(maxWidth: 220.0), // Increased maxWidth
//                                         padding: EdgeInsets.all(6.0),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius: BorderRadius.circular(8.0),
//                                           boxShadow: [
//                                             BoxShadow(
//                                               color: Colors.grey.withOpacity(0.3),
//                                               spreadRadius: 1,
//                                               blurRadius: 3,
//                                               offset: Offset(0, 2),
//                                             ),
//                                           ],
//                                         ),
//                                         child: Column(
//                                           mainAxisSize: MainAxisSize.min,
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               city,
//                                               overflow: TextOverflow.ellipsis,
//                                               style: TextStyle(
//                                                 fontSize: 18,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             Text(
//                                               "Total Cars: ${_cityDetails['Total Cars'] ?? 'N/A'}",
//                                               overflow: TextOverflow.ellipsis,
//                                               style: TextStyle(fontSize: 16),
//                                             ),
//                                             Text(
//                                               "Total Trips: ${_cityDetails['Total Trips'] ?? 'N/A'}",
//                                               overflow: TextOverflow.ellipsis,
//                                               style: TextStyle(fontSize: 16),
//                                             ),
//                                             Text(
//                                               "Total Income: ${_cityDetails['Total Income'] ?? 'N/A'}",
//                                               style: TextStyle(fontSize: 16),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (_isLoading)
//             Container(
//               color: Colors.black54,
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }



















// after search bar customization


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:http/http.dart' as http;
// import 'package:latlong2/latlong.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart'; // Import the package


// class CityMapScreen extends StatefulWidget {
//   @override
//   _CityMapScreenState createState() => _CityMapScreenState();
// }

// class _CityMapScreenState extends State<CityMapScreen> {
//   final TextEditingController _cityController = TextEditingController();
//   final MapController _mapController = MapController();
//   LatLng _cityLocation = LatLng(20.5937, 78.9629); // Default to India
//   Map<String, LatLng> _cityCoordinates = {}; // Store city coordinates
//   List<String> _activeCities = []; // Store active cities from backend
//   Map<String, dynamic> _cityDetails = {}; // Store city details
//   String? _selectedCity; // Currently selected city
//   bool _isLoading = false;
//   String? _hoveredCityName;

//   @override
//   void initState() {
//     super.initState();
//     _loadActiveCities();
//   }

//   Future<void> _loadActiveCities() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       final response = await http.get(
//           Uri.parse('http://localhost:5000/active-cities')); // Replace with your Flask backend URL
//       if (response.statusCode == 200) {
//         List<dynamic> cities = json.decode(response.body);
//         setState(() {
//           _activeCities = cities.map((e) => e.toString()).toList();
//           // Fetch coordinates for active cities
//           _fetchCityCoordinates();
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load active cities')),
//         );
//       }
//     } catch (e) {
//       print("Error loading active cities: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading active cities: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchCityCoordinates() async {
//     for (var city in _activeCities) {
//       LatLng? coords = await getCityCoordinates(city);
//       if (coords != null) {
//         setState(() {
//           _cityCoordinates[city] = coords;
//         });
//       }
//     }
//   }

//   Future<void> _searchCity(String cityName) async { // Modify _searchCity parameters
//     //String cityName = _cityController.text.trim();  //DO NOT USE: Use now parameters
//     if (cityName.isEmpty) return;

//     LatLng? cityLocation = await getCityCoordinates(cityName);
//     if (cityLocation != null) {
//       setState(() {
//         _cityLocation = cityLocation;
//       });
//       _mapController.move(_cityLocation, 10.0);
//       _fetchCityDetails(cityName);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('City not found')),
//       );
//       setState(() {
//         _cityDetails = {};
//         _selectedCity = null;
//       });
//     }
//   }

//   Future<void> _fetchCityDetails(String city) async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://localhost:5000/city-details'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'city': city}),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _cityDetails = json.decode(response.body);
//           _selectedCity = city;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load city details')),
//         );
//         setState(() {
//           _cityDetails = {};
//           _selectedCity = null;
//         });
//       }
//     } catch (e) {
//       print("Error fetching city details: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching city details: $e')),
//       );
//       setState(() {
//         _cityDetails = {};
//         _selectedCity = null;
//       });
//     }
//   }

//   Future<LatLng?> getCityCoordinates(String cityName) async {
//     try {
//       final url = Uri.parse(
//           "https://nominatim.openstreetmap.org/search?format=json&q=$cityName,India");
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data.isNotEmpty) {
//           final lat = double.parse(data[0]['lat']);
//           final lon = double.parse(data[0]['lon']);
//           return LatLng(lat, lon);
//         }
//       }
//       return null;
//     } catch (e) {
//       print("Error finding city: $e");
//       return null;
//     }
//   }

//   // This would be the Autocompletion List that are valid.
//    List<String> _getSuggestions(String query) {
//     return _activeCities.where((city) => city.toLowerCase().startsWith(query.toLowerCase())).toList();
//   }



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("City Map")),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Align( // ADD: ALIGN to change the Alignment of the whole thing
//                   alignment: Alignment.topCenter,
//                   child: Container(
//                     width: MediaQuery.of(context).size.width * 0.6, // Change width
//                     child: TypeAheadFormField<String>( // Now TypeAhead Widget
//                         textFieldConfiguration: TextFieldConfiguration(
//                           controller: _cityController, // Use regular controller
//                           decoration: InputDecoration(
//                             hintText: "Enter city in India",
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                         suggestionsCallback: (pattern) async {
//                           return _getSuggestions(pattern); // Use internal list
//                         },
//                         itemBuilder: (context, suggestion) {
//                           return ListTile(
//                             leading: Icon(Icons.location_city),
//                             title: Text(suggestion),
//                           );
//                         },
//                         onSuggestionSelected: (suggestion) {
//                           _cityController.text = suggestion; //Set with a text
//                           _searchCity(suggestion);
//                         },
//                         validator: (value) => value!.isEmpty ? 'Please select a city' : null,
//                         onSaved: (value) => print("Validate $value")
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: FlutterMap(
//                   mapController: _mapController,
//                   options: MapOptions(
//                     initialCenter: _cityLocation,
//                     initialZoom: 5.0,
//                     minZoom: 3,    // Set the minimum zoom level
//                     maxZoom: 18,   // Set the maximum zoom level
//                     interactionOptions: const InteractionOptions(
//                       flags: InteractiveFlag.all,
//                     ),
//                     onMapEvent: (mapEvent) {
//                       // Hide the tooltip when the map is zoomed
//                       if (mapEvent is MapEventMove ||
//                           mapEvent is MapEventFlingAnimation) {
//                         setState(() {
//                           _hoveredCityName = null; // Hide tooltip on map move
//                         });
//                       }
//                     },
//                     onMapReady: () {
//                       print("Map is ready!");
//                     },
//                   ),
//                   children: [
//                     TileLayer(
//                       urlTemplate:
//                           "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                       subdomains: ['a', 'b', 'c'],
//                     ),
//                     MarkerLayer(
//                       markers: _cityCoordinates.entries.map((entry) {
//                         String city = entry.key;
//                         LatLng location = entry.value;
//                         bool isActive = _activeCities.contains(city);

//                         return Marker(
//                           point: location,
//                           width: 150.0,
//                           height: 70.0,
//                           child: MouseRegion(
//                             cursor: SystemMouseCursors.click,
//                             onEnter: (event) {
//                               _fetchCityDetails(city);
//                               setState(() {
//                                 _hoveredCityName = city;
//                               });
//                             },
//                             onExit: (event) {
//                               setState(() {
//                                 _hoveredCityName = null;
//                               });
//                             },
//                             child: Stack(
//                               alignment: Alignment.bottomCenter,
//                               clipBehavior: Clip.none,
//                               children: [
//                                 Icon(
//                                   Icons.location_pin,
//                                   color: isActive ? Colors.blue : Colors.grey,
//                                   size: 30,
//                                 ),
//                                 if (_hoveredCityName == city)
//                                   AnimatedPositioned(
//                                   duration: const Duration(milliseconds: 200),
//                                   curve: Curves.easeInOut,
//                                   bottom: -55,
//                                   child: LayoutBuilder(
//                                     builder: (context, constraints) {
//                                       return Container(
//                                         constraints: BoxConstraints(maxWidth: 220.0), // Increased maxWidth
//                                         padding: EdgeInsets.all(6.0),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius: BorderRadius.circular(8.0),
//                                           boxShadow: [
//                                             BoxShadow(
//                                               color: Colors.grey.withOpacity(0.3),
//                                               spreadRadius: 1,
//                                               blurRadius: 3,
//                                               offset: Offset(0, 2),
//                                             ),
//                                           ],
//                                         ),
//                                         child: Column(
//                                           mainAxisSize: MainAxisSize.min,
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               city,
//                                               overflow: TextOverflow.ellipsis,
//                                               style: TextStyle(
//                                                 fontSize: 18,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             Text(
//                                               "Total Cars: ${_cityDetails['Total Cars'] ?? 'N/A'}",
//                                               overflow: TextOverflow.ellipsis,
//                                               style: TextStyle(fontSize: 16),
//                                             ),
//                                             Text(
//                                               "Total Trips: ${_cityDetails['Total Trips'] ?? 'N/A'}",
//                                               overflow: TextOverflow.ellipsis,
//                                               style: TextStyle(fontSize: 16),
//                                             ),
//                                             Text(
//                                               "Total Income: ${_cityDetails['Total Income'] ?? 'N/A'}",
//                                               style: TextStyle(fontSize: 16),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (_isLoading)
//             Container(
//               color: Colors.black54,
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }









// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:http/http.dart' as http;
// import 'package:latlong2/latlong.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart'; // Import the package


// class CityMapScreen extends StatefulWidget {
//   @override
//   _CityMapScreenState createState() => _CityMapScreenState();
// }

// class _CityMapScreenState extends State<CityMapScreen> {
//   final TextEditingController _cityController = TextEditingController();
//   final MapController _mapController = MapController();
//   LatLng _cityLocation = LatLng(20.5937, 78.9629); // Default to India
//   Map<String, LatLng> _cityCoordinates = {}; // Store city coordinates
//   List<String> _activeCities = []; // Store active cities from backend
//   Map<String, dynamic> _cityDetails = {}; // Store city details
//   String? _selectedCity; // Currently selected city
//   bool _isLoading = false;
//   String? _hoveredCityName;

//   @override
//   void initState() {
//     super.initState();
//     _loadActiveCities();
//   }

//   Future<void> _loadActiveCities() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       final response = await http.get(
//           Uri.parse('http://localhost:5000/active-cities')); // Replace with your Flask backend URL
//       if (response.statusCode == 200) {
//         List<dynamic> cities = json.decode(response.body);
//         setState(() {
//           _activeCities = cities.map((e) => e.toString()).toList();
//           // Fetch coordinates for active cities
//           _fetchCityCoordinates();
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load active cities')),
//         );
//       }
//     } catch (e) {
//       print("Error loading active cities: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading active cities: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchCityCoordinates() async {
//     for (var city in _activeCities) {
//       LatLng? coords = await getCityCoordinates(city);
//       if (coords != null) {
//         setState(() {
//           _cityCoordinates[city] = coords;
//         });
//       }
//     }
//   }

//   Future<void> _searchCity(String cityName) async { // Modify _searchCity parameters
//     //String cityName = _cityController.text.trim();  //DO NOT USE: Use now parameters
//     if (cityName.isEmpty) return;

//     LatLng? cityLocation = await getCityCoordinates(cityName);
//     if (cityLocation != null) {
//       setState(() {
//         _cityLocation = cityLocation;
//       });
//       _mapController.move(_cityLocation, 10.0);
//       _fetchCityDetails(cityName);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('City not found')),
//       );
//       setState(() {
//         _cityDetails = {};
//         _selectedCity = null;
//       });
//     }
//   }

//   Future<void> _fetchCityDetails(String city) async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://localhost:5000/city-details'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'city': city}),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _cityDetails = json.decode(response.body);
//           _selectedCity = city;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load city details')),
//         );
//         setState(() {
//           _cityDetails = {};
//           _selectedCity = null;
//         });
//       }
//     } catch (e) {
//       print("Error fetching city details: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching city details: $e')),
//       );
//       setState(() {
//         _cityDetails = {};
//         _selectedCity = null;
//       });
//     }
//   }

//   Future<LatLng?> getCityCoordinates(String cityName) async {
//     try {
//       final url = Uri.parse(
//           "https://nominatim.openstreetmap.org/search?format=json&q=$cityName,India");
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data.isNotEmpty) {
//           final lat = double.parse(data[0]['lat']);
//           final lon = double.parse(data[0]['lon']);
//           return LatLng(lat, lon);
//         }
//       }
//       return null;
//     } catch (e) {
//       print("Error finding city: $e");
//       return null;
//     }
//   }

//   // This would be the Autocompletion List that are valid.
//    List<String> _getSuggestions(String query) {
//     return _activeCities.where((city) => city.toLowerCase().startsWith(query.toLowerCase())).toList();
//   }



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("City Map")),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Align( // ADD: ALIGN to change the Alignment of the whole thing
//                   alignment: Alignment.topCenter,
//                   child: Container(
//                     width: MediaQuery.of(context).size.width * 0.6, // Change width
//                     child: TypeAheadField<String>( // Now TypeAhead Widget
//                         //textFieldConfiguration: TextFieldConfiguration( // REMOVED
//                         //  controller: _cityController, // Use regular controller
//                         //  decoration: InputDecoration(
//                         //    hintText: "Enter city in India",
//                         //    border: OutlineInputBorder(),
//                         //  ),
//                         //),
//                          builder: (context, controller, focusNode){ //ADD builder for typeaheadfield since i removed textFieldconfiguration
//                             return TextField(
//                                  controller: controller, // ADDED: the controller
//                                   focusNode: focusNode, //ADDED: focusNode
//                                  decoration: InputDecoration(
//                                      hintText: "Enter city in India",
//                                      border: OutlineInputBorder(),
//                                  ),
//                             );
//                          },
//                         suggestionsCallback: (pattern) async {
//                           return _getSuggestions(pattern); // Use internal list
//                         },
//                         itemBuilder: (context, suggestion) {
//                           return ListTile(
//                             leading: Icon(Icons.location_city),
//                             title: Text(suggestion),
//                           );
//                         },
//                         onSelected: (suggestion) {
//                           _cityController.text = suggestion; //Set with a text
//                           _searchCity(suggestion);
//                         },
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: FlutterMap(
//                   mapController: _mapController,
//                   options: MapOptions(
//                     initialCenter: _cityLocation,
//                     initialZoom: 5.0,
//                     minZoom: 3,    // Set the minimum zoom level
//                     maxZoom: 18,   // Set the maximum zoom level
//                     interactionOptions: const InteractionOptions(
//                       flags: InteractiveFlag.all,
//                     ),
//                     onMapEvent: (mapEvent) {
//                       // Hide the tooltip when the map is zoomed
//                       if (mapEvent is MapEventMove ||
//                           mapEvent is MapEventFlingAnimation) {
//                         setState(() {
//                           _hoveredCityName = null; // Hide tooltip on map move
//                         });
//                       }
//                     },
//                     onMapReady: () {
//                       print("Map is ready!");
//                     },
//                   ),
//                   children: [
//                     TileLayer(
//                       urlTemplate:
//                           "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                       subdomains: ['a', 'b', 'c'],
//                     ),
//                     MarkerLayer(
//                       markers: _cityCoordinates.entries.map((entry) {
//                         String city = entry.key;
//                         LatLng location = entry.value;
//                         bool isActive = _activeCities.contains(city);

//                         return Marker(
//                           point: location,
//                           width: 150.0,
//                           height: 70.0,
//                           child: MouseRegion(
//                             cursor: SystemMouseCursors.click,
//                             onEnter: (event) {
//                               _fetchCityDetails(city);
//                               setState(() {
//                                 _hoveredCityName = city;
//                               });
//                             },
//                             onExit: (event) {
//                               setState(() {
//                                 _hoveredCityName = null;
//                               });
//                             },
//                             child: Stack(
//                               alignment: Alignment.bottomCenter,
//                               clipBehavior: Clip.none,
//                               children: [
//                                 Icon(
//                                   Icons.location_pin,
//                                   color: isActive ? Colors.blue : Colors.grey,
//                                   size: 30,
//                                 ),
//                                 if (_hoveredCityName == city)
//                                   AnimatedPositioned(
//                                   duration: const Duration(milliseconds: 200),
//                                   curve: Curves.easeInOut,
//                                   bottom: -55,
//                                   child: LayoutBuilder(
//                                     builder: (context, constraints) {
//                                       return Container(
//                                         constraints: BoxConstraints(maxWidth: 220.0), // Increased maxWidth
//                                         padding: EdgeInsets.all(6.0),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius: BorderRadius.circular(8.0),
//                                           boxShadow: [
//                                             BoxShadow(
//                                               color: Colors.grey.withOpacity(0.3),
//                                               spreadRadius: 1,
//                                               blurRadius: 3,
//                                               offset: Offset(0, 2),
//                                             ),
//                                           ],
//                                         ),
//                                         child: Column(
//                                           mainAxisSize: MainAxisSize.min,
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               city,
//                                               overflow: TextOverflow.ellipsis,
//                                               style: TextStyle(
//                                                 fontSize: 18,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             Text(
//                                               "Total Cars: ${_cityDetails['Total Cars'] ?? 'N/A'}",
//                                               overflow: TextOverflow.ellipsis,
//                                               style: TextStyle(fontSize: 16),
//                                             ),
//                                             Text(
//                                               "Total Trips: ${_cityDetails['Total Trips'] ?? 'N/A'}",
//                                               overflow: TextOverflow.ellipsis,
//                                               style: TextStyle(fontSize: 16),
//                                             ),
//                                             Text(
//                                               "Total Income: ${_cityDetails['Total Income'] ?? 'N/A'}",
//                                               style: TextStyle(fontSize: 16),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (_isLoading)
//             Container(
//               color: Colors.black54,
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }
























// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:http/http.dart' as http;
// import 'package:latlong2/latlong.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart'; // Import the package


// class CityMapScreen extends StatefulWidget {
//   @override
//   _CityMapScreenState createState() => _CityMapScreenState();
// }

// class _CityMapScreenState extends State<CityMapScreen> {
//   final TextEditingController _cityController = TextEditingController();
//   final MapController _mapController = MapController();
//   LatLng _cityLocation = LatLng(20.5937, 78.9629); // Default to India
//   Map<String, LatLng> _cityCoordinates = {}; // Store city coordinates
//   List<String> _activeCities = []; // Store active cities from backend
//   Map<String, dynamic> _cityDetails = {}; // Store city details
//   String? _selectedCity; // Currently selected city
//   bool _isLoading = false;
//   String? _hoveredCityName;

//   @override
//   void initState() {
//     super.initState();
//     _loadActiveCities();
//   }

//   Future<void> _loadActiveCities() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       final response = await http.get(
//           Uri.parse('http://localhost:5000/active-cities')); // Replace with your Flask backend URL
//       if (response.statusCode == 200) {
//         List<dynamic> cities = json.decode(response.body);
//         setState(() {
//           _activeCities = cities.map((e) => e.toString()).toList();
//           // Fetch coordinates for active cities
//           _fetchCityCoordinates();
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load active cities')),
//         );
//       }
//     } catch (e) {
//       print("Error loading active cities: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading active cities: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchCityCoordinates() async {
//     for (var city in _activeCities) {
//       LatLng? coords = await getCityCoordinates(city);
//       if (coords != null) {
//         setState(() {
//           _cityCoordinates[city] = coords;
//         });
//       }
//     }
//   }

//   Future<void> _searchCity(String cityName) async { // Modify _searchCity parameters
//     //String cityName = _cityController.text.trim();  //DO NOT USE: Use now parameters
//     if (cityName.isEmpty) return;

//     LatLng? cityLocation = await getCityCoordinates(cityName);
//     if (cityLocation != null) {
//       setState(() {
//         _cityLocation = cityLocation;
//       });
//       _mapController.move(_cityLocation, 10.0);
//       _fetchCityDetails(cityName);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('City not found')),
//       );
//       setState(() {
//         _cityDetails = {};
//         _selectedCity = null;
//       });
//     }
//   }

//   Future<void> _fetchCityDetails(String city) async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://localhost:5000/city-details'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'city': city}),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _cityDetails = json.decode(response.body);
//           _selectedCity = city;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to load city details')),
//         );
//         setState(() {
//           _cityDetails = {};
//           _selectedCity = null;
//         });
//       }
//     } catch (e) {
//       print("Error fetching city details: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching city details: $e')),
//       );
//       setState(() {
//         _cityDetails = {};
//         _selectedCity = null;
//       });
//     }
//   }

//   Future<LatLng?> getCityCoordinates(String cityName) async {
//     try {
//       final url = Uri.parse(
//           "https://nominatim.openstreetmap.org/search?format=json&q=$cityName,India");
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data.isNotEmpty) {
//           final lat = double.parse(data[0]['lat']);
//           final lon = double.parse(data[0]['lon']);
//           return LatLng(lat, lon);
//         }
//       }
//       return null;
//     } catch (e) {
//       print("Error finding city: $e");
//       return null;
//     }
//   }

//   // This would be the Autocompletion List that are valid.
//    List<String> _getSuggestions(String query) {
//       if (query.isEmpty) {  // ADD:  Only start when the query is provided.
//         return [];
//       }
//     return _activeCities.where((city) => city.toLowerCase().startsWith(query.toLowerCase())).toList();
//   }



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("City Map")),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Align( // ADD: ALIGN to change the Alignment of the whole thing
//                   alignment: Alignment.topCenter,
//                   child: Container(
//                     width: MediaQuery.of(context).size.width * 0.6, // Change width
//                     child: TypeAheadField<String>( // Now TypeAhead Widget
//                          builder: (context, controller, focusNode){ //ADD builder for typeaheadfield since i removed textFieldconfiguration
//                             return TextField(
//                                  controller: controller, // ADDED: the controller
//                                   focusNode: focusNode, //ADDED: focusNode
//                                  decoration: InputDecoration(
//                                      hintText: "Enter city in India",
//                                      border: OutlineInputBorder(),
//                                  ),
//                             );
//                          },
//                         suggestionsCallback: (pattern) async {
//                           return _getSuggestions(pattern); // Use internal list
//                         },
//                         itemBuilder: (context, suggestion) {
//                           return ListTile(
//                             leading: Icon(Icons.location_on), // CHANGE THIS: change the icon to what is desired!
//                             title: Text(suggestion),
//                           );
//                         },
//                         onSelected: (suggestion) {
//                           _cityController.text = suggestion; //Set with a text
//                           _searchCity(suggestion);
//                         },
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: FlutterMap(
//                   mapController: _mapController,
//                   options: MapOptions(
//                     initialCenter: _cityLocation,
//                     initialZoom: 5.0,
//                     minZoom: 3,    // Set the minimum zoom level
//                     maxZoom: 18,   // Set the maximum zoom level
//                     interactionOptions: const InteractionOptions(
//                       flags: InteractiveFlag.all,
//                     ),
//                     onMapEvent: (mapEvent) {
//                       // Hide the tooltip when the map is zoomed
//                       if (mapEvent is MapEventMove ||
//                           mapEvent is MapEventFlingAnimation) {
//                         setState(() {
//                           _hoveredCityName = null; // Hide tooltip on map move
//                         });
//                       }
//                     },
//                     onMapReady: () {
//                       print("Map is ready!");
//                     },
//                   ),
//                   children: [
//                     TileLayer(
//                       urlTemplate:
//                           "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//                       subdomains: ['a', 'b', 'c'],
//                     ),
//                     MarkerLayer(
//                       markers: _cityCoordinates.entries.map((entry) {
//                         String city = entry.key;
//                         LatLng location = entry.value;
//                         bool isActive = _activeCities.contains(city);

//                         return Marker(
//                           point: location,
//                           width: 150.0,
//                           height: 70.0,
//                           child: MouseRegion(
//                             cursor: SystemMouseCursors.click,
//                             onEnter: (event) {
//                               _fetchCityDetails(city);
//                               setState(() {
//                                 _hoveredCityName = city;
//                               });
//                             },
//                             onExit: (event) {
//                               setState(() {
//                                 _hoveredCityName = null;
//                               });
//                             },
//                             child: Stack(
//                               alignment: Alignment.bottomCenter,
//                               clipBehavior: Clip.none,
//                               children: [
//                                 Icon(
//                                   Icons.location_pin,
//                                   color: isActive ? Colors.blue : Colors.grey,
//                                   size: 30,
//                                 ),
//                                 if (_hoveredCityName == city)
//                                   AnimatedPositioned(
//                                   duration: const Duration(milliseconds: 200),
//                                   curve: Curves.easeInOut,
//                                   bottom: -55,
//                                   child: LayoutBuilder(
//                                     builder: (context, constraints) {
//                                       return Container(
//                                         constraints: BoxConstraints(maxWidth: 220.0), // Increased maxWidth
//                                         padding: EdgeInsets.all(6.0),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius: BorderRadius.circular(8.0),
//                                           boxShadow: [
//                                             BoxShadow(
//                                               color: Colors.grey.withOpacity(0.3),
//                                               spreadRadius: 1,
//                                               blurRadius: 3,
//                                               offset: Offset(0, 2),
//                                             ),
//                                           ],
//                                         ),
//                                         child: Column(
//                                           mainAxisSize: MainAxisSize.min,
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               city,
//                                               overflow: TextOverflow.ellipsis,
//                                               style: TextStyle(
//                                                 fontSize: 18,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             Text(
//                                               "Total Cars: ${_cityDetails['Total Cars'] ?? 'N/A'}",
//                                               overflow: TextOverflow.ellipsis,
//                                               style: TextStyle(fontSize: 16),
//                                             ),
//                                             Text(
//                                               "Total Trips: ${_cityDetails['Total Trips'] ?? 'N/A'}",
//                                               overflow: TextOverflow.ellipsis,
//                                               style: TextStyle(fontSize: 16),
//                                             ),
//                                             Text(
//                                               "Total Income: ${_cityDetails['Total Income'] ?? 'N/A'}",
//                                               style: TextStyle(fontSize: 16),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (_isLoading)
//             Container(
//               color: Colors.black54,
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }
































import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart'; // Import the package


class CityMapScreen extends StatefulWidget {
  @override
  _CityMapScreenState createState() => _CityMapScreenState();
}

class _CityMapScreenState extends State<CityMapScreen> {
  final TextEditingController _cityController = TextEditingController();
  final MapController _mapController = MapController();
  LatLng _cityLocation = LatLng(20.5937, 78.9629); // Default to India
  Map<String, LatLng> _cityCoordinates = {}; // Store city coordinates
  List<String> _activeCities = []; // Store active cities from backend
  Map<String, dynamic> _cityDetails = {}; // Store city details
  String? _selectedCity; // Currently selected city
  bool _isLoading = false;
  String? _hoveredCityName;

  @override
  void initState() {
    super.initState();
    _loadActiveCities();
  }

  Future<void> _loadActiveCities() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(
          Uri.parse('http://localhost:5000/active-cities')); // Replace with your Flask backend URL
      if (response.statusCode == 200) {
        List<dynamic> cities = json.decode(response.body);
        setState(() {
          _activeCities = cities.map((e) => e.toString()).toList();
          // Fetch coordinates for active cities
          _fetchCityCoordinates();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load active cities')),
        );
      }
    } catch (e) {
      print("Error loading active cities: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading active cities: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCityCoordinates() async {
    for (var city in _activeCities) {
      LatLng? coords = await getCityCoordinates(city);
      if (coords != null) {
        setState(() {
          _cityCoordinates[city] = coords;
        });
      }
    }
  }

  Future<void> _searchCity(String cityName) async { // Modify _searchCity parameters
    //String cityName = _cityController.text.trim();  //DO NOT USE: Use now parameters
    if (cityName.isEmpty) return;

    LatLng? cityLocation = await getCityCoordinates(cityName);
    if (cityLocation != null) {
      setState(() {
        _cityLocation = cityLocation;
      });
      _mapController.move(_cityLocation, 10.0);
      _fetchCityDetails(cityName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('City not found')),
      );
      setState(() {
        _cityDetails = {};
        _selectedCity = null;
      });
    }
  }

  Future<void> _fetchCityDetails(String city) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/city-details'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'city': city}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _cityDetails = json.decode(response.body);
          _selectedCity = city;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load city details')),
        );
        setState(() {
          _cityDetails = {};
          _selectedCity = null;
        });
      }
    } catch (e) {
      print("Error fetching city details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching city details: $e')),
      );
      setState(() {
        _cityDetails = {};
        _selectedCity = null;
      });
    }
  }

  Future<LatLng?> getCityCoordinates(String cityName) async {
    try {
      final url = Uri.parse(
          "https://nominatim.openstreetmap.org/search?format=json&q=$cityName,India");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          return LatLng(lat, lon);
        }
      }
      return null;
    } catch (e) {
      print("Error finding city: $e");
      return null;
    }
  }

  // This would be the Autocompletion List that are valid.
   List<String> _getSuggestions(String query) {
      if (query.isEmpty) {  // ADD:  Only start when the query is provided.
        return [];
      }
    return _activeCities.where((city) => city.toLowerCase().startsWith(query.toLowerCase())).toList();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("City Map")),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Align( // ADD: ALIGN to change the Alignment of the whole thing
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4, // Change width
                    child: TypeAheadField<String>( // Now TypeAhead Widget
                         builder: (context, controller, focusNode){ //ADD builder for typeaheadfield since i removed textFieldconfiguration
                            return TextField(
                                 controller: controller, // ADDED: the controller
                                  focusNode: focusNode, //ADDED: focusNode
                                 decoration: InputDecoration(
                                     hintText: "Enter city in India",
                                     border: OutlineInputBorder(),
                                 ),
                            );
                         },
                         hideOnEmpty: true, //ADDED: Add hideOnEmpty
                        suggestionsCallback: (pattern) async {
                          return _getSuggestions(pattern); // Use internal list
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            leading: Icon(Icons.location_on), // CHANGE THIS: change the icon to what is desired!
                            title: Text(suggestion),
                          );
                        },
                        onSelected: (suggestion) {
                          FocusScope.of(context).unfocus(); //ADD: To unFocus
                          _cityController.text = suggestion; //Set with a text
                          _searchCity(suggestion);
                        },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _cityLocation,
                    initialZoom: 5.0,
                    minZoom: 3,    // Set the minimum zoom level
                    maxZoom: 18,   // Set the maximum zoom level
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                    onMapEvent: (mapEvent) {
                      // Hide the tooltip when the map is zoomed
                      if (mapEvent is MapEventMove ||
                          mapEvent is MapEventFlingAnimation) {
                        setState(() {
                          _hoveredCityName = null; // Hide tooltip on map move
                        });
                      }
                    },
                    onMapReady: () {
                      print("Map is ready!");
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: _cityCoordinates.entries.map((entry) {
                        String city = entry.key;
                        LatLng location = entry.value;
                        bool isActive = _activeCities.contains(city);

                        return Marker(
                          point: location,
                          width: 150.0,
                          height: 70.0,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            onEnter: (event) {
                              _fetchCityDetails(city);
                              setState(() {
                                _hoveredCityName = city;
                              });
                            },
                            onExit: (event) {
                              setState(() {
                                _hoveredCityName = null;
                              });
                            },
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  Icons.location_pin,
                                  color: isActive ? Colors.blue : Colors.grey,
                                  size: 30,
                                ),
                                if (_hoveredCityName == city)
                                  AnimatedPositioned(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  bottom: -55,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Container(
                                        constraints: BoxConstraints(maxWidth: 220.0), // Increased maxWidth
                                        padding: EdgeInsets.all(6.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.3),
                                              spreadRadius: 1,
                                              blurRadius: 3,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              city,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "Total Cars: ${_cityDetails['Total Cars'] ?? 'N/A'}",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              "Total Trips: ${_cityDetails['Total Trips'] ?? 'N/A'}",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              "Total Income: ${_cityDetails['Total Income'] ?? 'N/A'}",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}