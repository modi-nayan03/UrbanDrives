import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadLicenseScreen extends StatefulWidget {
  final String carModel;
  final double rentalCostPerHour;
  final double driverCostPerHour;
  final DateTime? initialPickupDate;
  final DateTime? initialReturnDate;
  final String carRegNum;

  const UploadLicenseScreen({
    super.key,
    required this.carModel,
    required this.rentalCostPerHour,
    required this.driverCostPerHour,
    this.initialPickupDate,
    this.initialReturnDate,
    required this.carRegNum,
  });

  @override
  UploadLicenseScreenState createState() => UploadLicenseScreenState();
}

class UploadLicenseScreenState extends State<UploadLicenseScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _frontImage;
  XFile? _backImage;

  Future<void> _pickImage(bool isFront) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  _getImage(isFront, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  _getImage(isFront, ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(bool isFront, ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      setState(() {
        if (pickedFile != null) {
          if (isFront) {
            _frontImage = pickedFile;
          } else {
            _backImage = pickedFile;
          }
        } else {
          print('No image selected.');
        }
      });
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _continueToNextScreen() {
    if (_frontImage == null || _backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please upload license front and back images")),
      );
      return;
    }
    // Navigate back with the images
    Navigator.of(context).pop({
      'frontImage': _frontImage,
      'backImage': _backImage,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Your License'),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildLicenseUploadCard(
              onTap: () => _pickImage(true),
              image: _frontImage,
              side: 'Upload Front-side License',
            ),
            const SizedBox(height: 15),
            _buildLicenseUploadCard(
              onTap: () => _pickImage(false),
              image: _backImage,
              side: 'Upload Back-side License',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _continueToNextScreen,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseUploadCard({
    required VoidCallback onTap,
    required XFile? image,
    required String side,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Colors.grey.shade400,
              width: 0.5,
              style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(side,
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
            if (image != null)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.green),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              )
            else
              Icon(Icons.cloud_upload_outlined,
                  size: 24, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}