import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/history_storage_service.dart';
import '../providers/language_provider.dart';
import '../models/patient_info.dart';
import '../widgets/floating_chat_widget.dart';
import 'results_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final history = await HistoryStorageService.getHistory();
      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(String id, bool isBangla) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBangla ? 'মুছে ফেলার নিশ্চিত করুন' : 'Confirm Delete'),
        content: Text(isBangla
            ? 'আপনি কি এই বিশ্লেষণ মুছে ফেলতে চান?'
            : 'Are you sure you want to delete this analysis?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isBangla ? 'বাতিল' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(isBangla ? 'মুছে ফেলুন' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await HistoryStorageService.deleteAnalysis(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isBangla ? 'মুছে ফেলা হয়েছে' : 'Deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadHistory(); // Reload history
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isBangla ? 'ত্রুটি: ${e.toString()}' : 'Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearAllHistory(bool isBangla) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBangla ? 'সব মুছে ফেলার নিশ্চিত করুন' : 'Clear All History'),
        content: Text(isBangla
            ? 'আপনি কি সমস্ত ইতিহাস মুছে ফেলতে চান? এটি পূর্বাবস্থায় ফিরিয়ে আনা যাবে না।'
            : 'Are you sure you want to clear all history? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isBangla ? 'বাতিল' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(isBangla ? 'সব মুছে ফেলুন' : 'Clear All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await HistoryStorageService.clearAllHistory();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isBangla ? 'সব ইতিহাস মুছে ফেলা হয়েছে' : 'All history cleared'),
            backgroundColor: Colors.green,
          ),
        );
        _loadHistory(); // Reload history
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isBangla ? 'ত্রুটি: ${e.toString()}' : 'Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewDetails(Map<String, dynamic> record) {
    try {
      // Extract data from record
      final patientInfoMap = record['patientInfo'] as Map<String, dynamic>;
      final analysisResults = record['analysisResults'] as Map<String, dynamic>;

      // Create PatientInfo object
      final patientInfo = PatientInfo.fromJson(patientInfoMap);

      // Navigate to ResultsScreen
      // Note: We don't have the original image file, so we'll pass a dummy XFile
      // The results screen can work without the image since we have heatmap
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            imageFile: XFile(''),  // Empty file path
            analysisResult: analysisResults,
            patientInfo: patientInfo,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isBangla = languageProvider.currentLocale.languageCode == 'bn';

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A237E), // Deep blue
                  Color(0xFF0D47A1), // Blue
                  Color(0xFF01579B), // Light blue
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(isBangla),

                // History list or empty state
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState(isBangla)
                      : _errorMessage != null
                          ? _buildErrorState(isBangla)
                          : _history.isEmpty
                              ? _buildEmptyState(isBangla)
                              : _buildHistoryList(isBangla),
                ),
              ],
            ),
          ),

          // Floating chat widget
          const FloatingChatWidget(),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isBangla) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBangla ? 'ইতিহাস' : 'History',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  isBangla
                      ? '${_history.length} টি বিশ্লেষণ'
                      : '${_history.length} ${_history.length == 1 ? 'analysis' : 'analyses'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Clear all button
          if (_history.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.white),
                onPressed: () => _clearAllHistory(isBangla),
                tooltip: isBangla ? 'সব মুছে ফেলুন' : 'Clear All',
              ),
            ),

          const SizedBox(width: 8),

          // Refresh button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadHistory,
              tooltip: isBangla ? 'রিফ্রেশ' : 'Refresh',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isBangla) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(
            isBangla ? 'ইতিহাস লোড হচ্ছে...' : 'Loading history...',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isBangla) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              isBangla ? 'ত্রুটি ঘটেছে' : 'An error occurred',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadHistory,
              icon: const Icon(Icons.refresh),
              label: Text(isBangla ? 'পুনরায় চেষ্টা করুন' : 'Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isBangla) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, color: Colors.white.withOpacity(0.5), size: 80),
            const SizedBox(height: 16),
            Text(
              isBangla ? 'কোনো ইতিহাস নেই' : 'No History',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isBangla
                  ? 'আপনি এখনো কোনো বিশ্লেষণ করেননি।\nএকটি এক্স-রে স্ক্যান করে শুরু করুন।'
                  : 'You haven\'t performed any analyses yet.\nStart by scanning an X-ray.',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(bool isBangla) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final record = _history[index];
        return _buildHistoryCard(record, isBangla);
      },
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> record, bool isBangla) {
    final patientInfo = record['patientInfo'] as Map<String, dynamic>;
    final analysisResults = record['analysisResults'] as Map<String, dynamic>;
    final id = record['id'] as String;
    final timestamp = DateTime.parse(record['timestamp'] as String);

    final probability = (analysisResults['probability'] as num).toDouble();
    final riskLevel = analysisResults['riskLevel'] as String;
    final patientName = patientInfo['name'] as String;
    final patientAge = patientInfo['age'] as int;

    // Format date
    final dateStr = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    final timeStr = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

    // Risk color
    Color riskColor;
    switch (riskLevel.toLowerCase()) {
      case 'high':
        riskColor = Colors.red;
        break;
      case 'medium':
        riskColor = Colors.orange;
        break;
      case 'low':
        riskColor = Colors.green;
        break;
      default:
        riskColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
            child: InkWell(
              onTap: () => _viewDetails(record),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: Name and delete button
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patientName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isBangla
                                    ? '$patientAge বছর'
                                    : '$patientAge years old',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteItem(id, isBangla),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Date and time
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.7), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '$dateStr  $timeStr',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Probability and risk level
                    Row(
                      children: [
                        // Probability badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: riskColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: riskColor, width: 2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.analytics, color: riskColor, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '${(probability * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: riskColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Risk level badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: riskColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            riskLevel.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Arrow icon
                        Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.5), size: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
