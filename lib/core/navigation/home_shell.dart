import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_destination.dart';
import 'navigation_cubit.dart';

/// Main tabs: bottom bar in portrait, side rail in landscape.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.destinations});

  final List<AppDestination> destinations;

  /// Width at which the bottom bar becomes a side rail.
  static const railBreakpoint = 600.0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationCubit(),
      child: _HomeShellView(destinations: destinations),
    );
  }
}

class _HomeShellView extends StatelessWidget {
  const _HomeShellView({required this.destinations});

  final List<AppDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final navigation = context.read<NavigationCubit>();
    final index = context.watch<NavigationCubit>().state.clamp(
      0,
      destinations.length - 1,
    );

    final pages = IndexedStack(
      index: index,
      children: [
        for (final destination in destinations)
          Builder(builder: destination.builder),
      ],
    );

    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigation.reset();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= HomeShell.railBreakpoint) {
            return Scaffold(
              body: Row(
                children: [
                  SafeArea(
                    right: false,
                    child: NavigationRail(
                      selectedIndex: index,
                      onDestinationSelected: navigation.select,
                      labelType: NavigationRailLabelType.all,
                      destinations: [
                        for (final destination in destinations)
                          NavigationRailDestination(
                            icon: Icon(destination.icon),
                            selectedIcon: Icon(destination.selectedIcon),
                            label: Text(destination.label),
                          ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: pages),
                ],
              ),
            );
          }

          return Scaffold(
            body: pages,
            bottomNavigationBar: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: navigation.select,
              destinations: [
                for (final destination in destinations)
                  NavigationDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: destination.label,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
