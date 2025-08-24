package com.picsgoo.picsgoo

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings

class MainActivity: FlutterActivity() {
    private val CHANNEL = "launcher_service"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun getBackgroundMode(): BackgroundMode {
        return BackgroundMode.transparent
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setAsDefaultLauncher" -> {
                    setAsDefaultLauncher()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun setAsDefaultLauncher() {
        val intent = Intent(Settings.ACTION_HOME_SETTINGS)
        startActivity(intent)
    }
}
