import 'package:flutter/material.dart';

import '../addcarform/form_button.dart';

class UpdateCongratulationsScreen extends StatefulWidget {
  final Function() continueAction;
  final Map<String, dynamic> carDetails;

  const UpdateCongratulationsScreen({
    super.key,
    required this.continueAction,
    required this.carDetails,
  });

  @override
  UpdateCongratulationsScreenState createState() =>
      UpdateCongratulationsScreenState();
}

class UpdateCongratulationsScreenState
    extends State<UpdateCongratulationsScreen> {
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      // Added Scaffold here
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                const Icon(
                  Icons.edit_note,
                  color: Colors.blue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: const Text(
                    'Congratulation!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
                'Your Car ${widget.carDetails['carBrand'] ?? 'N/A'} ${widget.carDetails['carModel'] ?? 'N/A'} ${widget.carDetails['CarRegistrationNumber'] ?? 'N/A'} is now eligible to get bookings',
                style: const TextStyle(fontSize: 16)),
            SizedBox(height: screenHeight * 0.02),
            const Text(
              'Terms & Conditions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.02),
            const Expanded(
              child: Text(
                  "By adding your car to this platform you agree to allow your car to be available for rent, to maintain your car in working condition, to provide the documents requested by the platform, and to follow the policies established by the platform."),
            ),
            Row(
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreedToTerms = value!;
                    });
                  },
                ),
                const Expanded(
                  child: Text('I agree to the terms and conditions'),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            SizedBox(
              width: double.infinity,
              child: FormButton(
                onPressed: _agreedToTerms
                    ? () {
                        widget.continueAction();
                      }
                    : null,
                label: 'Continue',
              ),
            )
          ],
        ),
      ),
    );
  }
}
