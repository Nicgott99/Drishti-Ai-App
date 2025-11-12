import 'package:flutter/material.dart';
import 'dart:async';

class LoadingStagesWidget extends StatefulWidget {
  final String patientName;
  final VoidCallback? onComplete;

  const LoadingStagesWidget({
    Key? key,
    required this.patientName,
    this.onComplete,
  }) : super(key: key);

  @override
  State<LoadingStagesWidget> createState() => _LoadingStagesWidgetState();
}

class _LoadingStagesWidgetState extends State<LoadingStagesWidget> with TickerProviderStateMixin {
  int _currentStage = 0;
  double _stageProgress = 0.0;
  Timer? _progressTimer;
  
  final List<AnalysisStage> _stages = [
    AnalysisStage(
      name: 'Preprocessing X-ray Image',
      nameBn: 'এক্স-রে ইমেজ প্রিপ্রসেসিং',
      description: 'Enhancing image quality and normalizing pixel values',
      descriptionBn: 'ইমেজের গুণমান বৃদ্ধি এবং পিক্সেল মান স্বাভাবিককরণ',
      duration: 5,
      icon: Icons.image_outlined,
    ),
    AnalysisStage(
      name: 'Running Deep Learning Model',
      nameBn: 'ডিপ লার্নিং মডেল চালু করা হচ্ছে',
      description: 'Analyzing chest X-ray with EfficientNetV2-S (20M parameters)',
      descriptionBn: 'EfficientNetV2-S দিয়ে বুকের এক্স-রে বিশ্লেষণ (২০ মিলিয়ন প্যারামিটার)',
      duration: 15,
      icon: Icons.psychology_outlined,
    ),
    AnalysisStage(
      name: 'Analyzing Risk Level',
      nameBn: 'ঝুঁকির স্তর বিশ্লেষণ',
      description: 'Calculating TB probability, confidence, and medical urgency',
      descriptionBn: 'টিবি সম্ভাবনা, আত্মবিশ্বাস এবং চিকিৎসা জরুরিতা গণনা',
      duration: 5,
      icon: Icons.analytics_outlined,
    ),
    AnalysisStage(
      name: 'Generating Attention Heatmap',
      nameBn: 'মনোযোগ হিটম্যাপ তৈরি করা হচ্ছে',
      description: 'Creating high-resolution visual map using Grad-CAM++',
      descriptionBn: 'Grad-CAM++ ব্যবহার করে উচ্চ-রেজোলিউশন ভিজ্যুয়াল ম্যাপ তৈরি',
      duration: 10,
      icon: Icons.thermostat_outlined,
    ),
    AnalysisStage(
      name: 'Finalizing Medical Analysis',
      nameBn: 'চিকিৎসা বিশ্লেষণ চূড়ান্ত করা হচ্ছে',
      description: 'Generating personalized recommendations and detailed report',
      descriptionBn: 'ব্যক্তিগত সুপারিশ এবং বিস্তারিত রিপোর্ট তৈরি করা হচ্ছে',
      duration: 5,
      icon: Icons.medical_information_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startAnalysis() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        final stageDuration = _stages[_currentStage].duration;
        _stageProgress += 0.05 / stageDuration;
        
        if (_stageProgress >= 1.0) {
          _stageProgress = 0.0;
          if (_currentStage < _stages.length - 1) {
            _currentStage++;
          } else {
            timer.cancel();
            widget.onComplete?.call();
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isBangla = locale == 'bn';
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F172A), // slate-900
            const Color(0xFF1E3A8A), // blue-900
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                Text(
                  isBangla 
                    ? '${widget.patientName} এর CXR স্ক্যান প্রক্রিয়াকরণ'
                    : 'Processing CXR scan for ${widget.patientName}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isBangla
                    ? 'এটি সম্পূর্ণ হতে প্রায় 40 সেকেন্ড সময় লাগবে'
                    : 'This will take approximately 40 seconds',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Stages list
                Expanded(
                  child: ListView.builder(
                    itemCount: _stages.length,
                    itemBuilder: (context, index) {
                      final stage = _stages[index];
                      final isActive = index == _currentStage;
                      final isCompleted = index < _currentStage;
                      
                      return _buildStageCard(
                        stage,
                        index + 1,
                        isActive,
                        isCompleted,
                        isBangla,
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Overall progress
                _buildOverallProgress(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStageCard(
    AnalysisStage stage,
    int stageNumber,
    bool isActive,
    bool isCompleted,
    bool isBangla,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isActive 
          ? Colors.blue.withOpacity(0.2)
          : isCompleted
            ? Colors.green.withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
            ? Colors.blue
            : isCompleted
              ? Colors.green
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ] : [],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Stage number or checkmark
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCompleted
                      ? Colors.green
                      : isActive
                        ? Colors.blue
                        : Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 28)
                      : isActive
                        ? Icon(stage.icon, color: Colors.white, size: 28)
                        : Text(
                            '$stageNumber',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
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
                        isBangla ? stage.nameBn : stage.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isActive || isCompleted
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isBangla ? stage.descriptionBn : stage.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isActive || isCompleted
                            ? Colors.white.withOpacity(0.7)
                            : Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Progress bar for active stage
            if (isActive) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _stageProgress,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_stageProgress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverallProgress() {
    final totalDuration = _stages.fold<double>(0, (sum, stage) => sum + stage.duration);
    final completedDuration = _stages
        .take(_currentStage)
        .fold<double>(0, (sum, stage) => sum + stage.duration) +
        (_stages[_currentStage].duration * _stageProgress);
    final overallProgress = completedDuration / totalDuration;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Overall Progress',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${(overallProgress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: overallProgress,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}

class AnalysisStage {
  final String name;
  final String nameBn;
  final String description;
  final String descriptionBn;
  final double duration; // in seconds
  final IconData icon;

  AnalysisStage({
    required this.name,
    required this.nameBn,
    required this.description,
    required this.descriptionBn,
    required this.duration,
    required this.icon,
  });
}
