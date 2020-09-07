package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.manager

import android.content.Context
import android.util.Log
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.ErrorCallbackHandler
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.PluginContext
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.network.NetworkContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import okhttp3.Request
import okhttp3.Response
import org.json.JSONObject
import java.io.File
import java.io.IOException
import java.net.HttpURLConnection

internal object AssetManager {

    private const val TAG = "AssetManager"
    private const val LAST_MODIFIED = "Last-Modified"
    private const val MODIFIED_SINCE_HEADER = "If-Modified-Since"

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

    fun updateAsset(fileName: String, url: String, assetCallback: ((String?) -> Unit)? = null) {
        GlobalScope.launch(Dispatchers.IO) {
            PluginContext.context?.let { context ->
                val preconditions = readPreconditions(context, fileName)
                val response = fetchNewAsset(fileName, url, preconditions)
                val updated = handleAsset(context, fileName, response)
                if (updated || assetCallback != null) {
                    GlobalScope.launch(Dispatchers.Main) {
                        assetCallback?.invoke(readAsset(fileName))
                    }
                }
            }
        }
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

    private fun readPreconditions(context: Context, fileName: String): JSONObject? {
        try {
            val preconditionsFileName = getPreconditionsFileName(fileName)
            val preconditionsFile = File(context.filesDir, preconditionsFileName)
            if (!preconditionsFile.exists()) {
                copyFromAssets(context, preconditionsFileName, preconditionsFileName)
            }
            val preconditions: JSONObject? = try {
                loadPreconditionsFromFile(preconditionsFile)
            } catch (t: Throwable) {
                try {
                    return loadPreconditionsFromAssets(context, preconditionsFileName)
                } catch (t: Throwable) {
                    loge("Failed to read config preconditions file from assets. ${t.message}.")
                    null
                }
            }

            return preconditions
        } catch (t: Throwable) {
            loge("Failed to read preconditions for asset: $fileName")
        }
        return null
    }

    private fun loadPreconditionsFromFile(file: File): JSONObject? {
        return try {
            JSONObject(file.readText())
        } catch (t: Throwable) {
            loge("Failed to read config preconditions file")
            null
        }
    }

    private fun loadPreconditionsFromAssets(context: Context, fileName: String): JSONObject? {
        val assetsStream = context.assets.open(fileName, Context.MODE_PRIVATE)
        return JSONObject(assetsStream.bufferedReader().use { it.readText() })
    }

    private fun fetchNewAsset(fileName: String, url: String, preconditions: JSONObject?): Response? {
        val request = Request.Builder()
                .url(url)
                .get()
                .apply { preconditions?.let { header(MODIFIED_SINCE_HEADER, preconditions.getString(LAST_MODIFIED)) } }
                .build()

        return makeCall(request, fileName)
    }

    private fun makeCall(request: Request, file: String): Response? {
        return try {
            NetworkContext.client().newCall(request).execute()
        } catch (e: IOException) {
            loge("Failed to fetch asset, asset: ${file}, message: ${e.message}")
            null
        } catch (t: Throwable) {
            loge("Failed to make call, exception: ${t.message}")
            null
        }
    }

    private fun handleAsset(context: Context, fileName: String, response: Response?): Boolean {
        when (response?.code()) {
            HttpURLConnection.HTTP_OK -> {
                return updateAssetFile(context, fileName, response.body()?.string(), response.header(LAST_MODIFIED))
            }
            HttpURLConnection.HTTP_NOT_MODIFIED -> {
                logd("Asset already up to date: $fileName")
            }
            else -> {
                // Irrelevant
            }
        }
        return false
    }

    private fun updateAssetFile(context: Context, fileName: String, asset: String?, lastModified: String?): Boolean {
        if (!asset.isNullOrBlank()) {
            try {
                File(context.filesDir, fileName).writeText(asset)

                if (!lastModified.isNullOrEmpty()) {
                    val newPreconditions = "{\"$LAST_MODIFIED\":\"$lastModified\"}"

                    val preconditionsFile = File(context.filesDir, getPreconditionsFileName(fileName))
                    preconditionsFile.writeText(newPreconditions)
                    logd("Asset updated to version: $fileName, preconditions: $newPreconditions")
                } else {
                    logd("Asset updated to newest version: $fileName")
                }

                return true
            } catch (t: Throwable) {
                loge("Failed to update asset file: $fileName, exception: ${t.message}")
                return false
            }
        }
        return false
    }

    private fun getPreconditionsFileName(fileName: String): String {
        return "$fileName.preconditions"
    }

    private fun logd(log: String) {
        Log.d(TAG, log)
    }

    private fun loge(log: String) {
        GlobalScope.launch(Dispatchers.Main) {
            Log.d(TAG, log)
            ErrorCallbackHandler.sendValue(log)
        }
    }
}