import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/services/excel_import_service.dart';
import 'package:treatment_center/core/services/import_service.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/import_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/import_assessment/import_assessment_event.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/import_assessment/import_assessment_state.dart';

class ImportAssessmentBloc
    extends Bloc<ImportAssessmentEvent, ImportAssessmentState> {
  final ImportAssessmentUsecase importAssessmentUsecase;
  final ImportAssessmentFromExcel importAssessmentFromExcel;
  final GetImportStatistics getImportStatistics;
  final AssessmentRepository assessmentRepository;
  final ExcelImportService excelImportService;

  ImportAssessmentBloc({
    required this.importAssessmentUsecase,
    required this.importAssessmentFromExcel,
    required this.getImportStatistics,
    required this.assessmentRepository,
    required this.excelImportService, // << add parameter
  }) : super(ImportAssessmentInitial()) {
    on<ImportAssessmentFromFileEvent>(_onImportAssessmentFromFile);
    on<ImportAssessmentFromExcelEvent>(_onImportAssessmentFromExcel);
    on<GetImportStatisticsEvent>(_onGetImportStatistics);
    on<ResetImportStateEvent>(_onResetImportState);
    on<ImportAssessmentFromExcelBytes>(_onImportExcelBytes);
  }

  Future<void> _onImportAssessmentFromFile(
    ImportAssessmentFromFileEvent event,
    Emitter<ImportAssessmentState> emit,
  ) async {
    emit(ImportAssessmentLoading());

    final params = ImportAssessmentParams(
      filePath: event.filePath,
      format: event.format,
      options: event.options ?? const ImportOptions(),
      saveAfterImport: event.saveAfterImport,
    );

    final result = await importAssessmentUsecase(params);

    result.fold(
      (failure) => emit(ImportAssessmentError(message: failure.message)),
      (assessment) => emit(
        ImportAssessmentSuccess(
          assessment: assessment,
          message:
              'Assessment imported successfully from ${event.format.toUpperCase()}',
        ),
      ),
    );
  }

  Future<void> _onImportAssessmentFromExcel(
    ImportAssessmentFromExcelEvent event,
    Emitter<ImportAssessmentState> emit,
  ) async {
    emit(ImportAssessmentLoading());

    final params = ImportAssessmentFromExcelParams(
      filePath: event.filePath,
      importSectionDetails: event.importSectionDetails,
      validateAfterImport: event.validateAfterImport,
      saveAfterImport: event.saveAfterImport,
    );

    final result = await importAssessmentFromExcel(params);

    result.fold(
      (failure) => emit(ImportAssessmentError(message: failure.message)),
      (assessment) => emit(
        ImportAssessmentSuccess(
          assessment: assessment,
          message: 'Excel assessment imported successfully',
        ),
      ),
    );
  }

  Future<void> _onGetImportStatistics(
    GetImportStatisticsEvent event,
    Emitter<ImportAssessmentState> emit,
  ) async {
    emit(ImportAssessmentLoading());

    final params = GetImportStatisticsParams.fromFile(
      filePath: event.filePath,
      format: event.format,
    );

    final result = await getImportStatistics(params);

    result.fold(
      (failure) => emit(ImportAssessmentError(message: failure.message)),
      (statistics) => emit(ImportStatisticsLoaded(statistics: statistics)),
    );
  }

  void _onResetImportState(
    ResetImportStateEvent event,
    Emitter<ImportAssessmentState> emit,
  ) {
    emit(ImportAssessmentInitial());
  }

  Future<void> _onImportExcelBytes(
    ImportAssessmentFromExcelBytes event,
    Emitter<ImportAssessmentState> emit,
  ) async {
    emit(ImportAssessmentLoading());

    try {
      final imported = await excelImportService.importFromBytes(
        event.bytes,
        originalName: event.originalName,
      );

      if (event.saveAfterImport) {
        final saved = await assessmentRepository.saveAssessment(
          imported.assessment,
        );
        saved.fold((f) => null, (_) {});
      }

      emit(
        ImportAssessmentSuccess(
          assessment: imported.assessment,
          message: 'Excel assessment imported successfully',
        ),
      );
    } on ImportException catch (e) {
      emit(ImportAssessmentError(message: e.message));
    } catch (e) {
      emit(ImportAssessmentError(message: e.toString()));
    }
  }
}
