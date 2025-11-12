import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient_info.dart';

/// Service for storing and retrieving patient analysis history
class HistoryStorageService {
  static const String _historyKey = 'analysis_history';
  static const int _maxHistoryItems = 50; // Limit history to 50 items

  /// Save a new analysis to history
  static Future<void> saveAnalysis({
    required PatientInfo patientInfo,
    required Map<String, dynamic> analysisResults,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing history
      final historyList = await getHistory();
      
      // Create new history record
      final newRecord = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'patientInfo': patientInfo.toJson(),
        'analysisResults': {
          'probability': analysisResults['probability'],
          'riskLevel': analysisResults['riskLevel'],
          'confidence': analysisResults['confidence'],
          'classification': analysisResults['classification'],
          'urgency_level': analysisResults['urgency_level'],
          'recommendations': analysisResults['recommendations'],
          'affected_regions': analysisResults['affected_regions'],
          'heatmap_explanation': analysisResults['heatmap_explanation'],
          'heatmap': analysisResults['heatmap'], // Base64 heatmap overlay
        },
      };
      
      // Add to beginning of list (most recent first)
      historyList.insert(0, newRecord);
      
      // Limit to max items
      if (historyList.length > _maxHistoryItems) {
        historyList.removeRange(_maxHistoryItems, historyList.length);
      }
      
      // Save to SharedPreferences
      final jsonString = jsonEncode(historyList);
      await prefs.setString(_historyKey, jsonString);
    } catch (e) {
      throw Exception('Failed to save analysis: $e');
    }
  }

  /// Get all history records
  static Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_historyKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to load history: $e');
    }
  }

  /// Delete a specific analysis by ID
  static Future<void> deleteAnalysis(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyList = await getHistory();
      
      // Remove the record with matching ID
      historyList.removeWhere((record) => record['id'] == id);
      
      // Save updated list
      final jsonString = jsonEncode(historyList);
      await prefs.setString(_historyKey, jsonString);
    } catch (e) {
      throw Exception('Failed to delete analysis: $e');
    }
  }

  /// Clear all history
  static Future<void> clearAllHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      throw Exception('Failed to clear history: $e');
    }
  }

  /// Get history count
  static Future<int> getHistoryCount() async {
    final historyList = await getHistory();
    return historyList.length;
  }

  /// Get history for a specific patient by name
  static Future<List<Map<String, dynamic>>> getHistoryByPatientName(String name) async {
    final historyList = await getHistory();
    return historyList.where((record) {
      final patientInfo = record['patientInfo'] as Map<String, dynamic>;
      return patientInfo['name'].toString().toLowerCase() == name.toLowerCase();
    }).toList();
  }

  /// Get recent history (last N items)
  static Future<List<Map<String, dynamic>>> getRecentHistory(int count) async {
    final historyList = await getHistory();
    return historyList.take(count).toList();
  }

  /// Export history as JSON string
  static Future<String> exportHistoryAsJson() async {
    final historyList = await getHistory();
    return jsonEncode(historyList);
  }

  /// Import history from JSON string
  static Future<void> importHistoryFromJson(String jsonString) async {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final historyList = jsonList.cast<Map<String, dynamic>>();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_historyKey, jsonEncode(historyList));
    } catch (e) {
      throw Exception('Failed to import history: $e');
    }
  }
}
