import 'package:shared_preferences/shared_preferences.dart';

class PriorityAppsPrefs {
  // let's make this class as a singleton class
  PriorityAppsPrefs._privateConstructor();
  static final PriorityAppsPrefs instance =
      PriorityAppsPrefs._privateConstructor();
  factory PriorityAppsPrefs() {
    return instance;
  }
  String key = 'priority_apps';

  Future<List<String>> getPriorityApps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }

  Future<void> setPriorityApps(List<String> apps) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, apps);
  }

  Future<void> addPriorityApp(String app) async {
    List<String> apps = await getPriorityApps();
    if (!apps.contains(app)) {
      apps.add(app);
      await setPriorityApps(apps);
    }
  }

  Future<void> removePriorityApp(String app) async {
    List<String> apps = await getPriorityApps();
    if (apps.contains(app)) {
      apps.remove(app);
      await setPriorityApps(apps);
    }
  }

  Future<bool> isPriorityApp(String app) async {
    List<String> apps = await getPriorityApps();
    return apps.contains(app);
  }

  Future<void> clearPriorityApps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
