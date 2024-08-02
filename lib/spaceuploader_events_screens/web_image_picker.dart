
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:async';

class WebImagePicker {
  List<html.File> _webImageFiles = [];

  Future<List<html.File>> pickImages() async {
    final completer = Completer<List<html.File>>();
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.multiple = true;
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        _webImageFiles = files.cast<html.File>();
        completer.complete(_webImageFiles);
      } else {
        completer.completeError('No files selected');
      }
    });

    return completer.future;
  }

  Future<Uint8List> getFileData(html.File file) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoadEnd.first;
    return reader.result as Uint8List;
  }

  String createObjectUrlFromBlob(html.File file) {
    return html.Url.createObjectUrlFromBlob(file);
  }
}
