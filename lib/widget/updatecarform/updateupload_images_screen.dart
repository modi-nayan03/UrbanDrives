import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateUploadImagesScreen extends StatefulWidget {
  final VoidCallback onNext;
  final Function(Map<String, dynamic>) uploadCarDetails;
  final Map<String, dynamic> carData;


  const UpdateUploadImagesScreen(
      {super.key, required this.onNext, required this.uploadCarDetails, required this.carData});

  @override
  State<UpdateUploadImagesScreen> createState() =>
      _UpdateUploadImagesScreenState();
}

class _UpdateUploadImagesScreenState extends State<UpdateUploadImagesScreen> {
  Uint8List? _coverImageBytes;
  Uint8List? _exteriorImageBytes;
  Uint8List? _interiorImageBytes;
  final ImagePicker _picker = ImagePicker();
  String? _existingCoverImage;
  String? _existingExteriorImage;
  String? _existingInteriorImage;
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
     _loadExistingImages();
  }

   Future<void> _loadExistingImages() async {
    setState(() {
      _isLoading = true;
    });
    _existingCoverImage = widget.carData['coverImageBytes'];
     _existingExteriorImage = widget.carData['exteriorImageBytes'];
    _existingInteriorImage = widget.carData['interiorImageBytes'];

     if (_existingCoverImage != null) {
       _coverImageBytes = base64Decode(_existingCoverImage!);
     }
     if (_existingExteriorImage != null){
       _exteriorImageBytes = base64Decode(_existingExteriorImage!);
     }
      if (_existingInteriorImage != null){
       _interiorImageBytes = base64Decode(_existingInteriorImage!);
     }
    setState(() {
      _isLoading = false;
    });
  }



  Future<void> _pickImage(ImageSource source, String imageType) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        if (imageType == "cover") {
          _coverImageBytes = bytes;
           _existingCoverImage = null;
        } else if (imageType == "exterior") {
          _exteriorImageBytes = bytes;
          _existingExteriorImage = null;
        } else if (imageType == 'interior') {
          _interiorImageBytes = bytes;
          _existingInteriorImage = null;
        }
      });
    }
  }

  void _showImageSourceDialog(String imageType) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery, imageType);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera, imageType);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Car Images'),
        centerTitle: true,
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildUploadButton(
              'Upload Cover Image',
              _coverImageBytes != null || _existingCoverImage != null,
              'cover',
            ),
            const SizedBox(height: 15),
            _buildUploadButton(
                'Upload Exterior Image',
                _exteriorImageBytes != null || _existingExteriorImage != null,
                'exterior'),
            const SizedBox(height: 15),
            _buildUploadButton(
                'Upload Interior Image',
                _interiorImageBytes != null || _existingInteriorImage != null,
                'interior'),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                   String? coverImageBase64;
                   String? exteriorImageBase64;
                   String? interiorImageBase64;

                   if (_coverImageBytes != null) {
                     coverImageBase64 = base64Encode(_coverImageBytes!);
                    }else{
                     coverImageBase64 = _existingCoverImage;
                    }
                    if (_exteriorImageBytes != null) {
                      exteriorImageBase64 = base64Encode(_exteriorImageBytes!);
                    }else{
                      exteriorImageBase64 = _existingExteriorImage;
                    }
                    if (_interiorImageBytes != null) {
                       interiorImageBase64 = base64Encode(_interiorImageBytes!);
                    }else{
                      interiorImageBase64 = _existingInteriorImage;
                    }

                  widget.uploadCarDetails({
                    'coverImageBytes': coverImageBase64,
                    'exteriorImageBytes': exteriorImageBase64,
                    'interiorImageBytes': interiorImageBase64
                  });

                  widget.onNext();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Upload & Continue',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton(String text, bool imageUploaded, String imageType) {
    return GestureDetector(
      onTap: () {
        _showImageSourceDialog(imageType);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade400)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
            if (imageUploaded)
              const Icon(Icons.check_circle_outline, color: Colors.green)
            else
              Icon(Icons.cloud_upload_outlined, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}