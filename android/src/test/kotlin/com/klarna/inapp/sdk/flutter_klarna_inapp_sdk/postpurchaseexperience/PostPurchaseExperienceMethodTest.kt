package com.klarna.inapp.sdk.flutter_klarna_inapp_sdk.postpurchaseexperience

import io.flutter.plugin.common.MethodCall
import org.junit.Assert
import org.junit.Test

class PostPurchaseExperienceMethodTest {

    @Test
    fun testInitializeValid() {
        val method = PostPurchaseExperienceMethod.Parser.parse(
            MethodCall(
                "initialize", mapOf(
                    "id" to 1,
                    "returnUrl" to "testRU",
                    "locale" to "test",
                    "purchaseCountry" to "testC",
                    "design" to "testD"
                )
            )
        ) as? PostPurchaseExperienceMethod.Initialize
        Assert.assertNotNull(method)
        Assert.assertTrue(method is PostPurchaseExperienceMethod.Initialize)
        Assert.assertEquals(1, method?.id)
        Assert.assertEquals("test", method?.locale)
        Assert.assertEquals("testC", method?.purchaseCountry)
        Assert.assertEquals("testD", method?.design)
    }

    @Test(expected = IllegalArgumentException::class)
    fun testInitializeInvalidReturnUrl() {
        PostPurchaseExperienceMethod.Parser.parse(
            MethodCall(
                "initialize",
                mapOf("id" to 1, "returnUrl" to null)
            )
        )
    }

    @Test(expected = IllegalArgumentException::class)
    fun testInitializeInvalidId() {
        PostPurchaseExperienceMethod.Parser.parse(MethodCall("initialize", mapOf("id" to null)))
    }

    @Test(expected = IllegalArgumentException::class)
    fun testInitializeInvalidLocale() {
        PostPurchaseExperienceMethod.Parser.parse(
            MethodCall(
                "initialize",
                mapOf("id" to 1, "locale" to null)
            )
        )
    }

    @Test(expected = IllegalArgumentException::class)
    fun testInitializeInvalidPurchaseCountry() {
        PostPurchaseExperienceMethod.Parser.parse(
            MethodCall(
                "initialize", mapOf(
                    "id" to 1,
                    "locale" to "test",
                    "purchaseCountry" to null
                )
            )
        )
    }

    @Test
    fun testDestroy() {
        val method = PostPurchaseExperienceMethod.Parser.parse(
            MethodCall(
                "destroy", mapOf(
                    "id" to 1
                )
            )
        ) as? PostPurchaseExperienceMethod.Destroy
        Assert.assertNotNull(method)
        Assert.assertTrue(method is PostPurchaseExperienceMethod.Destroy)
        Assert.assertEquals(1, method?.id)
    }

    @Test(expected = IllegalArgumentException::class)
    fun testDestroyInvalidId() {
        PostPurchaseExperienceMethod.Parser.parse(
            MethodCall(
                "destroy", mapOf(
                    "id" to null
                )
            )
        )
    }

    @Test
    fun testRenderOperation() {
        val method = PostPurchaseExperienceMethod.Parser.parse(
            MethodCall(
                "renderOperation", mapOf(
                    "id" to 1,
                    "locale" to "locale",
                    "operationToken" to "token"
                )
            )
        ) as? PostPurchaseExperienceMethod.RenderOperation
        Assert.assertNotNull(method)
        Assert.assertTrue(method is PostPurchaseExperienceMethod.RenderOperation)
        Assert.assertEquals(1, method?.id)
        Assert.assertEquals("locale", method?.locale)
        Assert.assertEquals("token", method?.operationToken)
    }

    @Test(expected = IllegalArgumentException::class)
    fun testRenderOperationInvalidId() {
        PostPurchaseExperienceMethod.Parser.parse(
            MethodCall(
                "renderOperation", mapOf(
                    "id" to null,
                    "locale" to null,
                    "operationToken" to "token"
                )
            )
        )
    }

    @Test(expected = IllegalArgumentException::class)
    fun testRenderOperationInvalidOperationToken() {
        PostPurchaseExperienceMethod.Parser.parse(
            MethodCall(
                "renderOperation", mapOf(
                    "id" to 1,
                    "operationToken" to null
                )
            )
        )
    }

    @Test
    fun testAuthorizationRequest() {
        val method = PostPurchaseExperienceMethod.Parser.parse(
            MethodCall(
                "authorizationRequest", mapOf(
                    "id" to 1,
                    "locale" to "locale",
                    "clientId" to "clientId",
                    "scope" to "scope",
                    "redirectUri" to "redirectUri",
                    "state" to "state",
                    "loginHint" to "loginHint",
                    "responseType" to "responseType"
                )
            )
        ) as? PostPurchaseExperienceMethod.AuthorizationRequest
        Assert.assertNotNull(method)
        Assert.assertTrue(method is PostPurchaseExperienceMethod.AuthorizationRequest)
        Assert.assertEquals(1, method?.id)
        Assert.assertEquals("locale", method?.locale)
        Assert.assertEquals("clientId", method?.clientId)
        Assert.assertEquals("scope", method?.scope)
        Assert.assertEquals("redirectUri", method?.redirectUri)
        Assert.assertEquals("state", method?.state)
        Assert.assertEquals("loginHint", method?.loginHint)
        Assert.assertEquals("responseType", method?.responseType)
    }

    @Test(expected = IllegalArgumentException::class)
    fun testAuthorizationRequestInvalidId() {
        PostPurchaseExperienceMethod.Parser.parse(
            MethodCall(
                "authorizationRequest", mapOf(
                    "id" to null,
                    "clientId" to "clientId",
                    "scope" to "scope",
                    "redirectUri" to "redirectUri"
                )
            )
        )
    }

    @Test(expected = IllegalArgumentException::class)
    fun testAuthorizationRequestInvalidClientId() {
        PostPurchaseExperienceMethod.Parser.parse(
            MethodCall(
                "authorizationRequest", mapOf(
                    "id" to 1,
                    "clientId" to null,
                    "scope" to "scope",
                    "redirectUri" to "redirectUri"
                )
            )
        )
    }

    @Test(expected = IllegalArgumentException::class)
    fun testAuthorizationRequestInvalidScope() {
        PostPurchaseExperienceMethod.Parser.parse(
            MethodCall(
                "authorizationRequest", mapOf(
                    "id" to 1,
                    "clientId" to "clientId",
                    "scope" to null,
                    "redirectUri" to "redirectUri"
                )
            )
        )
    }

    @Test(expected = IllegalArgumentException::class)
    fun testAuthorizationRequestInvalidRedirectUri() {
        PostPurchaseExperienceMethod.Parser.parse(
            MethodCall(
                "authorizationRequest", mapOf(
                    "id" to 1,
                    "clientId" to "clientId",
                    "scope" to "scope",
                    "redirectUri" to null
                )
            )
        )
    }

    @Test
    fun testInvalidMethod() {
        val method = PostPurchaseExperienceMethod.Parser.parse(
            MethodCall(
                "invalid",
                mapOf("returnUrl" to "test")
            )
        )
        Assert.assertNull(method)
    }
}