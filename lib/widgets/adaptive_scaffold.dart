import 'package:flutter/material.dart';
import 'package:wooden_mill_app/core/constants/app_constants.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';
import 'package:wooden_mill_app/core/utils/responsive_layout.dart';

class AdaptiveScaffold extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<Widget> bodyPages;

  const AdaptiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.bodyPages,
  });

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  DateTime? _lastBackPressTime;

  Future<bool> _handleRootBackPress() async {
    final now = DateTime.now();
    if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false; // Prevent exit
    }
    return true; // Allow exit on second press
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTabletOrDesktop = !ResponsiveLayout.isPhone(context);

    final Widget activeBody = widget.bodyPages.length == 1
        ? widget.bodyPages.first
        : IndexedStack(
            index: widget.selectedIndex,
            children: widget.bodyPages,
          );

    final scaffold = isTabletOrDesktop
        ? Scaffold(
            body: Row(
              children: [
                // Left Navigation Rail for Large Screens
                NavigationRail(
                  selectedIndex: widget.selectedIndex,
                  onDestinationSelected: widget.onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: ShadTokens.spaceLg),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(ShadTokens.radiusSm),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: ShadTokens.spaceLg),
                        child: Text(
                          AppConstants.appVersionName,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.note_add_outlined),
                      selectedIcon: Icon(Icons.note_add),
                      label: Text('New order'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history_outlined),
                      selectedIcon: Icon(Icons.history),
                      label: Text('History'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                ),
                const VerticalDivider(),
                // Main Body Content
                Expanded(
                  child: activeBody,
                ),
              ],
            ),
          )
        : Scaffold(
            body: activeBody,
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
              ),
              child: NavigationBar(
                selectedIndex: widget.selectedIndex,
                onDestinationSelected: widget.onDestinationSelected,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.note_add_outlined),
                    selectedIcon: Icon(Icons.note_add),
                    label: 'New order',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.history_outlined),
                    selectedIcon: Icon(Icons.history),
                    label: 'History',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _handleRootBackPress();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: scaffold,
    );
  }
}
