import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

/// Service to handle image picking and processing
class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery and return XFile
  Future<XFile?> pickFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      return pickedFile;
    } catch (e) {
      print('Error picking image from gallery: $e');
      rethrow;
    }
  }

  /// Pick image from camera and return XFile
  Future<XFile?> pickFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      return pickedFile;
    } catch (e) {
      print('Error picking image from camera: $e');
      rethrow;
    }
  }

  /// Decode and resize image to 512x512 for model input
  Future<img.Image?> preprocessImage(Uint8List bytes) async {
    try {
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      // Resize to 512x512 (matches PyTorch model input size)
      img.Image resized = img.copyResize(
        image,
        width: 512,
        height: 512,
        interpolation: img.Interpolation.linear,
      );
      
      return resized;
    } catch (e) {
      print('Error preprocessing image: $e');
      return null;
    }
  }
}
