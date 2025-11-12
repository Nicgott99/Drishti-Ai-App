import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../services/image_service.dart';
import '../services/model_service.dart';
import '../services/image_validator_service.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/floating_chat_widget.dart';
import 'results_screen.dart';
import 'history_screen.dart';
import '../models/patient_info.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImageService _imageService = ImageService();
  final ModelService _modelService = ModelService();
  final ImageValidatorService _validatorService = ImageValidatorService();
  bool _isLoading = false;
  String _loadingMessage = '';

  @override
  void initState() {
    super.initState();
    // Model initializes automatically in constructor
  }

  @override
  void dispose() {
    // No dispose needed for new model service
    super.dispose();
  }

  Future<void> _processImage(XFile? imageFile) async {
    if (imageFile == null) return;

    final localizations = AppLocalizations.of(context)!;

    // Step 1: Show validation loading
    setState(() {
      _isLoading = true;
      _loadingMessage = localizations.validatingImage;
    });

    try {
      // Step 2: Validate if image is an X-ray
      final validationResult = await _validatorService.validateXRayImage(imageFile);
      
      if (!validationResult['isValid']) {
        // Image is not an X-ray
        setState(() {
          _isLoading = false;
          _loadingMessage = '';
        });

        // Show error dialog with validation reason
        if (mounted) {
          _showValidationErrorDialog(
            validationResult['reason'] ?? localizations.notXRayImage,
          );
        }
        return;
      }

      // Step 3: If valid, proceed with analysis
      setState(() {
        _loadingMessage = localizations.analysisInProgress;
      });

      // Run inference with heatmap generation
      final result = await _modelService.runInference(imageFile, generateHeatmap: true);

      setState(() {
        _isLoading = false;
        _loadingMessage = '';
      });

      // Navigate to results screen
      if (mounted) {
        // Create default patient info for quick scan from home screen
        final defaultPatientInfo = PatientInfo(
          name: 'Quick Scan',
          age: 0,
          gender: 'Not Specified',
          phoneNumber: '',
        );
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              imageFile: imageFile,
              analysisResult: result,
              patientInfo: defaultPatientInfo,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _loadingMessage = '';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.errorTitle}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show validation error dialog
  void _showValidationErrorDialog(String message) {
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[700],
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(localizations.invalidXRay),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localizations.uploadXRayOnly,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final imageFile = await _imageService.pickFromGallery();
      await _processImage(imageFile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorPickingImage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final imageFile = await _imageService.pickFromCamera();
      await _processImage(imageFile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorPickingImage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return LoadingOverlay(
      isLoading: _isLoading,
      message: _loadingMessage.isNotEmpty ? _loadingMessage : null,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.appName),
          centerTitle: true,
          elevation: 0,
          actions: [
            // Language toggle button
            IconButton(
              icon: const Icon(Icons.language),
              onPressed: () {
                languageProvider.toggleLanguage();
              },
              tooltip: languageProvider.currentLocale.languageCode == 'en'
                  ? 'বাংলা'
                  : 'English',
            ),
          ],
        ),
        body: Stack(
          children: [
            // Main content
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.7),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo or Icon
                      const Icon(
                        Icons.medical_services_outlined,
                        size: 100,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 24),
                      
                      // Welcome text
                      Text(
                        localizations.welcome,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Subtitle
                      Text(
                        localizations.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // Upload button
                      _buildActionButton(
                        context: context,
                        icon: Icons.cloud_upload_outlined,
                        label: localizations.uploadButton,
                        onPressed: _pickFromGallery,
                        color: Colors.white,
                        textColor: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 20),
                      
                      // Capture button
                      _buildActionButton(
                        context: context,
                        icon: Icons.camera_alt_outlined,
                        label: localizations.captureButton,
                        onPressed: _pickFromCamera,
                        color: Colors.white.withOpacity(0.9),
                        textColor: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 20),
                      
                      // History button
                      _buildActionButton(
                        context: context,
                        icon: Icons.history,
                        label: languageProvider.currentLocale.languageCode == 'bn' 
                            ? 'ইতিহাস' 
                            : 'History',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryScreen(),
                            ),
                          );
                        },
                        color: Colors.white.withOpacity(0.2),
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 48),
                      
                      // Info text
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                localizations.selectImage,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.95),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Floating chat widget overlays at bottom-right
            const FloatingChatWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    required Color textColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
