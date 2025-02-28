import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'form_button.dart';
import 'km_button.dart';
import 'text_field.dart';


class EligibilityScreen extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function onNext;
  final Function(String?) onCarRegistrationNumberChanged;
  final Function(String?) onCarBrandChanged;
  final Function(String?) onCarModelChanged;
  final Function(String?) onYearOfRegistrationChanged;
  final Function(String?) onCityChanged;
  final Function(String?) onKmDrivenChanged;
  final Function(String?) onSeatingCapacityChanged;
  final Function(String?) onBodyTypeChanged;
  final String? kmDriven;
  final String? seatingCapacity;
  final String? bodyType;


  const EligibilityScreen({
    super.key,
    required this.formKey,
    required this.onNext,
    required this.onCarRegistrationNumberChanged,
    required this.onCarBrandChanged,
    required this.onCarModelChanged,
    required this.onYearOfRegistrationChanged,
    required this.onCityChanged,
    required this.onKmDrivenChanged,
    required this.kmDriven,
    required this.onSeatingCapacityChanged,
    required this.onBodyTypeChanged,
    required this.seatingCapacity,
    required this.bodyType,
    String? CarRegistrationNumber,
    String? city,
    String? carBrand,
    String? carModel,
    String? yearOfRegistration,
    required bool enabled,
  });


  @override
  EligibilityScreenState createState() => EligibilityScreenState();
}


class EligibilityScreenState extends State<EligibilityScreen> {
  String? _selectedKm;
  String? _selectedSeatingCapacity;
  String? _selectedBodyType;




  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();




  @override
  void initState() {
    super.initState();
    _selectedKm = widget.kmDriven;
    _selectedSeatingCapacity = widget.seatingCapacity;
    _selectedBodyType = widget.bodyType;
  }




  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _cityController.dispose();
    _licenseController.dispose();
    super.dispose();
  }
  
   bool _isValidLicenseNumber(String value) {
    if (value.length != 10) return false;

    for (int i = 0; i < value.length; i++) {
        final char = value[i];
        if (i < 2 || (i >= 4 && i < 6)) {
            if (!RegExp(r'[A-Z]').hasMatch(char.toUpperCase())) return false;
        } else if (i >= 2 && i < 4 || i >= 6){
            if (!RegExp(r'[0-9]').hasMatch(char)) return false;
        }
    }
    return true;
}



  String _formatLicenseNumber(String value) {
    String formatted = '';
    for (int i = 0; i < value.length; i++) {
          if (i < 2 || (i >= 4 && i < 6)) {
                formatted += value[i].toUpperCase();
          } else {
               formatted += value[i];
          }
    }
    return formatted;
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
              const Text(
                'Checking car eligibility',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
                 TextFormField(
                  controller: _licenseController,
                   maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Car Registration Number',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                        setState(() {
                           _licenseController.value =
                                _licenseController.value.copyWith(
                                  text: _formatLicenseNumber(value),
                                  selection: TextSelection.collapsed(
                                      offset: _formatLicenseNumber(value).length),
                                );
                        });
                    },
                  onSaved: (value) => widget.onCarRegistrationNumberChanged(value),
                   validator: (value){
                     if (value == null || value.isEmpty){
                         return 'Please enter Car Registration Number';
                     }
                     if (!_isValidLicenseNumber(value)) {
                         return 'Please enter valid car registration number';
                     }
                     return null;
                   }
                ),
              SizedBox(height: screenHeight * 0.02),
              TextFormField(
                  controller: _brandController,
                  decoration: const InputDecoration(
                    labelText: 'Car Brand',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _brandController.value = _brandController.value.copyWith(
                        text: value.toUpperCase(),
                        selection: TextSelection.collapsed(
                            offset: value.toUpperCase().length),
                      );
                    });
                    widget.onCarBrandChanged(_brandController.text);
                  },
                  onSaved: (value) => widget.onCarBrandChanged(value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter car brand';
                    }
                    return null;
                  }),
              SizedBox(height: screenHeight * 0.02),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Car Model',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _modelController.value = _modelController.value.copyWith(
                      text: value.toUpperCase(),
                      selection: TextSelection.collapsed(
                          offset: value.toUpperCase().length),
                    );
                  });
                  widget.onCarModelChanged(_modelController.text);
                },
                onSaved: (value) => widget.onCarModelChanged(value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter car model';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              CustomTextField(
                label: 'Year of registration',
                onSaved: (value) => widget.onYearOfRegistrationChanged(value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter year of registration';
                  }
                  if (value.length != 4 || int.tryParse(value) == null) {
                    return 'Enter valid year';
                  }
                  return null;
                },
                onChanged: (value){},
                enabled: true,
              ),
              SizedBox(height: screenHeight * 0.02),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _cityController.value = _cityController.value.copyWith(
                      text: value.toUpperCase(),
                      selection: TextSelection.collapsed(
                          offset: value.toUpperCase().length),
                    );
                  });
                  widget.onCityChanged(_cityController.text);
                },
                onSaved: (value) => widget.onCityChanged(value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter city';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              const Text(
                'Car Seating Capacity',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedSeatingCapacity = '2';
                        });
                        widget.onSeatingCapacityChanged('2');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedSeatingCapacity == '2'
                            ? Colors.blue
                            : Colors.white,
                        foregroundColor: _selectedSeatingCapacity == '2'
                            ? Colors.white
                            : Colors.black,
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('2'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedSeatingCapacity = '4';
                        });
                        widget.onSeatingCapacityChanged('4');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedSeatingCapacity == '4'
                            ? Colors.blue
                            : Colors.white,
                        foregroundColor: _selectedSeatingCapacity == '4'
                            ? Colors.white
                            : Colors.black,
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('4'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedSeatingCapacity = '5';
                        });
                        widget.onSeatingCapacityChanged('5');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedSeatingCapacity == '5'
                            ? Colors.blue
                            : Colors.white,
                        foregroundColor: _selectedSeatingCapacity == '5'
                            ? Colors.white
                            : Colors.black,
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('5'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedSeatingCapacity = '7';
                        });
                        widget.onSeatingCapacityChanged('7');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedSeatingCapacity == '7'
                            ? Colors.blue
                            : Colors.white,
                        foregroundColor: _selectedSeatingCapacity == '7'
                            ? Colors.white
                            : Colors.black,
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('7'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              const Text(
                'Body Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _selectedBodyType,
                items: <String>[
                  'Sedan',
                  'Hatchback',
                  'SUV',
                  'Minivan',
                  'Convertible',
                  'Coupe',
                  'Wagon',
                  'Van'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBodyType = value;
                  });
                  widget.onBodyTypeChanged(value);
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select Body type';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              const Text(
                'Car KM Driven',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: KMButton(
                      label: '0-20k',
                      onPressed: () {
                        setState(() {
                          _selectedKm = '0-20k';
                        });
                        widget.onKmDrivenChanged('0-20k');
                      },
                      isSelected: _selectedKm == '0-20k',
                      value: '0-20k',
                    ),
                  ),
                  Expanded(
                    child: KMButton(
                      label: '20-40k',
                      onPressed: () {
                        setState(() {
                          _selectedKm = '20-40k';
                        });
                        widget.onKmDrivenChanged('20-40k');
                      },
                      isSelected: _selectedKm == '20-40k',
                      value: '20-40k',
                    ),
                  ),
                  Expanded(
                    child: KMButton(
                      label: '40-60k',
                      onPressed: () {
                        setState(() {
                          _selectedKm = '40-60k';
                        });
                        widget.onKmDrivenChanged('40-60k');
                      },
                      isSelected: _selectedKm == '40-60k',
                      value: '40-60k',
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: KMButton(
                      label: '>60k',
                      onPressed: () {
                        setState(() {
                          _selectedKm = '>60k';
                        });
                        widget.onKmDrivenChanged('>60k');
                      },
                      isSelected: _selectedKm == '>60k',
                      value: '>60k',
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              SizedBox(
                width: double.infinity,
                child: FormButton(
                  onPressed: () {
                    if (widget.formKey.currentState!.validate()) {
                      if (_selectedSeatingCapacity == null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Please select Car Seating Capacity'),
                        ));
                        return;
                      }
                      if (_selectedKm == null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Please select KM Driven'),
                        ));
                        return;
                      }
                      widget.formKey.currentState!.save();
                      widget.onNext();
                    }
                  },
                  label: 'Add Vehicle',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}