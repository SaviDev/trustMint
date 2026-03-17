package com.antigravity.data_collection_app

import io.flutter.embedding.engine.plugins.FlutterPlugin
import android.util.Log

class BackgroundServicePlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("BackgroundServicePlugin", "Attached to engine")
    }
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}
}
