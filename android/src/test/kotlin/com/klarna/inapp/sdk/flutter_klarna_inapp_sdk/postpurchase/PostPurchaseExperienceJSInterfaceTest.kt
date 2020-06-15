package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchase

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util.ParserUtil
import io.mockk.*
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class PostPurchaseExperienceJSInterfaceTest {

    private val callback: PostPurchaseExperienceJSInterface.ResultCallback = mockk()
    private val jsInterface: PostPurchaseExperienceJSInterface = PostPurchaseExperienceJSInterface(callback)

    @Before
    fun setup() {
        every { callback.onInitialized(any(), any()) } just runs
        every { callback.onRenderOperation(any(), any(), any()) } just runs
        every { callback.onAuthorizationRequest(any(), any()) } just runs
        every { callback.onError(any(), any()) } just runs
    }

    @After
    fun teardown() {
        clearAllMocks()
    }

    @Test
    fun testInitialize() {
        jsInterface.postMessage(createMessage("onInitialize", null))
        verify { callback.onInitialized(true, null) }

        jsInterface.postMessage(createMessage("onInitialize", "error"))
        verify { callback.onInitialized(false, "error") }
    }

    @Test
    fun testRenderOperation() {
        jsInterface.postMessage(createMessage("onRenderOperation", "{ data: \"data\", error: null }"))
        verify { callback.onRenderOperation(true, "data", null) }

        jsInterface.postMessage(createMessage("onRenderOperation", "{ data: \"data\", error: \"error\" }"))
        verify { callback.onRenderOperation(false, "data", "error") }
    }

    @Test
    fun testAuthorizationRequest() {
        jsInterface.postMessage(createMessage("onAuthorizationRequest", null))
        verify { callback.onAuthorizationRequest(true, null) }

        jsInterface.postMessage(createMessage("onAuthorizationRequest", "error"))
        verify { callback.onAuthorizationRequest(false, "error") }
    }

    @Test
    fun testError() {
        jsInterface.postMessage(createMessage("error", "errorMessage"))
        verify { callback.onError(any(), any()) }
    }

    private fun createMessage(message: PostPurchaseExperienceJSInterface.PPECallbackMessage): String {
        return ParserUtil.toJson(message)!!
    }

    private fun createMessage(action: String, message: String?): String {
        return createMessage(PostPurchaseExperienceJSInterface.PPECallbackMessage(action, message))
    }

}