import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/import_assessment/import_assessment_bloc.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/import_assessment/import_assessment_event.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/import_assessment/import_assessment_state.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/breakpoints.dart';
import 'package:treatment_center/injection_container.dart';

class ImportAssessmentPage extends StatelessWidget {
  const ImportAssessmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ImportAssessmentBloc>(),
      child: const ImportAssessmentView(),
    );
  }
}

class ImportAssessmentView extends StatefulWidget {
  const ImportAssessmentView({super.key});

  @override
  State<ImportAssessmentView> createState() => _ImportAssessmentViewState();
}

class _ImportAssessmentViewState extends State<ImportAssessmentView> {
  String? _selectedFilePath;
  String _selectedFormat = 'xlsx';
  // ImportValidationSuccess? _lastValidationResult;
  Uint8List? _selectedBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar:
          AdaptiveBreakpoints.isDesktop(MediaQuery.sizeOf(context).width)
              ? null
              : AppBar(title: const Text('Import Assessment'), elevation: 0),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final contentWidth = AdaptiveBreakpoints.getContentWidth(screenWidth);
          final isMobile = AdaptiveBreakpoints.isMobile(screenWidth);

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child:
                    BlocListener<ImportAssessmentBloc, ImportAssessmentState>(
                      listener: _handleBlocState,
                      child: Column(
                        children: [
                          if (AdaptiveBreakpoints.isDesktop(screenWidth))
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 24,
                                bottom: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Import Assessment',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.headlineMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: SingleChildScrollView(
                              key: const PageStorageKey('import_scroll'),
                              padding: AdaptiveBreakpoints.getScreenPadding(
                                screenWidth,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildWelcomeHeader(context, isMobile),
                                  SizedBox(height: isMobile ? 20 : 24),
                                  _buildFormatSelection(context, isMobile),
                                  SizedBox(height: isMobile ? 16 : 20),
                                  _buildFileSelection(context, isMobile),
                                  SizedBox(height: isMobile ? 24 : 32),
                                  _buildImportButton(context, isMobile),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        child: Column(
          children: [
            Icon(
              Icons.file_upload,
              size: isMobile ? 40 : 48,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              'Import Assessment',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                fontSize: isMobile ? 18 : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Import assessment data from Excel files to continue working on existing assessments',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: isMobile ? 13 : null,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatSelection(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: theme.colorScheme.primary,
                  size: isMobile ? 20 : 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Select Import Format',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            DropdownButtonFormField<String>(
              value: _selectedFormat,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                labelText: 'Format',
                prefixIcon: Icon(Icons.description, size: isMobile ? 20 : 24),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: isMobile ? 12 : 16,
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: 'xlsx',
                  child: Text(
                    'Microsoft Excel (.xlsx)',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFormat = value!;
                  // _lastValidationResult = null;
                });
              },
              style: TextStyle(fontSize: isMobile ? 14 : 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelection(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);

    return Card(
      elevation: _selectedFilePath != null ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              _selectedFilePath != null
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: _selectedFilePath != null ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.file_present,
                  color: theme.colorScheme.primary,
                  size: isMobile ? 20 : 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Select File',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            if (_selectedFilePath != null) ...[
              _buildSelectedFileInfo(context, isMobile),
              SizedBox(height: isMobile ? 12 : 16),
            ],
            _buildFileActionButtons(context, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFileInfo(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected File:',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              fontSize: isMobile ? 11 : null,
            ),
          ),
          SizedBox(height: isMobile ? 4 : 8),
          Row(
            children: [
              Icon(
                Icons.insert_drive_file,
                size: isMobile ? 16 : 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedFilePath!.split('/').last,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 12 : null,
                  ),
                ),
              ),
            ],
          ),
          if (!isMobile) ...[
            const SizedBox(height: 4),
            Text(
              'Path: $_selectedFilePath',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileActionButtons(BuildContext context, bool isMobile) {
    return BlocBuilder<ImportAssessmentBloc, ImportAssessmentState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: isMobile ? 48 : 56,
          child: ElevatedButton.icon(
            onPressed: _pickFile,
            icon: Icon(
              Icons.file_upload,
              size: isMobile ? 20 : 24,
              color: Colors.white,
            ),
            label: Text(
              _selectedFilePath == null ? 'Choose File' : 'Change File',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImportButton(BuildContext context, bool isMobile) {
    return BlocBuilder<ImportAssessmentBloc, ImportAssessmentState>(
      builder: (context, state) {
        final isLoading = state is ImportAssessmentLoading;

        return SizedBox(
          width: double.infinity,
          height: isMobile ? 52 : 60,
          child: ElevatedButton.icon(
            onPressed: _importAssessment,
            icon:
                isLoading
                    ? SizedBox(
                      width: isMobile ? 18 : 20,
                      height: isMobile ? 18 : 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                          // canImport ? Colors.white : Colors.grey,
                        ),
                      ),
                    )
                    : Icon(Icons.download, size: isMobile ? 20 : 24),
            label: Text(
              isLoading ? 'Importing...' : 'IMPORT ASSESSMENT',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              // canImport
              // ? Theme.of(context).colorScheme.primary
              // : Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleBlocState(BuildContext context, ImportAssessmentState state) {
    if (state is ImportAssessmentSuccess) {
      _showSuccessSnackBar(context, state.message);
      Navigator.of(context).pop(state.assessment);
    } else if (state is ImportAssessmentError) {
      _showErrorSnackBar(context, state.message);
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            if (_selectedFilePath != null || _selectedBytes != null) {
              _importAssessment();
            }
          },
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _selectedFormat == 'xlsx' ? ['xlsx', 'xls'] : [],
      allowMultiple: false,
      withData: true,
    );

    if (!mounted) return;

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _selectedBytes = result.files.single.bytes;
      });

      // Automatically get file statistics
      if (_selectedFilePath != null) {
        context.read<ImportAssessmentBloc>().add(
          GetImportStatisticsEvent(
            filePath: _selectedFilePath!,
            format: _selectedFormat,
          ),
        );
      }
    }
  }

  void _importAssessment() {
    if (_selectedFilePath == null && _selectedBytes == null) return;

    _performImport();
  }

  void _performImport() {
    if (kIsWeb) {
      context.read<ImportAssessmentBloc>().add(
        ImportAssessmentFromExcelBytes(
          bytes: _selectedBytes!,
          originalName: _selectedFilePath?.split('/').last ?? 'import.xlsx',
          saveAfterImport: true,
        ),
      );
      return;
    }

    if (_selectedFormat == 'excel') {
      context.read<ImportAssessmentBloc>().add(
        ImportAssessmentFromExcelEvent(
          filePath: _selectedFilePath!,
          importSectionDetails: true,
          validateAfterImport: true,
          saveAfterImport: true,
        ),
      );
    } else {
      context.read<ImportAssessmentBloc>().add(
        ImportAssessmentFromFileEvent(
          filePath: _selectedFilePath!,
          format: _selectedFormat,
          saveAfterImport: true,
        ),
      );
    }
  }
}
