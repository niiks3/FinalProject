import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:project/views/login_signup_view.dart';

import 'web_image_picker_stub.dart' if (dart.library.html) 'web_image_picker.dart';

class AddSpaceScreen extends StatefulWidget {
  const AddSpaceScreen({super.key});

  @override
  _AddSpaceScreenState createState() => _AddSpaceScreenState();
}

class _AddSpaceScreenState extends State<AddSpaceScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startingBidController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  List<dynamic> _imageFiles = [];
  List<String> _imageFileNames = [];
  List<double> _uploadProgress = [];

  Future<void> _pickImages() async {
    if (kIsWeb) {
      final webPicker = WebImagePicker();
      _imageFiles = await webPicker.pickImages();
      setState(() {
        _imageFileNames = _imageFiles.map((file) => file.name).whereType<String>().toList();
        _uploadProgress = List.filled(_imageFiles.length, 0.0);
      });
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _imageFiles = result.paths.map((path) => io.File(path!)).toList();
          _imageFileNames = result.names.whereType<String>().toList();
          _uploadProgress = List.filled(result.paths.length, 0.0);
        });
      }
    }
  }

  Future<void> _uploadSpace() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please sign in to upload a space'),
      ));
      Get.to(() => const LoginSignupView());
      return;
    }

    if (_imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select images')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Uploading...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._imageFileNames.map((name) {
                int index = _imageFileNames.indexOf(name);
                return Column(
                  children: [
                    Text(name),
                    LinearProgressIndicator(
                      value: _uploadProgress[index] / 100,
                      minHeight: 5,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ],
          ),
        );
      },
    );

    final List<String> imageUrls = [];
    try {
      for (int i = 0; i < _imageFileNames.length; i++) {
        final imageName = DateTime.now().millisecondsSinceEpoch.toString();
        final storageRef = FirebaseStorage.instance.ref().child('spaces/$imageName');

        if (kIsWeb) {
          final webPicker = WebImagePicker();
          final data = await webPicker.getFileData(_imageFiles[i]);
          final uploadTask = storageRef.putData(data);
          uploadTask.snapshotEvents.listen((event) {
            setState(() {
              _uploadProgress[i] = (event.bytesTransferred.toDouble() / event.totalBytes.toDouble()) * 100;
            });
          });
          final snapshot = await uploadTask;
          final imageUrl = await snapshot.ref.getDownloadURL();
          imageUrls.add(imageUrl);
        } else {
          final uploadTask = storageRef.putFile(_imageFiles[i] as io.File);
          uploadTask.snapshotEvents.listen((event) {
            setState(() {
              _uploadProgress[i] = (event.bytesTransferred.toDouble() / event.totalBytes.toDouble()) * 100;
            });
          });
          final snapshot = await uploadTask;
          final imageUrl = await snapshot.ref.getDownloadURL();
          imageUrls.add(imageUrl);
        }
      }

      await _saveSpaceToFirestore(imageUrls);
      Navigator.of(context).pop(); // Close the upload progress dialog
    } catch (e) {
      Navigator.of(context).pop(); // Close the upload progress dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  Future<void> _saveSpaceToFirestore(List<String> imageUrls) async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      await FirebaseFirestore.instance.collection('spaces').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'imageUrls': imageUrls,
        'startTime': Timestamp.now(),
        'endTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
        'startingBid': double.parse(_startingBidController.text),
        'capacity': int.parse(_capacityController.text),
        'highestBid': {
          'bidderId': null,
          'amount': 0.0,
        },
        'createdBy': user!.uid,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Space uploaded successfully')));
      Navigator.pop(context);
    } catch (e) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'File Upload',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_upload, size: 50),
                        const SizedBox(height: 10),
                        const Text('Drag and Drop or Browse'),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _imageFileNames.map((name) {
                  int index = _imageFileNames.indexOf(name);
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: kIsWeb
                                ? NetworkImage(WebImagePicker().createObjectUrlFromBlob(_imageFiles[index]))
                                : FileImage(_imageFiles[index] as io.File) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _imageFiles.removeAt(index);
                              _imageFileNames.removeAt(index);
                              _uploadProgress.removeAt(index);
                            });
                          },
                          child: const Icon(Icons.close, color: Colors.red),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
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
              TextField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: 'Capacity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _uploadSpace,
                    child: const Text('Publish'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
