import 'package:flutter/material.dart';
import 'form_button.dart';

class CongratulationsScreen extends StatefulWidget {
  final Function() continueAction;
  final Map<String, dynamic> carDetails;

  const CongratulationsScreen({
    Key? key,
    required this.continueAction,
    required this.carDetails,
  }) : super(key: key);

  @override
  CongratulationsScreenState createState() => CongratulationsScreenState();
}

class CongratulationsScreenState extends State<CongratulationsScreen> {
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
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
             'Your Car ${widget.carDetails['carBrand'] ?? 'N/A'} ${widget.carDetails['carModel'] ?? 'N/A'} ${widget.carDetails['CarRegistrationNumber'] ?? 'N/A'} is Now Ready to Earn with Urban Drives.',
                style: const TextStyle(fontSize: 16),
            ),
            SizedBox(height: screenHeight * 0.02),
            const Text(
              'Terms & Conditions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.02),
           Expanded(
              child: SingleChildScrollView(
               child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                   const Text(
                     "By adding your car to the Urban Drives platform:",
                     textAlign: TextAlign.start,
                   ),
                       const SizedBox(height: 8),
                        ..._buildTermsList(),
                     const SizedBox(height: 10),
                    const Text(
                      "Please review the full Terms & Conditions for more details.",
                      textAlign: TextAlign.start,
                    ),
                 ],
               ),
              ),
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
                  child: Text('I agree to the Terms & Conditions'),
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
    List<Widget> _buildTermsList() {
        final terms = [
          "You agree to make your car available for rent.",
          "You agree to maintain your car in safe and working condition.",
          "You agree to provide all requested documents to Urban Drives.",
          "You agree to follow the policies established by the Urban Drives platform.",
          "You are responsible for providing accurate vehicle details.",
          "You are responsible for setting appropriate rental fees and terms.",
          "You will follow all applicable laws.",
        ];

      return terms.map((term) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const Text('•', style: TextStyle(fontSize: 16)),
           const SizedBox(width: 5),
           Expanded(child: Text(term, textAlign: TextAlign.start)),
         ],
       )).toList();
    }
}