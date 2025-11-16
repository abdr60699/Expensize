import 'package:flutter/material.dart';
import '../models/app_route.dart';
import 'nested_navigator.dart';

/// A tab item configuration
class TabItem {
  /// Unique identifier
  final String id;

  /// Tab label
  final String label;

  /// Tab icon
  final IconData icon;

  /// Selected icon (optional)
  final IconData? selectedIcon;

  /// Routes available in this tab
  final List<AppRoute> routes;

  /// Initial route for this tab
  final String initialRoute;

  /// Navigator key for this tab (optional)
  final GlobalKey<NavigatorState>? navigatorKey;

  const TabItem({
    required this.id,
    required this.label,
    required this.icon,
    this.selectedIcon,
    required this.routes,
    required this.initialRoute,
    this.navigatorKey,
  });
}

/// A widget that manages tabbed navigation with independent navigation stacks
class TabNavigator extends StatefulWidget {
  /// The tabs to display
  final List<TabItem> tabs;

  /// Initial tab index
  final int initialIndex;

  /// Callback when tab changes
  final void Function(int index)? onTabChanged;

  /// Whether to preserve state when switching tabs
  final bool preserveState;

  /// Bottom navigation bar type
  final BottomNavigationBarType type;

  /// Background color
  final Color? backgroundColor;

  /// Selected item color
  final Color? selectedItemColor;

  /// Unselected item color
  final Color? unselectedItemColor;

  /// Icon size
  final double iconSize;

  /// Selected font size
  final double selectedFontSize;

  /// Unselected font size
  final double unselectedFontSize;

  const TabNavigator({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onTabChanged,
    this.preserveState = true,
    this.type = BottomNavigationBarType.fixed,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.iconSize = 24.0,
    this.selectedFontSize = 14.0,
    this.unselectedFontSize = 12.0,
  });

  @override
  State<TabNavigator> createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  late int _currentIndex;
  final Map<String, Widget> _tabWidgets = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _buildTabWidgets();
  }

  void _buildTabWidgets() {
    for (final tab in widget.tabs) {
      _tabWidgets[tab.id] = NestedNavigator(
        key: ValueKey(tab.id),
        routes: tab.routes,
        initialRoute: tab.initialRoute,
        navigatorKey: tab.navigatorKey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: widget.tabs.map((tab) {
          if (widget.preserveState) {
            return _tabWidgets[tab.id]!;
          } else {
            // Rebuild on each tab change
            return _currentIndex == widget.tabs.indexOf(tab)
                ? _tabWidgets[tab.id]!
                : const SizedBox.shrink();
          }
        }).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: widget.type,
        backgroundColor: widget.backgroundColor,
        selectedItemColor: widget.selectedItemColor,
        unselectedItemColor: widget.unselectedItemColor,
        iconSize: widget.iconSize,
        selectedFontSize: widget.selectedFontSize,
        unselectedFontSize: widget.unselectedFontSize,
        items: widget.tabs.map((tab) {
          return BottomNavigationBarItem(
            icon: Icon(tab.icon),
            activeIcon: tab.selectedIcon != null
                ? Icon(tab.selectedIcon)
                : Icon(tab.icon),
            label: tab.label,
          );
        }).toList(),
      ),
    );
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) {
      // Pop to root of current tab
      final currentTab = widget.tabs[_currentIndex];
      currentTab.navigatorKey?.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentIndex = index;
      });
      widget.onTabChanged?.call(index);
    }
  }
}
