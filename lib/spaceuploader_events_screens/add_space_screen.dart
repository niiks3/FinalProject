import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import "dart:html" as html;
import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:project/views/login_signup_view.dart';

class AddSpaceScreen extends StatefulWidget {
  const AddSpaceScreen({super.key});

  @override
  _AddSpaceScreenState createState() => _AddSpaceScreenState();
}

class _AddSpaceScreenState extends State<AddSpaceScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startingBidController = TextEditingController();
  html.File? _imageFile;
  String? _imageFileName;
  io.File? _nativeImageFile;

  Future<void> _pickImage() async {
    print('Picking image...');
    if (kIsWeb) {
      html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();
      uploadInput.onChange.listen((e) {
        final files = uploadInput.files;
        if (files != null && files.isNotEmpty) {
          final file = files.first;
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);
          reader.onLoadEnd.listen((e) {
            setState(() {
              _imageFile = file;
              _imageFileName = file.name;
              print('Image selected: $_imageFileName');
            });
          });
        } else {
          print('No image selected.');
        }
      });
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _imageFileName = result.files.first.name;
          _nativeImageFile = io.File(result.files.first.path!);
          print('Image selected: $_imageFileName');
        });
      } else {
        print('No image selected.');
      }
    }
  }

  Future<void> _uploadSpace() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user is signed in.');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please sign in to upload a space'),
      ));
      Get.to(() => const LoginSignupView());
      return;
    }

    if (_imageFile == null && _nativeImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image')));
      return;
    }

    final imageName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = FirebaseStorage.instance.ref().child('spaces/$imageName');

    try {
      String imageUrl;
      if (kIsWeb) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(_imageFile!);
        await reader.onLoadEnd.first;
        final data = reader.result as Uint8List;
        print('Uploading image data (Web): ${data.length} bytes');
        final uploadTask = await storageRef.putData(data);
        imageUrl = await uploadTask.ref.getDownloadURL();
        print('Image uploaded (Web): $imageUrl');
        await _saveSpaceToFirestore(imageUrl);
      } else {
        print('Uploading image file (Mobile/Desktop)...');
        final uploadTask = await storageRef.putFile(_nativeImageFile!);
        imageUrl = await uploadTask.ref.getDownloadURL();
        print('Image uploaded (Mobile/Desktop): $imageUrl');
        await _saveSpaceToFirestore(imageUrl);
      }
    } catch (e) {
      print('Upload failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  Future<void> _saveSpaceToFirestore(String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      print('Saving space details to Firestore...');
      await FirebaseFirestore.instance.collection('spaces').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'imageUrl': imageUrl,
        'startTime': Timestamp.now(),
        'endTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
        'startingBid': double.parse(_startingBidController.text),
        'highestBid': {
          'bidderId': null,
          'amount': 0.0,
        },
        'createdBy': user!.uid,
      });
      print('Space details saved to Firestore');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Space uploaded successfully')));
      Navigator.pop(context);
    } catch (e) {
      print('Failed to save space details: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save space details: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Space')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _startingBidController,
                decoration: const InputDecoration(labelText: 'Starting Bid'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _imageFileName == null
                  ? const Text('No image selected.')
                  : Text(_imageFileName!),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              ElevatedButton(
                onPressed: _uploadSpace,
                child: const Text('Upload Space'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
