import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/providers/save_path_resolver.dart';

import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'export_service.dart';

/// Enum to clearly distinguish different rating states
enum RatingState {
  notAnswered, // null rating
  meetsTarget, // value 3
  partiallyMeets, // value 2
  doesNotMeet, // value 1
  dontKnow, // value 0 or label DK
  notApplicable, // value -1 or label NA
  unknown, // other cases
}

class PdfExportService extends BaseExportService {
  final GetSavePath getSavePath;

  // Class-level font variables
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;
  static pw.Font? _italicFont;
  static bool _fontsLoaded = false;

  PdfExportService({
    required super.fileProvider,
    this.getSavePath = defaultSavePath,
    // });
  });

  @override
  String get fileExtension => 'pdf';

  @override
  String get formatName => 'Adobe PDF';

  @override
  String get mimeType => 'application/pdf';

  /// Load Unicode-compatible fonts
  static Future<void> _loadFonts() async {
    if (_fontsLoaded) return; // Already loaded

    try {
      final regularFontData = await rootBundle.load(
        'assets/fonts/NotoSans-Regular.ttf',
      );
      final boldFontData = await rootBundle.load(
        'assets/fonts/NotoSans-Bold.ttf',
      );
      final italicFontData = await rootBundle.load(
        'assets/fonts/NotoSans-Italic.ttf',
      );

      _regularFont = pw.Font.ttf(regularFontData);
      _boldFont = pw.Font.ttf(boldFontData);
      _italicFont = pw.Font.ttf(italicFontData);
      _fontsLoaded = true;
      return;
    } catch (assetError) {
      //
    }
  }

  /// Create text style with Unicode font support
  static pw.TextStyle _createTextStyle({
    double fontSize = 12,
    bool bold = false,
    bool italic = false,
    PdfColor? color,
  }) {
    pw.Font font;
    if (bold && italic) {
      font = _italicFont ?? pw.Font.timesBoldItalic();
    } else if (bold) {
      font = _boldFont ?? pw.Font.timesBold();
    } else if (italic) {
      font = _italicFont ?? pw.Font.timesItalic();
    } else {
      font = _regularFont ?? pw.Font.times();
    }

    return pw.TextStyle(
      font: font,
      fontSize: fontSize,
      color: color ?? PdfColors.black,
    );
  }

  @visibleForTesting
  pw.TextStyle createTextStyle({
    double fontSize = 12,
    bool bold = false,
    bool italic = false,
    PdfColor? color,
  }) {
    return _createTextStyle(
      fontSize: fontSize,
      bold: bold,
      italic: italic,
      color: color,
    );
  }

  @override
  Future<ExportResult> exportAssessment(
    AssessmentFormModel assessment, {
    String? outputPath,
    ExportOptions? options,
  }) async {
    try {
      // Load fonts before creating PDF
      await _loadFonts();

      // Validate assessment before export
      validateForExport(assessment);

      final exportOptions = options ?? const ExportOptions();
      final fileName = getDefaultFileName(assessment);
      final pdf = pw.Document();

      // Build PDF content
      await _buildPdfDocument(pdf, assessment, exportOptions);

      // Save the PDF
      final pdfBytes = await pdf.save();

      // new
      final bytesUint8List = Uint8List.fromList(pdfBytes);

      // new
      final resolvedPath =
          outputPath ??
          await getSavePath(
            fileName: fileName,
            mimeType: mimeType,
            bytes: kIsWeb ? bytesUint8List : null,
          );
      // final resolvedPath =
      //     outputPath ??
      //     await getSavePath(
      //       fileName: fileName,
      //       mimeType: mimeType,
      //       bytes: kIsWeb ? Uint8List.fromList(pdfBytes) : null,
      //     );

      if (!kIsWeb) {
        final file = await fileProvider.getFile(resolvedPath);
        await fileProvider.writeAsBytes(file, pdfBytes);
        // Validate only when the file exists locally
        await validateExportedFile(resolvedPath, minSizeBytes: 5_000);
      }

      return ExportResult(
        filePath: resolvedPath,
        fileName: fileName,
        format: formatName,
        fileSizeBytes: pdfBytes.length,
        createdAt: DateTime.now(),
        // new
        bytes: kIsWeb ? bytesUint8List : null, // Include bytes on web

        metadata: {
          'pages': _getPageCount(assessment, exportOptions),
          'includeDetailedSections': exportOptions.includeSectionDetails,
          'includeAnalysis': exportOptions.includeAnalysis,
          'includeSignaturePage': exportOptions.includeSignaturePage,
          'sections': assessment.sections.length,
          'totalItems': assessment.totalItems,
          'completedItems': assessment.completedItems,
        },
      );
    } catch (e) {
      if (e is ExportException ||
          e is ValidationException ||
          e is FileException) {
        rethrow;
      }
      throw PdfExportException(
        message: 'Failed to export PDF file: ${e.toString()}',
      );
    }
  }

  @override
  void validateFormatSpecific(AssessmentFormModel assessment) {
    // PDF-specific validation
    assessment.sections.fold(0, (sum, section) => sum + section.items.length);
  }

  /// Build the complete PDF document
  Future<void> _buildPdfDocument(
    pw.Document pdf,
    AssessmentFormModel assessment,
    ExportOptions options,
  ) async {
    // Define consistent styles using safe fonts
    final titleStyle = _createTextStyle(fontSize: 20, bold: true);
    final subSectionHeaderStyle = _createTextStyle(fontSize: 14, bold: true);
    final smallStyle = _createTextStyle(fontSize: 8);

    // Page 1: Cover Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200, width: 2),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Structural Rapid Assessment Tool',
                      style: titleStyle,
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'for Treatment Centers during Ebola and Marburg Outbreaks',
                      style: subSectionHeaderStyle,
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Assessment Overview
              _buildInfoSection('Assessment Overview', [
                'Facility: ${assessment.facilityIdentification.facilityName}',
                'Code: ${assessment.facilityIdentification.facilityCode}',
                'Location: ${assessment.geoLocation.cityVillage}, ${assessment.geoLocation.regionProvince}, ${assessment.geoLocation.country}',
                'Assessor: ${assessment.assessorInfo.name}',
                'Date: ${assessment.assessorInfo.assessmentDate.toString().split(' ')[0]}',
                'Status: ${assessment.isSubmitted ? "Submitted" : "Draft"}',
                'Completion: ${assessment.completionPercentage.toStringAsFixed(1)}%',
              ]),

              pw.SizedBox(height: 20),

              // Summary Statistics
              _buildSummaryStats(assessment),

              pw.SizedBox(height: 20),

              _buildRatingDistribution(assessment),

              pw.SizedBox(height: 20),

              // Rating Legend
              _buildRatingLegend(),

              pw.Spacer(),

              // Footer
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.grey300),
                  ),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Generated on: ${DateTime.now().toString().split(' ')[0]}',
                      style: smallStyle,
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      'This assessment follows WHO guidelines for FVD treatment centers',
                      style: smallStyle,
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Page 2: Facility Identification
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                'Section 1',
                'Facility Information Assessment',
              ),
              pw.SizedBox(height: 15),

              // 1.1 Assessment Information
              _buildSubSectionHeader('1.1 Assessment Information'),
              _buildInfoTable([
                [
                  '1.1.1',
                  'Date of assessment',
                  assessment.assessorInfo.assessmentDate.toString().split(
                    ' ',
                  )[0],
                ],
                [
                  '1.1.2',
                  'Name of person conducting assessment',
                  assessment.assessorInfo.name,
                ],
                ['1.1.3', 'Email', assessment.assessorInfo.email],
                ['1.1.4', 'Phone', assessment.assessorInfo.phoneNumber],
              ]),
              pw.SizedBox(height: 15),

              // 1.2 Geographical Location
              _buildSubSectionHeader('1.2 Geographical Location'),
              _buildInfoTable([
                ['1.2.1', 'Country', assessment.geoLocation.country],
                [
                  '1.2.2',
                  'Region/Province',
                  assessment.geoLocation.regionProvince,
                ],
                ['1.2.3', 'District', assessment.geoLocation.district],
                ['1.2.4', 'City/Village', assessment.geoLocation.cityVillage],
                [
                  '1.2.5',
                  'Address/GPS coordinates',
                  assessment.geoLocation.addressOrCoordinates,
                ],
                [
                  '1.2.6',
                  'Record of facility location',
                  assessment.geoLocation.locationType?.name ?? '',
                ],
                [
                  '1.2.7',
                  'Latitude',
                  assessment.geoLocation.latitude?.toString() ??
                      'Not specified',
                ],
                [
                  '1.2.8',
                  'Longitude',
                  assessment.geoLocation.longitude?.toString() ??
                      'Not specified',
                ],
              ]),
              pw.SizedBox(height: 15),
            ],
          );
        },
      ),
    );

    // Page 3: Facility Services (with proper null safety)
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1.3 Facility Identification
              _buildSubSectionHeader('1.3 Facility Identification'),
              _buildInfoTable([
                [
                  '1.3.1',
                  'Facility code',
                  assessment.facilityIdentification.facilityCode,
                ],
                [
                  '1.3.2',
                  'Facility name',
                  assessment.facilityIdentification.facilityName,
                ],
                [
                  '1.3.3',
                  'Managing authority',
                  getManagingAuthorityText(
                    assessment.facilityIdentification.managingAuthority,
                  ),
                ],
                [
                  '1.3.4',
                  'Director/Manager name',
                  assessment.facilityIdentification.directorName,
                ],
                [
                  '1.3.5',
                  'Director/Manager phone',
                  assessment.facilityIdentification.directorPhone,
                ],
                [
                  '1.3.6',
                  'Director/Manager email',
                  assessment.facilityIdentification.directorEmail,
                ],
                [
                  '1.3.7',
                  'Respondent or key informant\'s name',
                  assessment.facilityIdentification.respondentName,
                ],
                [
                  '1.3.8',
                  'Respondent or key informant\'s position',
                  assessment.facilityIdentification.respondentPosition,
                ],
                [
                  '1.3.9',
                  'Type of structure',
                  getStructureTypeText(
                    assessment.facilityIdentification.structureType,
                  ),
                ],
                [
                  '1.3.10',
                  'Type of facility',
                  getFacilityTypeText(
                    assessment.facilityIdentification.facilityType,
                  ),
                ],
                [
                  '1.3.11',
                  'Type of existing health care facility',
                  assessment
                          .facilityIdentification
                          .existingFacilityType
                          ?.name ??
                      '',
                ],
              ]),

              pw.SizedBox(height: 25),

              _buildSubSectionHeader(
                '1.4 Existing health care facility services',
              ),

              // Handle null facility services properly
              ...[
                _buildInfoTable([
                  [
                    '1.4.1',
                    'The facility offers outpatient services',
                    _getYesNoText(
                      assessment.facilityServices.hasOutpatientServices,
                    ),
                  ],
                  [
                    '1.4.2',
                    'The facility offers inpatient services',
                    _getYesNoText(
                      assessment.facilityServices.hasInpatientServices,
                    ),
                  ],
                  if (assessment.facilityServices.hasInpatientServices ==
                      true) ...[
                    [
                      '1.4.3',
                      'Total number of overnight/inpatient beds',
                      assessment.facilityServices.totalInpatientBeds
                              ?.toString() ??
                          'Not specified',
                    ],
                    [
                      '1.4.4',
                      'Of the total number of inpatient beds, how many are intensive care unit (ICU) beds?',
                      assessment.facilityServices.icuBeds?.toString() ??
                          'Not specified',
                    ],
                    [
                      '1.4.5',
                      'The facility has dedicated 24-hour staffed emergency unit',
                      _getYesNoText(
                        assessment.facilityServices.hasEmergencyUnit,
                      ),
                    ],
                    [
                      '1.4.6',
                      'The facility has intensive care or high-dependency unit',
                      _getYesNoText(
                        assessment.facilityServices.hasIcuOrHighDependencyUnit,
                      ),
                    ],
                  ],
                ]),
              ],
              pw.Spacer(),

              _buildSection1Stats(assessment),
            ],
          );
        },
      ),
    );

    // Analysis page (if enabled)
    if (options.includeAnalysis) {
      _addAnalysisPage(pdf, assessment);
    }

    // Section pages with ALL details (if detailed sections are included)
    if (options.includeSectionDetails) {
      for (final section in assessment.sections) {
        if (section.items.isNotEmpty) {
          _addDetailedSectionPages(pdf, section, assessment);
        }
      }
    }

    // Summary and Recommendations page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Assessment', 'Summary and Recommendations'),
              pw.SizedBox(height: 20),

              // Overall completion
              _buildCompletionOverview(assessment),
              pw.SizedBox(height: 20),

              // Section breakdown
              _buildSectionBreakdown(assessment),
              pw.SizedBox(height: 20),

              pw.Spacer(),

              // Signature section (if enabled)
              if (options.includeSignaturePage)
                _buildSignatureSection(assessment),
            ],
          );
        },
      ),
    );
  }

  /// Add detailed section pages with ALL assessment items
  void _addDetailedSectionPages(
    pw.Document pdf,
    dynamic section,
    AssessmentFormModel assessment,
  ) {
    final items = section.items as List;
    const itemsPerPage = 2;

    // Calculate how many pages we need for this section
    final pageCount = (items.length / itemsPerPage).ceil();

    for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
      final startIndex = pageIndex * itemsPerPage;
      final endIndex =
          (startIndex + itemsPerPage < items.length)
              ? startIndex + itemsPerPage
              : items.length;
      final pageItems = items.sublist(startIndex, endIndex);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(25),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Section header
                _buildSectionHeader(
                  'Section ${section.sectionNumber}',
                  section.title ?? 'No title',
                ),
                pw.SizedBox(height: 8),

                // Page indicator for multi-page sections
                if (pageCount > 1)
                  pw.Container(
                    padding: const pw.EdgeInsets.all(6),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue100,
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                    child: pw.Text(
                      'Page ${pageIndex + 1} of $pageCount - Items ${startIndex + 1} to $endIndex of ${items.length}',
                      style: _createTextStyle(fontSize: 10, bold: true),
                    ),
                  ),

                pw.SizedBox(height: 10),

                // Section progress (only on first page)
                if (pageIndex == 0) _buildSectionProgress(section),

                pw.SizedBox(height: 15),

                // Assessment items
                pw.Expanded(
                  child: pw.Column(
                    children:
                        pageItems
                            .map<pw.Widget>(
                              (item) => _buildDetailedItemCard(item),
                            )
                            .toList(),
                  ),
                ),

                // Section summary (only on last page)
                if (pageIndex == pageCount - 1) _buildSectionSummary(section),
              ],
            );
          },
        ),
      );
    }
  }

  /// Build detailed item card with FVD assessment format
  pw.Widget _buildDetailedItemCard(dynamic item) {
    // Determine the exact rating state
    final RatingState state = _determineRatingState(item.selectedRating);

    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Question header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue600,
              borderRadius: pw.BorderRadius.only(
                topLeft: pw.Radius.circular(5),
                topRight: pw.Radius.circular(5),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Text(
                  item.sectionNumber ?? 'N/A',
                  style: _createTextStyle(
                    fontSize: 12,
                    bold: true,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Text(
                    item.area ?? 'No area specified',
                    style: _createTextStyle(
                      fontSize: 12,
                      bold: true,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Rating options with checkboxes
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header row
                pw.Container(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 100,
                        child: pw.Text(
                          'Response Options',
                          style: _createTextStyle(fontSize: 10, bold: true),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          'Description',
                          style: _createTextStyle(fontSize: 10, bold: true),
                        ),
                      ),
                      pw.Container(
                        width: 40,
                        child: pw.Text(
                          'Selected',
                          style: _createTextStyle(fontSize: 9, bold: true),
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                pw.Container(
                  height: 1,
                  color: PdfColors.grey300,
                  margin: const pw.EdgeInsets.only(bottom: 8),
                ),

                // Meets Target option
                _buildRatingOption(
                  'Meets target (+++) (3)',
                  item.meetsTargetDescription ??
                      'Fully meets the target requirements.',
                  state == RatingState.meetsTarget,
                  PdfColors.green600,
                ),

                pw.SizedBox(height: 6),

                // Partially Meets option
                _buildRatingOption(
                  'Partially meets target (++) (2)',
                  item.partiallyMeetsDescription ??
                      'Partially meets the target requirements with some gaps.',
                  state == RatingState.partiallyMeets,
                  PdfColors.orange400,
                ),

                pw.SizedBox(height: 6),

                // Does Not Meet option
                _buildRatingOption(
                  'Does not meet target (+) (1)',
                  item.doesNotMeetDescription ??
                      'Does not meet the target requirements.',
                  state == RatingState.doesNotMeet,
                  PdfColors.red600,
                ),

                pw.SizedBox(height: 6),

                // Don't Know option
                _buildRatingOption(
                  'Don\'t Know (DK) (0)',
                  'Information not available at time of assessment.',
                  state == RatingState.dontKnow,
                  PdfColors.purple400,
                ),

                pw.SizedBox(height: 6),

                // Not Applicable option
                _buildRatingOption(
                  'Not Applicable (NA) (-1)',
                  'This criterion does not apply to this facility.',
                  state == RatingState.notApplicable,
                  PdfColors.grey500,
                ),

                // Show status if not answered
                if (state == RatingState.notAnswered) ...[
                  pw.SizedBox(height: 10),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.orange50,
                      border: pw.Border.all(color: PdfColors.orange300),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      '[NOT ANSWERED] This assessment item has not been completed yet.',
                      style: _createTextStyle(
                        fontSize: 9,
                        bold: true,
                        italic: true,
                        color: PdfColors.orange600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a single rating option with checkbox
  pw.Widget _buildRatingOption(
    String optionText,
    String description,
    bool isSelected,
    PdfColor color,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Option label
        pw.Container(
          width: 100,
          child: pw.Text(
            optionText,
            style: _createTextStyle(
              fontSize: 9,
              bold: isSelected,
              color: isSelected ? color : PdfColors.black,
            ),
          ),
        ),

        // Description
        pw.Expanded(
          child: pw.Text(
            description,
            style: _createTextStyle(
              fontSize: 9,
              bold: isSelected,
              color: isSelected ? PdfColors.black : PdfColors.grey700,
            ),
          ),
        ),

        // Checkbox
        pw.Container(
          width: 40,
          child: pw.Center(
            child: pw.Container(
              width: 12,
              height: 12,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: isSelected ? color : PdfColors.grey400,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: pw.BorderRadius.circular(2),
                color: isSelected ? color : PdfColors.white,
              ),
              child:
                  isSelected
                      ? pw.Center(
                        child: pw.Text(
                          'X',
                          style: _createTextStyle(
                            fontSize: 8,
                            bold: true,
                            color: PdfColors.white,
                          ),
                        ),
                      )
                      : null,
            ),
          ),
        ),
      ],
    );
  }

  RatingState _determineRatingState(dynamic rating) {
    if (rating == null) {
      return RatingState.notAnswered;
    }

    // Check value first
    if (rating.value != null) {
      final intValue = rating.value;

      if (intValue != null) {
        switch (intValue) {
          case 3:
            return RatingState.meetsTarget;
          case 2:
            return RatingState.partiallyMeets;
          case 1:
            return RatingState.doesNotMeet;
          case 0:
            return RatingState.dontKnow;
          case -1:
            return RatingState.notApplicable;
        }
      }
    }

    return RatingState.unknown;
  }

  int _countSectionRatingsByValue(dynamic section, int value) {
    if (section?.items == null) return 0;

    return section.items.where((item) {
      if (item.selectedRating == null || item.selectedRating.value == null) {
        return false;
      }

      final intValue = item.selectedRating.value;

      return intValue == value;
    }).length;
  }

  int _countSectionRatingsByLabel(dynamic section, String label) {
    if (section?.items == null) return 0;

    return section.items.where((item) {
      if (item.selectedRating == null) return false;

      // Check by label
      if (item.selectedRating.label != null &&
          item.selectedRating.label.toString().toUpperCase() ==
              label.toUpperCase()) {
        return true;
      }

      // Also check by value for DK (0) and NA (-1)
      if (item.selectedRating.value != null) {
        final intValue = item.selectedRating.value;

        if (label.toUpperCase() == 'DK' && intValue == 0) return true;
        if (label.toUpperCase() == 'NA' && intValue == -1) return true;
      }

      return false;
    }).length;
  }

  pw.Widget _buildRatingDistribution(AssessmentFormModel assessment) {
    final meetsTarget = _countRatingsByValue(assessment, 3);
    final partiallyMeets = _countRatingsByValue(assessment, 2);
    final doesNotMeet = _countRatingsByValue(assessment, 1);
    final dontKnow = _countRatingsByLabel(assessment, 'DK');
    final notApplicable = _countRatingsByLabel(assessment, 'NA');
    final unanswered = _countUnansweredItems(assessment);

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Rating Distribution',
            style: _createTextStyle(fontSize: 14, bold: true),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildRatingItem(
                'Meets Target (+++)',
                meetsTarget,
                PdfColors.green400,
              ),
              _buildRatingItem(
                'Partially Meets (++)',
                partiallyMeets,
                PdfColors.yellow400,
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildRatingItem(
                'Does Not Meet (+)',
                doesNotMeet,
                PdfColors.red400,
              ),
              _buildRatingItem(
                'Don\'t Know (DK)',
                dontKnow,
                PdfColors.purple400,
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildRatingItem(
                'Not Applicable (NA)',
                notApplicable,
                PdfColors.grey500,
              ),
              _buildRatingItem('Not Answered', unanswered, PdfColors.orange400),
            ],
          ),
        ],
      ),
    );
  }

  int _countRatingsByValue(AssessmentFormModel assessment, int value) {
    int count = 0;
    for (final section in assessment.sections) {
      count += _countSectionRatingsByValue(section, value);
    }
    return count;
  }

  int _countRatingsByLabel(AssessmentFormModel assessment, String label) {
    int count = 0;
    for (final section in assessment.sections) {
      count += _countSectionRatingsByLabel(section, label);
    }
    return count;
  }

  /// Count unanswered items
  /// Count unanswered items (including Section 1 metadata + questions)
  int _countUnansweredItems(AssessmentFormModel assessment) {
    int count = 0;
    for (final section in assessment.sections) {
      if (section.sectionNumber == '1') {
        // Section 1 “total” includes both metadata fields and question‑items,
        // whereas completedItems only counts metadata+questions that are done.
        count +=
            assessment.section1TotalItems - assessment.section1CompletedItems;
      } else {
        // all other sections: unanswered are those with no selectedRating
        count +=
            section.items.where((item) => item.selectedRating == null).length;
      }
    }
    return count;
  }

  /// Build section summary with proper counts
  pw.Widget _buildSectionSummary(dynamic section) {
    final totalItems = section?.items?.length ?? 0;
    final completedCount = section.completedItemsCount;
    final unansweredCount = totalItems - completedCount;
    final progress = totalItems > 0 ? (completedCount / totalItems) * 100 : 0.0;

    final meets = _countSectionRatingsByValue(section, 3);
    final partial = _countSectionRatingsByValue(section, 2);
    final doesNot = _countSectionRatingsByValue(section, 1);
    final dk = _countSectionRatingsByLabel(section, 'DK');
    final na = _countSectionRatingsByLabel(section, 'NA');

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'SECTION ${section?.sectionNumber ?? 'N/A'} SUMMARY',
            style: _createTextStyle(fontSize: 12, bold: true),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Total Items: $totalItems',
                    style: _createTextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'Answered: $completedCount',
                    style: _createTextStyle(fontSize: 10, bold: true),
                  ),
                  pw.Text(
                    'Not Answered: $unansweredCount',
                    style: _createTextStyle(
                      fontSize: 10,
                      bold: true,
                      color: PdfColors.orange600,
                    ),
                  ),
                  pw.Text(
                    'Progress: ${progress.toStringAsFixed(1)}%',
                    style: _createTextStyle(fontSize: 10, bold: true),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Meets Target (+++): $meets',
                    style: _createTextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'Partially Meets (++): $partial',
                    style: _createTextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'Does Not Meet (+): $doesNot',
                    style: _createTextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Don\'t Know (DK): $dk',
                    style: _createTextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'Not Applicable (NA): $na',
                    style: _createTextStyle(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),

          // Progress warnings
          if (unansweredCount > 0) ...[
            pw.SizedBox(height: 8),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.orange100,
                border: pw.Border.all(color: PdfColors.orange400),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Row(
                children: [
                  pw.Text(
                    '[WARNING]',
                    style: _createTextStyle(fontSize: 10, bold: true),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: pw.Text(
                      'INCOMPLETE: $unansweredCount items still need to be assessed for a complete evaluation.',
                      style: _createTextStyle(
                        fontSize: 10,
                        bold: true,
                        color: PdfColors.orange600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  String getRatingText(dynamic rating) {
    final state = _determineRatingState(rating);
    switch (state) {
      case RatingState.notAnswered:
        return 'NOT ANSWERED';
      case RatingState.meetsTarget:
        return 'Meets Target (+++)';
      case RatingState.partiallyMeets:
        return 'Partially Meets (++)';
      case RatingState.doesNotMeet:
        return 'Does Not Meet (+)';
      case RatingState.dontKnow:
        return 'Don\'t Know (DK)';
      case RatingState.notApplicable:
        return 'Not Applicable (NA)';
      case RatingState.unknown:
        return rating?.label?.toString() ?? 'Unknown Rating';
    }
  }

  // =================== HELPER METHODS ===================
  /// Helper method to convert boolean to Yes/No text
  String _getYesNoText(bool? value) {
    if (value == null) return 'Not specified';
    return value ? 'Yes' : 'No';
  }

  // =================== UI BUILDER METHODS ===================

  void _addAnalysisPage(pw.Document pdf, AssessmentFormModel assessment) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Analysis', 'Detailed Statistical Analysis'),
              pw.SizedBox(height: 20),
              _buildOverallStatistics(assessment),
              pw.SizedBox(height: 20),
              _buildRatingBreakdownChart(assessment),
              pw.SizedBox(height: 20),
              _buildSectionPerformanceTable(assessment),
            ],
          );
        },
      ),
    );
  }

  pw.Widget _buildSectionHeader(String sectionNum, String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue600,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Text(
        '$sectionNum: $title',
        style: _createTextStyle(
          fontSize: 14,
          bold: true,
          color: PdfColors.white,
        ),
      ),
    );
  }

  pw.Widget _buildSubSectionHeader(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue100,
        borderRadius: pw.BorderRadius.circular(3),
      ),
      child: pw.Text(title, style: _createTextStyle(fontSize: 12, bold: true)),
    );
  }

  pw.Widget _buildInfoSection(String title, List<String> items) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: _createTextStyle(fontSize: 14, bold: true)),
          pw.SizedBox(height: 10),
          ...items.map(
            (item) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Text(item, style: _createTextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoTable(List<List<String>> rows) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FixedColumnWidth(50),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(3),
      },
      children:
          rows
              .map(
                (row) => pw.TableRow(
                  children:
                      row
                          .map(
                            (cell) => pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text(
                                cell,
                                style: _createTextStyle(fontSize: 10),
                              ),
                            ),
                          )
                          .toList(),
                ),
              )
              .toList(),
    );
  }

  pw.Widget _buildSummaryStats(AssessmentFormModel assessment) {
    final totalItems = assessment.totalItems;
    final completedItems = assessment.completedItems;
    final completionRate =
        totalItems > 0 ? (completedItems / totalItems) * 100 : 0.0;

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        border: pw.Border.all(color: PdfColors.green200),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Assessment Summary',
            style: _createTextStyle(fontSize: 14, bold: true),
          ),
          pw.SizedBox(height: 10),

          // Assessment Progress
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Total Sections: ${assessment.sections.length}',
                style: _createTextStyle(fontSize: 12),
              ),
              pw.Text(
                'Total Items: $totalItems',
                style: _createTextStyle(fontSize: 12),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Completed Items: $completedItems',
                style: _createTextStyle(fontSize: 12),
              ),
              pw.Text(
                'Completion Rate: ${completionRate.toStringAsFixed(1)}%',
                style: _createTextStyle(fontSize: 12, bold: true),
              ),
            ],
          ),

          // Facility Capacity (with null safety)
          ...[
            pw.SizedBox(height: 10),
            pw.Container(
              width: double.infinity,
              height: 1,
              color: PdfColors.grey300,
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Facility Capacity',
              style: _createTextStyle(fontSize: 12, bold: true),
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Outpatient Services: ${_getYesNoText(assessment.facilityServices.hasOutpatientServices)}',
                  style: _createTextStyle(fontSize: 11),
                ),
                pw.Text(
                  'Inpatient Services: ${_getYesNoText(assessment.facilityServices.hasInpatientServices)}',
                  style: _createTextStyle(fontSize: 11),
                ),
              ],
            ),
            if (assessment.facilityServices.hasInpatientServices == true) ...[
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Beds: ${assessment.facilityServices.totalInpatientBeds ?? "N/A"}',
                    style: _createTextStyle(fontSize: 11),
                  ),
                  pw.Text(
                    'ICU Beds: ${assessment.facilityServices.icuBeds ?? "N/A"}',
                    style: _createTextStyle(fontSize: 11),
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '24h Emergency: ${_getYesNoText(assessment.facilityServices.hasEmergencyUnit)}',
                    style: _createTextStyle(fontSize: 11),
                  ),
                  pw.Text(
                    'ICU/HDU: ${_getYesNoText(assessment.facilityServices.hasIcuOrHighDependencyUnit)}',
                    style: _createTextStyle(fontSize: 11),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  pw.Widget _buildRatingItem(String label, int count, PdfColor color) {
    return pw.Row(
      children: [
        pw.Container(width: 12, height: 12, color: color),
        pw.SizedBox(width: 5),
        pw.Text('$label: $count', style: _createTextStyle(fontSize: 10)),
      ],
    );
  }

  pw.Widget _buildRatingLegend() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Rating Scale Legend',
            style: _createTextStyle(fontSize: 12, bold: true),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Container(width: 15, height: 15, color: PdfColors.green400),
              pw.SizedBox(width: 5),
              pw.Text(
                '+++ (3) Meets target',
                style: _createTextStyle(fontSize: 10),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Container(width: 15, height: 15, color: PdfColors.yellow400),
              pw.SizedBox(width: 5),
              pw.Text(
                '++ (2) Partially meets target',
                style: _createTextStyle(fontSize: 10),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Container(width: 15, height: 15, color: PdfColors.red400),
              pw.SizedBox(width: 5),
              pw.Text(
                '+ (1) Does not meet target',
                style: _createTextStyle(fontSize: 10),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Container(width: 15, height: 15, color: PdfColors.purple400),
              pw.SizedBox(width: 5),
              pw.Text(
                'DK (0) - Don\'t Know',
                style: _createTextStyle(fontSize: 10),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Container(width: 15, height: 15, color: PdfColors.grey500),
              pw.SizedBox(width: 5),
              pw.Text(
                'NA (-1) - Not Applicable',
                style: _createTextStyle(fontSize: 10),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Container(width: 15, height: 15, color: PdfColors.orange400),
              pw.SizedBox(width: 5),
              pw.Text(
                'Not Answered - Pending Assessment',
                style: _createTextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSectionProgress(dynamic section) {
    final completedCount = section.completedItemsCount;
    final totalItems = section.items?.length ?? 0;
    final progress = totalItems > 0 ? (completedCount / totalItems) * 100 : 0.0;

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(3),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            'Progress: ',
            style: _createTextStyle(fontSize: 12, bold: true),
          ),
          pw.Text(
            '$completedCount/$totalItems items completed',
            style: _createTextStyle(fontSize: 12),
          ),
          pw.Spacer(),
          pw.Text(
            '${progress.toStringAsFixed(1)}%',
            style: _createTextStyle(fontSize: 12, bold: true),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildOverallStatistics(AssessmentFormModel assessment) {
    final totalItems = assessment.totalItems;
    final completedItems = assessment.completedItems;
    final meetsTarget = _countRatingsByValue(assessment, 3);
    final partiallyMeets = _countRatingsByValue(assessment, 2);
    final doesNotMeet = _countRatingsByValue(assessment, 1);
    final dontKnow = _countRatingsByLabel(assessment, 'DK');
    final notApplicable = _countRatingsByLabel(assessment, 'NA');
    final unanswered = _countUnansweredItems(assessment);

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Overall Statistics',
            style: _createTextStyle(fontSize: 14, bold: true),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              _buildStatRow('Total Assessment Items', totalItems.toString()),
              _buildStatRow('Completed Items', completedItems.toString()),
              _buildStatRow('Not Answered Items', unanswered.toString()),
              _buildStatRow(
                'Completion Rate',
                '${assessment.completionPercentage.toStringAsFixed(1)}%',
              ),
              _buildStatRow('Meeting Target (+++)', meetsTarget.toString()),
              _buildStatRow(
                'Partially Meeting (++)',
                partiallyMeets.toString(),
              ),
              _buildStatRow('Not Meeting (+)', doesNotMeet.toString()),
              _buildStatRow('Don\'t Know (DK)', dontKnow.toString()),
              _buildStatRow('Not Applicable (NA)', notApplicable.toString()),
            ],
          ),
        ],
      ),
    );
  }

  pw.TableRow _buildStatRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(label, style: _createTextStyle(fontSize: 10)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            value,
            style: _createTextStyle(fontSize: 10, bold: true),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildRatingBreakdownChart(AssessmentFormModel assessment) {
    final completedItems = assessment.completedItems;

    final meetsTarget = _countRatingsByValue(assessment, 3);
    final partiallyMeets = _countRatingsByValue(assessment, 2);
    final doesNotMeet = _countRatingsByValue(assessment, 1);

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Performance Distribution (% of completed items)',
            style: _createTextStyle(fontSize: 14, bold: true),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Meets Target: ${((meetsTarget / completedItems) * 100).toStringAsFixed(1)}%',
            style: _createTextStyle(fontSize: 12),
          ),
          pw.Text(
            'Partially Meets: ${((partiallyMeets / completedItems) * 100).toStringAsFixed(1)}%',
            style: _createTextStyle(fontSize: 12),
          ),
          pw.Text(
            'Does Not Meet: ${((doesNotMeet / completedItems) * 100).toStringAsFixed(1)}%',
            style: _createTextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSectionPerformanceTable(AssessmentFormModel assessment) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Section Performance Detail',
          style: _createTextStyle(fontSize: 14, bold: true),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    'Section',
                    style: _createTextStyle(fontSize: 9, bold: true),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    'Total',
                    style: _createTextStyle(fontSize: 9, bold: true),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    'Completed',
                    style: _createTextStyle(fontSize: 9, bold: true),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    '+++',
                    style: _createTextStyle(fontSize: 9, bold: true),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    '++',
                    style: _createTextStyle(fontSize: 9, bold: true),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    '+',
                    style: _createTextStyle(fontSize: 9, bold: true),
                  ),
                ),
              ],
            ),
            ...assessment.sections.take(15).map((section) {
              final isSection1 = section.sectionNumber == '1';
              final total =
                  isSection1
                      ? assessment.section1TotalItems
                      : section.items.length;
              final completedCount =
                  isSection1
                      ? assessment.section1CompletedItems
                      : section.completedItemsCount;
              final meets =
                  isSection1
                      ? _countSectionRatingsByValue(section, 3)
                      : _countSectionRatingsByValue(section, 3);
              final partial =
                  isSection1
                      ? _countSectionRatingsByValue(section, 2)
                      : _countSectionRatingsByValue(section, 2);
              final doesNot =
                  isSection1
                      ? _countSectionRatingsByValue(section, 1)
                      : _countSectionRatingsByValue(section, 1);

              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      section.sectionNumber,
                      style: _createTextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      '$total',
                      style: _createTextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      '$completedCount',
                      style: _createTextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      '$meets',
                      style: _createTextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      '$partial',
                      style: _createTextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      '$doesNot',
                      style: _createTextStyle(fontSize: 8),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildCompletionOverview(AssessmentFormModel assessment) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Overall Completion Status',
            style: _createTextStyle(fontSize: 14, bold: true),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Completion Rate: ${assessment.completionPercentage.toStringAsFixed(1)}%',
            style: _createTextStyle(fontSize: 12),
          ),
          pw.Text(
            'Status: ${assessment.isSubmitted ? "Submitted" : "Draft"}',
            style: _createTextStyle(fontSize: 12),
          ),
          if (assessment.isSubmitted && assessment.submissionDate != null)
            pw.Text(
              'Submitted: ${assessment.submissionDate!.toString().split(' ')[0]}',
              style: _createTextStyle(fontSize: 12),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildSection1Stats(AssessmentFormModel assessment) {
    final totalItems = assessment.section1TotalItems;
    final completedCount = assessment.section1CompletedItems;
    final unansweredCount = totalItems - completedCount;
    final progress = totalItems > 0 ? (completedCount / totalItems) * 100 : 0.0;

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'SECTION 1 SUMMARY',
            style: _createTextStyle(fontSize: 12, bold: true),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Total Items: $totalItems',
                    style: _createTextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'Answered: $completedCount',
                    style: _createTextStyle(fontSize: 10, bold: true),
                  ),
                  pw.Text(
                    'Not Answered: $unansweredCount',
                    style: _createTextStyle(
                      fontSize: 10,
                      bold: true,
                      color: PdfColors.orange600,
                    ),
                  ),
                  pw.Text(
                    'Progress: ${progress.toStringAsFixed(1)}%',
                    style: _createTextStyle(fontSize: 10, bold: true),
                  ),
                ],
              ),
            ],
          ),

          // Progress warnings
          if (unansweredCount > 0) ...[
            pw.SizedBox(height: 8),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.orange100,
                border: pw.Border.all(color: PdfColors.orange400),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Row(
                children: [
                  pw.Text(
                    '[WARNING]',
                    style: _createTextStyle(fontSize: 10, bold: true),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: pw.Text(
                      'INCOMPLETE: $unansweredCount items still need to be assessed for a complete evaluation.',
                      style: _createTextStyle(
                        fontSize: 10,
                        bold: true,
                        color: PdfColors.orange600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildSectionBreakdown(AssessmentFormModel assessment) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Section-by-Section Breakdown',
          style: _createTextStyle(fontSize: 14, bold: true),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Section',
                    style: _createTextStyle(fontSize: 10, bold: true),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Items',
                    style: _createTextStyle(fontSize: 10, bold: true),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Completed',
                    style: _createTextStyle(fontSize: 10, bold: true),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    'Progress',
                    style: _createTextStyle(fontSize: 10, bold: true),
                  ),
                ),
              ],
            ),
            ...assessment.sections.take(10).map((section) {
              final completedCount =
                  section.sectionNumber == '1'
                      ? assessment.section1CompletedItems
                      : section.completedItemsCount;
              final totalItems =
                  section.sectionNumber == '1'
                      ? assessment.section1TotalItems
                      : section.items.length;
              final progress =
                  totalItems > 0 ? (completedCount / totalItems) * 100 : 0.0;
              final sectionTitle = section.title;
              final displayTitle =
                  sectionTitle.length > 25
                      ? '${sectionTitle.substring(0, 25)}...'
                      : sectionTitle;

              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      '${section.sectionNumber}: $displayTitle',
                      style: _createTextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      '$totalItems',
                      style: _createTextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      '$completedCount',
                      style: _createTextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      '${progress.toStringAsFixed(1)}%',
                      style: _createTextStyle(fontSize: 9),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildSignatureSection(AssessmentFormModel assessment) {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        children: [
          pw.Text(
            'Assessment Certification',
            style: _createTextStyle(fontSize: 14, bold: true),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Assessor Signature:',
                    style: _createTextStyle(fontSize: 10),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Container(width: 150, height: 1, color: PdfColors.black),
                  pw.Text(
                    assessment.assessorInfo.name,
                    style: _createTextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    assessment.assessorInfo.email,
                    style: _createTextStyle(fontSize: 8),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Date:', style: _createTextStyle(fontSize: 10)),
                  pw.SizedBox(height: 30),
                  pw.Container(width: 100, height: 1, color: PdfColors.black),
                  pw.Text(
                    DateTime.now().toString().split(' ')[0],
                    style: _createTextStyle(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Facility Representative:',
                    style: _createTextStyle(fontSize: 10),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Container(width: 150, height: 1, color: PdfColors.black),
                  pw.Text(
                    assessment.facilityIdentification.directorName,
                    style: _createTextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Date:', style: _createTextStyle(fontSize: 10)),
                  pw.SizedBox(height: 30),
                  pw.Container(width: 100, height: 1, color: PdfColors.black),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =================== METADATA AND CONFIGURATION ===================

  int _getPageCount(AssessmentFormModel assessment, ExportOptions options) {
    int pageCount = 4; // Cover, facility info, facility services, summary

    if (options.includeAnalysis) {
      pageCount += 1; // Analysis page
    }

    if (options.includeSectionDetails) {
      // Calculate pages needed for detailed sections
      int sectionPages = 0;
      for (final section in assessment.sections) {
        if (section.items.isNotEmpty) {
          const itemsPerPage = 2; // Match actual itemsPerPage used
          sectionPages += (section.items.length / itemsPerPage).ceil();
        }
      }
      pageCount += sectionPages;
    }

    return pageCount;
  }
}
