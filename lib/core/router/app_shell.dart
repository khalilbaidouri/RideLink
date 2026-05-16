import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.destinations,
    this.showAddButton = false,
    this.onAddButtonPressed,
  });

  final StatefulNavigationShell navigationShell;
  final List<NavigationDestination> destinations;
  final bool showAddButton;
  final VoidCallback? onAddButtonPressed;

  void _onDestinationSelected(int index) {
    if (showAddButton && index == 2) return;
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: showAddButton
          ? FloatingActionButton(
              onPressed: onAddButtonPressed,
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: destinations,
      ),
    );
  }
}
