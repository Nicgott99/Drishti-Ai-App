/// Web-Specific Model Service (Browser only - Backend API)
/// This file is ONLY imported on web platform
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ModelService {
  bool _isServerHealthy = false;
  static const String _backendUrl = 'http://localhost:5000';

  ModelService() {
    debugPrint("🌐 WEB ModelService initialized");
    _checkServerHealth();
  }

  /// Check if backend server is available
  Future<void> _checkServerHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/health'),
      ).timeout(const Duration(seconds: 3));
      
      _isServerHealthy = response.statusCode == 200;
      if (_isServerHealthy) {
        debugPrint("✅ Backend server is healthy");
      } else {
        debugPrint("⚠️ Backend server returned: ${response.statusCode}");
      }
    } catch (e) {
      _isServerHealthy = false;
      debugPrint("⚠️ Backend server not available: $e");
    }
  }

  /// Public method to check server health (for scan_method_screen compatibility)
  Future<bool> checkServerHealth() async {
    await _checkServerHealth();
    return _isServerHealthy;
  }

  /// Main inference method - ALWAYS uses backend API on web
  Future<Map<String, dynamic>> runInference(
    XFile image, {
    bool generateHeatmap = true,
  }) async {
    debugPrint("🌐 Running WEB inference (Backend API only)");
    
    if (!_isServerHealthy) {
      // Try to reconnect
      await _checkServerHealth();
      
      if (!_isServerHealthy) {
        throw Exception(
          'Backend server is not available. '
          'Please ensure the Flask server is running on $backendUrl'
        );
      }
    }

    return await _runOnlineInference(image, generateHeatmap: generateHeatmap);
  }

  /// Run ONLINE inference with Backend API
  Future<Map<String, dynamic>> _runOnlineInference(
    XFile imageFile, {
    bool generateHeatmap = true,
  }) async {
    try {
      debugPrint("📡 Sending request to backend...");
      
      final bytes = await imageFile.readAsBytes();
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_backendUrl/predict'),
      );
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'xray.jpg',
        ),
      );
      
      request.fields['generate_heatmap'] = generateHeatmap.toString();

      debugPrint("📤 Uploading image (${bytes.length} bytes)...");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        debugPrint("✅ Backend response received");
        final result = json.decode(response.body) as Map<String, dynamic>;
        result['device_used'] = 'Backend API (Web)';
        return result;
      } else {
        debugPrint("❌ Backend error: ${response.statusCode}");
        throw Exception(
          'Backend API error: ${response.statusCode}\n${response.body}'
        );
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Online inference failed: $e");
      debugPrint("Stack trace: $stackTrace");
      throw Exception('Online inference failed: $e');
    }
  }

  // Web platform does NOT support offline mode
  bool get isOfflineModelAvailable => false;
  bool get isBackendAvailable => _isServerHealthy;
  String get backendUrl => _backendUrl;
}
