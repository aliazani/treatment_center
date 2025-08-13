import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/providers/file_provider_interface.dart';
import 'package:treatment_center/core/services/doc_export_service.dart';
import 'package:treatment_center/core/services/excel_export_service.dart';
import 'package:treatment_center/core/services/export_service.dart';
import 'package:treatment_center/core/services/pdf_export_service.dart';
import 'package:treatment_center/features/questionnaire_form/data/datasources/assessment_remote_datasource.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';

// Firebase
class AssessmentRemoteDataSourceImpl implements AssessmentRemoteDataSource {
  final FirebaseStorage storage;
  final FirebaseFunctions functions;
  final FileProvider fileProvider;
  final ExcelExportService excelService;
  final PdfExportService pdfService;
  final DocExportService docService;
  final bool Function() platformIsWeb;

  AssessmentRemoteDataSourceImpl({
    required this.storage,
    required this.functions,
    required this.fileProvider,
    required this.excelService,
    required this.pdfService,
    required this.docService,
    bool Function()? platformIsWeb,
  }) : platformIsWeb = platformIsWeb ?? (() => kIsWeb);

  static const int _maxAttachmentSizeBytes = 18 * 1024 * 1024; // 18MB

  @override
  Future<String> uploadAssessment(AssessmentFormModel assessment) async {
    try {
      final jsonData = jsonEncode(assessment.toJson());
      final fileName = 'assessments/${assessment.id}/assessment_data.json';

      final ref = storage.ref().child(fileName);
      await ref.putString(
        jsonData,
        metadata: SettableMetadata(
          contentType: 'application/json',
          customMetadata: {
            'assessmentId': assessment.id,
            'facilityName': assessment.facilityIdentification.facilityName,
            'uploadTimestamp': DateTime.now().toIso8601String(),
          },
        ),
      );

      return fileName;
    } catch (e) {
      throw ServerException(
        message: 'Failed to upload assessment: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> submitAssessmentViaFirebaseEmail(
    AssessmentFormModel assessment,
    String recipientEmail, {
    required List<String> exportFormats,
    String? subject,
    String? body,
    ExportOptions? exportOptions,
    List<String> photoFilePaths = const [],
  }) async {
    try {
      // 1. Upload assessment data to Firebase Storage
      await uploadAssessment(assessment);

      // 2. Export and upload files in requested formats
      List<String> attachmentUrls = [];

      for (String format in exportFormats) {
        final exportResult = await _exportAssessment(
          assessment,
          format,
          exportOptions,
        );

        final downloadUrl = await uploadExportedFile(
          exportResult,
          assessment.id,
        );

        attachmentUrls.add(downloadUrl);
      }
      List<String> photoUrls = [];
      int totalPhotoSize = 0;

      if (photoFilePaths.isNotEmpty) {
        photoUrls = await _uploadPhotoFiles(
          assessmentId: assessment.id,
          photoPaths: photoFilePaths,
        );

        totalPhotoSize = await _calculateTotalPhotoSize(photoFilePaths);
      }

      List<String> finalAttachments = [...attachmentUrls];
      List<String> photoLinks = [];

      if (totalPhotoSize > _maxAttachmentSizeBytes) {
        // Size exceeds limit - use photo links instead of attachments
        photoLinks = photoUrls;
      } else {
        // Size OK - attach photos directly
        finalAttachments.addAll(photoUrls);
      }

      final success = await sendEmailWithAttachments(
        recipientEmail,
        subject ?? _generateDefaultSubject(assessment, exportFormats),
        body ?? _generateDefaultBody(assessment, exportFormats, photoLinks),
        finalAttachments,
        _getAssessmentSummary(assessment),
      );

      return success;
    } catch (e) {
      throw ServerException(
        message:
            'Failed to submit assessment via Firebase email: ${e.toString()}',
      );
    }
  }

  Future<int> _calculateTotalPhotoSize(List<String> photoFilePaths) async {
    int totalSize = 0;

    for (String path in photoFilePaths) {
      try {
        if (platformIsWeb()) {
          final response = await http.head(Uri.parse(path));
          final contentLength = response.headers['content-length'];
          if (contentLength != null) {
            totalSize += int.parse(contentLength);
          }
        } else {
          final wrapped = await fileProvider.getFile(path);
          if (await wrapped.exists()) {
            totalSize += await wrapped.length();
          }
        }
      } catch (e) {
        // Continue if we can't get size for one file
        continue;
      }
    }

    return totalSize;
  }

  Future<ExportResult> _exportAssessment(
    AssessmentFormModel assessment,
    String format,
    ExportOptions? options,
  ) async {
    final normalizedFormat = format.toLowerCase();

    switch (normalizedFormat) {
      case 'excel':
      case 'xlsx':
        return await excelService.exportAssessment(
          assessment,
          options: options,
        );
      case 'pdf':
        return await pdfService.exportAssessment(assessment, options: options);
      case 'doc':
      case 'docx':
        return await docService.exportAssessment(assessment, options: options);
      default:
        throw ValidationException(
          message:
              'Unsupported export format: $format. Supported formats: pdf, excel, docx',
        );
    }
  }

  @override
  Future<String> uploadExportedFile(
    ExportResult result,
    String assessmentId,
  ) async {
    try {
      // Create Storage reference
      final storagePath =
          'assessments/$assessmentId/exports/${result.fileName}';
      final ref = storage.ref().child(storagePath);

      final metadata = SettableMetadata(
        contentType: _mimeFromName(result.fileName),
        customMetadata: {
          'assessmentId': assessmentId,
          'originalFileName': result.fileName,
          'uploadTimestamp': DateTime.now().toIso8601String(),
          'format': result.format,
        },
      );

      // Choose upload method based on platform and available data
      if (platformIsWeb()) {
        // Web: use bytes directly
        if (result.hasBytes) {
          await ref.putData(result.bytes!, metadata);
        } else {
          throw ValidationException(
            message:
                'Export result missing bytes for web platform: ${result.fileName}',
          );
        }
      } else {
        // Mobile/Desktop: use file path
        final wrapped = await fileProvider.getFile(result.filePath);
        if (!await wrapped.exists()) {
          throw ValidationException(
            message: 'File not found: ${result.filePath}',
          );
        }

        await ref.putFile(wrapped.raw as File, metadata);
      }

      // Return public download URL
      return await ref.getDownloadURL();
    } on ValidationException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to upload exported file: $e');
    }
  }

  String _mimeFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (lower.endsWith('.xlsx')) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }

    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic') || lower.endsWith('.heif')) return 'image/heic';

    return 'application/octet-stream';
  }

  String _basename(String fullPath) {
    if (fullPath.isEmpty) return fullPath;
    final norm = fullPath.replaceAll('\\', '/');
    final idx = norm.lastIndexOf('/');
    return idx >= 0 ? norm.substring(idx + 1) : norm;
  }

  Future<List<String>> _uploadPhotoFiles({
    required String assessmentId,
    required List<String> photoPaths,
  }) async {
    final urls = <String>[];
    for (int i = 0; i < photoPaths.length; i++) {
      final path = photoPaths[i];

      try {
        final name = _basename(path);
        final storagePath = 'assessments/$assessmentId/photos/$name';
        final ref = storage.ref().child(storagePath);

        final metadata = SettableMetadata(
          contentType: _mimeFromName(name),
          customMetadata: {
            'assessmentId': assessmentId,
            'originalFileName': name,
            'uploadTimestamp': DateTime.now().toIso8601String(),
          },
        );

        if (platformIsWeb()) {
          final response = await http.get(Uri.parse(path));
          if (response.statusCode == 200) {
            final bytes = response.bodyBytes;
            await ref.putData(bytes, metadata);
          } else {
            throw Exception(
              'Failed to fetch photo: HTTP ${response.statusCode}',
            );
          }
        } else {
          final wrapped = await fileProvider.getFile(path);
          if (!await wrapped.exists()) {
            throw ValidationException(message: 'Photo not found: $path');
          }
          await ref.putFile(wrapped.raw as File, metadata);
        }

        // Get download URL with detailed logging
        final downloadUrl = await ref.getDownloadURL();

        // Validate URL format
        if (downloadUrl.contains('firebasestorage.googleapis.com')) {
        } else {}

        urls.add(downloadUrl);
      } catch (e) {
        rethrow;
      }
    }

    return urls;
  }

  @override
  Future<bool> sendEmailWithAttachments(
    String recipientEmail,
    String subject,
    String body,
    List<String> attachmentUrls,
    Map<String, dynamic> assessmentData,
  ) async {
    try {
      final callable = functions.httpsCallable('sendAssessmentEmail');

      final result = await callable.call({
        'recipientEmail': recipientEmail,
        'subject': subject,
        'body': body,
        'attachmentUrls': attachmentUrls,
        'assessmentData': assessmentData,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return result.data['success'] == true;
    } catch (e) {
      throw ServerException(
        message: 'Failed to send email via Cloud Functions: ${e.toString()}',
      );
    }
  }

  String _generateDefaultSubject(
    AssessmentFormModel assessment,
    List<String> formats,
  ) {
    final formatString = formats.map((f) => f.toUpperCase()).join(', ');
    return 'FV Treatment Center Assessment ($formatString): ${assessment.facilityIdentification.facilityName}';
  }

  String _generateDefaultBody(
    AssessmentFormModel assessment,
    List<String> formats, [
    List<String> photoLinks = const [],
  ]) {
    final buffer = StringBuffer();

    buffer.writeln(
      'Please find attached the assessment form for ${assessment.facilityIdentification.facilityName}.',
    );
    buffer.writeln('');
    buffer.writeln('Assessment Details:');
    buffer.writeln(
      '• Facility Name: ${assessment.facilityIdentification.facilityName}',
    );
    buffer.writeln(
      '• Facility Code: ${assessment.facilityIdentification.facilityCode}',
    );
    buffer.writeln(
      '• Location: ${assessment.geoLocation.cityVillage}, ${assessment.geoLocation.regionProvince}, ${assessment.geoLocation.country}',
    );
    buffer.writeln('• Assessor: ${assessment.assessorInfo.name}');
    buffer.writeln(
      '• Assessment Date: ${assessment.assessorInfo.assessmentDate.toString().split(' ')[0]}',
    );
    buffer.writeln(
      '• Completion Rate: ${assessment.completionPercentage.toStringAsFixed(1)}%',
    );
    buffer.writeln(
      '• Status: ${assessment.isSubmitted ? "Submitted" : "Draft"}',
    );
    buffer.writeln('');
    buffer.writeln(
      'Attached formats: ${formats.map((f) => f.toUpperCase()).join(', ')}',
    );

    // Add photo links if photos were too large to attach
    if (photoLinks.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln(
        'Note: Facility photos are provided as links below (total size > 18MB):',
      );
      buffer.writeln('');
      for (int i = 0; i < photoLinks.length; i++) {
        buffer.writeln('Photo ${i + 1}: ${photoLinks[i]}');
      }
    }

    buffer.writeln('');
    buffer.writeln(
      'This email was sent automatically from the FV Treatment Center Assessment System.',
    );

    return buffer.toString();
  }

  Map<String, dynamic> _getAssessmentSummary(AssessmentFormModel assessment) {
    return {
      'id': assessment.id,
      'facilityName': assessment.facilityIdentification.facilityName,
      'facilityCode': assessment.facilityIdentification.facilityCode,
      'location':
          '${assessment.geoLocation.cityVillage}, ${assessment.geoLocation.regionProvince}, ${assessment.geoLocation.country}',
      'assessorName': assessment.assessorInfo.name,
      'assessmentDate':
          assessment.assessorInfo.assessmentDate?.toIso8601String(),
      'completionPercentage': assessment.completionPercentage,
      'isSubmitted': assessment.isSubmitted,
      'createdAt': assessment.createdAt.toIso8601String(),
      'updatedAt': assessment.updatedAt.toIso8601String(),
    };
  }
}
