import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import '../l10n/app_localizations.dart';
import '../models/patient_info.dart';
import '../services/image_service.dart';
import '../services/model_service.dart';
import '../services/image_validator_service.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/loading_stages_widget.dart';
import '../widgets/floating_chat_widget.dart';
import 'results_screen.dart';

class ScanMethodScreen extends StatefulWidget {
  final PatientInfo patientInfo;

  const ScanMethodScreen({
    Key? key,
    required this.patientInfo,
  }) : super(key: key);

  @override
  State<ScanMethodScreen> createState() => _ScanMethodScreenState();
}

class _ScanMethodScreenState extends State<ScanMethodScreen> {
  final ImageService _imageService = ImageService();
  final ModelService _modelService = ModelService();
  final ImageValidatorService _validatorService = ImageValidatorService();
  bool _isLoading = false;
  String _loadingMessage = '';

  @override
  void initState() {
    super.initState();
    // Initialize model service (offline mode - no backend check needed)
    _modelService.initialize();
  }

  Future<void> _processImage(XFile? imageFile) async {
    if (imageFile == null) return;

    final localizations = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
      _loadingMessage = localizations.validatingImage;
    });

    try {
      // STAGE 1: Basic validation for upload (lenient)
      final basicValidation = await _validatorService.validateXRayImage(imageFile);

      if (!basicValidation['isValid']) {
        setState(() {
          _isLoading = false;
        });
        _showValidationError(basicValidation['reason'] ?? 'Invalid image');
        return;
      }

      // STAGE 2: Deep validation before analysis (strict medical criteria)
      final deepValidation = await _validatorService.validateForAnalysis(imageFile);

      if (!deepValidation['isValid']) {
        setState(() {
          _isLoading = false;
        });
        _showValidationError(deepValidation['reason'] ?? 'Image does not appear to be a chest X-ray');
        return;
      }

      // Show loading stages screen and start analysis
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoadingStagesWidget(
              patientName: widget.patientInfo.name,
              onComplete: () {}, // Will be handled by result arrival
            ),
          ),
        );
      }

      // Set up progress callback
      _modelService.onProgress = (message, progress) {
        debugPrint("Progress update: $message - ${(progress * 100).toStringAsFixed(0)}%");
        // Progress is now displayed in LoadingStagesWidget
      };

      // Run inference (this takes ~40 seconds with realistic processing stages)
      final result = await _modelService.runInference(imageFile, generateHeatmap: true);

      setState(() {
        _isLoading = false;
      });

      // Navigate to results (replace loading screen)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              imageFile: imageFile,
              analysisResult: result,
              patientInfo: widget.patientInfo,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Pop loading screen if it's showing
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showError('Analysis Error', e.toString());
    }
  }

  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Invalid Image'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    try {
      final imageFile = await _imageService.pickFromCamera();
      await _processImage(imageFile);
    } catch (e) {
      _showError('Camera Error', e.toString());
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final imageFile = await _imageService.pickFromGallery();
      await _processImage(imageFile);
    } catch (e) {
      _showError('Gallery Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: _loadingMessage,
        child: Stack(
          children: [
            Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F172A),
                Color(0xFF1E293B),
                Color(0xFF1E3A8A),
                Color(0xFF312E81),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                _buildBackgroundEffects(),
                Column(
              children: [
                // App Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.selectScanMethod,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.patientInfo.name,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Patient Info Card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 25,
                                spreadRadius: -5,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.withOpacity(0.3),
                                          Colors.purple.withOpacity(0.3),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.patientInfo.name,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${widget.patientInfo.age} years • ${widget.patientInfo.gender}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.6),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Capture Button
                        _buildMethodButton(
                          icon: Icons.camera_alt,
                          title: localizations.captureXRay,
                          subtitle: localizations.useDeviceCamera,
                          gradientColors: const [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                          onTap: _pickFromCamera,
                        ),
                        const SizedBox(height: 24),

                        // Upload Button
                        _buildMethodButton(
                          icon: Icons.upload_file,
                          title: localizations.uploadXRay,
                          subtitle: localizations.selectFromGallery,
                          gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                          onTap: _pickFromGallery,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ), // Column
              ],
            ), // Stack (inside SafeArea)
          ), // SafeArea
        ), // Container
            const FloatingChatWidget(),
          ],
        ), // Stack (LoadingOverlay child)
      ), // LoadingOverlay
    ); // Scaffold
  }

  Widget _buildBackgroundEffects() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.blue.withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          left: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.purple.withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.5),
              blurRadius: 25,
              spreadRadius: -5,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 24),
          ],
        ),
        ),
      ),
    );
  }
}
