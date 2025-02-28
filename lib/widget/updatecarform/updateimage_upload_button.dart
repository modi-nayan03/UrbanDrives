import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class UpdateImageUploadButton extends StatefulWidget {
  final String label;
  final Function(Uint8List? imageBytes, String? imageName) onImageSelected;
  final Uint8List? imageBytes; // Added for prefilling
  final String? imageName;
  const UpdateImageUploadButton(
      {super.key,
      required this.label,
      required this.onImageSelected,
      this.imageBytes,
      this.imageName});

  @override
  _UpdateImageUploadButtonState createState() =>
      _UpdateImageUploadButtonState();
}

class _UpdateImageUploadButtonState extends State<UpdateImageUploadButton> {
  Uint8List? _imageBytes;
  String? _imageName;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false; // Added loading state

  @override
  void initState() {
    super.initState();
    _imageBytes = widget.imageBytes;
    _imageName = widget.imageName;
  }

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true; // Set loading state
    });
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageName = pickedFile.name;
          widget.onImageSelected(_imageBytes, _imageName);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      // Handle errors, maybe show a snackbar to the user
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: GestureDetector(
        onTap: _isLoading ? null : _pickImage, // Disable tap while loading
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading) // Show loading indicator
                const SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(),
                )
              else if (_imageBytes != null)
                SizedBox(
                    width: 30,
                    height: 30,
                    child: Image.memory(
                      _imageBytes!,
                      fit: BoxFit.cover,
                    ))
              else
                const Icon(
                  Icons.add_photo_alternate,
                  size: 30,
                ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: const TextStyle(fontSize: 16),
              )
            ],
          ),
        ),
      ),
    );
  }
}
