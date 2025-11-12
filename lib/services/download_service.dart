import 'dart:convert';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/patient_info.dart';

class DownloadService {
  /// Generate and download PDF report
  static Future<void> downloadPDFReport({
    required PatientInfo patientInfo,
    required Map<String, dynamic> analysisResults,
  }) async {
    try {
      final pdf = pw.Document();

      // Extract data from analysisResults
      final probability = analysisResults['probability'] as double? ?? 0.0;
      final riskLevel = analysisResults['riskLevel'] as String? ?? 'Unknown';
      final confidence = analysisResults['confidence'] as double? ?? 0.0;
      final timestamp = analysisResults['timestamp'] as String? ?? 'N/A';
      final classification = analysisResults['classification'] as String? ?? 'N/A';
      final urgencyLevel = analysisResults['urgency_level'] as String? ?? 'N/A';
      final recommendations = analysisResults['recommendations'] as List? ?? [];
      final affectedRegions = analysisResults['affected_regions'] as List? ?? [];
      final heatmapExplanation = analysisResults['heatmap_explanation'] as String? ?? 'N/A';

      // Build PDF content
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Drishti AI - TB Detection Report',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'AI-Powered Tuberculosis Screening Analysis',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Divider(thickness: 2),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Patient Information Section
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue300, width: 1),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                padding: const pw.EdgeInsets.all(16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Patient Information',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    _buildInfoRow('Name:', patientInfo.name),
                    _buildInfoRow('Age:', '${patientInfo.age} years'),
                    _buildInfoRow('Gender:', patientInfo.gender),
                    _buildInfoRow('Phone:', patientInfo.phoneNumber),
                    _buildInfoRow('Analysis Date:', timestamp),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Analysis Results Section
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.red300, width: 1),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                padding: const pw.EdgeInsets.all(16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Analysis Results',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red900,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    _buildInfoRow(
                      'TB Probability:',
                      '${(probability * 100).toStringAsFixed(2)}%',
                      valueColor: _getRiskColor(riskLevel),
                    ),
                    _buildInfoRow('Risk Level:', riskLevel, valueColor: _getRiskColor(riskLevel)),
                    _buildInfoRow('Confidence:', '${(confidence * 100).toStringAsFixed(2)}%'),
                    _buildInfoRow('Classification:', classification),
                    _buildInfoRow('Urgency Level:', urgencyLevel),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Affected Regions Section
              if (affectedRegions.isNotEmpty)
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.orange300, width: 1),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  padding: const pw.EdgeInsets.all(16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Affected Regions',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.orange900,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: affectedRegions.map((region) {
                          return pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: const pw.BoxDecoration(
                              color: PdfColors.orange100,
                              borderRadius: pw.BorderRadius.all(pw.Radius.circular(16)),
                            ),
                            child: pw.Text(
                              region.toString(),
                              style: const pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.orange900,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

              if (affectedRegions.isNotEmpty) pw.SizedBox(height: 20),

              // Heatmap Visualization (if available) - EMBEDDED IN PDF
              if (analysisResults.containsKey('heatmap') && analysisResults['heatmap'] != null) ...[
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.purple300, width: 1),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  padding: const pw.EdgeInsets.all(16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Heatmap Visualization',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.purple900,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      // EMBED HEATMAP IMAGE
                      pw.Center(
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.purple200, width: 1),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: () {
                            try {
                              // Decode base64 heatmap
                              final heatmapBase64 = analysisResults['heatmap'] as String;
                              final base64String = heatmapBase64.contains(',')
                                  ? heatmapBase64.split(',').last
                                  : heatmapBase64;
                              final heatmapBytes = base64Decode(base64String);
                              
                              // Embed as image
                              return pw.Image(
                                pw.MemoryImage(heatmapBytes),
                                width: 400,
                                height: 400,
                                fit: pw.BoxFit.contain,
                              );
                            } catch (e) {
                              debugPrint("❌ Error embedding heatmap: $e");
                              return pw.Text(
                                'Heatmap could not be loaded',
                                style: const pw.TextStyle(fontSize: 10, color: PdfColors.red),
                              );
                            }
                          }(),
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        heatmapExplanation,
                        style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
              ],

              // Medical Recommendations Section
              if (recommendations.isNotEmpty)
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.green300, width: 1),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  padding: const pw.EdgeInsets.all(16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Medical Recommendations',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green900,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      ...recommendations.asMap().entries.map((entry) {
                        return pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 8),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                '${entry.key + 1}. ',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.green900,
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Text(
                                  entry.value.toString(),
                                  style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

              pw.SizedBox(height: 30),

              // Medical Disclaimer
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: PdfColors.red50,
                  border: pw.Border.all(color: PdfColors.red900, width: 2),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                padding: const pw.EdgeInsets.all(16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Text(
                          '⚠️ IMPORTANT MEDICAL DISCLAIMER',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red900,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'This report is generated by an AI-powered screening tool and is NOT a medical diagnosis. '
                      'It is intended for screening purposes only and should not replace professional medical evaluation.\n\n'
                      'ALWAYS consult with a qualified healthcare professional (doctor, radiologist, or pulmonologist) '
                      'for proper interpretation of chest X-rays, diagnosis, and treatment decisions.\n\n'
                      'If you have symptoms of TB (persistent cough, fever, night sweats, weight loss) or if this screening '
                      'indicates high risk, seek medical attention immediately at a TB clinic or hospital.',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                    ),
                  ],
                ),
              ),

              // Footer
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'Generated by Drishti AI - TB Detection Platform',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'For support: https://drishti-ai.com | Contact: 16263 (NTCP Hotline)',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
                ),
              ),
            ];
          },
        ),
      );

      // Save PDF to Downloads folder (accessible to user)
      final bytes = await pdf.save();
      final fileName = 'Drishti_TB_Report_${patientInfo.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // For Android: Save to Downloads directory
      Directory? downloadsDir;
      
      if (Platform.isAndroid) {
        try {
          // Primary location: Download folder (user-accessible)
          final downloadPath = '/storage/emulated/0/Download';
          downloadsDir = Directory(downloadPath);
          
          if (!await downloadsDir.exists()) {
            debugPrint("⚠ Download folder doesn't exist, creating Pictures/DrishtiAI...");
            // Fallback to Pictures/DrishtiAI if Downloads doesn't exist
            final picturesPath = '/storage/emulated/0/Pictures/DrishtiAI';
            downloadsDir = Directory(picturesPath);
            await downloadsDir.create(recursive: true);
          }
          
          debugPrint("📂 PDF save location: ${downloadsDir.path}");
        } catch (e) {
          debugPrint("⚠ Failed to access storage: $e");
          // Final fallback: Use app directory
          final externalDir = await getExternalStorageDirectory();
          downloadsDir = externalDir;
        }
      } else {
        // For iOS: Use documents directory
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      final file = File('${downloadsDir!.path}/$fileName');
      await file.writeAsBytes(bytes);
      
      debugPrint('✅ PDF saved to: ${file.path}');
      debugPrint('📁 File size: ${bytes.length} bytes');
      return; // Success
    } catch (e) {
      print('❌ Failed to generate PDF: $e');
      throw Exception('Failed to generate PDF: $e');
    }
  }

  /// Helper: Build info row for PDF
  static pw.Widget _buildInfoRow(String label, String value, {PdfColor? valueColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 11,
                color: valueColor ?? PdfColors.grey900,
                fontWeight: valueColor != null ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper: Get risk color for PDF
  static PdfColor _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return PdfColors.red;
      case 'medium':
        return PdfColors.orange;
      case 'low':
        return PdfColors.green;
      default:
        return PdfColors.grey;
    }
  }
}
