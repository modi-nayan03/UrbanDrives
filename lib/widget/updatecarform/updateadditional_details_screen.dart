import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../addcarform/form_button.dart';

class UpdateAdditionalDetailsScreen extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function onNext;
  final Function(String?) onChassisNumberChanged;
  final Function(String?) onFuelTypeChanged;
  final Function(String?) onTransmissionTypeChanged;
  final Function(String?) onPricePerHourChanged;
  final String? fuelType;
  final String? transmissionType;
   final String? chassisNumber;
    final String? pricePerHour;
     final bool enabled;


  const UpdateAdditionalDetailsScreen({
    super.key,
    required this.formKey,
    required this.onNext,
    required this.onChassisNumberChanged,
    required this.onFuelTypeChanged,
    required this.onTransmissionTypeChanged,
    required this.onPricePerHourChanged,
     this.fuelType,
     this.transmissionType,
    this.chassisNumber,
    this.pricePerHour,
     this.enabled = true,
  });

  @override
  UpdateAdditionalDetailsScreenState createState() =>
      UpdateAdditionalDetailsScreenState();
}

class UpdateAdditionalDetailsScreenState
    extends State<UpdateAdditionalDetailsScreen> {
  String? _selectedFuelType;
  String? _selectedTransmissionType;
   final TextEditingController _chassisController = TextEditingController();
  final TextEditingController _pricePerHourController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _selectedFuelType = widget.fuelType;
    _selectedTransmissionType = widget.transmissionType;
     _chassisController.text = widget.chassisNumber ?? '';
       _pricePerHourController.text = widget.pricePerHour ?? '';

  }
  @override
  void dispose() {
    _chassisController.dispose();
    _pricePerHourController.dispose();
    super.dispose();
  }


  bool _isValidChassisNumber(String value) {
    // final chassisRegex = RegExp(r'^[a-zA-Z0-9]{17}$');
    // return chassisRegex.hasMatch(value.toUpperCase());
       return value.length <= 17;
  }

  String _formatChassisNumber(String value) {
    return value.toUpperCase();
  }

   void _onChassisNumberChanged(String value) {
    final formattedValue = _formatChassisNumber(value);
    if (formattedValue.length <= 17) {
      _chassisController.value = _chassisController.value.copyWith(
          text: formattedValue,
          selection: TextSelection.collapsed(offset: formattedValue.length));
      widget.onChassisNumberChanged(formattedValue);
    } else {
      _chassisController.value = _chassisController.value.copyWith(
          text: formattedValue.substring(0, 17),
          selection: TextSelection.collapsed(offset: 17));
       widget.onChassisNumberChanged(formattedValue.substring(0, 17));
    }
  }


  bool _isValidPricePerHour(String value) {
    if (value.isEmpty) return true;
    final priceRegex = RegExp(r'^\d+(\.\d{0,2})?$');
    return priceRegex.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: widget.formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: const Text(
                      'Wonderful! Your car is now eligible to join our platform',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Additional Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
               TextFormField(
                  controller: _chassisController,
                    enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Chasis Number',
                  border: OutlineInputBorder(),
                ),
                  onChanged: _onChassisNumberChanged,
                    onSaved: (value) => widget.onChassisNumberChanged(value),
                    validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter chasis number';
                  }
                  if (!_isValidChassisNumber(value)) {
                    return 'Chassis number must be 17 alphanumeric characters';
                  }
                  return null;
                },
              ),
                SizedBox(height: screenHeight * 0.02),
              const Text(
                'Fuel Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
                SizedBox(height: screenHeight * 0.01),
               Wrap(
                spacing: 8.0, // Spacing between buttons
                runSpacing: 4.0, // Spacing between rows
                children: [
                  ElevatedButton(
                     onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedFuelType == 'Diesel'
                          ? Colors.blue
                          : Colors.white,
                      foregroundColor: _selectedFuelType == 'Diesel'
                          ? Colors.white
                          : Colors.black,
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text('Diesel'),
                  ),
                    ElevatedButton(
                      onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedFuelType == 'Petrol'
                          ? Colors.blue
                          : Colors.white,
                      foregroundColor: _selectedFuelType == 'Petrol'
                          ? Colors.white
                          : Colors.black,
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text('Petrol'),
                  ),
                  ElevatedButton(
                     onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedFuelType == 'EV'
                          ? Colors.blue
                          : Colors.white,
                      foregroundColor: _selectedFuelType == 'EV'
                          ? Colors.white
                          : Colors.black,
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text('EV'),
                  ),
                   ElevatedButton(
                       onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedFuelType == 'HYBRID'
                          ? Colors.blue
                          : Colors.white,
                      foregroundColor: _selectedFuelType == 'HYBRID'
                          ? Colors.white
                          : Colors.black,
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text('HYBRID'),
                  ),
                     ElevatedButton(
                        onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedFuelType == 'CNG'
                          ? Colors.blue
                          : Colors.white,
                      foregroundColor: _selectedFuelType == 'CNG'
                          ? Colors.white
                          : Colors.black,
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text('CNG'),
                  ),
                ],
              ),
                SizedBox(height: screenHeight * 0.02),
              const Text(
                'Transmission Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
                SizedBox(height: screenHeight * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _selectedTransmissionType == 'Automatic'
                                  ? Colors.blue
                                  : Colors.white,
                          foregroundColor:
                              _selectedTransmissionType == 'Automatic'
                                  ? Colors.white
                                  : Colors.black,
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: const Text('Automatic'),
                      ),
                    ),
                   Expanded(
                    child: ElevatedButton(
                        onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedTransmissionType == 'Manual'
                            ? Colors.blue
                            : Colors.white,
                        foregroundColor: _selectedTransmissionType == 'Manual'
                            ? Colors.white
                            : Colors.black,
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('Manual'),
                    ),
                  ),
                ],
              ),
             SizedBox(height: screenHeight * 0.02),
                TextFormField(
                    controller: _pricePerHourController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price Per Hour',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                     onSaved: (value) => widget.onPricePerHourChanged(value),
                    validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price per hour';
                    }
                    if (!_isValidPricePerHour(value)) {
                      return 'Please enter valid price (e.g. 100 or 100.50)';
                    }
                    return null;
                  },
                  inputFormatters: [
                     FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                ),
                  SizedBox(height: screenHeight * 0.04),
              SizedBox(
                width: double.infinity,
                child: FormButton(
                    onPressed: () {
                       if (_selectedFuelType == null ||
                          _selectedTransmissionType == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please select Fuel Type and Transmission type')),
                        );
                        return;
                      }
                      if (widget.formKey.currentState!.validate()) {
                         widget.formKey.currentState!.save();
                        widget.onNext();
                      }
                    },
                    label: 'Next'),
              )
            ],
          ),
        ),
      ),
    );
  }
}