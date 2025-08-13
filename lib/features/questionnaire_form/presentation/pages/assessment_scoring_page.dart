import 'package:flutter/material.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/breakpoints.dart';

class AssessmentScoringPage extends StatefulWidget {
  final AssessmentFormEntity? assessmentForm;
  final Function(AssessmentFormEntity) onUpdateForm;

  const AssessmentScoringPage({
    super.key,
    this.assessmentForm,
    required this.onUpdateForm,
  });

  @override
  State<AssessmentScoringPage> createState() => _AssessmentScoringPageState();
}

class _AssessmentScoringPageState extends State<AssessmentScoringPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _sectionAnimationControllers;
  late Animation<double> _headerAnimation;
  late List<Animation<double>> _sectionAnimations;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Create controllers for each section
    final sectionCount =
        widget.assessmentForm?.sections
            .where((section) => section.sectionNumber != "1")
            .length ??
        0;
    _sectionAnimationControllers = List.generate(
      sectionCount,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _sectionAnimations =
        _sectionAnimationControllers
            .map(
              (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: controller, curve: Curves.elasticOut),
              ),
            )
            .toList();

    _startAnimations();
  }

  void _startAnimations() async {
    _animationController.forward();

    // Stagger section animations
    for (int i = 0; i < _sectionAnimationControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted) {
        _sectionAnimationControllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _sectionAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Scoring system: Fully satisfy = 2, Partially = 1, Not satisfy = -1, Don't know = 0, NA = 0
  int _calculateSectionScore(AssessmentSectionEntity section) {
    int score = 0;

    for (final item in section.items) {
      if (item.selectedRating != null) {
        switch (item.selectedRating!.value) {
          case 3: // Meets target
            score += 2;
            break;
          case 2: // Partially meets
            score += 1;
            break;
          case 1: // Does not meet
            score -= 1;
            break;
          case 0: // Don't know
            score += 0;
            break;
          case -1: // Not applicable
            score += 0;
            break;
        }
      }
    }

    return score;
  }

  int _calculateMaxPossibleScore(AssessmentSectionEntity section) {
    // Maximum possible score if all items are "Fully satisfy" (2 points each)
    return section.items.length * 2;
  }

  double _calculateSectionPercentage(AssessmentSectionEntity section) {
    final score = _calculateSectionScore(section);
    final maxScore = _calculateMaxPossibleScore(section);

    if (maxScore == 0) return 0.0;

    // Convert to percentage (0-100%), considering negative scores
    final percentage = ((score + maxScore) / (maxScore * 2)) * 100;
    return percentage.clamp(0.0, 100.0);
  }

  int _calculateTotalScore() {
    if (widget.assessmentForm?.sections.isEmpty ?? true) return 0;

    return widget.assessmentForm!.sections
        .where(
          (section) => section.sectionNumber != "1",
        ) // Filter out section 1
        .map(_calculateSectionScore)
        .fold(0, (sum, score) => sum + score);
  }

  int _calculateTotalMaxScore() {
    if (widget.assessmentForm?.sections.isEmpty ?? true) return 0;

    return widget.assessmentForm!.sections
        .where(
          (section) => section.sectionNumber != "1",
        ) // Filter out section 1
        .map(_calculateMaxPossibleScore)
        .fold(0, (sum, maxScore) => sum + maxScore);
  }

  double _calculateOverallPercentage() {
    final totalScore = _calculateTotalScore();
    final maxScore = _calculateTotalMaxScore();

    if (maxScore == 0) return 0.0;

    final percentage = ((totalScore + maxScore) / (maxScore * 2)) * 100;
    return percentage.clamp(0.0, 100.0);
  }

  String _getScoreGrade(double percentage) {
    if (percentage >= 90) return 'Excellent';
    if (percentage >= 80) return 'Very Good';
    if (percentage >= 70) return 'Good';
    if (percentage >= 60) return 'Fair';
    if (percentage >= 50) return 'Below Average';
    return 'Needs Improvement';
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) return const Color(0xFF2E7D32); // WHO Green
    if (percentage >= 60) return const Color(0xFFFF8F00); // WHO Orange
    return const Color(0xFFD32F2F); // Error Red
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalScore = _calculateTotalScore();
    final maxScore = _calculateTotalMaxScore();
    final overallPercentage = _calculateOverallPercentage();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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
                                        'Assessment Results',
                                        style: theme.textTheme.headlineMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Expanded(
                              child: SingleChildScrollView(
                                key: const PageStorageKey(
                                  'assessment_scoring_scroll',
                                ),
                                physics: const BouncingScrollPhysics(),
                                padding: AdaptiveBreakpoints.getScreenPadding(
                                  screenWidth,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header Section with overall score
                                    AnimatedBuilder(
                                      animation: _headerAnimation,
                                      builder: (context, child) {
                                        return FadeTransition(
                                          opacity: _headerAnimation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0, -0.5),
                                              end: Offset.zero,
                                            ).animate(_headerAnimation),
                                            child: _buildHeaderSection(
                                              theme,
                                              totalScore,
                                              maxScore,
                                              overallPercentage,
                                              isMobile,
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    SizedBox(height: isMobile ? 20 : 24),

                                    // Scoring Information
                                    _buildScoringInfo(theme, isMobile),

                                    SizedBox(height: isMobile ? 20 : 24),

                                    // Section Scores
                                    _buildSectionScores(theme, isMobile),

                                    SizedBox(height: isMobile ? 24 : 40),
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

  Widget _buildHeaderSection(
    ThemeData theme,
    int totalScore,
    int maxScore,
    double percentage,
    bool isMobile,
  ) {
    final scoreColor = _getScoreColor(percentage);
    final grade = _getScoreGrade(percentage);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scoreColor, scoreColor.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: isMobile ? 24 : 32,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assessment Score',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 18 : null,
                        ),
                      ),
                      SizedBox(height: isMobile ? 2 : 4),
                      Text(
                        'Based on your responses across all sections',
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
            SizedBox(height: isMobile ? 16 : 24),

            // Score Display
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '$totalScore / $maxScore',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 28 : 36,
                          ),
                        ),
                        SizedBox(height: isMobile ? 2 : 4),
                        Text(
                          'Total Points',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: isMobile ? 12 : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: isMobile ? 50 : 60,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${percentage.round()}%',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 28 : 36,
                          ),
                        ),
                        SizedBox(height: isMobile ? 2 : 4),
                        Text(
                          grade,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 12 : null,
                          ),
                        ),
                      ],
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

  Widget _buildScoringInfo(ThemeData theme, bool isMobile) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: theme.colorScheme.primary,
                  size: isMobile ? 20 : 24,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Text(
                  'Scoring System',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    fontSize: isMobile ? 16 : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive grid for scoring chips
                final crossAxisCount =
                    constraints.maxWidth < 300
                        ? 1
                        : constraints.maxWidth < 600
                        ? 2
                        : 3;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: isMobile ? 6 : 8,
                  crossAxisSpacing: isMobile ? 6 : 8,
                  childAspectRatio: crossAxisCount == 1 ? 6 : 2.5,
                  children: [
                    _buildScoreInfoChip(
                      theme,
                      'Fully Satisfies (+++)',
                      '+2 points',
                      const Color(0xFF2E7D32), // WHO Green
                      isMobile,
                    ),
                    _buildScoreInfoChip(
                      theme,
                      'Partially Satisfies (++)',
                      '+1 point',
                      const Color(0xFFFF8F00), // WHO Orange
                      isMobile,
                    ),
                    _buildScoreInfoChip(
                      theme,
                      'Does Not Satisfy (+)',
                      '-1 point',
                      const Color(0xFFD32F2F), // Error Red
                      isMobile,
                    ),
                    _buildScoreInfoChip(
                      theme,
                      'Don\'t Know (DK)',
                      '0 points',
                      const Color(0xFF9C27B0),
                      isMobile,
                    ),
                    _buildScoreInfoChip(
                      theme,
                      'Not Applicable (NA)',
                      '0 points',
                      const Color(0xFF607D8B),
                      isMobile,
                    ),
                    _buildScoreInfoChip(
                      theme,
                      'Not Answered',
                      '0 points',
                      theme.colorScheme.onSurfaceVariant,
                      isMobile,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreInfoChip(
    ThemeData theme,
    String label,
    String points,
    Color color,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: isMobile ? 10 : 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            points,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: isMobile ? 9 : 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionScores(ThemeData theme, bool isMobile) {
    if (widget.assessmentForm?.sections.isEmpty ?? true) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.folder_open_outlined,
                  size: isMobile ? 48 : 64,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  'No sections available',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
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
              Icons.format_list_numbered_rounded,
              color: theme.colorScheme.primary,
              size: isMobile ? 20 : 24,
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Text(
              'Section Scores',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                fontSize: isMobile ? 18 : null,
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 12 : 20),
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

              if (index < _sectionAnimations.length) {
                return AnimatedBuilder(
                  animation: _sectionAnimations[index],
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _sectionAnimations[index],
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.3, 0),
                          end: Offset.zero,
                        ).animate(_sectionAnimations[index]),
                        child: _buildSectionScoreCard(theme, section, isMobile),
                      ),
                    );
                  },
                );
              }
              return _buildSectionScoreCard(theme, section, isMobile);
            }),
      ],
    );
  }

  Widget _buildSectionScoreCard(
    ThemeData theme,
    AssessmentSectionEntity section,
    bool isMobile,
  ) {
    final score = _calculateSectionScore(section);
    final maxScore = _calculateMaxPossibleScore(section);
    final percentage = _calculateSectionPercentage(section);
    final scoreColor = _getScoreColor(percentage);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scoreColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          fontSize: isMobile ? 14 : null,
                        ),
                      ),
                      SizedBox(height: isMobile ? 2 : 4),
                      Text(
                        section.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontSize: isMobile ? 14 : null,
                        ),
                        maxLines: isMobile ? 2 : null,
                        overflow:
                            isMobile
                                ? TextOverflow.ellipsis
                                : TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: scoreColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${percentage.round()}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                      fontSize: isMobile ? 14 : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),

            // Progress bar
            Container(
              height: isMobile ? 6 : 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(isMobile ? 3 : 4),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: percentage.round(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            scoreColor,
                            scoreColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(isMobile ? 3 : 4),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 100 - percentage.round(),
                    child: const SizedBox(),
                  ),
                ],
              ),
            ),
            SizedBox(height: isMobile ? 8 : 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score: $score / $maxScore points',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                    fontSize: isMobile ? 12 : null,
                  ),
                ),
                Text(
                  '${section.items.length} items',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: isMobile ? 11 : null,
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
