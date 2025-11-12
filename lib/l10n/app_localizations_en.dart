// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Drishti AI';

  @override
  String get uploadButton => 'Upload X-Ray';

  @override
  String get captureButton => 'Capture X-Ray';

  @override
  String get resultTitle => 'Analysis Result';

  @override
  String get analysisInProgress => 'Analyzing X-Ray with AI...';

  @override
  String get probability => 'Probability';

  @override
  String get riskLevel => 'Risk Level';

  @override
  String get confidence => 'Confidence';

  @override
  String get showHeatmap => 'Show Heatmap';

  @override
  String get hideHeatmap => 'Hide Heatmap';

  @override
  String get saveReport => 'Save Report';

  @override
  String get reportSaved => 'Report saved successfully';

  @override
  String get riskHigh => 'High';

  @override
  String get riskMedium => 'Medium';

  @override
  String get riskLow => 'Low';

  @override
  String get errorTitle => 'Error';

  @override
  String get errorPickingImage => 'Failed to pick image';

  @override
  String get welcome => 'Welcome to Drishti AI';

  @override
  String get subtitle => 'AI-Powered TB Screening';

  @override
  String get selectImage => 'Select an X-Ray image to begin analysis';

  @override
  String get tbProbability => 'TB Probability';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get reportSavedAt => 'Report saved at';

  @override
  String get noImageSelected => 'No image selected';

  @override
  String get permissionDenied => 'Permission denied';

  @override
  String get invalidXRay => 'Invalid X-Ray Image';

  @override
  String get notXRayImage =>
      'This doesn\'t appear to be an X-ray image. Please upload a chest X-ray.';

  @override
  String get validatingImage => 'Validating image...';

  @override
  String get uploadXRayOnly => 'Please upload X-ray images only';

  @override
  String get chatbotTitle => 'TB Health Assistant';

  @override
  String get chatbotSubtitle => 'Ask me anything about TB or this screening';

  @override
  String get chatPlaceholder =>
      'Ask about TB symptoms, prevention, treatment...';

  @override
  String get aiDisclaimer =>
      'AI Assistant - For informational purposes only. Consult healthcare professionals for medical advice.';

  @override
  String get patientRegistration => 'Patient Registration';

  @override
  String get enterPatientInformation => 'Please enter patient information';

  @override
  String get patientName => 'Patient Name';

  @override
  String get enterFullName => 'Enter full name';

  @override
  String get pleaseEnterName => 'Please enter patient name';

  @override
  String get age => 'Age';

  @override
  String get invalidAge => 'Invalid age';

  @override
  String get required => 'Required';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get pleaseEnterPhone => 'Please enter phone number';

  @override
  String get patientInfoNote =>
      'Patient information is kept confidential and used only for medical records';

  @override
  String get continueToScanning => 'Continue to Scanning';

  @override
  String get selectScanMethod => 'Select Scan Method';

  @override
  String get captureXRay => 'Capture X-Ray';

  @override
  String get useDeviceCamera => 'Use device camera';

  @override
  String get uploadXRay => 'Upload X-Ray';

  @override
  String get selectFromGallery => 'Select from gallery';

  @override
  String get analysisResults => 'Analysis Results';

  @override
  String get xRayAnalysis => 'X-Ray Analysis';

  @override
  String get withGradCAM => 'With AI Heatmap (Grad-CAM)';

  @override
  String get originalImage => 'Original Image';

  @override
  String get tbSuggestive => 'TB Suggestive';

  @override
  String get noTBDetected => 'No TB Detected';

  @override
  String get referralRequired => 'Referral to specialist required';

  @override
  String get normalResult => 'No signs of tuberculosis detected';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get recommendation1 => '• Refer patient for sputum microscopy test';

  @override
  String get recommendation2 => '• Schedule follow-up within 48 hours';

  @override
  String get recommendation3 => '• Monitor patient symptoms closely';

  @override
  String get normalRecommendation1 => '• Continue routine health monitoring';

  @override
  String get normalRecommendation2 => '• Maintain healthy lifestyle practices';

  @override
  String get returnHome => 'Return to Home';

  @override
  String get shareReport => 'Share Report';

  @override
  String get saveOptions => 'Save Options';

  @override
  String get saveToDevice => 'Save to Device';

  @override
  String get printReport => 'Print Report';

  @override
  String get emailReport => 'Email Report';
}
