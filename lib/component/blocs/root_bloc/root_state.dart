part of 'root_bloc.dart';

@immutable
abstract class RootState {}


abstract class RootShowPrioritizedBuildState extends RootState {}

abstract class RootShowPrioritizedBuildActionState extends RootShowPrioritizedBuildState {}

abstract class RootScreeBuildState extends RootState {}

final class RootInitial extends RootState {}

class InitialAllAppsLoadedState extends RootShowPrioritizedBuildActionState {
  final List<AppsModel> allApps;
  InitialAllAppsLoadedState({required this.allApps});
}

class ShowPrioritizedAllAppsLoadedResetState extends RootShowPrioritizedBuildActionState {}

class LoadPrioritizedAppsState extends RootScreeBuildState {
  final List<AppsModel> prioritizedApps;
  LoadPrioritizedAppsState({required this.prioritizedApps});
}

class SelectPriorityAppState extends RootScreeBuildState {
  final List<AppsModel> allApps;
  final Set<String> selectedPackages;

  SelectPriorityAppState({
    required this.allApps,
    this.selectedPackages = const {},
  });

  SelectPriorityAppState copyWith({
    List<AppsModel>? allApps,
    Set<String>? selectedPackages,
  }) {
    return SelectPriorityAppState(
      allApps: allApps ?? this.allApps,
      selectedPackages: selectedPackages ?? this.selectedPackages,
    );
  }
}

class PreparingAllAppsLoadingState extends RootShowPrioritizedBuildState {}

class PreparedAllAppsLoadedState extends RootShowPrioritizedBuildState {}

