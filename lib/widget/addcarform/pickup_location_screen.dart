import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'form_button.dart';

class PickupLocationScreen extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function onNext;
  final Function(String?) onPickupLocationChanged; // Add this
  final String? pickupLocation;

  const PickupLocationScreen({
    super.key,
    required this.formKey,
    required this.onNext,
    required this.onPickupLocationChanged,
    this.pickupLocation,
  });

  @override
  PickupLocationScreenState createState() => PickupLocationScreenState();
}

class PickupLocationScreenState extends State<PickupLocationScreen> {
  String? _locationAddress;
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _locationAddress = widget.pickupLocation;
    _locationController.text = _locationAddress ?? '';
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Location permissions are permanently denied.');
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition();
    return position;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _suggestLocation() async {
    try {
      Position position = await _getCurrentLocation();
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            "${place.name}, ${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";
        setState(() {
          _locationAddress = address;
          _locationController.text = _locationAddress!;
        });
        widget.onPickupLocationChanged(_locationAddress);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Share your pickup location',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'pickup location',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) {
                      widget.onPickupLocationChanged(value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter pickup location';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _locationAddress = value;
                      });
                    },
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await _suggestLocation();
                  },
                  icon: const Icon(Icons.my_location),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FormButton(
                  onPressed: () async {
                    if (widget.formKey.currentState!.validate()) {
                      widget.formKey.currentState!.save();
                      widget.onNext();
                    }
                  },
                  label: 'Confirm and Proceed'),
            )
          ],
        ),
      ),
    );
  }
}

