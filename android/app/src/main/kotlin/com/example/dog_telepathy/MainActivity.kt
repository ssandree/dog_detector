package com.example.dog_telepathy

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.StatFs
import android.os.Environment

class MainActivity: FlutterActivity() {
    private val CHANNEL = "storage_info"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "getStorageInfo") {
                val path = Environment.getDataDirectory().absolutePath
                val stat = StatFs(path)

                val total = stat.blockSizeLong * stat.blockCountLong
                val free = stat.blockSizeLong * stat.availableBlocksLong

                result.success(mapOf(
                    "total" to total,
                    "free" to free,
                    "used" to (total - free)
                ))
            } else {
                result.notImplemented()
            }
        }
    }
}
