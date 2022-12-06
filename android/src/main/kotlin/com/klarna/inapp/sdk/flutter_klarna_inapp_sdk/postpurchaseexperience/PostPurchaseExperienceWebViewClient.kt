package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchaseexperience

import android.webkit.WebView
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.webview.KlarnaWebViewClient
import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.webview.WebViewManager
import com.klarna.mobile.sdk.api.hybrid.KlarnaHybridSDK
import java.util.*

internal class PostPurchaseExperienceWebViewClient(klarnaHybridSDK: KlarnaHybridSDK) : KlarnaWebViewClient(klarnaHybridSDK) {

    private var loaded = false

    private val scriptQueue = PriorityQueue<String>()

    override fun onPageFinished(view: WebView, url: String) {
        super.onPageFinished(view, url)
        loaded = true

        if (scriptQueue.isNotEmpty()) {
            val array = scriptQueue.toTypedArray()
            scriptQueue.clear()
            array.forEach {
                view.evaluateJavascript(it, null)
            }
        }
    }

    /**
     * @return true if script is consumed, false if it is queued
     */
    fun queueJS(webViewManager: WebViewManager, script: String): Boolean {
        return if (loaded) {
            webViewManager.loadJS(script, null)
            true
        } else {
            scriptQueue.add(script)
            false
        }
    }
}