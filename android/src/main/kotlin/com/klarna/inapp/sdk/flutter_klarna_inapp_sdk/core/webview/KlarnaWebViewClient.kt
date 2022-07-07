package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.webview

import android.annotation.TargetApi
import android.os.Build
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import com.klarna.mobile.sdk.api.hybrid.KlarnaHybridSDK

internal open class KlarnaWebViewClient(private val klarnaHybridSDK: KlarnaHybridSDK) :
    WebViewClient() {

    override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean {
        return !klarnaHybridSDK.shouldFollowNavigation(url)
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
        request?.url?.toString()?.let {
            return !klarnaHybridSDK.shouldFollowNavigation(it)
        }
        return super.shouldOverrideUrlLoading(view, request)
    }

    override fun onPageFinished(view: WebView, url: String) {
        klarnaHybridSDK.newPageLoad(view)
    }
}