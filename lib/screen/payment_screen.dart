import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'my_trips_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum PaymentMethod {
  card,
  upi,
  cash,
  bankTransfer,
  phonepe,
  paytm,
}

class PaymentScreen extends StatefulWidget {
  final String carRegNum;
  final String startTime;
  final String endTime;
  final double amount;
  final String userName;
   final String userEmail;  
  final double rentalCostPerDay;
  final double driverCostPerDay;
  final int numberOfDays;
  final DateTime returnDate;
  final String carModel;
  final DateTime pickupDate;
  final String carId;
  final String userId;
  final String? frontImage;
  final String? backImage;

  const PaymentScreen({
    Key? key,
    required this.carRegNum,
    required this.startTime,
    required this.endTime,
    required this.amount,
    required this.userName,
    required this.userEmail,
    required this.rentalCostPerDay,
    required this.driverCostPerDay,
    required this.numberOfDays,
    required this.returnDate,
    required this.carModel,
    required this.pickupDate,
    required this.carId,
    required this.userId,
    this.frontImage,
    this.backImage,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.card;
  String _selectedPaymentMethodString = "card";
  PaymentMethod _selectedUpiMethod = PaymentMethod.phonepe;
  bool _showUpiOptions = false;
  bool _showCardForm = false;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethodString = _paymentMethodToString(_selectedPaymentMethod);
  }

  String _paymentMethodToString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return 'card';
      case PaymentMethod.upi:
        return 'upi';
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.bankTransfer:
        return 'bankTransfer';
      case PaymentMethod.phonepe:
        return 'phonepe';
      case PaymentMethod.paytm:
        return 'paytm';
      default:
        return 'card';
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitPayment() async {
    if (_formKey.currentState!.validate() ||
        _selectedPaymentMethod != PaymentMethod.card) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _createBooking();
      } catch (e) {
        print('Error creating booking: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create booking')));
        setState(() {
          _isLoading = false;
        });
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createBooking() async {
    final url = Uri.parse('http://127.0.0.1:5000/create-booking');

    // Parse startTime and endTime to DateTime objects
    DateTime pickupTime;
    DateTime returnTime;
    try {
      pickupTime = DateTime.parse(widget.startTime);
      returnTime = DateTime.parse(widget.endTime);
    } catch (e) {
      print("Error parsing date time: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid date/time format')));
      setState(() {
        _isLoading = false;
      });
      return; // Stop execution if date parsing fails
    }

    // Calculate the number of hours
    double numberOfHours =
        returnTime.difference(pickupTime).inMinutes / 60;
    numberOfHours = double.parse(numberOfHours.toStringAsFixed(2));

    // Convert to UTC (Important!)
    pickupTime = pickupTime.toUtc();
    returnTime = returnTime.toUtc();

    try {
      // Request body
      Map<String, dynamic> requestBody = {
        'userId': widget.userId,
        'carId': widget.carId,
        'carRegNumber': widget.carRegNum,
        'pickupTime': pickupTime.toIso8601String(),
        'returnTime': returnTime.toIso8601String(),
        'frontImage': widget.frontImage,
        'backImage': widget.backImage,
        'amount': widget.amount,
        'paymentMethod': _selectedPaymentMethodString,
        'paymentStatus': 'success',
        'numberOfHours': numberOfHours, // ADD THIS
      };

      // Log the data being sent
      print('Sending booking data: ${json.encode(requestBody)}');

      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      )
          .timeout(const Duration(seconds: 10)); // Add a timeout

      if (response.statusCode == 201) {
        print("Booking successful");
        final totalAmount = numberOfHours * widget.amount;
        _navigateToMyTripsScreen(totalAmount);
      } else {
        // Log the status code and response body
        print('Failed to create booking: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Failed to create booking: ${response.statusCode} - ${response.body}'))); //Show Response for details.

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error creating booking: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to create booking: $e')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToMyTripsScreen(double totalAmount) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyTripsScreen(
          newTrip: Trip(
            carModel: widget.carModel,
            pickUpPoint: 'PickUp Address',
            pickUpTime:
                DateFormat("EEE d MMM yyyy, h:mm a").format(widget.pickupDate),
            dropPoint: 'Drop Address',
            dropTime:
                DateFormat("EEE d MMM yyyy, h:mm a").format(widget.returnDate),
            totalTime: '${numberOfHours} Hour',
            amountPaid: totalAmount.toStringAsFixed(0), // Pass totalAmount here
            status: TripStatus.ongoing,
            imagePath: '', totalAmount: '', carId: '', tripId: '', tripStatus: '', createdAt: '', 
          ),
          userId: widget.userId,
        ),
      ),
    );
  }


    int get numberOfHours {
    try {
      final startDateTime = DateTime.parse(widget.startTime);
      final endDateTime = DateTime.parse(widget.endTime);
      return endDateTime.difference(startDateTime).inHours;
    } catch (e) {
      print("Error parsing date time: $e");
      return 0;
    }
  }

  double get totalAmount {
    return numberOfHours * widget.amount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBookingDetails(),
              const SizedBox(height: 20),
              const Text(
                'Select Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildPaymentMethodButton(
                icon: Icons.credit_card,
                title: 'Credit / Debit Card',
                paymentMethod: PaymentMethod.card,
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = PaymentMethod.card;
                    _selectedPaymentMethodString =
                        _paymentMethodToString(_selectedPaymentMethod);
                    _showUpiOptions = false;
                    _showCardForm = true;
                  });
                },
                isSelected: _selectedPaymentMethod == PaymentMethod.card,
              ),
              Visibility(
                  visible: _selectedPaymentMethod == PaymentMethod.card,
                  child: _buildCardPaymentForm()),
              _buildPaymentMethodButton(
                icon: Icons.import_export,
                title: 'UPI',
                paymentMethod: PaymentMethod.upi,
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = PaymentMethod.upi;
                    _selectedPaymentMethodString =
                        _paymentMethodToString(_selectedPaymentMethod);
                    _showUpiOptions = true;
                    _showCardForm = false;
                  });
                },
                isSelected: _selectedPaymentMethod == PaymentMethod.upi,
              ),
              Visibility(
                visible: _selectedPaymentMethod == PaymentMethod.upi,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'More UPI Options',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade50,
                      ),
                      child: RadioListTile<PaymentMethod>(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  "assets/images/phonepe.png",
                                  width: 25,
                                ),
                                const SizedBox(width: 10),
                                const Text('PhonePe',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        value: PaymentMethod.phonepe,
                        groupValue: _selectedUpiMethod,
                        onChanged: (PaymentMethod? value) {
                          setState(() {
                            _selectedUpiMethod = value!;
                            _selectedPaymentMethodString =
                                _paymentMethodToString(_selectedUpiMethod);
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade50,
                      ),
                      child: RadioListTile<PaymentMethod>(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        title: Row(
                          children: [
                            Image.asset(
                              "assets/images/paytm.png",
                              width: 25,
                            ),
                            const SizedBox(width: 10),
                            const Text('Paytm UPI',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        value: PaymentMethod.paytm,
                        groupValue: _selectedUpiMethod,
                        onChanged: (PaymentMethod? value) {
                          setState(() {
                            _selectedUpiMethod = value!;
                            _selectedPaymentMethodString =
                                _paymentMethodToString(_selectedUpiMethod);
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              _buildPaymentMethodButton(
                icon: Icons.timer_outlined,
                title: 'Cash on Delivery',
                paymentMethod: PaymentMethod.cash,
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = PaymentMethod.cash;
                    _selectedPaymentMethodString =
                        _paymentMethodToString(_selectedPaymentMethod);
                    _showUpiOptions = false;
                    _showCardForm = false;
                  });
                },
                isSelected: _selectedPaymentMethod == PaymentMethod.cash,
              ),
              _buildPaymentMethodButton(
                icon: Icons.account_balance,
                title: 'Bank Transfer',
                paymentMethod: PaymentMethod.bankTransfer,
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = PaymentMethod.bankTransfer;
                    _selectedPaymentMethodString =
                        _paymentMethodToString(_selectedPaymentMethod);
                    _showUpiOptions = false;
                    _showCardForm = false;
                  });
                },
                isSelected:
                    _selectedPaymentMethod == PaymentMethod.bankTransfer,
              ),
              _buildPaymentMethodButton(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Mobile Wallet',
                paymentMethod: PaymentMethod.cash,
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = PaymentMethod.cash;
                    _selectedPaymentMethodString =
                        _paymentMethodToString(_selectedPaymentMethod);
                    _showUpiOptions = false;
                    _showCardForm = false;
                  });
                },
                isSelected: _selectedPaymentMethod == PaymentMethod.cash,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.asset(
                    "assets/images/visa.png",
                    width: 40,
                  ),
                  Image.asset(
                    "assets/images/mastercard.png",
                    width: 40,
                  ),
                  Image.asset(
                    "assets/images/rupay.png",
                    width: 40,
                  ),
                  Image.asset(
                    "assets/images/Safe.png",
                    width: 40,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildPriceSummary(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitPayment,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Text('Pay Now ₹${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton({
    required IconData icon,
    required String title,
    required PaymentMethod paymentMethod,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade50,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: isSelected ? Colors.blue : Colors.black,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.blue : Colors.black),
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails() {
    String message;
    switch (_selectedPaymentMethod) {
      case PaymentMethod.card:
        message = "Pay securely with your Credit/Debit Card.";
        break;
      case PaymentMethod.upi:
        switch (_selectedUpiMethod) {
          case PaymentMethod.phonepe:
            message = "Pay securely with PhonePe.";
            break;
          case PaymentMethod.paytm:
            message = "Pay securely with Paytm UPI.";
            break;
          default:
            message = "Pay securely with UPI.";
        }
        break;
      case PaymentMethod.cash:
        message = "Pay Cash On Delivery";
        break;
      case PaymentMethod.bankTransfer:
        message = "Pay with Bank Transfer";
        break;
      default:
        message = "Pay With Selected Method";
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
      ),
    );
  }

  Widget _buildBookingDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Booking Details:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text("Car Reg. Num: ${widget.carRegNum}"),
        Text(
          "Pickup Time: ${DateFormat("EEE d MMM yyyy, h:mm a").format(widget.pickupDate)}",
        ),
        Text(
          "Return Time: ${DateFormat("EEE d MMM yyyy, h:mm a").format(widget.returnDate)}",
        ),
        Text(
          "Number of Days: ${widget.numberOfDays}",
        ),
        Text(
          "Total Hours: $numberOfHours",
        ),
      ],
    );
  }

  Widget _buildPriceSummary() {
    double totalRentalCost = widget.rentalCostPerDay * widget.numberOfDays;
    // double totalDriverCost = widget.driverCostPerDay * widget.numberOfDays;
    // double totalPrice = totalRentalCost + totalDriverCost;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Price Summary:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text("₹${totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name on Card'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter name on card';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _cardNumberController,
          decoration: const InputDecoration(labelText: 'Card Number'),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card number';
            }
            if (value.length < 16 || value.length > 16) {
              return 'Please enter a valid card number';
            }
            return null;
          },
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryDateController,
                decoration:
                    const InputDecoration(labelText: 'Expiry Date (MM/YY)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter expiry date';
                  }
                  if (value.length < 5 || value.length > 5) {
                    return 'Please enter a valid expiry date';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(labelText: 'CVV'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter CVV';
                  }
                  if (value.length < 3 || value.length > 3) {
                    return 'Please enter a valid CVV';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}