package com.klarna.mobile.sdk.flutter.postpurchase.manager

import com.klarna.mobile.sdk.flutter.PluginContext
import com.klarna.mobile.sdk.flutter.postpurchase.method.KlarnaPostPurchaseSDKMethod
import com.klarna.mobile.sdk.api.postpurchase.KlarnaPostPurchaseSDK
import io.flutter.plugin.common.MethodChannel
import io.mockk.clearAllMocks
import io.mockk.every
import io.mockk.just
import io.mockk.mockk
import io.mockk.mockkConstructor
import io.mockk.mockkObject
import io.mockk.runs
import io.mockk.verify
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import kotlin.random.Random

@RunWith(RobolectricTestRunner::class)
class KlarnaPostPurchaseSDKManagerTest {

    private val id: Int = Random.nextInt()
    private lateinit var postPurchaseSDKManager: KlarnaPostPurchaseSDKManager
    private lateinit var result: MethodChannel.Result

    @Before
    fun setup() {
        mockkConstructor(KlarnaPostPurchaseSDK::class)

        mockkObject(PluginContext)
        every { PluginContext.activity } returns mockk()

        postPurchaseSDKManager = KlarnaPostPurchaseSDKManager(id)
        result = mockk()
        every { result.success(any()) } just runs
        every { result.error(any(), any(), any()) } just runs
    }

    @After
    fun teardown() {
        clearAllMocks()
    }

    private fun createSDK() {
        val method = KlarnaPostPurchaseSDKMethod.Create(id, "staging", "na", null)
        postPurchaseSDKManager.create(method, result)
    }

    @Test
    fun testInitialize() {
        createSDK()
        val method = KlarnaPostPurchaseSDKMethod.Initialize(id, "sv-SE", "SE", "design")
        postPurchaseSDKManager.initialize(method, result)
        verify {
            anyConstructed<KlarnaPostPurchaseSDK>().initialize(
                method.locale,
                method.purchaseCountry,
                method.design
            )
        }
        verify { result.success(any()) }
    }

    @Test
    fun testAuthorizationRequest() {
        createSDK()
        val method = KlarnaPostPurchaseSDKMethod.AuthorizationRequest(
            id,
            "client",
            "scope",
            "redirectUrl",
            "sv-SE",
            null,
            null,
            null
        )
        postPurchaseSDKManager.authorizationRequest(method, result)
        verify {
            anyConstructed<KlarnaPostPurchaseSDK>().authorizationRequest(
                method.clientId,
                method.scope,
                method.redirectUri,
                method.locale,
                method.state,
                method.loginHint,
                method.responseType
            )
        }
        verify { result.success(any()) }
    }

    @Test
    fun testRenderOperation() {
        createSDK()
        val method =
            KlarnaPostPurchaseSDKMethod.RenderOperation(id, "token", "sv-SE", "redirectUrl")
        postPurchaseSDKManager.renderOperation(method, result)
        verify {
            anyConstructed<KlarnaPostPurchaseSDK>().renderOperation(
                method.operationToken,
                method.locale,
                method.redirectUri
            )
        }
        verify { result.success(any()) }
    }

    @Test
    fun testDestroy() {
        createSDK()
        val method = KlarnaPostPurchaseSDKMethod.Destroy(id)
        postPurchaseSDKManager.destroy(method, result)
        verify { anyConstructed<KlarnaPostPurchaseSDK>().removeCallback(any()) }
        verify { result.success(any()) }
    }
}