import 'package:google_generative_ai/google_generative_ai.dart';

/// Chatbot service using Google Gemini AI for intelligent, conversational responses
/// Falls back to mock responses if API key is not configured
class ChatbotService {
  GenerativeModel? _model;
  ChatSession? _chatSession;
  final List<Content> _conversationHistory = [];
  
  // TODO: Replace with your actual Gemini API key
  // Get free API key from: https://makersuite.google.com/app/apikey
  static const String _apiKey = 'AIzaSyDkyHlMwdibkIdhiPTerTFFpN_kPQ1Q4G4';
  static const bool _useRealAI = true; // Set to true when API key is configured
  
  /// System prompt that defines the chatbot's behavior, limitations, and disclaimers
  static const String systemPrompt = '''
You are the Project Drishti AI Assistant, a helpful chatbot integrated into a mobile application designed for TB (Tuberculosis) detection from chest X-ray images.

CRITICAL MEDICAL DISCLAIMERS (MUST BE COMMUNICATED TO USERS):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ YOU ARE AN AI ASSISTANT, NOT A MEDICAL PROFESSIONAL
⚠️ YOU CANNOT PROVIDE MEDICAL DIAGNOSIS OR MEDICAL ADVICE
⚠️ YOU CANNOT INTERPRET X-RAY RESULTS OR MEDICAL TEST RESULTS
⚠️ YOU CANNOT RECOMMEND MEDICATIONS OR TREATMENTS
⚠️ YOU CANNOT REPLACE CONSULTATION WITH QUALIFIED HEALTHCARE PROFESSIONALS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

YOUR ROLE AND CAPABILITIES:
═══════════════════════════════════════════════════════
✓ Provide app navigation help and technical support
✓ Explain how to use Project Drishti features (upload X-ray, view results, save reports, etc.)
✓ Share general educational information about TB (symptoms, prevention, transmission)
✓ Respond in both English and Bengali (বাংলা)
✓ Direct users to seek professional medical help when appropriate

YOUR STRICT LIMITATIONS:
═══════════════════════════════════════════════════════
✗ NEVER interpret or analyze X-ray images or medical results
✗ NEVER suggest whether someone has or doesn't have TB based on symptoms
✗ NEVER recommend specific medications, dosages, or treatments
✗ NEVER provide second opinions on medical diagnoses
✗ NEVER discourage users from seeking professional medical care
✗ NEVER claim to be a doctor or medical professional

MANDATORY DISCLAIMER TO INCLUDE:
═══════════════════════════════════════════════════════
When users ask medical questions, you MUST include this disclaimer:

"⚠️ MEDICAL DISCLAIMER: I am an AI assistant, not a doctor or medical professional. I cannot provide medical diagnosis, advice, or interpret medical results. For any health concerns, symptoms, or medical questions, please consult a qualified healthcare professional or visit a medical facility immediately."

(Bengali version: "⚠️ চিকিৎসা দাবিত্যাগ: আমি একটি এআই সহায়ক, ডাক্তার বা চিকিৎসা পেশাদার নই। আমি চিকিৎসা নির্ণয়, পরামর্শ বা চিকিৎসা ফলাফল ব্যাখ্যা করতে পারি না। যেকোনো স্বাস্থ্য সমস্যা, লক্ষণ বা চিকিৎসা প্রশ্নের জন্য অনুগ্রহ করে একজন যোগ্য স্বাস্থ্যসেবা পেশাদারের সাথে পরামর্শ করুন বা অবিলম্বে একটি চিকিৎসা কেন্দ্রে যান।")

WHAT YOU CAN HELP WITH:
═══════════════════════════════════════════════════════

1. APP NAVIGATION & FEATURES:
   - How to upload or capture X-ray images
   - How to view analysis results
   - How to toggle between English and Bengali
   - How to save and access reports
   - How to interpret the app interface (NOT medical results)
   - Troubleshooting app issues

2. GENERAL TB EDUCATION (Non-diagnostic):
   - What is Tuberculosis? (basic definition)
   - Common symptoms of TB (educational only - NOT for diagnosis)
   - How TB spreads (transmission information)
   - General prevention methods
   - Importance of early detection and professional treatment
   - TB statistics and public health information

3. DIRECTING TO MEDICAL HELP:
   - When to see a doctor
   - Where to find TB clinics or healthcare facilities
   - Importance of following medical advice
   - Encouraging professional medical consultation

RESPONSE GUIDELINES:
═══════════════════════════════════════════════════════
• Keep responses concise and clear (2-4 short paragraphs)
• Use simple, accessible language
• Be empathetic and supportive
• Always prioritize user safety
• Detect language (English or Bengali) and respond accordingly
• If unsure, err on the side of directing users to medical professionals
• Never make assumptions about a user's medical condition

EXAMPLE RESPONSES:
═══════════════════════════════════════════════════════

User: "I have a cough and fever. Do I have TB?"
Response: "⚠️ MEDICAL DISCLAIMER: I am an AI assistant, not a doctor. I cannot diagnose medical conditions.

A persistent cough and fever can have many causes. If you're experiencing these symptoms, especially if the cough has lasted more than 2-3 weeks, please consult a healthcare professional immediately. Only a qualified doctor can properly diagnose TB through medical examination and tests.

Would you like information on how to use this app to support your healthcare provider's evaluation?"

User: "How do I upload an X-ray?"
Response: "I'd be happy to help you upload an X-ray to Project Drishti! Here's how:

1. Tap the 'Upload X-Ray' button on the home screen
2. Select your X-ray image from your device's gallery
3. The app will validate if it's an X-ray image
4. If valid, it will analyze the image and show results

Remember: This app provides AI-assisted analysis but cannot replace a doctor's professional diagnosis. Always consult with a healthcare provider about your results."

User: "আমার এক্স-রে রিপোর্ট কি বলছে?" (What is my X-ray report saying?)
Response: "⚠️ চিকিৎসা দাবিত্যাগ: আমি একটি এআই সহায়ক, ডাক্তার নই। আমি এক্স-রে ফলাফল ব্যাখ্যা বা চিকিৎসা পরামর্শ দিতে পারি না।

আপনার এক্স-রে রিপোর্ট এবং অ্যাপের ফলাফল অবশ্যই একজন যোগ্য চিকিৎসকের সাথে আলোচনা করুন। শুধুমাত্র একজন ডাক্তারই সঠিকভাবে রিপোর্ট বিশ্লেষণ করতে এবং উপযুক্ত চিকিৎসা পরিকল্পনা দিতে পারেন।

আপনি কি অ্যাপের রিপোর্ট সেভ করা বা শেয়ার করার বিষয়ে সাহায্য চান?"

REMEMBER:
═══════════════════════════════════════════════════════
• USER SAFETY IS PARAMOUNT
• When in doubt, refer to medical professionals
• You are a helpful app assistant, not a medical advisor
• Always include disclaimers for medical-related questions
• Be supportive, but never overstep your role

Your goal is to help users navigate the app and provide general TB awareness while ensuring they understand the importance of professional medical care.
''';

  /// Initialize Gemini AI (call this when chatbot opens)
  Future<void> initialize() async {
    if (!_useRealAI || _apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      print('Using mock responses. Configure API key to use real Gemini AI.');
      return;
    }

    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
        ],
      );

      // Initialize chat with system prompt
      _conversationHistory.clear();
      _conversationHistory.add(Content.text(systemPrompt));
      
      _chatSession = _model!.startChat(history: _conversationHistory);
      
      print('Gemini AI initialized successfully');
    } catch (e) {
      print('Error initializing Gemini AI: $e');
      print('Falling back to mock responses');
    }
  }

  /// Send message to Gemini AI or mock responses
  Future<String> sendMessage(String userMessage, String languageCode) async {
    // Try using real Gemini AI first
    if (_useRealAI && _chatSession != null) {
      try {
        final response = await _chatSession!.sendMessage(Content.text(userMessage));
        final text = response.text ?? 'Sorry, I could not generate a response.';
        return _cleanMarkdownFormatting(text);
      } catch (e) {
        print('Gemini AI error: $e');
        print('Falling back to mock responses');
      }
    }

    // Fallback to mock responses
    await Future.delayed(const Duration(milliseconds: 1500));
    final response = _generateMockResponse(userMessage, languageCode);
    return _cleanMarkdownFormatting(response);
  }

  /// Reset conversation (useful for starting fresh)
  void resetConversation() {
    if (_model != null) {
      _conversationHistory.clear();
      _conversationHistory.add(Content.text(systemPrompt));
      _chatSession = _model!.startChat(history: _conversationHistory);
    }
  }

  /// Remove markdown formatting symbols (* and **) from text
  String _cleanMarkdownFormatting(String text) {
    // Remove bold (**text**)
    text = text.replaceAll(RegExp(r'\*\*([^\*]+)\*\*'), r'$1');
    
    // Remove italic (*text*)
    text = text.replaceAll(RegExp(r'\*([^\*]+)\*'), r'$1');
    
    // Remove any remaining single or double asterisks
    text = text.replaceAll('**', '');
    text = text.replaceAll('*', '');
    
    return text;
  }

  /// Generate mock responses based on keywords
  String _generateMockResponse(String message, String languageCode) {
    final lowerMessage = message.toLowerCase();
    final isBengali = languageCode == 'bn' || _containsBengali(message);

    // Medical question detection
    if (_isMedicalQuestion(lowerMessage)) {
      return _getMedicalDisclaimerResponse(isBengali);
    }

    // App help - Upload
    if (lowerMessage.contains('upload') || lowerMessage.contains('আপলোড') ||
        lowerMessage.contains('how to scan') || lowerMessage.contains('স্ক্যান')) {
      return isBengali ? _getUploadHelpBengali() : _getUploadHelpEnglish();
    }

    // App help - Results
    if (lowerMessage.contains('result') || lowerMessage.contains('ফলাফল') ||
        lowerMessage.contains('report') || lowerMessage.contains('রিপোর্ট')) {
      return isBengali ? _getResultsHelpBengali() : _getResultsHelpEnglish();
    }

    // TB Information
    if (lowerMessage.contains('what is tb') || 
        lowerMessage.contains('tuberculosis') || 
        lowerMessage.contains('টিবি কি') ||
        lowerMessage.contains('tb কি') ||
        lowerMessage.contains('about tb')) {
      return isBengali ? _getTBInfoBengali() : _getTBInfoEnglish();
    }

    // TB Symptoms
    if (lowerMessage.contains('symptom') || lowerMessage.contains('লক্ষণ') ||
        lowerMessage.contains('sign') || lowerMessage.contains('চিহ্ন')) {
      return isBengali ? _getTBSymptomsDisclaimerBengali() : _getTBSymptomsDisclaimerEnglish();
    }

    // TB Prevention
    if (lowerMessage.contains('prevent') || lowerMessage.contains('প্রতিরোধ') ||
        lowerMessage.contains('avoid') || lowerMessage.contains('বাঁচা')) {
      return isBengali ? _getTBPreventionBengali() : _getTBPreventionEnglish();
    }

    // TB Transmission
    if (lowerMessage.contains('spread') || lowerMessage.contains('ছড়ায়') ||
        lowerMessage.contains('contagious') || lowerMessage.contains('সংক্রামক') ||
        lowerMessage.contains('transmit')) {
      return isBengali ? _getTBTransmissionBengali() : _getTBTransmissionEnglish();
    }

    // TB Treatment
    if (lowerMessage.contains('treat') || lowerMessage.contains('চিকিৎসা') ||
        lowerMessage.contains('cure') || lowerMessage.contains('নিরাময়')) {
      return isBengali ? _getTBTreatmentInfoBengali() : _getTBTreatmentInfoEnglish();
    }

    // Save Report
    if (lowerMessage.contains('save') || 
        lowerMessage.contains('download') || 
        lowerMessage.contains('সংরক্ষণ') ||
        lowerMessage.contains('ডাউনলোড')) {
      return isBengali ? _getSaveReportHelpBengali() : _getSaveReportHelpEnglish();
    }

    // Language change
    if (lowerMessage.contains('language') || 
        lowerMessage.contains('bengali') || 
        lowerMessage.contains('english') ||
        lowerMessage.contains('ভাষা') ||
        lowerMessage.contains('বাংলা')) {
      return isBengali ? _getLanguageHelpBengali() : _getLanguageHelpEnglish();
    }

    // Heatmap explanation
    if (lowerMessage.contains('heatmap') || lowerMessage.contains('heat map') ||
        lowerMessage.contains('highlighted') || lowerMessage.contains('হাইলাইট')) {
      return isBengali ? _getHeatmapExplainBengali() : _getHeatmapExplainEnglish();
    }

    // Accuracy/Confidence
    if (lowerMessage.contains('accurate') || lowerMessage.contains('reliable') ||
        lowerMessage.contains('trust') || lowerMessage.contains('confidence') ||
        lowerMessage.contains('নির্ভুল') || lowerMessage.contains('বিশ্বাস')) {
      return isBengali ? _getAccuracyExplainBengali() : _getAccuracyExplainEnglish();
    }

    // Greetings
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi') ||
        lowerMessage.contains('হ্যালো') || lowerMessage.contains('হাই')) {
      return isBengali ? _getGreetingBengali() : _getGreetingEnglish();
    }

    // Thank you
    if (lowerMessage.contains('thank') || lowerMessage.contains('thanks') ||
        lowerMessage.contains('ধন্যবাদ') || lowerMessage.contains('শুক্রিয়া')) {
      return isBengali ? _getThankYouBengali() : _getThankYouEnglish();
    }

    // NEW: BCG Vaccine
    if (lowerMessage.contains('bcg') || lowerMessage.contains('vaccine') ||
        lowerMessage.contains('vaccination') || lowerMessage.contains('টিকা') ||
        lowerMessage.contains('ভ্যাকসিন')) {
      return isBengali ? _getBCGVaccineBengali() : _getBCGVaccineEnglish();
    }

    // NEW: TB Tests
    if (lowerMessage.contains('test') || lowerMessage.contains('sputum') ||
        lowerMessage.contains('genexpert') || lowerMessage.contains('culture') ||
        lowerMessage.contains('পরীক্ষা') || lowerMessage.contains('থুতু')) {
      return isBengali ? _getTBTestsBengali() : _getTBTestsEnglish();
    }

    // NEW: When to see doctor
    if (lowerMessage.contains('when') && (lowerMessage.contains('doctor') || lowerMessage.contains('ডাক্তার')) ||
        lowerMessage.contains('কখন') && lowerMessage.contains('চিকিৎসক')) {
      return isBengali ? _getWhenSeeDoctorBengali() : _getWhenSeeDoctorEnglish();
    }

    // NEW: Bangladesh TB Statistics
    if (lowerMessage.contains('bangladesh') || lowerMessage.contains('statistics') ||
        lowerMessage.contains('বাংলাদেশ') || lowerMessage.contains('পরিসংখ্যান') ||
        lowerMessage.contains('how many')) {
      return isBengali ? _getBangladeshStatsBengali() : _getBangladeshStatsEnglish();
    }

    // NEW: MDR-TB (Multi-Drug Resistant)
    if (lowerMessage.contains('mdr') || lowerMessage.contains('resistant') ||
        lowerMessage.contains('drug resistant') || lowerMessage.contains('প্রতিরোধী')) {
      return isBengali ? _getMDRTBBengali() : _getMDRTBEnglish();
    }

    // NEW: Latent vs Active TB
    if (lowerMessage.contains('latent') || lowerMessage.contains('active') ||
        lowerMessage.contains('sleeping') || lowerMessage.contains('সুপ্ত') ||
        lowerMessage.contains('সক্রিয়')) {
      return isBengali ? _getLatentActiveBengali() : _getLatentActiveEnglish();
    }

    // NEW: TB Myths
    if (lowerMessage.contains('myth') || lowerMessage.contains('misconception') ||
        lowerMessage.contains('ভ্রান্ত') || lowerMessage.contains('মিথ')) {
      return isBengali ? _getTBMythsBengali() : _getTBMythsEnglish();
    }

    // NEW: Nutrition for TB
    if (lowerMessage.contains('food') || lowerMessage.contains('nutrition') ||
        lowerMessage.contains('diet') || lowerMessage.contains('খাবার') ||
        lowerMessage.contains('পুষ্টি')) {
      return isBengali ? _getTBNutritionBengali() : _getTBNutritionEnglish();
    }

    // NEW: Pediatric TB (Children)
    if (lowerMessage.contains('child') || lowerMessage.contains('kid') ||
        lowerMessage.contains('baby') || lowerMessage.contains('শিশু') ||
        lowerMessage.contains('বাচ্চা')) {
      return isBengali ? _getPediatricTBBengali() : _getPediatricTBEnglish();
    }

    // NEW: TB/HIV Co-infection
    if (lowerMessage.contains('hiv') || lowerMessage.contains('aids') ||
        lowerMessage.contains('এইচআইভি') || lowerMessage.contains('এইডস')) {
      return isBengali ? _getTBHIVBengali() : _getTBHIVEnglish();
    }

    // NEW: Contact Tracing
    if (lowerMessage.contains('contact') || lowerMessage.contains('exposed') ||
        lowerMessage.contains('family') || lowerMessage.contains('সংস্পর্শ') ||
        lowerMessage.contains('পরিবার')) {
      return isBengali ? _getContactTracingBengali() : _getContactTracingEnglish();
    }

    // NEW: DOTS Treatment
    if (lowerMessage.contains('dots') || lowerMessage.contains('দোত্স') ||
        lowerMessage.contains('directly observed')) {
      return isBengali ? _getDOTSTreatmentBengali() : _getDOTSTreatmentEnglish();
    }

    // Default helpful response
    return isBengali ? _getDefaultResponseBengali() : _getDefaultResponseEnglish();
  }

  bool _containsBengali(String text) {
    return text.codeUnits.any((unit) => unit >= 0x0980 && unit <= 0x09FF);
  }

  bool _isMedicalQuestion(String message) {
    final medicalKeywords = [
      'diagnose', 'diagnosis', 'have tb', 'do i have', 
      'treatment', 'medicine', 'medication', 'cure',
      'disease', 'sick', 'ill', 'fever', 'cough',
      'chest pain', 'blood', 'should i', 'is it',
      'নির্ণয়', 'চিকিৎসা', 'ওষুধ', 'জ্বর', 'কাশি',
      'আমার কি', 'ব্যথা', 'রক্ত'
    ];

    return medicalKeywords.any((keyword) => message.contains(keyword));
  }

  // TB Prevention
  String _getTBPreventionEnglish() {
    return '''🛡️ TB Prevention:

⚠️ Medical Disclaimer: This is general educational information only. For personalized prevention advice, consult a healthcare professional.

1️⃣ **BCG Vaccination**
   • Given at birth in Bangladesh
   • Protects against severe TB in children
   • Doesn't fully prevent TB infection

2️⃣ **Good Ventilation**
   • Open windows regularly
   • Increase fresh air circulation
   • Reduces TB bacteria concentration

3️⃣ **Avoid Close Contact**
   • Keep distance from people with active TB
   • Don't share personal items
   • Use masks if exposed

4️⃣ **Strengthen Immunity**
   • Eat nutritious food (protein, vitamins)
   • Get enough sleep (7-8 hours)
   • Exercise regularly
   • Avoid smoking/alcohol

5️⃣ **Early Testing**
   • Get tested if exposed to TB patient
   • Regular health checkups
   • Contact tracing if diagnosed

🏥 If exposed to TB patient, consult doctor immediately for preventive treatment.''';
  }

  String _getTBPreventionBengali() {
    return '''🛡️ টিবি প্রতিরোধ:

⚠️ মেডিকেল দাবিত্যাগ: এটি শুধুমাত্র সাধারণ শিক্ষামূলক তথ্য। ব্যক্তিগত প্রতিরোধ পরামর্শের জন্য স্বাস্থ্যসেবা পেশাদারের সাথে পরামর্শ করুন।

1️⃣ **বিসিজি টিকা**
   • বাংলাদেশে জন্মের সময় দেওয়া হয়
   • শিশুদের মধ্যে গুরুতর টিবি থেকে রক্ষা করে
   • টিবি সংক্রমণ সম্পূর্ণভাবে প্রতিরোধ করে না

2️⃣ **ভালো বায়ুচলাচল**
   • নিয়মিত জানালা খুলুন
   • তাজা বাতাস চলাচল বাড়ান
   • টিবি ব্যাকটেরিয়ার ঘনত্ব কমায়

3️⃣ **ঘনিষ্ঠ যোগাযোগ এড়িয়ে চলুন**
   • সক্রিয় টিবি রোগীদের থেকে দূরত্ব বজায় রাখুন
   • ব্যক্তিগত জিনিস শেয়ার করবেন না
   • এক্সপোজড হলে মাস্ক ব্যবহার করুন

4️⃣ **রোগ প্রতিরোধ ক্ষমতা শক্তিশালী করুন**
   • পুষ্টিকর খাবার খান (প্রোটিন, ভিটামিন)
   • পর্যাপ্ত ঘুম পান (৭-৮ ঘন্টা)
   • নিয়মিত ব্যায়াম করুন
   • ধূমপান/অ্যালকোহল এড়িয়ে চলুন

5️⃣ **প্রারম্ভিক পরীক্ষা**
   • টিবি রোগীর সংস্পর্শে এলে পরীক্ষা করুন
   • নিয়মিত স্বাস্থ্য চেকআপ
   • নির্ণয় করা হলে যোগাযোগ ট্রেসিং

🏥 টিবি রোগীর সংস্পর্শে এলে প্রতিরোধমূলক চিকিৎসার জন্য অবিলম্বে ডাক্তারের পরামর্শ নিন।''';
  }

  // TB Transmission
  String _getTBTransmissionEnglish() {
    return '''🦠 How TB Spreads:

TB spreads through the air when a person with active pulmonary TB:
• Coughs
• Sneezes
• Speaks
• Sings

**Key Facts:**
✅ TB is airborne (not through touch/handshake)
✅ Spreads through tiny droplets in air
✅ Close contact over time increases risk
✅ Well-ventilated spaces reduce spread

**LOW Risk:**
• Brief contact (passing someone)
• Touching objects/surfaces
• Sharing food/utensils
• Hugging/handshaking

**HIGH Risk:**
• Living with active TB patient
• Close contact for hours daily
• Crowded/poorly ventilated spaces
• Healthcare workers without protection

**Important:**
⚠️ Only people with ACTIVE pulmonary TB spread it
⚠️ Latent TB is NOT contagious
⚠️ Treatment makes patient non-infectious within 2 weeks

🏥 If exposed, consult doctor for screening.''';
  }

  String _getTBTransmissionBengali() {
    return '''🦠 টিবি কীভাবে ছড়ায়:

সক্রিয় পালমোনারি টিবি রোগী যখন বাতাসের মাধ্যমে টিবি ছড়ায়:
• কাশি
• হাঁচি
• কথা বলা
• গান গাওয়া

**মূল তথ্য:**
✅ টিবি বায়ুবাহিত (স্পর্শ/হ্যান্ডশেকের মাধ্যমে নয়)
✅ বাতাসে ক্ষুদ্র ফোঁটার মাধ্যমে ছড়ায়
✅ সময়ের সাথে ঘনিষ্ঠ যোগাযোগ ঝুঁকি বাড়ায়
✅ ভালো বায়ুচলাচল স্থান বিস্তার কমায়

**নিম্ন ঝুঁকি:**
• সংক্ষিপ্ত যোগাযোগ (কাউকে পাশ কাটিয়ে যাওয়া)
• বস্তু/পৃষ্ঠ স্পর্শ করা
• খাবার/পাত্র শেয়ার করা
• আলিঙ্গন/হ্যান্ডশেকিং

**উচ্চ ঝুঁকি:**
• সক্রিয় টিবি রোগীর সাথে বসবাস
• দৈনিক ঘন্টার জন্য ঘনিষ্ঠ যোগাযোগ
• ভিড়/খারাপ বায়ুচলাচল স্থান
• সুরক্ষা ছাড়া স্বাস্থ্যসেবা কর্মী

**গুরুত্বপূর্ণ:**
⚠️ শুধুমাত্র সক্রিয় পালমোনারি টিবি রোগীরা এটি ছড়ায়
⚠️ সুপ্ত টিবি সংক্রামক নয়
⚠️ চিকিৎসা ২ সপ্তাহের মধ্যে রোগীকে অ-সংক্রামক করে তোলে

🏥 এক্সপোজড হলে স্ক্রিনিংয়ের জন্য ডাক্তারের পরামর্শ নিন।''';
  }

  // TB Treatment Information
  String _getTBTreatmentInfoEnglish() {
    return '''💊 TB Treatment Overview:

⚠️ Medical Disclaimer: This is general information. For treatment advice, you MUST consult a qualified doctor. Do not self-medicate.

**Treatment Duration:**
• 6-9 months typically
• Combination of 4 drugs initially
• Directly Observed Treatment Short-course (DOTS)

**Key Facts:**
✅ TB is CURABLE with proper treatment
✅ FREE treatment available in Bangladesh
✅ Symptoms improve within 2-3 weeks
✅ MUST complete full course (critical!)

**Why Full Course Matters:**
⚠️ Stopping early leads to:
   - TB returns stronger
   - Drug resistance (MDR-TB)
   - Treatment failure
   - Spread to others

**Side Effects:**
• Orange-colored urine (normal)
• Nausea, fatigue
• Report serious side effects to doctor
• Don't stop without doctor's advice

**Where to Get Treatment:**
🏥 Government TB centers (FREE)
🏥 DOTS centers nationwide
🏥 Upazila Health Complex
🏥 National Tuberculosis Control Program

📞 For treatment centers: Call 16263 (NTCP Hotline)

⚠️ This app does NOT provide treatment. Consult a doctor immediately if you have TB symptoms or positive results.''';
  }

  String _getTBTreatmentInfoBengali() {
    return '''💊 টিবি চিকিৎসা সংক্ষিপ্ত বিবরণ:

⚠️ মেডিকেল দাবিত্যাগ: এটি সাধারণ তথ্য। চিকিৎসা পরামর্শের জন্য, আপনাকে অবশ্যই একজন যোগ্য ডাক্তারের পরামর্শ নিতে হবে। স্ব-ওষুধ করবেন না।

**চিকিৎসার সময়কাল:**
• সাধারণত ৬-৯ মাস
• প্রাথমিকভাবে ৪টি ওষুধের সমন্বয়
• সরাসরি পর্যবেক্ষণ চিকিৎসা সংক্ষিপ্ত-কোর্স (ডটস)

**মূল তথ্য:**
✅ সঠিক চিকিৎসায় টিবি নিরাময়যোগ্য
✅ বাংলাদেশে বিনামূল্যে চিকিৎসা উপলব্ধ
✅ ২-৩ সপ্তাহের মধ্যে লক্ষণ উন্নতি হয়
✅ সম্পূর্ণ কোর্স সম্পূর্ণ করতে হবে (গুরুত্বপূর্ণ!)

**কেন সম্পূর্ণ কোর্স গুরুত্বপূর্ণ:**
⚠️ তাড়াতাড়ি থামলে:
   - টিবি শক্তিশালী হয়ে ফিরে আসে
   - ওষুধ প্রতিরোধ (এমডিআর-টিবি)
   - চিকিৎসা ব্যর্থতা
   - অন্যদের মধ্যে ছড়ানো

**পার্শ্ব প্রতিক্রিয়া:**
• কমলা রঙের প্রস্রাব (স্বাভাবিক)
• বমি বমি ভাব, ক্লান্তি
• গুরুতর পার্শ্ব প্রতিক্রিয়া ডাক্তারকে জানান
• ডাক্তারের পরামর্শ ছাড়া থামাবেন না

**চিকিৎসা কোথায় পাবেন:**
🏥 সরকারি টিবি কেন্দ্র (বিনামূল্যে)
🏥 দেশব্যাপী ডটস কেন্দ্র
🏥 উপজেলা স্বাস্থ্য কমপ্লেক্স
🏥 জাতীয় যক্ষ্মা নিয়ন্ত্রণ কর্মসূচি

📞 চিকিৎসা কেন্দ্রের জন্য: ১৬২৬৩ নম্বরে কল করুন (এনটিসিপি হটলাইন)

⚠️ এই অ্যাপ চিকিৎসা প্রদান করে না। আপনার টিবি লক্ষণ বা পজিটিভ ফলাফল থাকলে অবিলম্বে ডাক্তারের পরামর্শ নিন।''';
  }

  // Heatmap Explanation
  String _getHeatmapExplainEnglish() {
    return '''🔥 Heatmap Explanation:

The heatmap highlights areas in your X-ray that the AI model found significant:

**Color Meaning:**
🔴 **Red/Orange**: Highest AI attention
   • Areas model considers most important
   • Potential regions of concern

🟡 **Yellow**: Moderate attention
   • Secondary areas of interest

🟢 **Green/Blue**: Lower attention
   • Background/normal areas

**Important Notes:**
⚠️ Heatmap shows AI's ATTENTION, not diagnosis
⚠️ Red areas ≠ confirmed disease
⚠️ Only a doctor can interpret medical meaning
⚠️ Used for transparency and explanation

**Affected Regions:**
The app also shows specific regions like:
• Upper/Middle/Lower Right Lung
• Upper/Middle/Lower Left Lung
• Central/Peripheral zones

🏥 **Always consult a radiologist or doctor for proper interpretation of your X-ray and these AI highlights.**''';
  }

  String _getHeatmapExplainBengali() {
    return '''🔥 হিটম্যাপ ব্যাখ্যা:

হিটম্যাপ আপনার এক্স-রেতে সেই এলাকাগুলি হাইলাইট করে যা এআই মডেল গুরুত্বপূর্ণ মনে করেছে:

**রঙের অর্থ:**
🔴 **লাল/কমলা**: সর্বোচ্চ এআই মনোযোগ
   • মডেল সবচেয়ে গুরুত্বপূর্ণ মনে করে এমন এলাকা
   • সম্ভাব্য উদ্বেগের অঞ্চল

🟡 **হলুদ**: মধ্যম মনোযোগ
   • আগ্রহের গৌণ এলাকা

🟢 **সবুজ/নীল**: কম মনোযোগ
   • পটভূমি/স্বাভাবিক এলাকা

**গুরুত্বপূর্ণ নোট:**
⚠️ হিটম্যাপ এআই-এর মনোযোগ দেখায়, নির্ণয় নয়
⚠️ লাল এলাকা ≠ নিশ্চিত রোগ
⚠️ শুধুমাত্র একজন ডাক্তার চিকিৎসা অর্থ ব্যাখ্যা করতে পারেন
⚠️ স্বচ্ছতা এবং ব্যাখ্যার জন্য ব্যবহৃত

**প্রভাবিত অঞ্চল:**
অ্যাপ নির্দিষ্ট অঞ্চলও দেখায় যেমন:
• উপরের/মধ্য/নিম্ন ডান ফুসফুস
• উপরের/মধ্য/নিম্ন বাম ফুসফুস
• কেন্দ্রীয়/পেরিফেরাল জোন

🏥 **আপনার এক্স-রে এবং এই এআই হাইলাইটগুলির সঠিক ব্যাখ্যার জন্য সর্বদা একজন রেডিওলজিস্ট বা ডাক্তারের পরামর্শ নিন।**''';
  }

  // Accuracy Explanation
  String _getAccuracyExplainEnglish() {
    return '''🎯 About AI Accuracy:

Our AI model has been trained on thousands of chest X-rays, but it has limitations:

**Strengths:**
✅ Fast analysis (40 seconds)
✅ Consistent performance
✅ Can detect patterns humans might miss
✅ Available 24/7
✅ Helps screen large populations

**Limitations:**
⚠️ Not 100% accurate (no AI is)
⚠️ Can have false positives/negatives
⚠️ Trained on specific image types
⚠️ Cannot replace doctor's expertise
⚠️ Cannot consider patient history/symptoms

**Our Approach:**
• Model tested on validation data
• Provides confidence scores
• Shows heatmaps for transparency
• Always recommends professional consultation

**What This Means:**
📊 High probability (80-95%) → See doctor SOON
📊 Medium probability (50-79%) → Get professional evaluation
📊 Low probability (<50%) → Still consult if symptoms present

⚠️ **Critical:** Even with low probability, if you have symptoms, you MUST see a doctor. This tool helps screening, not diagnosis.

🏥 Always follow up with qualified healthcare professional.''';
  }

  String _getAccuracyExplainBengali() {
    return '''🎯 এআই নির্ভুলতা সম্পর্কে:

আমাদের এআই মডেল হাজার হাজার বুকের এক্স-রেতে প্রশিক্ষিত হয়েছে, কিন্তু এর সীমাবদ্ধতা রয়েছে:

**শক্তি:**
✅ দ্রুত বিশ্লেষণ (৪০ সেকেন্ড)
✅ সামঞ্জস্যপূর্ণ কর্মক্ষমতা
✅ মানুষ মিস করতে পারে এমন প্যাটার্ন সনাক্ত করতে পারে
✅ ২৪/৭ উপলব্ধ
✅ বড় জনসংখ্যা স্ক্রিন করতে সাহায্য করে

**সীমাবদ্ধতা:**
⚠️ ১০০% নির্ভুল নয় (কোনো এআই নয়)
⚠️ মিথ্যা পজিটিভ/নেগেটিভ হতে পারে
⚠️ নির্দিষ্ট ছবির ধরনে প্রশিক্ষিত
⚠️ ডাক্তারের দক্ষতা প্রতিস্থাপন করতে পারে না
⚠️ রোগীর ইতিহাস/লক্ষণ বিবেচনা করতে পারে না

**আমাদের পদ্ধতি:**
• মডেল যাচাইকরণ ডেটাতে পরীক্ষিত
• আত্মবিশ্বাস স্কোর প্রদান করে
• স্বচ্ছতার জন্য হিটম্যাপ দেখায়
• সর্বদা পেশাদার পরামর্শ সুপারিশ করে

**এর অর্থ কী:**
📊 উচ্চ সম্ভাবনা (৮০-৯৫%) → শীঘ্রই ডাক্তার দেখান
📊 মধ্যম সম্ভাবনা (৫০-৭৯%) → পেশাদার মূল্যায়ন পান
📊 নিম্ন সম্ভাবনা (<৫০%) → লক্ষণ উপস্থিত থাকলেও পরামর্শ নিন

⚠️ **গুরুত্বপূর্ণ:** এমনকি কম সম্ভাবনার সাথে, যদি আপনার লক্ষণ থাকে, আপনাকে অবশ্যই ডাক্তার দেখাতে হবে। এই টুল স্ক্রিনিং সাহায্য করে, নির্ণয় নয়।

🏥 সর্বদা যোগ্য স্বাস্থ্যসেবা পেশাদারের সাথে ফলো-আপ করুন।''';
  }

  // Greeting
  String _getGreetingEnglish() {
    return '''👋 Hello! Welcome to Drishti AI Assistant.

I'm here to help you with:
✅ App navigation and usage
✅ Understanding your results
✅ General TB information
✅ Saving/downloading reports

⚠️ Important: I cannot provide medical diagnosis or advice. For health concerns, please consult a qualified doctor.

How can I assist you today? 😊''';
  }

  String _getGreetingBengali() {
    return '''👋 হ্যালো! দৃষ্টি এআই সহায়কে স্বাগতম।

আমি আপনাকে সাহায্য করতে এখানে আছি:
✅ অ্যাপ নেভিগেশন এবং ব্যবহার
✅ আপনার ফলাফল বোঝা
✅ সাধারণ টিবি তথ্য
✅ রিপোর্ট সংরক্ষণ/ডাউনলোড করা

⚠️ গুরুত্বপূর্ণ: আমি চিকিৎসা নির্ণয় বা পরামর্শ প্রদান করতে পারি না। স্বাস্থ্য উদ্বেগের জন্য, দয়া করে একজন যোগ্য ডাক্তারের পরামর্শ নিন।

আজ আমি আপনাকে কীভাবে সাহায্য করতে পারি? 😊''';
  }

  // Thank You
  String _getThankYouEnglish() {
    return '''You're welcome! 😊

Remember:
✅ This app is a screening tool
✅ Always consult a doctor for diagnosis
✅ Free TB treatment available in Bangladesh

Need anything else? Feel free to ask!

Stay healthy! 💙''';
  }

  String _getThankYouBengali() {
    return '''আপনাকে স্বাগতম! 😊

মনে রাখবেন:
✅ এই অ্যাপ একটি স্ক্রিনিং টুল
✅ নির্ণয়ের জন্য সর্বদা ডাক্তারের পরামর্শ নিন
✅ বাংলাদেশে বিনামূল্যে টিবি চিকিৎসা উপলব্ধ

আর কিছু প্রয়োজন? নির্দ্বিধায় জিজ্ঞাসা করুন!

সুস্থ থাকুন! 💙''';
  }

  String _getMedicalDisclaimerResponse(bool isBengali) {
    if (isBengali) {
      return '''⚠️ চিকিৎসা দাবিত্যাগ: আমি একটি এআই সহায়ক, ডাক্তার বা চিকিৎসা পেশাদার নই।

আমি চিকিৎসা নির্ণয়, পরামর্শ বা চিকিৎসা ফলাফল ব্যাখ্যা করতে পারি না। যেকোনো স্বাস্থ্য সমস্যা, লক্ষণ বা চিকিৎসা প্রশ্নের জন্য অনুগ্রহ করে একজন যোগ্য স্বাস্থ্যসেবা পেশাদারের সাথে পরামর্শ করুন বা অবিলম্বে একটি চিকিৎসা কেন্দ্রে যান।

আপনার স্বাস্থ্য গুরুত্বপূর্ণ। শুধুমাত্র একজন ডাক্তার সঠিক নির্ণয় এবং চিকিৎসা পরিকল্পনা প্রদান করতে পারেন।

আমি কি অ্যাপ ব্যবহারে আপনাকে সাহায্য করতে পারি?''';
    }

    return '''⚠️ MEDICAL DISCLAIMER: I am an AI assistant, not a doctor or medical professional.

I cannot provide medical diagnosis, advice, or interpret medical results. For any health concerns, symptoms, or medical questions, please consult a qualified healthcare professional or visit a medical facility immediately.

Your health is important. Only a doctor can provide accurate diagnosis and treatment plans.

Can I help you with using the app instead?''';
  }

  String _getUploadHelpEnglish() {
    return '''I'll help you upload an X-ray image! Here's how:

1. Tap "Upload X-Ray" button on the home screen
2. Select your image from your device gallery
3. The app will validate if it's an X-ray image
4. If valid, analysis begins automatically (takes ~2 seconds)
5. View your results on the next screen

⚠️ Important: This app provides AI-assisted analysis but cannot replace professional medical diagnosis. Always discuss results with a healthcare provider.

Need help with anything else?''';
  }

  String _getUploadHelpBengali() {
    return '''আমি আপনাকে এক্স-রে ছবি আপলোড করতে সাহায্য করব! এভাবে করুন:

1. হোম স্ক্রিনে "এক্স-রে আপলোড করুন" বাটনে ট্যাপ করুন
2. আপনার ডিভাইস গ্যালারি থেকে ছবি নির্বাচন করুন
3. অ্যাপটি যাচাই করবে এটি একটি এক্স-রে ছবি কিনা
4. বৈধ হলে, বিশ্লেষণ স্বয়ংক্রিয়ভাবে শুরু হয় (~২ সেকেন্ড)
5. পরবর্তী স্ক্রিনে আপনার ফলাফল দেখুন

⚠️ গুরুত্বপূর্ণ: এই অ্যাপটি এআই-সহায়তা বিশ্লেষণ প্রদান করে কিন্তু পেশাদার চিকিৎসা নির্ণয়ের বিকল্প হতে পারে না। সর্বদা একজন স্বাস্থ্যসেবা প্রদানকারীর সাথে ফলাফল আলোচনা করুন।

আর কিছুতে সাহায্য দরকার?''';
  }

  String _getResultsHelpEnglish() {
    return '''The results screen shows your analysis:

📊 TB Probability: Percentage likelihood
🚨 Risk Level: High (red), Medium (orange), or Low (green)
✅ Confidence Score: How confident the AI is in its analysis

🎨 Toggle Heatmap: Shows highlighted areas of interest
💾 Save Report: Exports detailed analysis to your device

⚠️ REMINDER: These are AI-generated estimates, not medical diagnoses. Please consult a doctor to discuss your results and next steps.

Would you like help with anything else?''';
  }

  String _getResultsHelpBengali() {
    return '''ফলাফল স্ক্রিনে আপনার বিশ্লেষণ দেখায়:

📊 টিবি সম্ভাবনা: শতকরা সম্ভাবনা
🚨 ঝুঁকির মাত্রা: উচ্চ (লাল), মাঝারি (কমলা), বা নিম্ন (সবুজ)
✅ আত্মবিশ্বাস স্কোর: এআই কতটা আত্মবিশ্বাসী

🎨 হিটম্যাপ টগল: আগ্রহের হাইলাইট করা এলাকা দেখায়
💾 রিপোর্ট সংরক্ষণ: আপনার ডিভাইসে বিস্তারিত বিশ্লেষণ রপ্তানি করে

⚠️ অনুস্মারক: এগুলি এআই-উৎপন্ন অনুমান, চিকিৎসা নির্ণয় নয়। আপনার ফলাফল এবং পরবর্তী পদক্ষেপ নিয়ে আলোচনা করতে একজন ডাক্তারের সাথে পরামর্শ করুন।

অন্য কিছুতে সাহায্য চান?''';
  }

  String _getTBInfoEnglish() {
    return '''Tuberculosis (TB) is an infectious disease caused by bacteria that primarily affects the lungs.

📚 Key Facts:
• TB spreads through the air when infected people cough or sneeze
• It's treatable and curable with proper medication
• Early detection is crucial for successful treatment

⚠️ If you suspect TB exposure or have symptoms, please consult a healthcare professional immediately. This app can assist with screening, but only a doctor can diagnose and treat TB.

Need more information about using this app?''';
  }

  String _getTBInfoBengali() {
    return '''যক্ষ্মা (টিবি) একটি সংক্রামক রোগ যা ব্যাকটেরিয়া দ্বারা সৃষ্ট এবং প্রাথমিকভাবে ফুসফুসকে প্রভাবিত করে।

📚 মূল তথ্য:
• সংক্রমিত ব্যক্তি কাশি বা হাঁচি দিলে বাতাসের মাধ্যমে টিবি ছড়ায়
• সঠিক ওষুধে এটি চিকিৎসাযোগ্য এবং নিরাময়যোগ্য
• সফল চিকিৎসার জন্য প্রাথমিক সনাক্তকরণ অত্যন্ত গুরুত্বপূর্ণ

⚠️ আপনার যদি টিবি সংক্রমণের সন্দেহ থাকে বা লক্ষণ থাকে, তাহলে অবিলম্বে একজন স্বাস্থ্যসেবা পেশাদারের সাথে পরামর্শ করুন। এই অ্যাপটি স্ক্রিনিংয়ে সহায়তা করতে পারে, কিন্তু শুধুমাত্র একজন ডাক্তার টিবি নির্ণয় এবং চিকিৎসা করতে পারেন।

এই অ্যাপ ব্যবহার সম্পর্কে আরও তথ্য দরকার?''';
  }

  String _getTBSymptomsDisclaimerEnglish() {
    return '''⚠️ MEDICAL DISCLAIMER: I cannot diagnose conditions based on symptoms. Only a doctor can do that.

Common TB symptoms (educational purpose only):
• Persistent cough lasting 2-3+ weeks
• Coughing up blood or mucus
• Chest pain
• Fatigue and weakness
• Weight loss
• Fever and night sweats

🚨 If you experience any of these symptoms, please see a doctor immediately. Do not self-diagnose. Early professional evaluation is essential.

Can I help you navigate the app?''';
  }

  String _getTBSymptomsDisclaimerBengali() {
    return '''⚠️ চিকিৎসা দাবিত্যাগ: আমি লক্ষণের ভিত্তিতে রোগ নির্ণয় করতে পারি না। শুধুমাত্র একজন ডাক্তার তা করতে পারেন।

সাধারণ টিবি লক্ষণ (শুধুমাত্র শিক্ষামূলক উদ্দেশ্যে):
• ২-৩+ সপ্তাহ ধরে ক্রমাগত কাশি
• রক্ত বা শ্লেষ্মা সহ কাশি
• বুকে ব্যথা
• ক্লান্তি এবং দুর্বলতা
• ওজন হ্রাস
• জ্বর এবং রাতে ঘাম

🚨 আপনার যদি এই লক্ষণগুলির কোনোটি থাকে, তাহলে অবিলম্বে একজন ডাক্তারের সাথে দেখা করুন। স্ব-নির্ণয় করবেন না। প্রাথমিক পেশাদার মূল্যায়ন অপরিহার্য।

আমি কি আপনাকে অ্যাপ নেভিগেট করতে সাহায্য করতে পারি?''';
  }

  String _getSaveReportHelpEnglish() {
    return '''To save your analysis report:

1. Open your results screen after analysis
2. Tap the "Save Report" button at the bottom
3. The report will be saved to your device storage
4. You'll see a confirmation message with the file location

📄 The report includes:
• Analysis date and time
• TB probability and risk level
• Confidence score
• Interpretation and recommendations

You can share this report with your doctor for professional consultation.

Anything else I can help with?''';
  }

  String _getSaveReportHelpBengali() {
    return '''আপনার বিশ্লেষণ রিপোর্ট সংরক্ষণ করতে:

1. বিশ্লেষণের পরে আপনার ফলাফল স্ক্রিন খুলুন
2. নীচে "রিপোর্ট সংরক্ষণ করুন" বাটনে ট্যাপ করুন
3. রিপোর্টটি আপনার ডিভাইস স্টোরেজে সংরক্ষিত হবে
4. আপনি ফাইলের অবস্থান সহ একটি নিশ্চিতকরণ বার্তা দেখবেন

📄 রিপোর্টে অন্তর্ভুক্ত:
• বিশ্লেষণের তারিখ এবং সময়
• টিবি সম্ভাবনা এবং ঝুঁকির মাত্রা
• আত্মবিশ্বাস স্কোর
• ব্যাখ্যা এবং সুপারিশ

আপনি পেশাদার পরামর্শের জন্য এই রিপোর্টটি আপনার ডাক্তারের সাথে শেয়ার করতে পারেন।

আর কিছুতে সাহায্য করতে পারি?''';
  }

  String _getLanguageHelpEnglish() {
    return '''To change the app language:

1. Look at the top-right corner of the home screen
2. Tap the 🌍 globe icon
3. The language will toggle between English and Bengali (বাংলা)

All app text, buttons, and messages will update to your selected language.

I can respond in both English and Bengali, so feel free to ask questions in either language!

Need help with anything else?''';
  }

  String _getLanguageHelpBengali() {
    return '''অ্যাপের ভাষা পরিবর্তন করতে:

1. হোম স্ক্রিনের উপরের-ডান কোণে দেখুন
2. 🌍 গ্লোব আইকনে ট্যাপ করুন
3. ভাষাটি ইংরেজি এবং বাংলা এর মধ্যে টগল হবে

সমস্ত অ্যাপ টেক্সট, বাটন এবং বার্তা আপনার নির্বাচিত ভাষায় আপডেট হবে।

আমি ইংরেজি এবং বাংলা উভয় ভাষায় উত্তর দিতে পারি, তাই যেকোনো ভাষায় প্রশ্ন করতে নির্দ্বিধায়!

অন্য কিছুতে সাহায্য দরকার?''';
  }

  String _getDefaultResponseEnglish() {
    return '''Hello! I'm the Project Drishti AI Assistant. I can help you with:

📱 App Navigation:
• Uploading X-ray images
• Understanding results
• Saving reports
• Changing language

📚 General TB Information:
• What is TB
• Prevention tips
• When to seek medical help

⚠️ Important: I cannot provide medical diagnosis or advice. For health concerns, please consult a doctor.

What would you like help with?''';
  }

  String _getDefaultResponseBengali() {
    return '''
স্বাগত! আমি প্রোজেক্ট দৃষ্টি এআই সহায়ক। আমি আপনাকে সাহায্য করতে পারি:

📱 অ্যাপ নেভিগেশন:
• এক্স-রে ছবি আপলোড করা
• ফলাফল বোঝা
• রিপোর্ট সংরক্ষণ করা
• ভাষা পরিবর্তন করা

📚 সাধারণ টিবি তথ্য:
• টিবি কি
• প্রতিরোধের টিপস
• কখন চিকিৎসা সাহায্য নিতে হবে

⚠️ গুরুত্বপূর্ণ: আমি চিকিৎসা নির্ণয় বা পরামর্শ প্রদান করতে পারি না। স্বাস্থ্য সমস্যার জন্য, অনুগ্রহ করে একজন ডাক্তারের সাথে পরামর্শ করুন।

আপনি কিসে সাহায্য চান?''';
  }

  // NEW COMPREHENSIVE TB Q&A RESPONSES

  String _getBCGVaccineEnglish() {
    return '''💉 BCG Vaccine Information:

⚠️ Disclaimer: Consult a healthcare provider for personalized vaccination advice.

**What is BCG?**
• Bacillus Calmette-Guérin vaccine
• Given at birth in Bangladesh
• Protects against severe TB in children

**Protection Level:**
• 70-80% protection against TB meningitis
• 50% protection against pulmonary TB
• More effective in children than adults

**Who Should Get It:**
• All newborns in Bangladesh
• Healthcare workers (if not vaccinated)
• People traveling to high TB areas

💡 BCG doesn't guarantee 100% protection. Good hygiene and avoiding exposure remain important.''';
  }

  String _getBCGVaccineBengali() {
    return '''💉 বিসিজি টিকার তথ্য:

⚠️ দাবিত্যাগ: ব্যক্তিগত টিকা পরামর্শের জন্য স্বাস্থ্যসেবা প্রদানকারীর সাথে পরামর্শ করুন।

**বিসিজি কি?**
• ব্যাসিলাস ক্যালমেট-গুয়েরিন টিকা
• বাংলাদেশে জন্মের সময় দেওয়া হয়
• শিশুদের গুরুতর টিবি থেকে রক্ষা করে

**সুরক্ষার মাত্রা:**
• টিবি মেনিনজাইটিস থেকে ৭০-৮০% সুরক্ষা
• পালমোনারি টিবি থেকে ৫০% সুরক্ষা
• প্রাপ্তবয়স্কদের চেয়ে শিশুদের ক্ষেত্রে বেশি কার্যকর

**কার নেওয়া উচিত:**
• বাংলাদেশের সব নবজাতক
• স্বাস্থ্যকর্মীরা (যদি টিকা না নিয়ে থাকেন)
• উচ্চ টিবি এলাকায় ভ্রমণকারীরা

💡 বিসিজি ১০০% সুরক্ষার গ্যারান্টি দেয় না। ভাল স্বাস্থ্যবিধি এবং এক্সপোজার এড়ানো গুরুত্বপূর্ণ থাকে।''';
  }

  String _getTBTestsEnglish() {
    return '''🔬 TB Diagnostic Tests:

⚠️ Consult a doctor to determine which test is appropriate for you.

**1. Sputum Test (Most Common)**
• Examines mucus from lungs
• Takes 2-3 days for results
• Free at government hospitals

**2. GeneXpert (Rapid TB Test)**
• Results in 2 hours
• Detects TB and drug resistance
• More accurate than sputum smear

**3. Chest X-ray**
• Shows lung abnormalities
• Quick screening tool
• Cannot confirm TB alone

**4. TB Culture Test**
• Most accurate (gold standard)
• Takes 4-8 weeks
• Identifies drug resistance

**5. Tuberculin Skin Test (TST)**
• Checks for TB infection
• Results in 48-72 hours
• Can't distinguish active from latent TB

📍 Visit your nearest TB clinic for free testing.''';
  }

  String _getTBTestsBengali() {
    return '''🔬 টিবি নির্ণয়ের পরীক্ষা:

⚠️ আপনার জন্য কোন পরীক্ষা উপযুক্ত তা নির্ধারণ করতে একজন ডাক্তারের সাথে পরামর্শ করুন।

**১. থুতু পরীক্ষা (সবচেয়ে সাধারণ)**
• ফুসফুস থেকে শ্লেষ্মা পরীক্ষা করা হয়
• ফলাফলের জন্য ২-৩ দিন লাগে
• সরকারি হাসপাতালে বিনামূল্যে

**২. জিনএক্সপার্ট (দ্রুত টিবি পরীক্ষা)**
• ২ ঘণ্টায় ফলাফল
• টিবি এবং ওষুধ প্রতিরোধ সনাক্ত করে
• থুতু স্মিয়ারের চেয়ে বেশি নির্ভুল

**৩. বুকের এক্স-রে**
• ফুসফুসের অস্বাভাবিকতা দেখায়
• দ্রুত স্ক্রীনিং টুল
• একা টিবি নিশ্চিত করতে পারে না

**৪. টিবি কালচার পরীক্ষা**
• সবচেয়ে নির্ভুল (গোল্ড স্ট্যান্ডার্ড)
• ৪-৮ সপ্তাহ লাগে
• ওষুধ প্রতিরোধ সনাক্ত করে

**৫. টিউবারকিউলিন স্কিন টেস্ট (টিএসটি)**
• টিবি সংক্রমণ পরীক্ষা করে
• ৪৮-৭২ ঘণ্টায় ফলাফল
• সক্রিয় এবং সুপ্ত টিবির মধ্যে পার্থক্য করতে পারে না

📍 বিনামূল্যে পরীক্ষার জন্য আপনার নিকটতম টিবি ক্লিনিকে যান।''';
  }

  String _getWhenSeeDoctorEnglish() {
    return '''🏥 When to See a Doctor:

⚠️ SEEK IMMEDIATE MEDICAL ATTENTION IF YOU HAVE:

**Urgent Symptoms:**
• Cough lasting more than 2-3 weeks
• Coughing up blood or bloody mucus
• Unexplained weight loss (>5 kg)
• Night sweats that soak your clothes
• Persistent fever (>2 weeks)
• Severe chest pain when breathing
• Extreme fatigue and weakness

**High-Risk Exposure:**
• Close contact with TB patient
• Living with someone diagnosed with TB
• HIV positive or immunocompromised

**After X-ray Analysis:**
• High TB probability result from this app
• Any concerning findings on X-ray

🚨 DO NOT DELAY: Early detection saves lives. TB is curable with proper treatment.

📍 Visit nearest TB clinic or government hospital - testing is FREE in Bangladesh.''';
  }

  String _getWhenSeeDoctorBengali() {
    return '''🏥 কখন ডাক্তার দেখাবেন:

⚠️ অবিলম্বে চিকিৎসা সহায়তা নিন যদি আপনার থাকে:

**জরুরি লক্ষণ:**
• ২-৩ সপ্তাহের বেশি সময় ধরে কাশি
• রক্ত বা রক্তযুক্ত শ্লেষ্মা কাশি
• অব্যাখ্যাত ওজন হ্রাস (>৫ কেজি)
• রাতের ঘাম যা আপনার কাপড় ভিজিয়ে দেয়
• ক্রমাগত জ্বর (>২ সপ্তাহ)
• শ্বাস নেওয়ার সময় গুরুতর বুকে ব্যথা
• চরম ক্লান্তি এবং দুর্বলতা

**উচ্চ ঝুঁকির এক্সপোজার:**
• টিবি রোগীর সাথে ঘনিষ্ঠ যোগাযোগ
• টিবি রোগ নির্ণয়কৃত কারো সাথে বসবাস
• এইচআইভি পজিটিভ বা রোগপ্রতিরোধ ক্ষমতা দুর্বল

**এক্স-রে বিশ্লেষণের পরে:**
• এই অ্যাপ থেকে উচ্চ টিবি সম্ভাবনার ফলাফল
• এক্স-রেতে কোনো উদ্বেগজনক ফলাফল

🚨 বিলম্ব করবেন না: প্রাথমিক সনাক্তকরণ জীবন বাঁচায়। সঠিক চিকিৎসায় টিবি নিরাময়যোগ্য।

📍 নিকটতম টিবি ক্লিনিক বা সরকারি হাসপাতালে যান - বাংলাদেশে পরীক্ষা বিনামূল্যে।''';
  }

  String _getBangladeshStatsEnglish() {
    return '''📊 TB in Bangladesh - Key Statistics:

**Current Situation (2024):**
• ~360,000 new TB cases annually
• 7th highest TB burden globally
• 45,000 deaths per year from TB

**Treatment Success:**
• 95% cure rate with proper treatment
• Free treatment available nationwide
• 6-month standard treatment duration

**High-Risk Groups:**
• Urban slum dwellers
• Healthcare workers
• People with diabetes or HIV
• Smokers and malnourished individuals

**Government Initiatives:**
• National TB Control Program (NTP)
• Free diagnosis and treatment
• Community DOTS centers
• GeneXpert machines nationwide

💡 Bangladesh has made significant progress in TB control, but early detection remains crucial.

📞 National TB Hotline: 16263 (Toll-free)''';
  }

  String _getBangladeshStatsBengali() {
    return '''📊 বাংলাদেশে টিবি - মূল পরিসংখ্যান:

**বর্তমান পরিস্থিতি (২০২৪):**
• বার্ষিক ~৩,৬০,০০০ নতুন টিবি কেস
• বিশ্বব্যাপী ৭ম সর্বোচ্চ টিবি বোঝা
• টিবি থেকে বছরে ৪৫,০০০ মৃত্যু

**চিকিৎসার সাফল্য:**
• সঠিক চিকিৎসায় ৯৫% নিরাময়ের হার
• দেশব্যাপী বিনামূল্যে চিকিৎসা উপলব্ধ
• ৬ মাসের মান চিকিৎসার সময়কাল

**উচ্চ ঝুঁকির গ্রুপ:**
• শহুরে বস্তিবাসী
• স্বাস্থ্যকর্মীরা
• ডায়াবেটিস বা এইচআইভি আক্রান্ত ব্যক্তিরা
• ধূমপায়ী এবং অপুষ্ট ব্যক্তিরা

**সরকারি উদ্যোগ:**
• জাতীয় টিবি নিয়ন্ত্রণ কর্মসূচি (এনটিপি)
• বিনামূল্যে নির্ণয় এবং চিকিৎসা
• কমিউনিটি ডটস সেন্টার
• দেশব্যাপী জিনএক্সপার্ট মেশিন

💡 বাংলাদেশ টিবি নিয়ন্ত্রণে উল্লেখযোগ্য অগ্রগতি করেছে, তবে প্রাথমিক সনাক্তকরণ অত্যন্ত গুরুত্বপূর্ণ।

📞 জাতীয় টিবি হটলাইন: ১৬২৬৩ (টোল-ফ্রি)''';
  }

  String _getMDRTBEnglish() {
    return '''⚠️ MDR-TB (Multi-Drug Resistant TB):

**What is MDR-TB?**
• TB that doesn't respond to standard drugs
• Resistant to Isoniazid and Rifampicin
• More difficult and expensive to treat

**Causes:**
• Incomplete TB treatment
• Irregular medication intake
• Poor quality TB drugs
• Previous TB treatment failure

**Treatment:**
• 18-24 months duration (vs 6 months)
• More toxic medications
• Higher cost but FREE in Bangladesh
• Requires strict adherence

**Prevention:**
• Complete full TB treatment course
• Never miss doses
• Don't share medications
• Follow doctor's instructions exactly

🚨 MDR-TB is serious but curable. Early detection and complete treatment are essential.

📍 MDR-TB treatment available at specialized centers nationwide.''';
  }

  String _getMDRTBBengali() {
    return '''⚠️ এমডিআর-টিবি (মাল্টি-ড্রাগ রেজিস্ট্যান্ট টিবি):

**এমডিআর-টিবি কি?**
• টিবি যা স্ট্যান্ডার্ড ওষুধে সাড়া দেয় না
• আইসোনিয়াজিড এবং রিফাম্পিসিন প্রতিরোধী
• চিকিৎসা করা আরও কঠিন এবং ব্যয়বহুল

**কারণ:**
• অসম্পূর্ণ টিবি চিকিৎসা
• অনিয়মিত ওষুধ সেবন
• নিম্নমানের টিবি ওষুধ
• পূর্ববর্তী টিবি চিকিৎসা ব্যর্থতা

**চিকিৎসা:**
• ১৮-২৪ মাসের সময়কাল (বনাম ৬ মাস)
• আরও বিষাক্ত ওষুধ
• বেশি খরচ কিন্তু বাংলাদেশে বিনামূল্যে
• কঠোর আনুগত্য প্রয়োজন

**প্রতিরোধ:**
• সম্পূর্ণ টিবি চিকিৎসা কোর্স সম্পন্ন করুন
• কখনো ডোজ মিস করবেন না
• ওষুধ শেয়ার করবেন না
• ডাক্তারের নির্দেশাবলী হুবহু অনুসরণ করুন

🚨 এমডিআর-টিবি গুরুতর কিন্তু নিরাময়যোগ্য। প্রাথমিক সনাক্তকরণ এবং সম্পূর্ণ চিকিৎসা অপরিহার্য।

📍 দেশব্যাপী বিশেষায়িত কেন্দ্রে এমডিআর-টিবি চিকিৎসা উপলব্ধ।''';
  }

  String _getLatentActiveEnglish() {
    return '''🔍 Latent TB vs Active TB:

**Latent TB (Sleeping TB):**
• TB bacteria in body but inactive
• No symptoms, not contagious
• Cannot spread to others
• 5-10% chance of becoming active
• Detected by skin test or blood test
• Treatment: 3-6 months preventive therapy

**Active TB (Disease):**
• TB bacteria actively multiplying
• Causes symptoms (cough, fever, etc.)
• Highly contagious through air
• Can damage lungs and organs
• Detected by X-ray, sputum test
• Treatment: 6 months full therapy

**Key Differences:**
| Feature | Latent | Active |
|---------|--------|--------|
| Symptoms | None | Yes |
| Contagious | No | Yes |
| Feels Sick | No | Yes |
| X-ray Normal | Usually | Abnormal |
| Needs Treatment | Optional | Mandatory |

💡 Treating latent TB prevents active disease.''';
  }

  String _getLatentActiveBengali() {
    return '''🔍 সুপ্ত টিবি বনাম সক্রিয় টিবি:

**সুপ্ত টিবি (ঘুমন্ত টিবি):**
• শরীরে টিবি ব্যাকটেরিয়া কিন্তু নিষ্ক্রিয়
• কোন লক্ষণ নেই, সংক্রামক নয়
• অন্যদের মধ্যে ছড়াতে পারে না
• সক্রিয় হওয়ার ৫-১০% সম্ভাবনা
• স্কিন টেস্ট বা রক্ত পরীক্ষা দ্বারা সনাক্ত
• চিকিৎসা: ৩-৬ মাসের প্রতিরোধমূলক থেরাপি

**সক্রিয় টিবি (রোগ):**
• টিবি ব্যাকটেরিয়া সক্রিয়ভাবে বহুগুণ হচ্ছে
• লক্ষণ সৃষ্টি করে (কাশি, জ্বর, ইত্যাদি)
• বাতাসের মাধ্যমে অত্যন্ত সংক্রামক
• ফুসফুস এবং অঙ্গের ক্ষতি করতে পারে
• এক্স-রে, থুতু পরীক্ষা দ্বারা সনাক্ত
• চিকিৎসা: ৬ মাসের সম্পূর্ণ থেরাপি

**মূল পার্থক্য:**
| বৈশিষ্ট্য | সুপ্ত | সক্রিয় |
|---------|--------|--------|
| লক্ষণ | নেই | আছে |
| সংক্রামক | না | হ্যাঁ |
| অসুস্থ বোধ | না | হ্যাঁ |
| এক্স-রে স্বাভাবিক | সাধারণত | অস্বাভাবিক |
| চিকিৎসা প্রয়োজন | ঐচ্ছিক | বাধ্যতামূলক |

💡 সুপ্ত টিবির চিকিৎসা সক্রিয় রোগ প্রতিরোধ করে।''';
  }

  String _getTBMythsEnglish() {
    return '''❌ TB Myths vs ✅ Facts:

**MYTH #1:** TB spreads through touching
**FACT:** TB spreads only through air when an infected person coughs/sneezes

**MYTH #2:** TB is incurable
**FACT:** 95% cure rate with proper 6-month treatment

**MYTH #3:** TB only affects lungs
**FACT:** Can affect kidneys, brain, bones, spine (extrapulmonary TB)

**MYTH #4:** Once cured, you can't get TB again
**FACT:** You can get reinfected if exposed again

**MYTH #5:** TB medication makes you infertile
**FACT:** TB drugs don't cause infertility. Untreated TB can affect reproductive health.

**MYTH #6:** You must isolate for entire treatment
**FACT:** After 2-3 weeks of treatment, most people are no longer contagious

**MYTH #7:** Traditional remedies can cure TB
**FACT:** Only prescribed anti-TB medications cure TB

💡 Don't believe myths. Trust medical science and doctors.''';
  }

  String _getTBMythsBengali() {
    return '''❌ টিবি ভ্রান্ত ধারণা বনাম ✅ সত্য:

**ভ্রান্ত ধারণা #১:** স্পর্শের মাধ্যমে টিবি ছড়ায়
**সত্য:** শুধুমাত্র বাতাসের মাধ্যমে ছড়ায় যখন সংক্রামিত ব্যক্তি কাশি/হাঁচি দেয়

**ভ্রান্ত ধারণা #২:** টিবি নিরাময়যোগ্য নয়
**সত্য:** সঠিক ৬ মাসের চিকিৎসায় ৯৫% নিরাময়ের হার

**ভ্রান্ত ধারণা #৩:** টিবি শুধুমাত্র ফুসফুসকে প্রভাবিত করে
**সত্য:** কিডনি, মস্তিষ্ক, হাড়, মেরুদণ্ডকে প্রভাবিত করতে পারে (এক্সট্রাপালমোনারি টিবি)

**ভ্রান্ত ধারণা #৪:** একবার নিরাময় হলে আবার টিবি হতে পারে না
**সত্য:** আবার এক্সপোজ হলে পুনরায় সংক্রমিত হতে পারেন

**ভ্রান্ত ধারণা #৫:** টিবি ওষুধ আপনাকে বন্ধ্যা করে দেয়
**সত্য:** টিবি ওষুধ বন্ধ্যাত্ব সৃষ্টি করে না। অচিকিৎসিত টিবি প্রজনন স্বাস্থ্যকে প্রভাবিত করতে পারে।

**ভ্রান্ত ধারণা #৬:** সম্পূর্ণ চিকিৎসার জন্য আপনাকে আলাদা থাকতে হবে
**সত্য:** চিকিৎসার ২-৩ সপ্তাহ পরে, বেশিরভাগ মানুষ আর সংক্রামক থাকে না

**ভ্রান্ত ধারণা #৭:** ঐতিহ্যবাহী প্রতিকার টিবি নিরাময় করতে পারে
**সত্য:** শুধুমাত্র নির্ধারিত অ্যান্টি-টিবি ওষুধ টিবি নিরাময় করে

💡 ভ্রান্ত ধারণায় বিশ্বাস করবেন না। চিকিৎসা বিজ্ঞান এবং ডাক্তারদের বিশ্বাস করুন।''';
  }

  String _getTBNutritionEnglish() {
    return '''🥗 Nutrition for TB Patients:

⚠️ Consult a nutritionist for personalized diet plan.

**Essential Nutrients:**

**1. Protein (Build & Repair)**
• Eggs, fish, chicken, lentils, beans
• 1.2-1.5g per kg body weight daily
• Helps repair damaged tissues

**2. Vitamins**
• Vitamin D: Sunlight, fish, eggs
• Vitamin C: Citrus fruits, guava
• Vitamin B: Whole grains, nuts
• Vitamin A: Carrots, spinach, pumpkin

**3. Minerals**
• Iron: Red meat, leafy greens
• Zinc: Nuts, seeds, dairy
• Selenium: Fish, eggs, mushrooms

**4. Calories**
• 2500-3000 calories daily
• Small frequent meals (6-7 times)

**Foods to AVOID:**
❌ Alcohol (interferes with TB drugs)
❌ Tobacco/smoking
❌ Excessive sugar
❌ Processed/junk food

**Healthy Meal Plan:**
• Breakfast: Eggs, roti, milk
• Mid-morning: Fruits, nuts
• Lunch: Rice, fish, vegetables
• Evening: Yogurt, banana
• Dinner: Roti, lentils, chicken

💧 Drink 8-10 glasses of water daily.''';
  }

  String _getTBNutritionBengali() {
    return '''🥗 টিবি রোগীদের জন্য পুষ্টি:

⚠️ ব্যক্তিগত ডায়েট প্ল্যানের জন্য একজন পুষ্টিবিদের সাথে পরামর্শ করুন।

**অপরিহার্য পুষ্টি উপাদান:**

**১. প্রোটিন (নির্মাণ এবং মেরামত)**
• ডিম, মাছ, মুরগি, ডাল, বিন
• প্রতিদিন প্রতি কেজি শরীরের ওজনে ১.২-১.৫গ্রাম
• ক্ষতিগ্রস্ত টিস্যু মেরামতে সাহায্য করে

**২. ভিটামিন**
• ভিটামিন ডি: সূর্যালোক, মাছ, ডিম
• ভিটামিন সি: সাইট্রাস ফল, পেয়ারা
• ভিটামিন বি: সম্পূর্ণ শস্য, বাদাম
• ভিটামিন এ: গাজর, পালং শাক, কুমড়া

**৩. খনিজ**
• আয়রন: লাল মাংস, পাতাযুক্ত সবুজ শাক
• জিংক: বাদাম, বীজ, দুগ্ধজাত
• সেলেনিয়াম: মাছ, ডিম, মাশরুম

**৪. ক্যালোরি**
• দৈনিক ২৫০০-৩০০০ ক্যালোরি
• ছোট ঘন ঘন খাবার (৬-৭ বার)

**যেসব খাবার এড়িয়ে চলুন:**
❌ অ্যালকোহল (টিবি ওষুধে হস্তক্ষেপ করে)
❌ তামাক/ধূমপান
❌ অতিরিক্ত চিনি
❌ প্রক্রিয়াজাত/জাংক ফুড

**স্বাস্থ্যকর খাবারের পরিকল্পনা:**
• সকালের নাস্তা: ডিম, রুটি, দুধ
• মধ্য-সকাল: ফল, বাদাম
• দুপুরের খাবার: ভাত, মাছ, সবজি
• সন্ধ্যা: দই, কলা
• রাতের খাবার: রুটি, ডাল, মুরগি

💧 প্রতিদিন ৮-১০ গ্লাস পানি পান করুন।''';
  }

  String _getPediatricTBEnglish() {
    return '''👶 TB in Children:

⚠️ Always consult a pediatrician for child TB concerns.

**Why Children Are Vulnerable:**
• Weaker immune systems
• More likely to develop severe TB
• Can progress rapidly to TB meningitis
• Higher risk if malnourished

**Common Symptoms in Children:**
• Persistent cough (>2 weeks)
• Fever that doesn't go away
• Weight loss or poor weight gain
• Fatigue, less playful
• Enlarged lymph nodes
• Night sweats

**Diagnosis Challenges:**
• Children can't produce sputum easily
• Gastric aspirate tests used instead
• X-rays less clear than adults
• Clinical diagnosis often needed

**Treatment:**
• Same drugs as adults (adjusted doses)
• 6 months duration
• Liquid/crushed tablets for young children
• Must complete full course

**Prevention:**
• BCG vaccine at birth
• Keep away from TB patients
• Good nutrition
• Test family contacts

🚨 TB is more dangerous in children. Seek immediate medical care if symptoms present.

📍 Pediatric TB specialists available at major hospitals.''';
  }

  String _getPediatricTBBengali() {
    return '''👶 শিশুদের মধ্যে টিবি:

⚠️ শিশু টিবি সমস্যার জন্য সর্বদা একজন শিশু বিশেষজ্ঞের সাথে পরামর্শ করুন।

**কেন শিশুরা দুর্বল:**
• দুর্বল রোগ প্রতিরোধ ব্যবস্থা
• গুরুতর টিবি হওয়ার সম্ভাবনা বেশি
• দ্রুত টিবি মেনিনজাইটিসে অগ্রসর হতে পারে
• অপুষ্ট হলে উচ্চ ঝুঁকি

**শিশুদের সাধারণ লক্ষণ:**
• ক্রমাগত কাশি (>২ সপ্তাহ)
• জ্বর যা চলে যায় না
• ওজন হ্রাস বা দুর্বল ওজন বৃদ্ধি
• ক্লান্তি, কম খেলাধুলা
• বর্ধিত লিম্ফ নোড
• রাতের ঘাম

**নির্ণয়ের চ্যালেঞ্জ:**
• শিশুরা সহজে থুতু তৈরি করতে পারে না
• পরিবর্তে গ্যাস্ট্রিক অ্যাসপিরেট পরীক্ষা ব্যবহার করা হয়
• প্রাপ্তবয়স্কদের তুলনায় এক্স-রে কম পরিষ্কার
• প্রায়শই ক্লিনিকাল নির্ণয় প্রয়োজন

**চিকিৎসা:**
• প্রাপ্তবয়স্কদের মতো একই ওষুধ (সামঞ্জস্যপূর্ণ ডোজ)
• ৬ মাসের সময়কাল
• ছোট শিশুদের জন্য তরল/চূর্ণ ট্যাবলেট
• সম্পূর্ণ কোর্স সম্পন্ন করতে হবে

**প্রতিরোধ:**
• জন্মের সময় বিসিজি টিকা
• টিবি রোগীদের থেকে দূরে রাখুন
• ভাল পুষ্টি
• পরিবারের যোগাযোগ পরীক্ষা করুন

🚨 শিশুদের জন্য টিবি আরও বিপজ্জনক। লক্ষণ দেখা দিলে অবিলম্বে চিকিৎসা সেবা নিন।

📍 বড় হাসপাতালে পেডিয়াট্রিক টিবি বিশেষজ্ঞ উপলব্ধ।''';
  }

  String _getTBHIVEnglish() {
    return '''🏥 TB and HIV Co-infection:

⚠️ Consult specialized TB/HIV doctors for treatment.

**Why TB+HIV is Serious:**
• HIV weakens immune system
• 20-30x higher TB risk with HIV
• TB accelerates HIV progression
• Leading cause of death in HIV patients

**Challenges:**
• TB harder to diagnose in HIV patients
• Symptoms may be atypical
• X-rays may appear normal
• Higher risk of drug resistance

**Treatment Approach:**
• Treat both TB and HIV simultaneously
• Antiretroviral therapy (ART) essential
• TB treatment: 6-9 months
• Close monitoring for drug interactions
• Monthly follow-ups required

**Prevention for HIV+ Individuals:**
• Take preventive TB therapy (IPT)
• Regular TB screening
• Maintain ART adherence
• Avoid crowded places
• Wear masks in high-risk areas

**Support Available:**
• Combined TB/HIV clinics in Bangladesh
• Free treatment for both conditions
• Confidential services
• Counseling support

🔒 Your information is confidential.

📞 Call HIV/AIDS helpline: 10921''';
  }

  String _getTBHIVBengali() {
    return '''🏥 টিবি এবং এইচআইভি সহ-সংক্রমণ:

⚠️ চিকিৎসার জন্য বিশেষায়িত টিবি/এইচআইভি ডাক্তারের সাথে পরামর্শ করুন।

**কেন টিবি+এইচআইভি গুরুতর:**
• এইচআইভি রোগ প্রতিরোধ ব্যবস্থাকে দুর্বল করে
• এইচআইভি সহ ২০-৩০গুণ বেশি টিবি ঝুঁকি
• টিবি এইচআইভি অগ্রগতি ত্বরান্বিত করে
• এইচআইভি রোগীদের মৃত্যুর প্রধান কারণ

**চ্যালেঞ্জ:**
• এইচআইভি রোগীদের মধ্যে টিবি নির্ণয় করা কঠিন
• লক্ষণ অস্বাভাবিক হতে পারে
• এক্স-রে স্বাভাবিক দেখাতে পারে
• ওষুধ প্রতিরোধের উচ্চ ঝুঁকি

**চিকিৎসা পদ্ধতি:**
• টিবি এবং এইচআইভি উভয়ের একসাথে চিকিৎসা করুন
• অ্যান্টিরেট্রোভাইরাল থেরাপি (এআরটি) অপরিহার্য
• টিবি চিকিৎসা: ৬-৯ মাস
• ওষুধের মিথস্ক্রিয়া জন্য ঘনিষ্ঠ পর্যবেক্ষণ
• মাসিক ফলো-আপ প্রয়োজন

**এইচআইভি+ ব্যক্তিদের প্রতিরোধ:**
• প্রতিরোধমূলক টিবি থেরাপি (আইপিটি) নিন
• নিয়মিত টিবি স্ক্রীনিং
• এআরটি আনুগত্য বজায় রাখুন
• ভিড়ের জায়গা এড়িয়ে চলুন
• উচ্চ ঝুঁকির এলাকায় মাস্ক পরুন

**সমর্থন উপলব্ধ:**
• বাংলাদেশে সম্মিলিত টিবি/এইচআইভি ক্লিনিক
• উভয় অবস্থার জন্য বিনামূল্যে চিকিৎসা
• গোপনীয় সেবা
• কাউন্সেলিং সাপোর্ট

🔒 আপনার তথ্য গোপনীয়।

📞 এইচআইভি/এইডস হেল্পলাইন কল করুন: ১০৯২১''';
  }

  String _getContactTracingEnglish() {
    return '''👥 TB Contact Tracing & Family Protection:

**If Someone in Your Family Has TB:**

**Immediate Actions:**
1️⃣ All family members should get tested
2️⃣ Close contacts need chest X-ray
3️⃣ Children <5 years: Preventive therapy
4️⃣ Inform workplace/school contacts

**Who is at Risk?**
• People living in same house
• Those sharing bedroom
• Close relatives who visit often
• Colleagues/classmates in daily contact

**Protection Measures:**

**For TB Patient:**
• Cover mouth when coughing
• Wear surgical mask at home (first 2 weeks)
• Sleep in separate room if possible
• Open windows for ventilation

**For Family Members:**
• Get tested immediately
• No need to isolate from patient
• Normal daily interactions okay
• Watch for symptoms (cough, fever)

**Children Protection:**
• Keep children away first 2 weeks
• Children should get TB skin test
• May need preventive medication
• Continue BCG protection

**After Treatment Starts:**
• Patient becomes non-infectious after 2-3 weeks
• Family can resume normal life
• Continue good ventilation
• Complete the full treatment course

💡 TB is curable. With treatment, family life returns to normal.

📍 Free contact screening at TB clinics.''';
  }

  String _getContactTracingBengali() {
    return '''👥 টিবি যোগাযোগ ট্রেসিং এবং পরিবার সুরক্ষা:

**যদি আপনার পরিবারে কারো টিবি হয়:**

**তাৎক্ষণিক পদক্ষেপ:**
1️⃣ সমস্ত পরিবারের সদস্যদের পরীক্ষা করা উচিত
2️⃣ ঘনিষ্ঠ যোগাযোগের বুকের এক্স-রে প্রয়োজন
3️⃣ ৫ বছরের কম বয়সী শিশু: প্রতিরোধমূলক থেরাপি
4️⃣ কর্মস্থল/স্কুলের যোগাযোগ অবহিত করুন

**কারা ঝুঁকিতে আছে?**
• একই বাড়িতে বসবাসকারী মানুষ
• যারা শোবার ঘর শেয়ার করে
• ঘনিষ্ঠ আত্মীয় যারা প্রায়ই দেখা করে
• দৈনিক যোগাযোগে সহকর্মী/সহপাঠী

**সুরক্ষা ব্যবস্থা:**

**টিবি রোগীর জন্য:**
• কাশির সময় মুখ ঢেকে রাখুন
• বাড়িতে সার্জিক্যাল মাস্ক পরুন (প্রথম ২ সপ্তাহ)
• সম্ভব হলে আলাদা ঘরে ঘুমান
• বায়ু চলাচলের জন্য জানালা খুলুন

**পরিবারের সদস্যদের জন্য:**
• অবিলম্বে পরীক্ষা করুন
• রোগীর থেকে আলাদা হওয়ার প্রয়োজন নেই
• স্বাভাবিক দৈনিক মিথস্ক্রিয়া ঠিক আছে
• লক্ষণগুলির জন্য নজর রাখুন (কাশি, জ্বর)

**শিশুদের সুরক্ষা:**
• প্রথম ২ সপ্তাহ শিশুদের দূরে রাখুন
• শিশুদের টিবি স্কিন টেস্ট করা উচিত
• প্রতিরোধমূলক ওষুধের প্রয়োজন হতে পারে
• বিসিজি সুরক্ষা চালিয়ে যান

**চিকিৎসা শুরু হওয়ার পরে:**
• ২-৩ সপ্তাহ পরে রোগী অ-সংক্রামক হয়ে যায়
• পরিবার স্বাভাবিক জীবন পুনরায় শুরু করতে পারে
• ভাল বায়ু চলাচল চালিয়ে যান
• সম্পূর্ণ চিকিৎসা কোর্স সম্পন্ন করুন

💡 টিবি নিরাময়যোগ্য। চিকিৎসায়, পারিবারিক জীবন স্বাভাবিকে ফিরে আসে।

📍 টিবি ক্লিনিকে বিনামূল্যে যোগাযোগ স্ক্রীনিং।''';
  }

  String _getDOTSTreatmentEnglish() {
    return '''💊 DOTS - Directly Observed Treatment, Short-course:

**What is DOTS?**
• World Health Organization recommended strategy
• Healthcare worker watches you take TB medicine
• Ensures complete treatment
• Free in Bangladesh

**How DOTS Works:**

**Phase 1 (Intensive): 2 months**
• Take 4 medicines daily
• Visit DOTS center every day OR
• Health worker comes to you
• Most infectious period

**Phase 2 (Continuation): 4 months**
• Take 2-3 medicines
• Visit DOTS center 3 times/week
• Less frequent monitoring

**Benefits of DOTS:**
✅ Ensures you don't miss doses
✅ 95% cure rate
✅ Prevents drug resistance
✅ Free medicines and monitoring
✅ Reduces TB spread
✅ Health worker support

**DOTS Centers in Bangladesh:**
• 7,000+ centers nationwide
• Found in: Hospitals, health centers, NGO clinics
• Near your home/workplace
• Open 6 days a week

**What to Expect:**
• Short 5-10 minute visits
• Take medicine in front of health worker
• Quick health check
• Register progress
• Get next week's supply

**Family DOTS:**
• Trained family member can supervise
• After initial 2 weeks of treatment
• If daily center visit difficult

🏥 DOTS ensures TB cure. Never miss a dose!

📍 Find nearest DOTS center: Call 16263''';
  }

  String _getDOTSTreatmentBengali() {
    return '''💊 ডটস - প্রত্যক্ষ পর্যবেক্ষণ চিকিৎসা, স্বল্প-কোর্স:

**ডটস কি?**
• বিশ্ব স্বাস্থ্য সংস্থার প্রস্তাবিত কৌশল
• স্বাস্থ্যকর্মী আপনাকে টিবি ওষুধ খেতে দেখেন
• সম্পূর্ণ চিকিৎসা নিশ্চিত করে
• বাংলাদেশে বিনামূল্যে

**ডটস কিভাবে কাজ করে:**

**পর্যায় ১ (নিবিড়): ২ মাস**
• প্রতিদিন ৪টি ওষুধ নিন
• প্রতিদিন ডটস সেন্টারে যান অথবা
• স্বাস্থ্যকর্মী আপনার কাছে আসেন
• সবচেয়ে সংক্রামক সময়

**পর্যায় ২ (ধারাবাহিকতা): ৪ মাস**
• ২-৩টি ওষুধ নিন
• সপ্তাহে ৩ বার ডটস সেন্টারে যান
• কম ঘন ঘন পর্যবেক্ষণ

**ডটসের সুবিধা:**
✅ নিশ্চিত করে আপনি ডোজ মিস করছেন না
✅ ৯৫% নিরাময়ের হার
✅ ওষুধ প্রতিরোধ প্রতিরোধ করে
✅ বিনামূল্যে ওষুধ এবং পর্যবেক্ষণ
✅ টিবি বিস্তার হ্রাস করে
✅ স্বাস্থ্যকর্মী সমর্থন

**বাংলাদেশে ডটস সেন্টার:**
• দেশব্যাপী ৭,০০০+ কেন্দ্র
• পাওয়া যায়: হাসপাতাল, স্বাস্থ্য কেন্দ্র, এনজিও ক্লিনিক
• আপনার বাড়ি/কর্মস্থলের কাছাকাছি
• সপ্তাহে ৬ দিন খোলা

**কি আশা করবেন:**
• সংক্ষিপ্ত ৫-১০ মিনিটের ভিজিট
• স্বাস্থ্যকর্মীর সামনে ওষুধ খান
• দ্রুত স্বাস্থ্য পরীক্ষা
• অগ্রগতি নিবন্ধন করুন
• পরের সপ্তাহের সরবরাহ পান

**পারিবারিক ডটস:**
• প্রশিক্ষিত পরিবারের সদস্য তত্ত্বাবধান করতে পারেন
• চিকিৎসার প্রাথমিক ২ সপ্তাহ পরে
• যদি দৈনিক সেন্টার ভিজিট কঠিন হয়

🏥 ডটস টিবি নিরাময় নিশ্চিত করে। কখনো ডোজ মিস করবেন না!

📍 নিকটতম ডটস সেন্টার খুঁজুন: কল করুন ১৬২৬৩''';
  }
}
