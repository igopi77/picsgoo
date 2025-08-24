import 'package:shared_preferences/shared_preferences.dart';

class WallpaperPrefs {
  // Singleton pattern
  WallpaperPrefs._privateConstructor();
  static final WallpaperPrefs instance = WallpaperPrefs._privateConstructor();
  factory WallpaperPrefs() {
    return instance;
  }
  static const String _wallpaperKey = 'selected_wallpaper';
  static const String _defaultWallpaper = 'assets/wallpapers/1.jpg';

  Future<void> setWallpaper(String wallpaperPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wallpaperKey, wallpaperPath);
  }

  Future<String> getWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_wallpaperKey) ?? _defaultWallpaper;
  }

  Future<void> clearWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_wallpaperKey);
  }
}