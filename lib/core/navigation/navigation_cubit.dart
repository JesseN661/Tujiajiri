import 'package:flutter_bloc/flutter_bloc.dart';

/// Holds the index of the selected tab in [HomeShell].
class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0);

  void select(int index) => emit(index);

  /// Goes back to the first tab (used by the system back button).
  void reset() => emit(0);
}
