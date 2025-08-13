import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/assessment_list/assessment_list_event.dart';

void main() {
  group('AssessmentEvent Equatable & props', () {
    test('LoadAssessments should be equal and have no props', () {
      final a = const LoadAssessments();
      final b = const LoadAssessments();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.props, isEmpty);
    });

    test('CreateAssessment should be equal and have no props', () {
      final a = const CreateAssessment();
      final b = const CreateAssessment();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.props, isEmpty);
    });

    test('DeleteAssessmentEvent equality, hashCode and props', () {
      const id1 = 'abc';
      const id2 = 'def';

      final a = const DeleteAssessmentEvent(assessmentId: id1);
      final b = const DeleteAssessmentEvent(assessmentId: id1);
      final c = const DeleteAssessmentEvent(assessmentId: id2);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));

      expect(a.props, equals([id1]));
      expect(c.props, equals([id2]));
    });

    test('FilterAssessments equality, hashCode and props', () {
      final f1 = const FilterAssessments(filter: AssessmentFilter.draft);
      final f2 = const FilterAssessments(filter: AssessmentFilter.draft);
      final f3 = const FilterAssessments(filter: AssessmentFilter.submitted);

      expect(f1, equals(f2));
      expect(f1.hashCode, equals(f2.hashCode));
      expect(f1, isNot(equals(f3)));

      expect(f1.props, equals([AssessmentFilter.draft]));
    });

    test('SearchAssessments equality, hashCode and props', () {
      const q1 = 'foo';
      const q2 = 'bar';

      final s1 = const SearchAssessments(query: q1);
      final s2 = const SearchAssessments(query: q1);
      final s3 = const SearchAssessments(query: q2);

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1, isNot(equals(s3)));

      expect(s1.props, equals([q1]));
    });

    test('UpdateAssessment equality, hashCode and props', () {
      const id = 'xyz';
      final data1 = {'a': 1, 'b': true};
      final data2 = {'a': 2};

      final u1 = UpdateAssessment(assessmentId: id, data: data1);
      final u2 = UpdateAssessment(assessmentId: id, data: data1);
      final u3 = UpdateAssessment(assessmentId: id, data: data2);

      expect(u1, equals(u2));
      expect(u1.hashCode, equals(u2.hashCode));
      expect(u1, isNot(equals(u3)));

      expect(u1.props, equals([id, data1]));
    });
  });
}
