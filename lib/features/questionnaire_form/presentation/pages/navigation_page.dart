import 'package:flutter/material.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/breakpoints.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/pages/home_page.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/pages/assessment_list_page.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/pages/settings_page.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/pages/tools_page.dart';

class MainNavigationPage extends StatefulWidget {
  /// Expose the theme‐change callback
  final void Function(ThemeMode themeMode) onThemeChanged;

  const MainNavigationPage({super.key, required this.onThemeChanged});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final PageStorageBucket _bucket = PageStorageBucket();

  List<NavigationItem> get _navigationItems => [
    NavigationItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      page: const HomePage(),
    ),
    NavigationItem(
      label: 'Saved',
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder,
      page: const AssessmentListPage(),
    ),
    NavigationItem(
      label: 'Tools',
      icon: Icons.medical_services_outlined,
      activeIcon: Icons.medical_services,
      page: const ToolsPage(),
    ),
    NavigationItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      page: SettingsPage(onThemeChanged: widget.onThemeChanged),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        if (AdaptiveBreakpoints.isDesktop(screenWidth)) {
          return _buildDesktopLayout();
        } else if (AdaptiveBreakpoints.isTablet(screenWidth)) {
          return _buildTabletLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  // Desktop layout with side navigation
  Widget _buildDesktopLayout() {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Row(
        children: [
          // Side navigation rail
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: _DesktopSideNavigation(
              items: _navigationItems,
              selectedIndex: _selectedIndex,
              onItemSelected: (index) => setState(() => _selectedIndex = index),
            ),
          ),
          // Main content
          Expanded(
            child: PageStorage(
              bucket: _bucket,
              child: _navigationItems[_selectedIndex].page,
            ),
          ),
        ],
      ),
    );
  }

  // Tablet layout with compact navigation
  Widget _buildTabletLayout() {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: PageStorage(
        bucket: _bucket,
        child: _navigationItems[_selectedIndex].page,
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // Mobile layout with bottom navigation
  Widget _buildMobileLayout() {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: PageStorage(
        bucket: _bucket,
        child: _navigationItems[_selectedIndex].page,
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: theme.colorScheme.primary,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedItemColor: theme.colorScheme.onSurfaceVariant,
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items:
              _navigationItems
                  .map(
                    (item) => BottomNavigationBarItem(
                      icon: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Icon(item.icon, size: 24),
                      ),
                      activeIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Icon(item.activeIcon, size: 24),
                      ),
                      label: item.label,
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}

// Navigation item data class
class NavigationItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget page;

  NavigationItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.page,
  });
}

// Desktop side navigation
class _DesktopSideNavigation extends StatelessWidget {
  final List<NavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const _DesktopSideNavigation({
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // WHO Header Card
        Card(
          margin: const EdgeInsets.all(16),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const _CompactWHOHeader(),
          ),
        ),

        const SizedBox(height: 8),

        // Navigation items
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 12),
                  child: Text(
                    'Navigation',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = index == selectedIndex;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Card(
                          elevation: isSelected ? 2 : 0,
                          color:
                              isSelected
                                  ? theme.colorScheme.primaryContainer
                                  : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color:
                                  isSelected
                                      ? theme.colorScheme.primary.withValues(
                                        alpha: 0.3,
                                      )
                                      : Colors.transparent,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? theme.colorScheme.primary.withValues(
                                          alpha: 0.1,
                                        )
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isSelected ? item.activeIcon : item.icon,
                                size: 20,
                                color:
                                    isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            title: Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                color:
                                    isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                              ),
                            ),
                            onTap: () => onItemSelected(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Version info card
        Card(
          margin: const EdgeInsets.all(16),
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Version 1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Compact WHO header for desktop sidebar
class _CompactWHOHeader extends StatelessWidget {
  const _CompactWHOHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.public, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WHO',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'FVD Assessment Tool',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
