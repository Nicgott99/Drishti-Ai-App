import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../providers/language_provider.dart';
import '../models/patient_info.dart';
import '../widgets/floating_chat_widget.dart';
import 'scan_method_screen.dart';

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<PatientRegistrationScreen> createState() => _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedGender = 'Male';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _proceedToScanning() {
    if (_formKey.currentState!.validate()) {
      final patientInfo = PatientInfo(
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        gender: _selectedGender,
        phoneNumber: _phoneController.text.trim(),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanMethodScreen(patientInfo: patientInfo),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isBangla = locale == 'bn';

    return Scaffold(
      body: Stack(
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
              child: Column(
                children: [
                  // Simple Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBangla ? 'রোগীর তথ্য' : 'Patient Information',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isBangla 
                                ? 'নিবন্ধনের জন্য আপনার তথ্য প্রদান করুন'
                                : 'Provide your details for registration',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
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
                                icon: Text(
                                  languageProvider.currentLocale.languageCode == 'en' ? '🇧🇩' : '🇬🇧',
                                  style: const TextStyle(fontSize: 24),
                                ),
                                onPressed: () {
                                  languageProvider.toggleLanguage();
                                },
                                tooltip: languageProvider.currentLocale.languageCode == 'en'
                                    ? 'বাংলা'
                                    : 'English',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Scrollable Form
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Icon
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.withOpacity(0.3),
                                    Colors.purple.withOpacity(0.3),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_add,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Name Field
                            _buildTextField(
                              controller: _nameController,
                              label: isBangla ? 'নাম' : 'Full Name',
                              hint: isBangla ? 'আপনার পূর্ণ নাম লিখুন' : 'Enter your full name',
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return isBangla ? 'নাম প্রয়োজন' : 'Name is required';
                                }
                                if (value.trim().length < 2) {
                                  return isBangla ? 'নাম কমপক্ষে ২ অক্ষর হতে হবে' : 'Name must be at least 2 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            // Age Field
                            _buildTextField(
                              controller: _ageController,
                              label: isBangla ? 'বয়স' : 'Age',
                              hint: isBangla ? 'আপনার বয়স লিখুন' : 'Enter your age',
                              icon: Icons.cake_outlined,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return isBangla ? 'বয়স প্রয়োজন' : 'Age is required';
                                }
                                final age = int.tryParse(value);
                                if (age == null || age < 1 || age > 150) {
                                  return isBangla ? 'সঠিক বয়স লিখুন (১-১৫০)' : 'Enter valid age (1-150)';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            // Gender Selector
                            _buildGenderSelector(isBangla),
                            const SizedBox(height: 20),
                            
                            // Phone Field
                            _buildTextField(
                              controller: _phoneController,
                              label: isBangla ? 'ফোন নম্বর' : 'Phone Number',
                              hint: isBangla ? '০১৭xxxxxxxx' : '01xxxxxxxxx',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return isBangla ? 'ফোন নম্বর প্রয়োজন' : 'Phone number is required';
                                }
                                if (!RegExp(r'^01[0-9]{9}$').hasMatch(value.trim())) {
                                  return isBangla 
                                    ? 'সঠিক বাংলাদেশি ফোন নম্বর লিখুন (০১ দিয়ে শুরু, ১১ সংখ্যা)'
                                    : 'Enter valid Bangladesh phone (starts with 01, 11 digits)';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),
                            
                            // Submit Button
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF3B82F6),
                                    Color(0xFF8B5CF6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3B82F6).withOpacity(0.5),
                                    blurRadius: 25,
                                    spreadRadius: -5,
                                    offset: const Offset(0, 20),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _proceedToScanning,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      isBangla ? 'স্ক্যানিং এ যান' : 'Proceed to Scanning',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Privacy Notice
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.lock_outline,
                                        color: Colors.white.withOpacity(0.7),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          isBangla
                                              ? 'আপনার তথ্য সুরক্ষিত এবং গোপনীয়'
                                              : 'Your information is safe and confidential',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const FloatingChatWidget(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.3),
                      Colors.purple.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              labelStyle: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 14,
              ),
              errorStyle: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector(bool isBangla) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: DropdownButtonFormField<String>(
            value: _selectedGender,
            dropdownColor: const Color(0xFF1E293B),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
            decoration: InputDecoration(
              labelText: isBangla ? 'লিঙ্গ' : 'Gender',
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.3),
                      Colors.purple.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.wc, color: Colors.white, size: 20),
              ),
              labelStyle: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            items: [
              DropdownMenuItem(
                value: 'Male',
                child: Text(isBangla ? 'পুরুষ' : 'Male'),
              ),
              DropdownMenuItem(
                value: 'Female',
                child: Text(isBangla ? 'মহিলা' : 'Female'),
              ),
              DropdownMenuItem(
                value: 'Other',
                child: Text(isBangla ? 'অন্যান্য' : 'Other'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedGender = value!;
              });
            },
          ),
        ),
      ),
    );
  }
}
