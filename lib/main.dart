import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'providers/language_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const DrishtiApp());
}

class DrishtiApp extends StatelessWidget {
  const DrishtiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            
            // App title
            title: 'Drishti AI - দৃষ্টি',
            
            // Premium Theme
            theme: ThemeData(
              primarySwatch: Colors.indigo,
              primaryColor: const Color(0xFF667eea),
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: AppBarTheme(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: const Color(0xFF667eea).withOpacity(0.5),
                ),
              ),
              useMaterial3: true,
              fontFamily: 'Roboto',
            ),
            
            // Localization setup
            locale: languageProvider.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('bn', ''), // Bengali
            ],
            
            // Start with splash screen
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
