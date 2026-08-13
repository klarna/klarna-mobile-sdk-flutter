package com.klarna.mobile.sdk.flutter.core.handler

import android.util.Log
import com.klarna.mobile.sdk.flutter.ResultError
import com.klarna.mobile.sdk.flutter.core.method.MethodParser
import io.flutter.plugin.common.ErrorLogResult
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.mockk.clearAllMocks
import io.mockk.mockkClass
import io.mockk.spyk
import io.mockk.verify
import org.junit.After
import org.junit.Before
import org.junit.Test

class BaseMethodHandlerTest {

    private val handler: Handler = spyk(Handler())
    private val result: MethodChannel.Result = spyk(ErrorLogResult("error"))

    @Before
    fun setup() {
        mockkClass(Log::class)
    }

    @After
    fun teardown() {
        clearAllMocks()
    }

    @Test
    fun testMethodValid() {
        handler.onMethodCall(MethodCall("valid", null), result)
        verify { handler.onMethod(true, result) }
        verify { result.success(null) }
    }

    @Test
    fun testMethodInvalid() {
        handler.onMethodCall(MethodCall("error", null), result)
        verify { handler.onMethod(false, result) }
        verify { result.error(ResultError.PLUGIN_METHOD_ERROR.errorCode, "error", any()) }
    }

    @Test
    fun testMethodNull() {
        handler.onMethodCall(MethodCall("null", null), result)
        verify(exactly = 0) { handler.onMethod(any(), any()) }
        verify { result.notImplemented() }
    }


    private class Handler : BaseMethodHandler<Boolean>(Parser()) {


        private class Parser : MethodParser<Boolean> {
            override fun parse(call: MethodCall): Boolean? {
                return if (call.method == "null") null else call.method != "error"
            }

        }

        override fun onMethod(method: Boolean, result: MethodChannel.Result) {
            if (method)
                result.success(null)
            else
                throw java.lang.IllegalStateException()
        }
    }
}