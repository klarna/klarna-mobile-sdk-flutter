package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchaseexperience

import com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.core.util.ParserUtil
import io.mockk.clearAllMocks
import io.mockk.mockk
import io.mockk.verify
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class PostPurchaseExperienceJSInterfaceTest {

    private val callback: PostPurchaseExperienceJSInterface.ResultCallback = mockk(relaxed = true)
    private val jsInterface: PostPurchaseExperienceJSInterface =
        PostPurchaseExperienceJSInterface(callback)

    @Before
    fun setup() {

    }

    @After
    fun teardown() {
        clearAllMocks()
    }

    @Test
    fun testInitialize() {
        jsInterface.receivedMessage(createMessage("onInitialize", null, null))
        verify { callback.onInitialize(true, null, null) }

        jsInterface.receivedMessage(createMessage("onInitialize", createResult(null, null), null))
        verify { callback.onInitialize(true, createResult(null, null), null) }

        jsInterface.receivedMessage(createMessage("onInitialize", createResult("\"data\"", null), null))
        verify { callback.onInitialize(true, createResult("\"data\"", null), null) }

        jsInterface.receivedMessage(
            createMessage(
                "onInitialize",
                createResult("\"data\"", "\"null\""),
                null
            )
        )
        verify { callback.onInitialize(true, createResult("\"data\"", "\"null\""), null) }

        jsInterface.receivedMessage(
            createMessage(
                "onInitialize",
                createResult("\"data\"", "\"null\""),
                "error"
            )
        )
        verify { callback.onInitialize(false, createResult("\"data\"", "\"null\""), "error") }
    }

    @Test
    fun testRenderOperation() {
        jsInterface.receivedMessage(createMessage("onRenderOperation", null, null))
        verify { callback.onRenderOperation(true, null, null) }

        jsInterface.receivedMessage(createMessage("onRenderOperation", createResult(null, null), null))
        verify { callback.onRenderOperation(true, createResult(null, null), null) }

        jsInterface.receivedMessage(
            createMessage(
                "onRenderOperation",
                createResult("\"data\"", null),
                null
            )
        )
        verify { callback.onRenderOperation(true, createResult("\"data\"", null), null) }

        jsInterface.receivedMessage(
            createMessage(
                "onRenderOperation",
                createResult("\"data\"", "\"null\""),
                null
            )
        )
        verify { callback.onRenderOperation(true, createResult("\"data\"", "\"null\""), null) }

        jsInterface.receivedMessage(
            createMessage(
                "onRenderOperation",
                createResult("\"data\"", "\"null\""),
                "error"
            )
        )
        verify { callback.onRenderOperation(false, createResult("\"data\"", "\"null\""), "error") }
    }

    @Test
    fun testAuthorizationRequest() {
        jsInterface.receivedMessage(createMessage("onAuthorizationRequest", null, null))
        verify { callback.onAuthorizationRequest(true, null, null) }

        jsInterface.receivedMessage(
            createMessage(
                "onAuthorizationRequest",
                createResult(null, null),
                null
            )
        )
        verify { callback.onAuthorizationRequest(true, createResult(null, null), null) }

        jsInterface.receivedMessage(
            createMessage(
                "onAuthorizationRequest",
                createResult("\"data\"", null),
                null
            )
        )
        verify { callback.onAuthorizationRequest(true, createResult("\"data\"", null), null) }

        jsInterface.receivedMessage(
            createMessage(
                "onAuthorizationRequest",
                createResult("\"data\"", "\"null\""),
                null
            )
        )
        verify { callback.onAuthorizationRequest(true, createResult("\"data\"", "\"null\""), null) }

        jsInterface.receivedMessage(
            createMessage(
                "onAuthorizationRequest",
                createResult("\"data\"", "\"null\""),
                "error"
            )
        )
        verify {
            callback.onAuthorizationRequest(
                false,
                createResult("\"data\"", "\"null\""),
                "error"
            )
        }
    }

    @Test
    fun testError() {
        jsInterface.receivedMessage(createMessage("errorAction", "errorMessage", "error"))
        verify { callback.onError(any(), any()) }
    }

    private fun createResult(data: String?, error: String?): String {
        return "{data: $data, error: $error}"
    }

    private fun createMessage(message: PostPurchaseExperienceJSInterface.PPECallbackMessage): String {
        return ParserUtil.toJson(message)!!
    }

    private fun createMessage(action: String, message: String?, error: String?): String {
        return createMessage(
            PostPurchaseExperienceJSInterface.PPECallbackMessage(
                action,
                message,
                error
            )
        )
    }

}