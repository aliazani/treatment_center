import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/core/services/export_service.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';

import 'usecase.dart';

class SubmitAssessmentViaFirebaseEmailUsecase
    extends UseCase<bool, FirebaseEmailParams> {
  final AssessmentRepository repository;

  SubmitAssessmentViaFirebaseEmailUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(FirebaseEmailParams params) async {
    return await repository.submitAssessmentViaFirebaseEmail(
      params.assessment,
      params.recipientEmail,
      exportFormats: params.exportFormats,
      subject: params.subject,
      body: params.body,
      photoFilePaths: params.photoFilePaths,
      exportOptions: params.exportOptions,
    );
  }
}

class FirebaseEmailParams extends Equatable {
  final AssessmentFormEntity assessment;
  final String recipientEmail;
  final List<String> exportFormats;
  final String? subject;
  final String? body;
  final List<String> photoFilePaths;
  final ExportOptions? exportOptions;

  const FirebaseEmailParams({
    required this.assessment,
    required this.recipientEmail,
    this.exportFormats = const ['pdf'],
    this.subject,
    this.body,
    this.photoFilePaths = const [],
    this.exportOptions,
  });

  @override
  List<Object?> get props => [
    assessment,
    recipientEmail,
    exportFormats,
    subject,
    body,
    photoFilePaths,
    exportOptions,
  ];
}

// Upload Assessment to Firebase
class UploadAssessmentToFirebase extends UseCase<String, AssessmentFormEntity> {
  final AssessmentRepository repository;

  UploadAssessmentToFirebase(this.repository);

  @override
  Future<Either<Failure, String>> call(AssessmentFormEntity params) async {
    return await repository.uploadAssessmentToFirebase(params);
  }
}
