import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/breakpoints.dart';

class AssessmentDashboardPage extends StatefulWidget {
  final AssessmentFormEntity? assessmentForm;
  final Function(AssessmentFormEntity) onUpdateForm;

  const AssessmentDashboardPage({
    super.key,
    this.assessmentForm,
    required this.onUpdateForm,
  });

  @override
  State<AssessmentDashboardPage> createState() =>
      _AssessmentDashboardPageState();
}

class _AssessmentDashboardPageState extends State<AssessmentDashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Map<String, int> _calculateOverallStatistics() {
    if (widget.assessmentForm == null) {
      return {
        'meetsTarget': 0,
        'partiallyMeets': 0,
        'doesNotMeet': 0,
        'dontKnow': 0,
        'notApplicable': 0,
        'unanswered': 0,
      };
    }

    int meetsTarget = 0;
    int partiallyMeets = 0;
    int doesNotMeet = 0;
    int dontKnow = 0;
    int notApplicable = 0;
    int unanswered = 0;

    for (final section in widget.assessmentForm!.sections.where(
      (section) => section.sectionNumber != "1",
    )) {
      for (final item in section.items) {
        if (item.selectedRating == null) {
          unanswered++;
        } else {
          switch (item.selectedRating!.value) {
            case 3:
              meetsTarget++;
              break;
            case 2:
              partiallyMeets++;
              break;
            case 1:
              doesNotMeet++;
              break;
            case 0:
              dontKnow++;
              break;
            case -1:
              notApplicable++;
              break;
          }
        }
      }
    }

    return {
      'meetsTarget': meetsTarget,
      'partiallyMeets': partiallyMeets,
      'doesNotMeet': doesNotMeet,
      'dontKnow': dontKnow,
      'notApplicable': notApplicable,
      'unanswered': unanswered,
    };
  }

  Map<String, int> _calculateSectionStatistics(
    AssessmentSectionEntity section,
  ) {
    int meetsTarget = 0;
    int partiallyMeets = 0;
    int doesNotMeet = 0;
    int dontKnow = 0;
    int notApplicable = 0;
    int unanswered = 0;

    for (final item in section.items) {
      if (item.selectedRating == null) {
        unanswered++;
      } else {
        switch (item.selectedRating!.value) {
          case 3:
            meetsTarget++;
            break;
          case 2:
            partiallyMeets++;
            break;
          case 1:
            doesNotMeet++;
            break;
          case 0:
            dontKnow++;
            break;
          case -1:
            notApplicable++;
            break;
        }
      }
    }

    return {
      'meetsTarget': meetsTarget,
      'partiallyMeets': partiallyMeets,
      'doesNotMeet': doesNotMeet,
      'dontKnow': dontKnow,
      'notApplicable': notApplicable,
      'unanswered': unanswered,
    };
  }

  List<PieChartSectionData> _getPieChartSections(
    Map<String, int> stats, {
    bool isLarge = true,
    bool isMobile = false,
  }) {
    final total = stats.values.fold<int>(0, (sum, count) => sum + count);
    if (total == 0) return [];

    late final double radius;
    late final double fontSize;

    if (isMobile) {
      radius = isLarge ? 60.0 : 40.0;
      fontSize = isLarge ? 12.0 : 8.0;
    } else {
      radius = isLarge ? 80.0 : 50.0;
      fontSize = isLarge ? 14.0 : 10.0;
    }

    return [
      PieChartSectionData(
        color: const Color(0xFF4CAF50),
        value: stats['meetsTarget']!.toDouble(),
        title: '${((stats['meetsTarget']! / total) * 100).round()}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xFFFF9800),
        value: stats['partiallyMeets']!.toDouble(),
        title: '${((stats['partiallyMeets']! / total) * 100).round()}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xFFF44336),
        value: stats['doesNotMeet']!.toDouble(),
        title: '${((stats['doesNotMeet']! / total) * 100).round()}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xFF9C27B0),
        value: stats['dontKnow']!.toDouble(),
        title: '${((stats['dontKnow']! / total) * 100).round()}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xFF607D8B),
        value: stats['notApplicable']!.toDouble(),
        title: '${((stats['notApplicable']! / total) * 100).round()}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xFFE0E0E0),
        value: stats['unanswered']!.toDouble(),
        title: '${((stats['unanswered']! / total) * 100).round()}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    ].where((section) => section.value > 0).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final contentWidth = AdaptiveBreakpoints.getContentWidth(screenWidth);
          final isMobile = AdaptiveBreakpoints.isMobile(screenWidth);

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
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
                                        'Assessment Dashboard',
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
                                key: const PageStorageKey('dashboard_scroll'),
                                physics: const BouncingScrollPhysics(),
                                padding: AdaptiveBreakpoints.getScreenPadding(
                                  screenWidth,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header Section
                                    _buildHeaderSection(context, isMobile),
                                    SizedBox(height: isMobile ? 40 : 24),

                                    // Overall Statistics
                                    _buildOverallStatisticsCard(
                                      context,
                                      isMobile,
                                    ),
                                    SizedBox(height: isMobile ? 20 : 24),

                                    // Section-wise Statistics
                                    _buildSectionStatistics(context, isMobile),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 10 : 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.analytics_rounded,
                size: isMobile ? 24 : 28,
                color: Colors.white,
              ),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assessment Dashboard',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 18 : null,
                    ),
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    'Statistical overview of your assessment progress',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: isMobile ? 13 : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatisticsCard(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);
    final overallStats = _calculateOverallStatistics();
    final hasData = overallStats.values.any((count) => count > 0);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.donut_large_rounded,
                  color: theme.colorScheme.primary,
                  size: isMobile ? 20 : 24,
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Expanded(
                  child: Text(
                    'Overall Assessment Statistics',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      fontSize: isMobile ? 16 : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 20),

            if (!hasData)
              _buildNoDataWidget(context, isMobile)
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive layout based on screen width
                  if (constraints.maxWidth > 600 && !isMobile) {
                    // Wide layout: Chart and legend side by side
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pie Chart
                        SizedBox(
                          width: isMobile ? 200 : 280,
                          height: isMobile ? 200 : 280,
                          child: PieChart(
                            PieChartData(
                              sections: _getPieChartSections(
                                overallStats,
                                isLarge: true,
                                isMobile: isMobile,
                              ),
                              centerSpaceRadius: isMobile ? 40 : 60,
                              sectionsSpace: 3,
                              pieTouchData: PieTouchData(
                                touchCallback: (
                                  FlTouchEvent event,
                                  pieTouchResponse,
                                ) {
                                  // Add touch feedback if needed
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isMobile ? 32 : 40),
                        // Legend
                        Expanded(
                          child: _buildLegend(context, overallStats, isMobile),
                        ),
                      ],
                    );
                  } else {
                    // Narrow layout: Chart and legend stacked
                    return Column(
                      children: [
                        SizedBox(
                          width: isMobile ? 200 : 250,
                          height: isMobile ? 200 : 250,
                          child: PieChart(
                            PieChartData(
                              sections: _getPieChartSections(
                                overallStats,
                                isLarge: true,
                                isMobile: isMobile,
                              ),
                              centerSpaceRadius: isMobile ? 40 : 50,
                              sectionsSpace: 3,
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 16 : 24),
                        _buildLegend(context, overallStats, isMobile),
                      ],
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: isMobile ? 150 : 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: isMobile ? 48 : 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'No assessment data available',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: isMobile ? 14 : null,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            'Complete assessment sections to see statistics',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: isMobile ? 12 : null,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(
    BuildContext context,
    Map<String, int> stats,
    bool isMobile,
  ) {
    Theme.of(context);

    final items = [
      _LegendItem(
        'Fully Satisfies (+++)',
        const Color(0xFF4CAF50),
        stats['meetsTarget']!,
      ),
      _LegendItem(
        'Partially Satisfies (++)',
        const Color(0xFFFF9800),
        stats['partiallyMeets']!,
      ),
      _LegendItem(
        'Does Not Satisfy (+)',
        const Color(0xFFF44336),
        stats['doesNotMeet']!,
      ),
      _LegendItem(
        'Don\'t Know (DK)',
        const Color(0xFF9C27B0),
        stats['dontKnow']!,
      ),
      _LegendItem(
        'Not Applicable (NA)',
        const Color(0xFF607D8B),
        stats['notApplicable']!,
      ),
      _LegendItem('Unanswered', const Color(0xFFE0E0E0), stats['unanswered']!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          items
              .map((item) => _buildLegendItem(context, item, isMobile))
              .toList(),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    _LegendItem item,
    bool isMobile,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 6 : 8),
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 4 : 6,
        horizontal: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: item.color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 16 : 20,
            height: isMobile ? 16 : 20,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Text(
              item.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: isMobile ? 12 : null,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 6 : 10,
              vertical: isMobile ? 2 : 4,
            ),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.count.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: item.color,
                fontSize: isMobile ? 10 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionStatistics(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);

    if (widget.assessmentForm?.sections.isEmpty ?? true) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          child: Column(
            children: [
              Icon(
                Icons.assignment_outlined,
                size: isMobile ? 40 : 48,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                'No sections available',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: isMobile ? 14 : null,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.bar_chart_rounded,
              color: theme.colorScheme.primary,
              size: isMobile ? 20 : 24,
            ),
            SizedBox(width: isMobile ? 6 : 8),
            Expanded(
              child: Text(
                'Section-wise Analysis',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontSize: isMobile ? 16 : null,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 12 : 16),
        ...widget.assessmentForm!.sections
            .where(
              (section) => section.sectionNumber != "1",
            ) // Filter out section 1
            .toList()
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final section = entry.value;
              final filteredSections =
                  widget.assessmentForm!.sections
                      .where((s) => s.sectionNumber != "1")
                      .toList();
              return Padding(
                padding: EdgeInsets.only(
                  bottom:
                      index < filteredSections.length - 1
                          ? (isMobile ? 12 : 16)
                          : 0,
                ),
                child: _buildSectionCard(context, section, isMobile),
              );
            }),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    AssessmentSectionEntity section,
    bool isMobile,
  ) {
    final theme = Theme.of(context);
    final sectionStats = _calculateSectionStatistics(section);
    final totalItems = section.items.length;
    final completedItems = totalItems - sectionStats['unanswered']!;
    final completionRate =
        totalItems > 0 ? (completedItems / totalItems) * 100 : 0.0;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Section ${section.sectionNumber}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontSize: isMobile ? 13 : null,
                        ),
                      ),
                      SizedBox(height: isMobile ? 2 : 4),
                      Text(
                        section.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontSize: isMobile ? 13 : null,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 12,
                    vertical: isMobile ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getCompletionColor(
                      completionRate,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getCompletionColor(
                        completionRate,
                      ).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${completionRate.round()}% Complete',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getCompletionColor(completionRate),
                      fontSize: isMobile ? 10 : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 24 : 40),

            // Chart and Statistics
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 500 && !isMobile) {
                  // Wide layout: Chart and stats side by side
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Mini pie chart
                      SizedBox(
                        width: 120,
                        height: 120,
                        child:
                            totalItems == 0
                                ? _buildNoItemsWidget(context, isMobile)
                                : PieChart(
                                  PieChartData(
                                    sections: _getPieChartSections(
                                      sectionStats,
                                      isLarge: false,
                                      isMobile: isMobile,
                                    ),
                                    centerSpaceRadius: 30,
                                    sectionsSpace: 2,
                                  ),
                                ),
                      ),
                      const SizedBox(width: 24),
                      // Statistics chips
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildStatChip(
                              context,
                              '+++',
                              sectionStats['meetsTarget']!,
                              const Color(0xFF4CAF50),
                              isMobile,
                            ),
                            _buildStatChip(
                              context,
                              '++',
                              sectionStats['partiallyMeets']!,
                              const Color(0xFFFF9800),
                              isMobile,
                            ),
                            _buildStatChip(
                              context,
                              '+',
                              sectionStats['doesNotMeet']!,
                              const Color(0xFFF44336),
                              isMobile,
                            ),
                            _buildStatChip(
                              context,
                              'DK',
                              sectionStats['dontKnow']!,
                              const Color(0xFF9C27B0),
                              isMobile,
                            ),
                            _buildStatChip(
                              context,
                              'NA',
                              sectionStats['notApplicable']!,
                              const Color(0xFF607D8B),
                              isMobile,
                            ),
                            _buildStatChip(
                              context,
                              '?',
                              sectionStats['unanswered']!,
                              const Color(0xFFE0E0E0),
                              isMobile,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  // Narrow layout: Chart and stats stacked
                  return Column(
                    children: [
                      SizedBox(
                        width: isMobile ? 80 : 100,
                        height: isMobile ? 80 : 100,
                        child:
                            totalItems == 0
                                ? _buildNoItemsWidget(context, isMobile)
                                : PieChart(
                                  PieChartData(
                                    sections: _getPieChartSections(
                                      sectionStats,
                                      isLarge: false,
                                      isMobile: isMobile,
                                    ),
                                    centerSpaceRadius: isMobile ? 20 : 25,
                                    sectionsSpace: 2,
                                  ),
                                ),
                      ),
                      SizedBox(height: isMobile ? 32 : 40),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildStatChip(
                            context,
                            '+++',
                            sectionStats['meetsTarget']!,
                            const Color(0xFF4CAF50),
                            isMobile,
                          ),
                          _buildStatChip(
                            context,
                            '++',
                            sectionStats['partiallyMeets']!,
                            const Color(0xFFFF9800),
                            isMobile,
                          ),
                          _buildStatChip(
                            context,
                            '+',
                            sectionStats['doesNotMeet']!,
                            const Color(0xFFF44336),
                            isMobile,
                          ),
                          _buildStatChip(
                            context,
                            'DK',
                            sectionStats['dontKnow']!,
                            const Color(0xFF9C27B0),
                            isMobile,
                          ),
                          _buildStatChip(
                            context,
                            'NA',
                            sectionStats['notApplicable']!,
                            const Color(0xFF607D8B),
                            isMobile,
                          ),
                          _buildStatChip(
                            context,
                            '?',
                            sectionStats['unanswered']!,
                            const Color(0xFFE0E0E0),
                            isMobile,
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoItemsWidget(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.remove_circle_outline,
              size: isMobile ? 16 : 24,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: isMobile ? 2 : 4),
            Text(
              'No items',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: isMobile ? 8 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCompletionColor(double completionRate) {
    if (completionRate >= 80) return const Color(0xFF4CAF50);
    if (completionRate >= 50) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  Widget _buildStatChip(
    BuildContext context,
    String label,
    int count,
    Color color,
    bool isMobile,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 10,
        vertical: isMobile ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: isMobile ? 10 : null,
            ),
          ),
          SizedBox(width: isMobile ? 4 : 6),
          Text(
            count.toString(),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: isMobile ? 10 : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem {
  final String label;
  final Color color;
  final int count;

  _LegendItem(this.label, this.color, this.count);
}
