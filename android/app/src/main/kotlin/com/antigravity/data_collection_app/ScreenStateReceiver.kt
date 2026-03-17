package com.antigravity.data_collection_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class ScreenStateReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("ScreenStateReceiver", "Screen state changed: ${intent.action}")
    }
}
