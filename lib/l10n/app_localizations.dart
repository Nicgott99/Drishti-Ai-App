import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Drishti AI'**
  String get appName;

  /// No description provided for @uploadButton.
  ///
  /// In en, this message translates to:
  /// **'Upload X-Ray'**
  String get uploadButton;

  /// No description provided for @captureButton.
  ///
  /// In en, this message translates to:
  /// **'Capture X-Ray'**
  String get captureButton;

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis Result'**
  String get resultTitle;

  /// No description provided for @analysisInProgress.
  ///
  /// In en, this message translates to:
  /// **'Analyzing X-Ray with AI...'**
  String get analysisInProgress;

  /// No description provided for @probability.
  ///
  /// In en, this message translates to:
  /// **'Probability'**
  String get probability;

  /// No description provided for @riskLevel.
  ///
  /// In en, this message translates to:
  /// **'Risk Level'**
  String get riskLevel;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @showHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Show Heatmap'**
  String get showHeatmap;

  /// No description provided for @hideHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Hide Heatmap'**
  String get hideHeatmap;

  /// No description provided for @saveReport.
  ///
  /// In en, this message translates to:
  /// **'Save Report'**
  String get saveReport;

  /// No description provided for @reportSaved.
  ///
  /// In en, this message translates to:
  /// **'Report saved successfully'**
  String get reportSaved;

  /// No description provided for @riskHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get riskHigh;

  /// No description provided for @riskMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get riskMedium;

  /// No description provided for @riskLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get riskLow;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get errorPickingImage;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Drishti AI'**
  String get welcome;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered TB Screening'**
  String get subtitle;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select an X-Ray image to begin analysis'**
  String get selectImage;

  /// No description provided for @tbProbability.
  ///
  /// In en, this message translates to:
  /// **'TB Probability'**
  String get tbProbability;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @reportSavedAt.
  ///
  /// In en, this message translates to:
  /// **'Report saved at'**
  String get reportSavedAt;

  /// No description provided for @noImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get noImageSelected;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get permissionDenied;

  /// No description provided for @invalidXRay.
  ///
  /// In en, this message translates to:
  /// **'Invalid X-Ray Image'**
  String get invalidXRay;

  /// No description provided for @notXRayImage.
  ///
  /// In en, this message translates to:
  /// **'This doesn\'t appear to be an X-ray image. Please upload a chest X-ray.'**
  String get notXRayImage;

  /// No description provided for @validatingImage.
  ///
  /// In en, this message translates to:
  /// **'Validating image...'**
  String get validatingImage;

  /// No description provided for @uploadXRayOnly.
  ///
  /// In en, this message translates to:
  /// **'Please upload X-ray images only'**
  String get uploadXRayOnly;

  /// No description provided for @chatbotTitle.
  ///
  /// In en, this message translates to:
  /// **'TB Health Assistant'**
  String get chatbotTitle;

  /// No description provided for @chatbotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about TB or this screening'**
  String get chatbotSubtitle;

  /// No description provided for @chatPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Ask about TB symptoms, prevention, treatment...'**
  String get chatPlaceholder;

  /// No description provided for @aiDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant - For informational purposes only. Consult healthcare professionals for medical advice.'**
  String get aiDisclaimer;

  /// No description provided for @patientRegistration.
  ///
  /// In en, this message translates to:
  /// **'Patient Registration'**
  String get patientRegistration;

  /// No description provided for @enterPatientInformation.
  ///
  /// In en, this message translates to:
  /// **'Please enter patient information'**
  String get enterPatientInformation;

  /// No description provided for @patientName.
  ///
  /// In en, this message translates to:
  /// **'Patient Name'**
  String get patientName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get enterFullName;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter patient name'**
  String get pleaseEnterName;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @invalidAge.
  ///
  /// In en, this message translates to:
  /// **'Invalid age'**
  String get invalidAge;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhone;

  /// No description provided for @patientInfoNote.
  ///
  /// In en, this message translates to:
  /// **'Patient information is kept confidential and used only for medical records'**
  String get patientInfoNote;

  /// No description provided for @continueToScanning.
  ///
  /// In en, this message translates to:
  /// **'Continue to Scanning'**
  String get continueToScanning;

  /// No description provided for @selectScanMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Scan Method'**
  String get selectScanMethod;

  /// No description provided for @captureXRay.
  ///
  /// In en, this message translates to:
  /// **'Capture X-Ray'**
  String get captureXRay;

  /// No description provided for @useDeviceCamera.
  ///
  /// In en, this message translates to:
  /// **'Use device camera'**
  String get useDeviceCamera;

  /// No description provided for @uploadXRay.
  ///
  /// In en, this message translates to:
  /// **'Upload X-Ray'**
  String get uploadXRay;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from gallery'**
  String get selectFromGallery;

  /// No description provided for @analysisResults.
  ///
  /// In en, this message translates to:
  /// **'Analysis Results'**
  String get analysisResults;

  /// No description provided for @xRayAnalysis.
  ///
  /// In en, this message translates to:
  /// **'X-Ray Analysis'**
  String get xRayAnalysis;

  /// No description provided for @withGradCAM.
  ///
  /// In en, this message translates to:
  /// **'With AI Heatmap (Grad-CAM)'**
  String get withGradCAM;

  /// No description provided for @originalImage.
  ///
  /// In en, this message translates to:
  /// **'Original Image'**
  String get originalImage;

  /// No description provided for @tbSuggestive.
  ///
  /// In en, this message translates to:
  /// **'TB Suggestive'**
  String get tbSuggestive;

  /// No description provided for @noTBDetected.
  ///
  /// In en, this message translates to:
  /// **'No TB Detected'**
  String get noTBDetected;

  /// No description provided for @referralRequired.
  ///
  /// In en, this message translates to:
  /// **'Referral to specialist required'**
  String get referralRequired;

  /// No description provided for @normalResult.
  ///
  /// In en, this message translates to:
  /// **'No signs of tuberculosis detected'**
  String get normalResult;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @recommendation1.
  ///
  /// In en, this message translates to:
  /// **'• Refer patient for sputum microscopy test'**
  String get recommendation1;

  /// No description provided for @recommendation2.
  ///
  /// In en, this message translates to:
  /// **'• Schedule follow-up within 48 hours'**
  String get recommendation2;

  /// No description provided for @recommendation3.
  ///
  /// In en, this message translates to:
  /// **'• Monitor patient symptoms closely'**
  String get recommendation3;

  /// No description provided for @normalRecommendation1.
  ///
  /// In en, this message translates to:
  /// **'• Continue routine health monitoring'**
  String get normalRecommendation1;

  /// No description provided for @normalRecommendation2.
  ///
  /// In en, this message translates to:
  /// **'• Maintain healthy lifestyle practices'**
  String get normalRecommendation2;

  /// No description provided for @returnHome.
  ///
  /// In en, this message translates to:
  /// **'Return to Home'**
  String get returnHome;

  /// No description provided for @shareReport.
  ///
  /// In en, this message translates to:
  /// **'Share Report'**
  String get shareReport;

  /// No description provided for @saveOptions.
  ///
  /// In en, this message translates to:
  /// **'Save Options'**
  String get saveOptions;

  /// No description provided for @saveToDevice.
  ///
  /// In en, this message translates to:
  /// **'Save to Device'**
  String get saveToDevice;

  /// No description provided for @printReport.
  ///
  /// In en, this message translates to:
  /// **'Print Report'**
  String get printReport;

  /// No description provided for @emailReport.
  ///
  /// In en, this message translates to:
  /// **'Email Report'**
  String get emailReport;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
