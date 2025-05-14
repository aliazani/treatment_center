import 'dart:io';

import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:treatment_center/core/providers/file_provider.dart';
import 'package:treatment_center/core/services/email_sender.dart';

import '../../../../core/error/exceptions.dart';
import '../models/assessment_form_model.dart';
import './assessment_remote_datasource.dart';

/// Implementation of [AssessmentRemoteDataSource] that handles file creation and email sending
class AssessmentRemoteDataSourceImpl implements AssessmentRemoteDataSource {
  final EmailSender emailSender;
  final Future<Directory> Function() getTempDir;
  final FileProvider fileProvider;

  AssessmentRemoteDataSourceImpl({
    required this.emailSender,
    required this.fileProvider,
    this.getTempDir = getTemporaryDirectory,
  });

  @override
  Future<String> exportAssessmentToFile(
    AssessmentFormModel assessment,
    String format,
  ) async {
    try {
      final tempDir = await getTempDir();
      final filePath =
          '${tempDir.path}/assessment_${assessment.id}.${format.toLowerCase()}';

      switch (format.toLowerCase()) {
        case 'pdf':
          await _generatePdfFile(assessment, filePath);
          break;
        case 'doc':
          await _generateDocFile(assessment, filePath);
          break;
        default:
          throw FileException();
      }

      return filePath;
    } catch (e) {
      if (e is FileException) {
        rethrow;
      }
      throw FileException();
    }
  }

  @override
  Future<bool> submitAssessmentViaEmail(
    AssessmentFormModel assessment,
    String recipientEmail, {
    required String exportFormat,
    String? subject,
    String? body,
  }) async {
    try {
      // Generate the file
      final filePath = await exportAssessmentToFile(assessment, exportFormat);

      // Create email
      final email = Email(
        recipients: [recipientEmail],
        subject:
            subject ??
            'FV Treatment Center Assessment: ${assessment.facilityIdentification.facilityName}',
        body:
            body ??
            'Please find attached the assessment form for ${assessment.facilityIdentification.facilityName}.\n\nThis assessment was conducted on ${assessment.assessorInfo.assessmentDate.toString().split(' ')[0]} by ${assessment.assessorInfo.name}.',
        attachmentPaths: [filePath],
      );

      // Send email
      await emailSender.send(email);
      return true;
    } catch (e) {
      throw EmailException();
    }
  }

  /// Generates a PDF file from the assessment
  Future<void> _generatePdfFile(
    AssessmentFormModel assessment,
    String filePath,
  ) async {
    final pdf = pw.Document();

    // Create PDF content
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title
              pw.Center(
                child: pw.Text(
                  'FV Treatment Center Assessment',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Facility info
              pw.Text(
                'Facility: ${assessment.facilityIdentification.facilityName}',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Code: ${assessment.facilityIdentification.facilityCode}',
              ),
              pw.Text(
                'Location: ${assessment.geoLocation.cityVillage}, ${assessment.geoLocation.regionProvince}, ${assessment.geoLocation.country}',
              ),
              pw.SizedBox(height: 10),

              // Assessor info
              pw.Text(
                'Assessment Details:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text('Assessor: ${assessment.assessorInfo.name}'),
              pw.Text(
                'Date: ${assessment.assessorInfo.assessmentDate.toString().split(' ')[0]}',
              ),
              pw.Text('Email: ${assessment.assessorInfo.email}'),
              pw.SizedBox(height: 20),

              // Create sections summary
              pw.Text(
                'Assessment Sections:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              ...assessment.sections.map((section) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${section.sectionNumber} - ${section.title}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Completion: ${section.completedItemsCount}/${section.items.length} items rated',
                    ),
                    pw.SizedBox(height: 5),
                  ],
                );
              }).toList(),

              // Footer with status
              pw.Spacer(),
              pw.Divider(),
              pw.Text(
                'Assessment Status: ${assessment.isSubmitted ? "Submitted" : "Draft"}',
                style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF
    final file = await fileProvider.getFile(filePath);
    await fileProvider.writeAsBytes(file, await pdf.save());
  }

  /// Generates a DOC file from the assessment
  Future<void> _generateDocFile(
    AssessmentFormModel assessment,
    String filePath,
  ) async {
    // Creating a simple text file with .doc extension
    final file = await fileProvider.getFile(filePath);
    final buffer = StringBuffer();

    buffer.writeln('FV TREATMENT CENTER ASSESSMENT');
    buffer.writeln('');
    buffer.writeln(
      'Facility: ${assessment.facilityIdentification.facilityName}',
    );
    buffer.writeln('Code: ${assessment.facilityIdentification.facilityCode}');
    buffer.writeln(
      'Location: ${assessment.geoLocation.cityVillage}, ${assessment.geoLocation.regionProvince}, ${assessment.geoLocation.country}',
    );
    buffer.writeln('');
    buffer.writeln('Assessment Details:');
    buffer.writeln('Assessor: ${assessment.assessorInfo.name}');
    buffer.writeln(
      'Date: ${assessment.assessorInfo.assessmentDate.toString().split(' ')[0]}',
    );
    buffer.writeln('Email: ${assessment.assessorInfo.email}');
    buffer.writeln('');

    buffer.writeln('Assessment Sections:');
    for (final section in assessment.sections) {
      buffer.writeln('${section.sectionNumber} - ${section.title}');
      buffer.writeln(
        'Completion: ${section.completedItemsCount}/${section.items.length} items rated',
      );
      buffer.writeln('');

      // Add assessment items
      for (final item in section.items) {
        buffer.writeln('  - ${item.sectionNumber}: ${item.area}');
        if (item.selectedRating != null) {
          buffer.writeln('    Rating: ${item.selectedRating!.label}');
        } else {
          buffer.writeln('    Rating: Not rated');
        }
        if (item.comment != null && item.comment!.isNotEmpty) {
          buffer.writeln('    Comment: ${item.comment}');
        }
        buffer.writeln('');
      }
    }

    buffer.writeln(
      'Assessment Status: ${assessment.isSubmitted ? "Submitted" : "Draft"}',
    );
    if (assessment.isSubmitted && assessment.submissionDate != null) {
      buffer.writeln(
        'Submission Date: ${assessment.submissionDate.toString().split(' ')[0]}',
      );
    }

    await fileProvider.writeAsString(file, buffer.toString());
  }
}