package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.webview

import android.webkit.WebView
import android.webkit.WebViewClient
import com.klarna.mobile.sdk.api.hybrid.KlarnaHybridSDK

internal class KlarnaWebViewClient(private val klarnaHybridSDK: KlarnaHybridSDK) : WebViewClient() {

    override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean {
        return !klarnaHybridSDK.shouldFollowNavigation(url)
    }

    override fun onPageFinished(view: WebView, url: String) {
        klarnaHybridSDK.newPageLoad(view)
    }
}