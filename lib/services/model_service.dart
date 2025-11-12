/// Platform-Specific Model Service
/// 
/// This file uses conditional imports to provide different implementations:
/// - Mobile (Android/iOS): Uses TFLite for offline inference OR backend API
/// - Web: Uses backend API only (TFLite not supported on web)
/// 
/// The UI code remains unchanged - it just imports this file
library;

// Conditional imports based on platform
export 'model_service_mobile.dart'
    if (dart.library.html) 'model_service_web.dart';
