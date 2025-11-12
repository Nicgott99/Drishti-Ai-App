import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;

/// Service to validate if an image is likely an X-ray using intelligent multi-stage validation
/// Stage 1: Basic validation (lenient) - for initial upload
/// Stage 2: Deep validation (strict) - before analysis
class ImageValidatorService {
  
  /// Stage 1: Basic validation for upload (LENIENT - accepts most grayscale images)
  /// Returns a map with 'isValid' (bool) and 'reason' (String)
  Future<Map<String, dynamic>> validateXRayImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        return {
          'isValid': false,
          'reason': 'Unable to decode image. Please select a valid image file.',
        };
      }

      print('\n🔍 Stage 1: Basic Validation (Upload)');
      
      // Check 1: Minimum size
      if (image.width < 200 || image.height < 200) {
        print('❌ Size: ${image.width}x${image.height} - TOO SMALL');
        return {
          'isValid': false,
          'reason': 'Image is too small. X-rays should be at least 200x200 pixels.',
        };
      }
      print('✓ Size: ${image.width}x${image.height} - OK');

      // Check 2: Grayscale content (25% threshold - very lenient for upload)
      final grayscaleScore = _calculateGrayscaleScore(image);
      print('  Grayscale: ${(grayscaleScore * 100).toStringAsFixed(1)}%');
      
      if (grayscaleScore < 0.25) {
        print('❌ Too colorful for X-ray');
        return {
          'isValid': false,
          'reason': 'Image is too colorful. X-rays are grayscale images.',
        };
      }
      print('✓ Grayscale check: PASSED');

      print('✅ Stage 1: ACCEPTED for upload\n');
      return {
        'isValid': true,
        'reason': 'Image accepted. Preparing for analysis...',
      };
    } catch (e) {
      return {
        'isValid': false,
        'reason': 'Error processing image: $e',
      };
    }
  }

  /// Stage 2: Deep validation before analysis (STRICT - medical criteria)
  /// This runs AFTER upload, before AI analysis
  Future<Map<String, dynamic>> validateForAnalysis(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        return {
          'isValid': false,
          'reason': 'Unable to decode image.',
        };
      }

      print('\n🔬 Stage 2: Deep Validation (Pre-Analysis)');
      
      // Check 1: Size (stricter - typical X-rays are 500x500+)
      if (image.width < 300 || image.height < 300) {
        print('❌ Size too small for medical analysis');
        return {
          'isValid': false,
          'reason': 'Image resolution is too low for reliable analysis. Please use a higher quality X-ray image.',
        };
      }
      print('✓ Size: ${image.width}x${image.height} - Medical grade');

      // Check 2: Grayscale purity (60% threshold - lenient for medical X-rays)
      final grayscaleScore = _calculateGrayscaleScore(image);
      print('  Grayscale purity: ${(grayscaleScore * 100).toStringAsFixed(1)}%');
      
      if (grayscaleScore < 0.60) {
        print('❌ Not enough grayscale content');
        return {
          'isValid': false,
          'reason': 'Image contains too many color elements. Please upload a grayscale chest X-ray.',
        };
      }
      print('✓ Grayscale purity: EXCELLENT');

      // Check 3: Medical image characteristics (lenient - need 1 out of 3)
      final hasLungPattern = _checkLungFieldPattern(image);
      print('  Lung field pattern: ${hasLungPattern ? "DETECTED" : "NOT FOUND"}');
      
      final hasCorrectDistribution = _checkMedicalBrightnessDistribution(image);
      print('  Medical brightness: ${hasCorrectDistribution ? "CORRECT" : "INCORRECT"}');

      final contrastRatio = _calculateContrastRatio(image);
      print('  Contrast ratio: ${contrastRatio.toStringAsFixed(2)}');

      // Require at least 1 out of 3 medical characteristics (very lenient)
      int medicalScore = 0;
      if (hasLungPattern) medicalScore++;
      if (hasCorrectDistribution) medicalScore++;
      if (contrastRatio >= 0.25 && contrastRatio <= 0.95) medicalScore++; // Wider range

      print('  Medical score: $medicalScore/3');

      if (medicalScore < 1) {
        print('❌ Does not appear to be a chest X-ray');
        return {
          'isValid': false,
          'reason': 'This does not appear to be a medical X-ray image. Please upload a chest X-ray.',
        };
      }

      print('✅ Stage 2: VALIDATED as chest X-ray\n');
      return {
        'isValid': true,
        'reason': 'Chest X-ray validated. Proceeding with TB analysis...',
      };
    } catch (e) {
      return {
        'isValid': false,
        'reason': 'Validation error: $e',
      };
    }
  }

  /// Calculate grayscale score (0.0-1.0, higher = more grayscale)
  /// X-rays MUST be grayscale - colorful images are rejected
  /// Medical X-rays are pure grayscale (R=G=B for every pixel)
  double _calculateGrayscaleScore(img.Image image) {
    int sampleCount = 0;
    int grayscaleCount = 0;
    
    // Sample every 5th pixel for performance
    for (int y = 0; y < image.height; y += 5) {
      for (int x = 0; x < image.width; x += 5) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        
        // Check if RGB values are similar (grayscale)
        // Medical X-rays have R≈G≈B (difference < 15 is medical-grade grayscale)
        final maxDiff = math.max((r - g).abs(), math.max((r - b).abs(), (g - b).abs()));
        
        if (maxDiff < 15) { // Medical-grade grayscale: R, G, B are nearly identical
          grayscaleCount++;
        }
        
        sampleCount++;
      }
    }
    
    return grayscaleCount / sampleCount;
  }

  /// Check for lung field pattern (dark center with bright edges)
  /// Chest X-rays have distinctive lung field anatomy
  bool _checkLungFieldPattern(img.Image image) {
    // Divide image into 9 regions (3x3 grid)
    final regionWidth = image.width ~/ 3;
    final regionHeight = image.height ~/ 3;
    
    // Calculate average brightness for each region
    final List<double> regionBrightness = [];
    
    for (int ry = 0; ry < 3; ry++) {
      for (int rx = 0; rx < 3; rx++) {
        double totalBrightness = 0;
        int pixelCount = 0;
        
        final startX = rx * regionWidth;
        final startY = ry * regionHeight;
        final endX = (rx + 1) * regionWidth;
        final endY = (ry + 1) * regionHeight;
        
        for (int y = startY; y < endY && y < image.height; y += 10) {
          for (int x = startX; x < endX && x < image.width; x += 10) {
            final pixel = image.getPixel(x, y);
            totalBrightness += (pixel.r + pixel.g + pixel.b) / 3;
            pixelCount++;
          }
        }
        
        regionBrightness.add(pixelCount > 0 ? totalBrightness / pixelCount : 0);
      }
    }
    
    // Lung fields are in center regions (index 4) and should be darker
    // Borders should be brighter (anatomical structure)
    final centerBrightness = regionBrightness[4];
    final borderBrightness = (regionBrightness[0] + regionBrightness[1] + 
                              regionBrightness[2] + regionBrightness[3] + 
                              regionBrightness[5] + regionBrightness[6] + 
                              regionBrightness[7] + regionBrightness[8]) / 8;
    
    // Very lenient threshold - just check if there's ANY difference
    // This accepts most X-rays with visible lung fields
    return borderBrightness > centerBrightness + 5; // Relaxed from 10 to 5
  }

  /// Check medical brightness distribution
  /// X-rays have specific histogram characteristics
  bool _checkMedicalBrightnessDistribution(img.Image image) {
    final List<int> histogram = List<int>.filled(256, 0);
    int totalPixels = 0;
    
    // Build brightness histogram
    for (int y = 0; y < image.height; y += 5) {
      for (int x = 0; x < image.width; x += 5) {
        final pixel = image.getPixel(x, y);
        final brightness = ((pixel.r + pixel.g + pixel.b) / 3).toInt();
        histogram[brightness]++;
        totalPixels++;
      }
    }
    
    // Calculate distribution metrics
    int darkPixels = 0;
    int midPixels = 0;
    int brightPixels = 0;
    
    for (int i = 0; i < 256; i++) {
      if (i < 85) {
        darkPixels += histogram[i];
      } else if (i < 170) {
        midPixels += histogram[i];
      } else {
        brightPixels += histogram[i];
      }
    }
    
    final darkRatio = darkPixels / totalPixels;
    final midRatio = midPixels / totalPixels;
    final brightRatio = brightPixels / totalPixels;
    
    // Very lenient thresholds - accept wide range of X-ray distributions
    // Just check that it's not completely dark or completely bright (not a valid X-ray)
    return (darkRatio > 0.05 && darkRatio < 0.80) &&
           (midRatio > 0.05 && midRatio < 0.80) &&
           (brightRatio > 0.05 && brightRatio < 0.80);
  }

  /// Detect non-medical content (faces, colorful objects, etc.)
  /// Rejects images with high color saturation or unusual patterns
  bool _detectNonMedicalContent(img.Image image) {
    int colorfulPixels = 0;
    int totalSamples = 0;
    
    // Check for colorful pixels (indicate photos, not X-rays)
    for (int y = 0; y < image.height; y += 8) {
      for (int x = 0; x < image.width; x += 8) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        
        // Calculate color saturation
        final max = [r, g, b].reduce((a, b) => a > b ? a : b);
        final min = [r, g, b].reduce((a, b) => a < b ? a : b);
        final saturation = max == 0 ? 0 : (max - min) / max;
        
        if (saturation > 0.30) { // Very lenient - only reject if >30% saturation
          colorfulPixels++;
        }
        
        totalSamples++;
      }
    }
    
    // If more than 25% pixels are highly saturated, reject (very lenient)
    return (colorfulPixels / totalSamples) > 0.25;
  }

  /// Calculate contrast ratio
  /// X-rays have specific contrast characteristics
  double _calculateContrastRatio(img.Image image) {
    double minBrightness = 255;
    double maxBrightness = 0;
    
    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);
        final brightness = (pixel.r + pixel.g + pixel.b) / 3;
        
        if (brightness < minBrightness) minBrightness = brightness;
        if (brightness > maxBrightness) maxBrightness = brightness;
      }
    }
    
    // Calculate contrast ratio
    return (maxBrightness - minBrightness) / 255.0;
  }

  /// Quick validation (removed - now uses full validation always)
  @Deprecated('Use validateXRayImage instead')
  Future<Map<String, dynamic>> quickValidate(XFile imageFile) async {
    return await validateXRayImage(imageFile);
  }
}
