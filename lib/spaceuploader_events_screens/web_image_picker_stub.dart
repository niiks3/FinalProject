// web_image_picker_stub.dart

import 'dart:typed_data';

class WebImagePicker {
  Future<List<dynamic>> pickImages() async {
    // This will never be called in non-web environments
    throw UnsupportedError('Cannot pick images on non-web platforms');
  }

  Future<Uint8List> getFileData(dynamic file) async {
    // This will never be called in non-web environments
    throw UnsupportedError('Cannot get file data on non-web platforms');
  }

  String createObjectUrlFromBlob(dynamic file) {
    // This will never be called in non-web environments
    throw UnsupportedError('Cannot create object URL on non-web platforms');
  }
}
