import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../models/patient_info.dart';
import '../widgets/floating_chat_widget.dart';
import '../services/download_service.dart';
import '../services/history_storage_service.dart';

class ResultsScreen extends StatefulWidget {
  final XFile imageFile;
  final Map<String, dynamic> analysisResult;
  final PatientInfo patientInfo;

  const ResultsScreen({
    Key? key,
    required this.imageFile,
    required this.analysisResult,
    required this.patientInfo,
  }) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> with SingleTickerProviderStateMixin {
  bool _showHeatmap = true;
  Uint8List? _imageBytes;
  Uint8List? _heatmapBytes;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
    _loadImage();
    _loadHeatmap();
    _saveToHistory(); // Auto-save to history
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await widget.imageFile.readAsBytes();
      if (mounted) {
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  Future<void> _loadHeatmap() async {
    if (widget.analysisResult.containsKey('heatmap') && widget.analysisResult['heatmap'] != null) {
      try {
        String heatmapBase64 = widget.analysisResult['heatmap'] as String;
        
        // Remove data URI prefix if present
        if (heatmapBase64.startsWith('data:image')) {
          heatmapBase64 = heatmapBase64.split(',').last;
        }
        
        final decodedBytes = base64Decode(heatmapBase64);
        if (mounted) {
          setState(() {
            _heatmapBytes = decodedBytes;
          });
          debugPrint("✓ Heatmap loaded successfully (${decodedBytes.length} bytes)");
        }
      } catch (e) {
        debugPrint('Error decoding heatmap: $e');
      }
    } else {
      debugPrint('⚠ No heatmap data in analysis result');
    }
  }

  Future<void> _saveToHistory() async {
    try {
      await HistoryStorageService.saveAnalysis(
        patientInfo: widget.patientInfo,
        analysisResults: widget.analysisResult,
      );
      print('Analysis saved to history successfully');
    } catch (e) {
      print('Error saving to history: $e');
      // Don't show error to user - history saving is non-critical
    }
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getUrgencyColor(String? urgencyLevel) {
    if (urgencyLevel == null) return Colors.green[700]!;
    switch (urgencyLevel.toLowerCase()) {
      case 'critical':
        return Colors.red[900]!;
      case 'high':
        return Colors.orange[700]!;
      case 'moderate':
        return Colors.yellow[700]!;
      default:
        return Colors.green[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final isBangla = locale == 'bn';
    final probability = (widget.analysisResult['probability'] as num?)?.toDouble() ?? 0.0;
    final riskLevel = widget.analysisResult['riskLevel'] as String? ?? 'low';
    final confidence = (widget.analysisResult['confidence'] as num?)?.toDouble() ?? 0.0;
    final classification = widget.analysisResult['classification'] as String? ?? 'Unknown';
    final urgencyLevel = widget.analysisResult['urgency_level'] as String?;
    final recommendations = widget.analysisResult['recommendations'] as List?;
    final affectedRegions = widget.analysisResult['affected_regions'] as List?;
    final heatmapExplanation = widget.analysisResult['heatmap_explanation'] as String?;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0F172A),
                  const Color(0xFF1E3A8A),
                  _getRiskColor(riskLevel).withOpacity(0.2),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildPremiumAppBar(localizations, isBangla),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (urgencyLevel != null && (urgencyLevel.toLowerCase() == 'critical' || urgencyLevel.toLowerCase() == 'high'))
                              _buildUrgencyAlert(urgencyLevel, isBangla),
                            if (urgencyLevel != null && (urgencyLevel.toLowerCase() == 'critical' || urgencyLevel.toLowerCase() == 'high'))
                              const SizedBox(height: 16),
                            _buildPremiumPatientInfoCard(isBangla),
                            const SizedBox(height: 16),
                            _buildPremiumResultsSummaryCard(probability, riskLevel, confidence, classification, isBangla),
                            const SizedBox(height: 16),
                            if (affectedRegions != null && affectedRegions.isNotEmpty)
                              _buildAffectedRegionsCard(affectedRegions, isBangla),
                            if (affectedRegions != null && affectedRegions.isNotEmpty)
                              const SizedBox(height: 16),
                            _buildPremiumImageSection(isBangla),
                            const SizedBox(height: 16),
                            if (heatmapExplanation != null && heatmapExplanation.isNotEmpty)
                              _buildHeatmapExplanationCard(heatmapExplanation, isBangla),
                            if (heatmapExplanation != null && heatmapExplanation.isNotEmpty)
                              const SizedBox(height: 16),
                            if (recommendations != null && recommendations.isNotEmpty)
                              _buildRecommendationsCard(recommendations, isBangla),
                            if (recommendations != null && recommendations.isNotEmpty)
                              const SizedBox(height: 16),
                            _buildPremiumActionButtons(isBangla),
                            const SizedBox(height: 16),
                            _buildTBSymptomsCard(isBangla),
                            const SizedBox(height: 16),
                            _buildPreventionCard(isBangla),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const FloatingChatWidget(),
        ],
      ),
    );
  }

  Widget _buildPremiumAppBar(AppLocalizations localizations, bool isBangla) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBangla ? 'বিশ্লেষণ ফলাফল' : localizations.analysisResults,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrgencyAlert(String urgencyLevel, bool isBangla) {
    final isCritical = urgencyLevel.toLowerCase() == 'critical';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getUrgencyColor(urgencyLevel).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getUrgencyColor(urgencyLevel), width: 2),
      ),
      child: Row(
        children: [
          Icon(
            isCritical ? Icons.warning_amber : Icons.info,
            color: _getUrgencyColor(urgencyLevel),
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBangla
                      ? (isCritical ? 'জরর মনযগ পরযজন!' : 'উচচ অগরধকার')
                      : (isCritical ? 'Urgent Attention Required!' : 'High Priority'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getUrgencyColor(urgencyLevel),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isBangla
                      ? (isCritical
                          ? 'অবলমব একজন চকৎসক পরমরশ নন'
                          : 'শঘরই একজন সবসথয পশদরর পরমরশ নন')
                      : (isCritical
                          ? 'Please consult a doctor immediately'
                          : 'Please consult a healthcare professional soon'),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumPatientInfoCard(bool isBangla) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    isBangla ? 'রগর তথয' : 'Patient Information',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                isBangla ? 'নম' : 'Name',
                widget.patientInfo.name,
                Icons.badge,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                isBangla ? 'বযস' : 'Age',
                '${widget.patientInfo.age} ${isBangla ? 'বছর' : 'years'}',
                Icons.cake,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                isBangla ? 'লঙগ' : 'Gender',
                widget.patientInfo.gender,
                Icons.person_outline,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                isBangla ? 'ফন' : 'Phone',
                widget.patientInfo.phoneNumber,
                Icons.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumResultsSummaryCard(double probability, String riskLevel, double confidence, String classification, bool isBangla) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    isBangla ? 'এআই বিশ্লেষণ ফলাফল' : 'AI Analysis Results',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildResultRow(
                isBangla ? 'শরণবভগ' : 'Classification',
                classification,
                Icons.category,
              ),
              const SizedBox(height: 16),
              Text(
                isBangla ? 'যকষমর সমভবন' : 'TB Probability',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1500),
                    height: 30,
                    width: MediaQuery.of(context).size.width * 0.85 * probability,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getRiskColor(riskLevel),
                          _getRiskColor(riskLevel).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  Container(
                    height: 30,
                    alignment: Alignment.center,
                    child: Text(
                      '${(probability * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildResultRow(
                isBangla ? 'ঝক সতর' : 'Risk Level',
                riskLevel.toUpperCase(),
                Icons.warning_amber,
                color: _getRiskColor(riskLevel),
              ),
              const SizedBox(height: 16),
              _buildResultRow(
                isBangla ? 'আতমবশবস' : 'Confidence',
                '${(confidence * 100).toStringAsFixed(1)}%',
                Icons.check_circle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.white70, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAffectedRegionsCard(List affectedRegions, bool isBangla) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    isBangla ? 'পরভবত অঞচল' : 'Affected Regions',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: affectedRegions.map((region) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.withOpacity(0.5)),
                    ),
                    child: Text(
                      region.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumImageSection(bool isBangla) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.medical_services, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        isBangla ? 'বকর একস-র' : 'Chest X-Ray',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (_heatmapBytes != null)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () => setState(() => _showHeatmap = false),
                            style: TextButton.styleFrom(
                              backgroundColor: !_showHeatmap
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                              ),
                            ),
                            child: Text(
                              isBangla ? 'মল' : 'Original',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: !_showHeatmap ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _showHeatmap = true),
                            style: TextButton.styleFrom(
                              backgroundColor: _showHeatmap
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                            ),
                            child: Text(
                              isBangla ? 'হটমযপ' : 'Heatmap',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: _showHeatmap ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (_showHeatmap && _heatmapBytes != null) {
      return Image.memory(
        _heatmapBytes!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 300,
            color: Colors.black26,
            child: const Center(
              child: Icon(Icons.error, color: Colors.white, size: 48),
            ),
          );
        },
      );
    } else if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 300,
            color: Colors.black26,
            child: const Center(
              child: Icon(Icons.error, color: Colors.white, size: 48),
            ),
          );
        },
      );
    } else {
      return Container(
        height: 300,
        color: Colors.black26,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
  }

  Widget _buildHeatmapExplanationCard(String explanation, bool isBangla) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    isBangla ? 'হটমযপ বযখয' : 'Heatmap Explanation',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                explanation,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(List recommendations, bool isBangla) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.health_and_safety, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    isBangla ? 'চকৎস সপরশ' : 'Medical Recommendations',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...recommendations.asMap().entries.map((entry) {
                final index = entry.key;
                final recommendation = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          recommendation.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumActionButtons(bool isBangla) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            isBangla ? 'রিপোর্ট ডাউনলোড করুন (হিটম্যাপ সহ)' : 'Download Report (with Heatmap)',
            Icons.download,
            Colors.blue,
            () async {
              try {
                // Show loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isBangla
                        ? 'পিডিএফ তৈরি করছে...'
                        : 'Generating PDF with heatmap...'),
                    duration: const Duration(seconds: 2),
                  ),
                );

                // Download PDF (includes embedded heatmap if TB case)
                await DownloadService.downloadPDFReport(
                  patientInfo: widget.patientInfo,
                  analysisResults: widget.analysisResult,
                );

                // Show success
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isBangla
                          ? 'পিডিএফ রিপোর্ট ডাউনলোড হয়েছে! (হিটম্যাপ যুক্ত)'
                          : 'PDF report downloaded! (Heatmap included)'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Show error
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isBangla
                          ? 'ত্রুটি: ${e.toString()}'
                          : 'Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color, width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTBSymptomsCard(bool isBangla) {
    final symptoms = isBangla
        ? [
            ' সপতহর বশ কশ',
            'বক বযথ',
            'রকতকত কফ',
            'জবর এব ঠনড লগ',
            'রত ঘম',
            'ওজন হরস',
            'কষধ হরস',
          ]
        : [
            'Persistent cough for more than 2 weeks',
            'Chest pain',
            'Coughing up blood or phlegm',
            'Fever and chills',
            'Night sweats',
            'Weight loss',
            'Loss of appetite',
          ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.coronavirus, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    isBangla ? 'যক্ষ্মার লক্ষণ' : 'TB Symptoms',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...symptoms.map((symptom) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          symptom,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreventionCard(bool isBangla) {
    final preventions = isBangla
        ? [
            'ভল বযচলচল বজয রখন',
            'যকষম রগদর সথ ঘনষঠ সসপরশ এডয চলন',
            'টক নন (BCG)',
            'মসক বযবহর করন',
            'নযমত সবসথয পরকষ করন',
            'সবসথযকর জবনযপন বজয রখন',
          ]
        : [
            'Maintain good ventilation',
            'Avoid close contact with TB patients',
            'Get vaccinated (BCG)',
            'Use protective masks',
            'Regular health checkups',
            'Maintain a healthy lifestyle',
          ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    isBangla ? 'পরতরধর উপয' : 'Prevention Guidelines',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...preventions.map((prevention) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          prevention,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
