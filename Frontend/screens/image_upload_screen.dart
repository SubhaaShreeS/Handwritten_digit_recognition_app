import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key});

  @override
  State<ImageUploadScreen> createState() => ImageUploadScreenState();
}

class ImageUploadScreenState extends State<ImageUploadScreen> {
  File? selectedImage;
  String prediction = '';

  Future<void> pickImageFromGallery() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File file = File(image.path);
      String result = await ApiService.predictDigit(file);
      setState(() {
        selectedImage = file;
        prediction = result;
      });
    }
  }

  Future<void> captureImageFromCamera() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      File file = File(image.path);
      String result = await ApiService.predictDigit(file);
      setState(() {
        selectedImage = file;
        prediction = result;
      });
    }
  }

  Widget buildImageView() {
    if (selectedImage != null) {
      return Image.file(selectedImage!, width: 200, height: 200);
    }

    return Container(
      width: 200,
      height: 200,
      color: Colors.grey[300],
      child: Center(child: Text('No image')),
    );
  }

  Widget buildButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: pickImageFromGallery,
          child: Text('Pick from Gallery'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: captureImageFromCamera,
          child: Text('Capture from Camera'),
        ),
        SizedBox(height: 20),
        Text('Prediction: $prediction'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Digit Image')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildImageView(),
            SizedBox(height: 20),
            buildButtons(),
          ],
        ),
      ),
    );
  }
}
