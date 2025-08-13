import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/compare_assessments/compare_assessments_bloc.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/compare_assessments/compare_assessments_event.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/compare_assessments/compare_assessments_state.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/breakpoints.dart';
import 'package:treatment_center/injection_container.dart' as di;

class CompareAssessmentsPage extends StatelessWidget {
  const CompareAssessmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              di.sl<CompareAssessmentsBloc>()
                ..add(const LoadAssessmentsForComparison()),
      child: const AssessmentComparisonView(),
    );
  }
}

class AssessmentComparisonView extends StatelessWidget {
  const AssessmentComparisonView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar:
          AdaptiveBreakpoints.isDesktop(MediaQuery.sizeOf(context).width)
              ? null
              : AppBar(
                title: const Text('Assessment Comparison'),
                elevation: 0,
                actions: [
                  BlocBuilder<
                    CompareAssessmentsBloc,
                    AssessmentComparisonState
                  >(
                    builder: (context, state) {
                      if (state is AssessmentComparisonLoaded) {
                        return PopupMenuButton<ComparisonFilter>(
                          icon: const Icon(Icons.filter_list),
                          onSelected: (filter) {
                            context.read<CompareAssessmentsBloc>().add(
                              FilterComparisonByType(filter: filter),
                            );
                          },
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: ComparisonFilter.all,
                                  child: Text('Show All'),
                                ),
                                const PopupMenuItem(
                                  value: ComparisonFilter.differences,
                                  child: Text('Differences Only'),
                                ),
                                const PopupMenuItem(
                                  value: ComparisonFilter.improved,
                                  child: Text('Improvements'),
                                ),
                                const PopupMenuItem(
                                  value: ComparisonFilter.declined,
                                  child: Text('Declined'),
                                ),
                              ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final contentWidth = AdaptiveBreakpoints.getContentWidth(screenWidth);
          final isMobile = AdaptiveBreakpoints.isMobile(screenWidth);

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: BlocBuilder<
                  CompareAssessmentsBloc,
                  AssessmentComparisonState
                >(
                  builder: (context, state) {
                    return Column(
                      children: [
                        if (AdaptiveBreakpoints.isDesktop(screenWidth))
                          Padding(
                            padding: const EdgeInsets.only(top: 24, bottom: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Assessment Comparison',
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.headlineMedium,
                                  ),
                                ),
                                if (state is AssessmentComparisonLoaded) ...[
                                  PopupMenuButton<ComparisonFilter>(
                                    icon: const Icon(Icons.filter_list),
                                    onSelected: (filter) {
                                      context
                                          .read<CompareAssessmentsBloc>()
                                          .add(
                                            FilterComparisonByType(
                                              filter: filter,
                                            ),
                                          );
                                    },
                                    itemBuilder:
                                        (context) => [
                                          const PopupMenuItem(
                                            value: ComparisonFilter.all,
                                            child: Text('Show All'),
                                          ),
                                          const PopupMenuItem(
                                            value: ComparisonFilter.differences,
                                            child: Text('Differences Only'),
                                          ),
                                          const PopupMenuItem(
                                            value: ComparisonFilter.improved,
                                            child: Text('Improvements'),
                                          ),
                                          const PopupMenuItem(
                                            value: ComparisonFilter.declined,
                                            child: Text('Declined'),
                                          ),
                                        ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        Expanded(
                          child: _buildContent(
                            context,
                            state,
                            isMobile,
                            screenWidth,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton:
          BlocBuilder<CompareAssessmentsBloc, AssessmentComparisonState>(
            builder: (context, state) {
              if (state is AssessmentComparisonLoaded) {
                return FloatingActionButton(
                  onPressed: () {
                    context.read<CompareAssessmentsBloc>().add(
                      const ResetComparison(),
                    );
                  },
                  child: const Icon(Icons.refresh),
                );
              }
              return const SizedBox.shrink();
            },
          ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AssessmentComparisonState state,
    bool isMobile,
    double screenWidth,
  ) {
    if (state is AssessmentComparisonLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AssessmentComparisonError) {
      return SingleChildScrollView(
        child: _ErrorView(message: state.message, isMobile: isMobile),
      );
    }

    if (state is AssessmentSelectionLoaded) {
      return _AssessmentSelectionView(
        state: state,
        isMobile: isMobile,
        screenWidth: screenWidth,
      );
    }

    if (state is AssessmentComparisonLoaded) {
      return _ComparisonResultsView(
        state: state,
        isMobile: isMobile,
        screenWidth: screenWidth,
      );
    }

    return Center(
      child: Text(
        'Unknown state',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final bool isMobile;

  const _ErrorView({required this.message, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: AdaptiveBreakpoints.getScreenPadding(
        MediaQuery.of(context).size.width,
      ),
      child: Center(
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 24 : 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: isMobile ? 48 : 64,
                  color: theme.colorScheme.error,
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  'Error loading assessments',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: isMobile ? 18 : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 20 : 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<CompareAssessmentsBloc>().add(
                      const LoadAssessmentsForComparison(),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssessmentSelectionView extends StatelessWidget {
  final AssessmentSelectionLoaded state;
  final bool isMobile;
  final double screenWidth;

  const _AssessmentSelectionView({
    required this.state,
    required this.isMobile,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey('assessment_selection_scroll'),
      padding: AdaptiveBreakpoints.getScreenPadding(screenWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectionHeader(context),
          SizedBox(height: isMobile ? 24 : 32),
          _buildAssessmentSelector(
            context,
            'First Assessment',
            state.firstSelectedAssessment,
            true,
          ),
          SizedBox(height: isMobile ? 16 : 24),
          _buildAssessmentSelector(
            context,
            'Second Assessment',
            state.secondSelectedAssessment,
            false,
          ),
          SizedBox(height: isMobile ? 24 : 32),
          _buildCompareButton(context),
        ],
      ),
    );
  }

  Widget _buildSelectionHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        child: Column(
          children: [
            Icon(
              Icons.compare_arrows,
              size: isMobile ? 40 : 48,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              'Compare Assessments',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                fontSize: isMobile ? 18 : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Select two assessments to compare their results side by side',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentSelector(
    BuildContext context,
    String title,
    AssessmentFormEntity? selectedAssessment,
    bool isFirst,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: selectedAssessment != null ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              selectedAssessment != null
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: selectedAssessment != null ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  isFirst ? Icons.looks_one : Icons.looks_two,
                  color: theme.colorScheme.primary,
                  size: isMobile ? 20 : 24,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ],
            ),
          ),
          if (selectedAssessment != null) ...[
            const Divider(height: 1),
            _buildSelectedAssessmentInfo(selectedAssessment, theme),
          ],
          const Divider(height: 1),
          _buildAssessmentDropdown(context, selectedAssessment, isFirst, theme),
        ],
      ),
    );
  }

  Widget _buildSelectedAssessmentInfo(
    AssessmentFormEntity assessment,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            assessment.facilityIdentification.facilityName,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 13 : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Assessed by: ${assessment.assessorInfo.name}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: isMobile ? 11 : null,
            ),
          ),
          Text(
            'Date: ${assessment.assessorInfo.assessmentDate != null ? DateFormat('MMM dd, yyyy').format(assessment.assessorInfo.assessmentDate!) : 'No date'}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: isMobile ? 11 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentDropdown(
    BuildContext context,
    AssessmentFormEntity? selectedAssessment,
    bool isFirst,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Select Assessment',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
        value: selectedAssessment?.id,
        isExpanded: true,
        items:
            state.availableAssessments
                .where((assessment) {
                  if (isFirst) {
                    return assessment.id != state.secondSelectedAssessment?.id;
                  } else {
                    return assessment.id != state.firstSelectedAssessment?.id;
                  }
                })
                .map(
                  (assessment) => DropdownMenuItem<String>(
                    value: assessment.id,
                    child: Text(
                      '${assessment.facilityIdentification.facilityName} - ${assessment.assessorInfo.assessmentDate != null ? DateFormat('MMM dd, yyyy').format(assessment.assessorInfo.assessmentDate!) : 'No date'}',
                      style: TextStyle(fontSize: isMobile ? 12 : 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
        onChanged: (String? assessmentId) {
          if (assessmentId != null) {
            if (isFirst) {
              context.read<CompareAssessmentsBloc>().add(
                SelectFirstAssessment(assessmentId: assessmentId),
              );
            } else {
              context.read<CompareAssessmentsBloc>().add(
                SelectSecondAssessment(assessmentId: assessmentId),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildCompareButton(BuildContext context) {
    final canCompare = state.canCompare;

    return SizedBox(
      width: double.infinity,
      height: isMobile ? 48 : 56,
      child: ElevatedButton.icon(
        onPressed:
            canCompare
                ? () {
                  context.read<CompareAssessmentsBloc>().add(
                    const CompareAssessments(),
                  );
                }
                : null,
        icon: const Icon(Icons.compare),
        label: Text(
          'COMPARE ASSESSMENTS',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _ComparisonResultsView extends StatelessWidget {
  final AssessmentComparisonLoaded state;
  final bool isMobile;
  final double screenWidth;

  const _ComparisonResultsView({
    required this.state,
    required this.isMobile,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey('comparison_results_scroll'),
      padding: AdaptiveBreakpoints.getScreenPadding(screenWidth),
      child: Column(
        children: [
          _ComparisonHeader(state: state, isMobile: isMobile),
          SizedBox(height: isMobile ? 16 : 24),
          _ComparisonStatistics(
            statistics: state.comparisonResult.statistics,
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 16 : 24),
          _ComparisonSections(state: state, isMobile: isMobile),
        ],
      ),
    );
  }
}

class _ComparisonHeader extends StatelessWidget {
  final AssessmentComparisonLoaded state;
  final bool isMobile;

  const _ComparisonHeader({required this.state, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overview = state.comparisonResult.overviewComparison;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child:
            isMobile
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _AssessmentSummary(
                      title: 'First Assessment',
                      facilityName: overview.firstFacilityName,
                      assessorName: overview.firstAssessorName,
                      date: overview.firstAssessmentDate,
                      color: theme.colorScheme.primary,
                      isMobile: isMobile,
                    ),
                    const SizedBox(height: 8),
                    Tooltip(
                      message: 'Switch comparison order',
                      child: InkWell(
                        onTap: () {
                          context.read<CompareAssessmentsBloc>().add(
                            const SwitchComparisonOrder(),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.compare_arrows,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _AssessmentSummary(
                      title: 'Second Assessment',
                      facilityName: overview.secondFacilityName,
                      assessorName: overview.secondAssessorName,
                      date: overview.secondAssessmentDate,
                      color: theme.colorScheme.secondary,
                      isMobile: isMobile,
                    ),
                  ],
                )
                : Row(
                  children: [
                    Expanded(
                      child: _AssessmentSummary(
                        title: 'First Assessment',
                        facilityName: overview.firstFacilityName,
                        assessorName: overview.firstAssessorName,
                        date: overview.firstAssessmentDate,
                        color: theme.colorScheme.primary,
                        isMobile: isMobile,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Tooltip(
                        message: 'Switch comparison order',
                        child: InkWell(
                          onTap: () {
                            context.read<CompareAssessmentsBloc>().add(
                              const SwitchComparisonOrder(),
                            );
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Icon(
                              Icons.compare_arrows,
                              color: theme.colorScheme.primary,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _AssessmentSummary(
                        title: 'Second Assessment',
                        facilityName: overview.secondFacilityName,
                        assessorName: overview.secondAssessorName,
                        date: overview.secondAssessmentDate,
                        color: theme.colorScheme.secondary,
                        isMobile: isMobile,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

class _AssessmentSummary extends StatelessWidget {
  final String title;
  final String facilityName;
  final String assessorName;
  final DateTime date;
  final Color color;
  final bool isMobile;

  const _AssessmentSummary({
    required this.title,
    required this.facilityName,
    required this.assessorName,
    required this.date,
    required this.color,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 11 : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            facilityName,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 12 : null,
            ),
            maxLines: isMobile ? 1 : null,
            overflow: isMobile ? TextOverflow.ellipsis : null,
          ),
          Text(
            'By: $assessorName',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: isMobile ? 10 : null,
            ),
            maxLines: isMobile ? 1 : null,
            overflow: isMobile ? TextOverflow.ellipsis : null,
          ),
          Text(
            DateFormat('MMM dd, yyyy').format(date),
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: isMobile ? 10 : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonStatistics extends StatelessWidget {
  final ComparisonStatistics statistics;
  final bool isMobile;

  const _ComparisonStatistics({
    required this.statistics,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparison Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 14 : null,
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            isMobile
                ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.assessment,
                            label: 'Total Items',
                            value: statistics.totalItems.toString(),
                            color: theme.colorScheme.primary,
                            isMobile: isMobile,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.trending_up,
                            label: 'Improved',
                            value: statistics.improvedItems.toString(),
                            color: Colors.green,
                            isMobile: isMobile,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.trending_down,
                            label: 'Declined',
                            value: statistics.declinedItems.toString(),
                            color: Colors.red,
                            isMobile: isMobile,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.percent,
                            label: 'Improvement',
                            value:
                                '${statistics.improvementPercentage.toStringAsFixed(1)}%',
                            color: theme.colorScheme.secondary,
                            isMobile: isMobile,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
                : Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.assessment,
                        label: 'Total Items',
                        value: statistics.totalItems.toString(),
                        color: theme.colorScheme.primary,
                        isMobile: isMobile,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.trending_up,
                        label: 'Improved',
                        value: statistics.improvedItems.toString(),
                        color: Colors.green,
                        isMobile: isMobile,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.trending_down,
                        label: 'Declined',
                        value: statistics.declinedItems.toString(),
                        color: Colors.red,
                        isMobile: isMobile,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.percent,
                        label: 'Improvement',
                        value:
                            '${statistics.improvementPercentage.toStringAsFixed(1)}%',
                        color: theme.colorScheme.secondary,
                        isMobile: isMobile,
                      ),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isMobile;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isMobile ? 16 : 20),
          SizedBox(height: isMobile ? 2 : 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: isMobile ? 12 : null,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: isMobile ? 9 : null,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ComparisonSections extends StatelessWidget {
  final AssessmentComparisonLoaded state;
  final bool isMobile;

  const _ComparisonSections({required this.state, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final filteredSections = _getFilteredSections();

    return Column(
      children: [
        // Filter status card
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: isMobile ? 16 : 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Filter: ${_getFilterName()} | Showing ${filteredSections.length}/${state.comparisonResult.sectionComparisons.length} sections',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: isMobile ? 10 : 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: isMobile ? 8 : 16),
        ...filteredSections.map((section) {
          return _ComparisonSectionCard(
            section: section,
            isExpanded: state.expandedSections.contains(section.sectionId),
            onToggle: () {
              context.read<CompareAssessmentsBloc>().add(
                ToggleComparisonSection(sectionId: section.sectionId),
              );
            },
            filter: state.currentFilter,
            isMobile: isMobile,
          );
        }),
      ],
    );
  }

  String _getFilterName() {
    switch (state.currentFilter) {
      case ComparisonFilter.all:
        return 'Show All';
      case ComparisonFilter.differences:
        return 'Differences Only';
      case ComparisonFilter.similarities:
        return 'Similarities';
      case ComparisonFilter.improved:
        return 'Improvements';
      case ComparisonFilter.declined:
        return 'Declined';
    }
  }

  List<SectionComparison> _getFilteredSections() {
    final sections = state.comparisonResult.sectionComparisons;

    switch (state.currentFilter) {
      case ComparisonFilter.differences:
        return sections.where((s) => s.hasChanges).toList();
      case ComparisonFilter.similarities:
        return sections.where((s) => !s.hasChanges).toList();
      case ComparisonFilter.improved:
        return sections
            .where(
              (s) => s.itemComparisons.any(
                (i) => i.type == ComparisonType.improved,
              ),
            )
            .toList();
      case ComparisonFilter.declined:
        return sections
            .where(
              (s) => s.itemComparisons.any(
                (i) => i.type == ComparisonType.declined,
              ),
            )
            .toList();
      case ComparisonFilter.all:
        return sections;
    }
  }
}

class _ComparisonSectionCard extends StatelessWidget {
  final SectionComparison section;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ComparisonFilter filter;
  final bool isMobile;

  const _ComparisonSectionCard({
    required this.section,
    required this.isExpanded,
    required this.onToggle,
    required this.filter,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      elevation: section.hasChanges ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              section.hasChanges
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Row(
                children: [
                  if (section.hasChanges) ...[
                    Container(
                      width: 4,
                      height: isMobile ? 20 : 24,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                  ],
                  Expanded(
                    child: Text(
                      section.sectionTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            section.hasChanges
                                ? theme.colorScheme.primary
                                : null,
                        fontSize: isMobile ? 13 : null,
                      ),
                    ),
                  ),
                  if (section.hasChanges) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 6 : 8,
                        vertical: isMobile ? 2 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_getChangedItemsCount()} changes',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: isMobile ? 9 : null,
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 4 : 8),
                  ],
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: isMobile ? 20 : 24,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            _buildItemComparisons(context),
          ],
        ],
      ),
    );
  }

  int _getChangedItemsCount() {
    return section.itemComparisons
        .where((item) => item.type != ComparisonType.unchanged)
        .length;
  }

  Widget _buildItemComparisons(BuildContext context) {
    final filteredItems = _getFilteredItems();

    if (filteredItems.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Text(
          'No items match the current filter',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: isMobile ? 12 : null,
          ),
        ),
      );
    }

    return Column(
      children:
          filteredItems.map((item) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: _ItemComparisonRow(item: item, isMobile: isMobile),
              ),
            );
          }).toList(),
    );
  }

  List<ItemComparison> _getFilteredItems() {
    switch (filter) {
      case ComparisonFilter.differences:
        return section.itemComparisons
            .where((i) => i.type != ComparisonType.unchanged)
            .toList();
      case ComparisonFilter.similarities:
        return section.itemComparisons
            .where((i) => i.type == ComparisonType.unchanged)
            .toList();
      case ComparisonFilter.improved:
        return section.itemComparisons
            .where((i) => i.type == ComparisonType.improved)
            .toList();
      case ComparisonFilter.declined:
        return section.itemComparisons
            .where((i) => i.type == ComparisonType.declined)
            .toList();
      case ComparisonFilter.all:
        return section.itemComparisons;
    }
  }
}

class _ItemComparisonRow extends StatelessWidget {
  final ItemComparison item;
  final bool isMobile;

  const _ItemComparisonRow({required this.item, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.all(isMobile ? 8 : 12),
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(theme),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getBorderColor(theme), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.area,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 12 : null,
                  ),
                ),
              ),
              _ComparisonTypeChip(type: item.type, isMobile: isMobile),
            ],
          ),
          SizedBox(height: isMobile ? 6 : 8),
          isMobile
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: _ValueDisplay(
                      label: 'First Assessment',
                      value: item.firstValue,
                      color: theme.colorScheme.primary,
                      isMobile: isMobile,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: _ValueDisplay(
                      label: 'Second Assessment',
                      value: item.secondValue,
                      color: theme.colorScheme.secondary,
                      isMobile: isMobile,
                    ),
                  ),
                ],
              )
              : Row(
                children: [
                  Expanded(
                    child: _ValueDisplay(
                      label: 'First Assessment',
                      value: item.firstValue,
                      color: theme.colorScheme.primary,
                      isMobile: isMobile,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ValueDisplay(
                      label: 'Second Assessment',
                      value: item.secondValue,
                      color: theme.colorScheme.secondary,
                      isMobile: isMobile,
                    ),
                  ),
                ],
              ),
          if (item.description != null) ...[
            SizedBox(height: isMobile ? 6 : 8),
            Text(
              item.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
                fontSize: isMobile ? 10 : null,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor(ThemeData theme) {
    switch (item.type) {
      case ComparisonType.improved:
        return Colors.green.withValues(alpha: 0.05);
      case ComparisonType.declined:
        return Colors.red.withValues(alpha: 0.05);
      case ComparisonType.different:
        return Colors.orange.withValues(alpha: 0.05);
      case ComparisonType.unchanged:
        return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
      case ComparisonType.firstOnly:
      case ComparisonType.secondOnly:
        return Colors.blue.withValues(alpha: 0.05);
    }
  }

  Color _getBorderColor(ThemeData theme) {
    switch (item.type) {
      case ComparisonType.improved:
        return Colors.green.withValues(alpha: 0.3);
      case ComparisonType.declined:
        return Colors.red.withValues(alpha: 0.3);
      case ComparisonType.different:
        return Colors.orange.withValues(alpha: 0.3);
      case ComparisonType.unchanged:
        return theme.colorScheme.outline.withValues(alpha: 0.2);
      case ComparisonType.firstOnly:
      case ComparisonType.secondOnly:
        return Colors.blue.withValues(alpha: 0.3);
    }
  }
}

class _ComparisonTypeChip extends StatelessWidget {
  final ComparisonType type;
  final bool isMobile;

  const _ComparisonTypeChip({required this.type, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 8,
        vertical: isMobile ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _getChipColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getChipColor().withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getChipIcon(),
            size: isMobile ? 10 : 14,
            color: _getChipColor(),
          ),
          SizedBox(width: isMobile ? 2 : 4),
          Text(
            _getChipLabel(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getChipColor(),
              fontWeight: FontWeight.w500,
              fontSize: isMobile ? 8 : null,
            ),
          ),
        ],
      ),
    );
  }

  Color _getChipColor() {
    switch (type) {
      case ComparisonType.improved:
        return Colors.green;
      case ComparisonType.declined:
        return Colors.red;
      case ComparisonType.different:
        return Colors.orange;
      case ComparisonType.unchanged:
        return Colors.grey;
      case ComparisonType.firstOnly:
      case ComparisonType.secondOnly:
        return Colors.blue;
    }
  }

  IconData _getChipIcon() {
    switch (type) {
      case ComparisonType.improved:
        return Icons.trending_up;
      case ComparisonType.declined:
        return Icons.trending_down;
      case ComparisonType.different:
        return Icons.change_circle;
      case ComparisonType.unchanged:
        return Icons.check_circle_outline;
      case ComparisonType.firstOnly:
        return Icons.looks_one;
      case ComparisonType.secondOnly:
        return Icons.looks_two;
    }
  }

  String _getChipLabel() {
    switch (type) {
      case ComparisonType.improved:
        return 'Improved';
      case ComparisonType.declined:
        return 'Declined';
      case ComparisonType.different:
        return 'Changed';
      case ComparisonType.unchanged:
        return 'Same';
      case ComparisonType.firstOnly:
        return 'First Only';
      case ComparisonType.secondOnly:
        return 'Second Only';
    }
  }
}

class _ValueDisplay extends StatelessWidget {
  final String label;
  final String? value;
  final Color color;
  final bool isMobile;

  const _ValueDisplay({
    required this.label,
    this.value,
    required this.color,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: isMobile ? double.infinity : null,
      padding: EdgeInsets.all(isMobile ? 6 : 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: isMobile ? 9 : null,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value ?? 'No rating',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: isMobile ? 11 : null,
            ),
          ),
        ],
      ),
    );
  }
}
