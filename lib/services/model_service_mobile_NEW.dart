/// Mobile-Specific Model Service (Android/iOS) - USES REAL BACKEND API
/// This version connects to Flask backend for accurate TB predictions
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ModelService {
  bool _isInitialized = false;
  bool _isServerHealthy = false;
  
  // Backend URL - use 10.0.2.2 for Android emulator, localhost for real device
  static const String _backendUrl = 'http://10.0.2.2:5000';
  
  /// Progress callback for UI updates
  Function(String, double)? onProgress;

  /// Helper to update progress
  void _updateProgress(String message, double progress) {
    debugPrint("📊 Progress: ${(progress * 100).toStringAsFixed(0)}% - $message");
    if (onProgress != null) {
      onProgress!(message, progress);
    }
  }
  
  /// Initialize service and check backend
  Future<void> initialize() async {
    debugPrint("✓ Initializing Mobile Model Service (BACKEND API MODE)...");
    await _checkServerHealth();
    _isInitialized = true;
    debugPrint("✓ Mobile service ready! Backend available: $_isServerHealthy");
  }

  /// Check if backend server is available
  Future<void> _checkServerHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/health'),
      ).timeout(const Duration(seconds: 3));
      
      _isServerHealthy = response.statusCode == 200;
      if (_isServerHealthy) {
        debugPrint("✅ Backend server is HEALTHY and ready for predictions");
      } else {
        debugPrint("⚠️ Backend returned: ${response.statusCode}");
      }
    } catch (e) {
      _isServerHealthy = false;
      debugPrint("⚠️ Backend server not available: $e");
      debugPrint("📝 Start backend: cd Drishti-AI-mobile_app && python backend/server.py");
    }
  }

  /// Public health check method
  Future<bool> checkServerHealth() async {
    await _checkServerHealth();
    return _isServerHealthy;
  }

  /// Main inference - uses REAL AI model via backend API
  Future<Map<String, dynamic>> runInference(
    XFile imageFile, {
    bool generateHeatmap = true,
  }) async {
    debugPrint("🔍 Running REAL AI inference with backend API...");
    
    // Verify backend is available
    if (!_isServerHealthy) {
      await _checkServerHealth();
      
      if (!_isServerHealthy) {
        throw Exception(
          'Backend server is not available.\n\n'
          'Please start the Flask server:\n'
          'cd Drishti-AI-mobile_app/backend\n'
          'python server.py\n\n'
          'Backend URL: $_backendUrl'
        );
      }
    }
    
    try {
      // Stage 1: Load image (0-10%)
      _updateProgress("Loading image...", 0.0);
      await Future.delayed(Duration(seconds: 2));
      final bytes = await imageFile.readAsBytes();
      _updateProgress("Image loaded", 0.10);
      
      // Stage 2: Upload to server (10-20%)
      _updateProgress("Uploading to AI server...", 0.10);
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_backendUrl/predict'),
      );
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',  // Backend expects 'image' field
          bytes,
          filename: 'xray.jpg',
        ),
      );
      
      request.fields['generate_heatmap'] = generateHeatmap.toString();

      debugPrint("📤 Uploading ${bytes.length} bytes...");
      _updateProgress("Waiting for AI analysis...", 0.20);
      
      // Send request (backend takes ~35 seconds total)
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Request timed out after 60 seconds');
        },
      );
      
      // Stage 3: Simulate backend processing (20-90%)
      // Backend does: preprocessing (5s) + inference (15s) + heatmap (15s)
      for (double progress = 0.20; progress < 0.90; progress += 0.05) {
        await Future.delayed(Duration(milliseconds: 1500));
        
        if (progress < 0.35) {
          _updateProgress("Preprocessing X-ray image...", progress);
        } else if (progress < 0.60) {
          _updateProgress("Running EfficientNetV2 model...", progress);
        } else {
          _updateProgress("Generating Grad-CAM++ heatmap...", progress);
        }
      }
      
      // Stage 4: Receive results (90-100%)
      _updateProgress("Receiving results...", 0.90);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        debugPrint("✅ Backend response received successfully");
        _updateProgress("Processing results...", 0.95);
        
        final result = json.decode(response.body) as Map<String, dynamic>;
        
        // Add metadata
        result['device_used'] = 'EfficientNetV2 Deep Learning Model (Backend API)';
        result['model_version'] = 'v3_anti_artifact_512_10pct';
        
        _updateProgress("Analysis complete!", 1.0);
        
        final probability = result['probability'] ?? 0.0;
        final classification = result['classification'] ?? 'Unknown';
        
        debugPrint("✓ REAL AI analysis completed");
        debugPrint("📊 TB Probability: ${(probability * 100).toStringAsFixed(1)}%");
        debugPrint("🏷️ Classification: $classification");
        
        return result;
        
      } else {
        debugPrint("❌ Backend returned error: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
        throw Exception('Backend error ${response.statusCode}: ${response.body}');
      }
      
    } catch (e, stackTrace) {
      debugPrint("❌ Inference failed: $e");
      debugPrint("Stack trace: $stackTrace");
      
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection refused')) {
        throw Exception(
          'Cannot connect to backend server.\n\n'
          'Please start Flask server:\n'
          'cd Drishti-AI-mobile_app/backend\n'
          'python server.py'
        );
      }
      
      throw Exception('Inference failed: $e');
    }
  }
}
