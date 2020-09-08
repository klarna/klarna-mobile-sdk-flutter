package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.manager

import android.content.Context
import android.util.Log
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.ErrorCallbackHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.PluginContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.io.File

internal object AssetManager {

    private const val TAG = "AssetManager"

    fun readAsset(fileName: String): String? {
        PluginContext.context?.let { context ->
            try {
                var file = File(context.filesDir, fileName)

                if (!file.exists()) {
                    copyFromAssets(context, fileName, fileName)
                    file = File(context.filesDir, fileName)
                }

                return file.readText()
            } catch (t: Throwable) {
                loge("Failed to read from assets, exception: ${t.message}")
            }
        }
        return null
    }

    private fun copyFromAssets(context: Context, original: String, target: String) {
        try {
            context.deleteFile(target)

            val input = context.assets.open(original, Context.MODE_PRIVATE)
            val output = context.openFileOutput(target, Context.MODE_PRIVATE)

            input.copyTo(output)
            input.close()
            output.close()
        } catch (t: Throwable) {
            loge("Failed to copy from assets, exception: ${t.message}")
        }
    }

    private fun loge(log: String) {
        GlobalScope.launch(Dispatchers.Main) {
            Log.d(TAG, log)
            ErrorCallbackHandler.sendValue(log)
        }
    }
}