import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:device_apps/device_apps.dart';
import 'package:picsgoo/component/models/apps_model.dart';
import 'package:picsgoo/component/utils/preferences/app_preferences/priority_apps_prefs.dart';

part 'root_event.dart';
part 'root_state.dart';

class RootBloc extends Bloc<RootEvent, RootState> {
  RootBloc() : super(RootInitial()) {
    on<LoadAppsEvent> (loadAppsEvent);
    on<LaunchAppEvent> (launchAppEvent);
    on<LoadAllPrioritizedAppsEvent> (loadAllPrioritizedAppsEvent);
    on<RootInitialEvent> (rootInitialEvent);
    on<SavePriorityAppsEvent> (savePriorityAppsEvent);
    on<TogglePriorityAppEvent> (togglePriorityAppEvent);
    on<ResetToShowPrioritizedEvent> ((event, emit) => emit(ShowPrioritizedAllAppsLoadedResetState()));
  }

  Future<void> loadAppsEvent(LoadAppsEvent event, Emitter<RootState> emit) async {
    emit(PreparingAllAppsLoadingState());
    List<Application> allApps = [];
    allApps = await DeviceApps.getInstalledApplications(includeSystemApps:true, onlyAppsWithLaunchIntent: true, includeAppIcons: true);
    emit(PreparedAllAppsLoadedState());
    emit(InitialAllAppsLoadedState(allApps: allApps.map((app) => AppsModel(app: app)).toList()));
  }

  Future<List<AppsModel>> getAllApps() async {
    List<Application> allApps = await DeviceApps.getInstalledApplications(includeSystemApps:true, onlyAppsWithLaunchIntent: true, includeAppIcons: true);
    return allApps.map((app) => AppsModel(app: app)).toList();
  }

  FutureOr<void> launchAppEvent(LaunchAppEvent event, Emitter<RootState> emit) {
    DeviceApps.openApp(event.packageName);
  }

  Future<void> loadAllPrioritizedAppsEvent(LoadAllPrioritizedAppsEvent event, Emitter<RootState> emit) async {
    List<String> prioritizedPackageNames = await PriorityAppsPrefs().getPriorityApps();
    List<Application> allApps = await DeviceApps.getInstalledApplications(includeSystemApps:true, onlyAppsWithLaunchIntent: true, includeAppIcons: true);
    List<AppsModel> prioritizedApps = allApps.where((app) => prioritizedPackageNames.contains(app.packageName)).map((app) => AppsModel(app: app)).toList();
    emit(LoadPrioritizedAppsState(prioritizedApps: prioritizedApps));
  }

  Future<void> rootInitialEvent(RootInitialEvent event, Emitter<RootState> emit) async {
    List<String> prioritizedPackageNames = await PriorityAppsPrefs().getPriorityApps();
    if (prioritizedPackageNames.isEmpty) {
      List<Application> allApps = await DeviceApps.getInstalledApplications(includeSystemApps:true, onlyAppsWithLaunchIntent: true, includeAppIcons: true);
      List<AppsModel> allAppsModels = allApps.map((app) => AppsModel(app: app)).toList();
      emit(SelectPriorityAppState(allApps: allAppsModels, selectedPackages: {}));
    } else {
      add(LoadAllPrioritizedAppsEvent());
    }
  }

  FutureOr<void> savePriorityAppsEvent(SavePriorityAppsEvent event, Emitter<RootState> emit) {
    PriorityAppsPrefs().setPriorityApps(event.packageNames);
    add(LoadAllPrioritizedAppsEvent());
  }

  FutureOr<void> togglePriorityAppEvent(TogglePriorityAppEvent event, Emitter<RootState> emit) {
    if (state is SelectPriorityAppState) {
      final currentState = state as SelectPriorityAppState;
      final selectedPackages = Set<String>.from(currentState.selectedPackages);
      if (selectedPackages.contains(event.packageName)) {
        selectedPackages.remove(event.packageName);
      } else {
        selectedPackages.add(event.packageName);
      }
      emit(currentState.copyWith(selectedPackages: selectedPackages));
    }
  }
}
