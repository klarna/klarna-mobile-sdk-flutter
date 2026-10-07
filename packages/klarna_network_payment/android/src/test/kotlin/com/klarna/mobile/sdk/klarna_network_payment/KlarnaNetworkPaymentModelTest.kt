package com.klarna.mobile.sdk.klarna_network_payment

import android.app.Activity
import org.mockito.Mockito.mock
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertFailsWith
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

class KlarnaNetworkPaymentModelTest {

    @Test
    fun iso8601DateParserAcceptsSupportedDateForms() {
        val midnight = assertNotNull(parseKnIso8601Date("2026-01-01T00:00:00Z"))

        assertEquals(midnight, parseKnIso8601Date("2026-01-01"))
        assertEquals(midnight, parseKnIso8601Date("2026-01-01T01:00:00+01:00"))
        assertEquals(midnight, parseKnIso8601Date("2025-12-31T19:00:00-05:00"))

        val milliseconds =
            assertNotNull(parseKnIso8601Date("2026-01-01T00:00:00.123Z"))
        assertEquals(
            milliseconds,
            parseKnIso8601Date("2026-01-01T00:00:00.123456789Z"),
        )
        assertNotNull(parseKnIso8601Date("2026-01-01T00:00:00.1Z"))
    }

    @Test
    fun iso8601DateParserRejectsMalformedOrPartialInput() {
        val invalidInputs =
            listOf(
                "",
                "2026-02-30",
                "2026-01-01T00:00:00",
                "2026-01-01T00:00:00.Z",
                "2026-01-01T00:00:00+0100",
                "2026-01-01T00:00:00Ztrailing",
                "prefix2026-01-01T00:00:00Z",
            )

        invalidInputs.forEach { input ->
            assertNull(parseKnIso8601Date(input), input)
        }
        assertNull(parseKnIso8601Date(null))
    }

    @Test
    fun invalidBillingPlanDateThrowsStructuredValidationError() {
        val error =
            assertFailsWith<KnPaymentValidationException> {
                requireKnBillingPlanDate("2026-02-30")
            }

        assertEquals(
            "billingPlan.from must be YYYY-MM-DD or an RFC 3339 timestamp; got '2026-02-30'.",
            error.message,
        )
    }

    @Test
    fun checkedInt32AcceptsBoundariesAndRejectsOverflow() {
        assertEquals(Int.MIN_VALUE, knCheckedInt32(Int.MIN_VALUE.toLong(), "field"))
        assertEquals(Int.MAX_VALUE, knCheckedInt32(Int.MAX_VALUE.toLong(), "field"))

        assertFailsWith<KnPaymentValidationException> {
            knCheckedInt32(Int.MIN_VALUE.toLong() - 1, "field")
        }
        assertFailsWith<KnPaymentValidationException> {
            knCheckedInt32(Int.MAX_VALUE.toLong() + 1, "field")
        }
    }

    @Test
    fun presentationStoreRejectsOutOfOrderCompletions() {
        val store = PresentationContentStore<String>()
        val first = store.beginRequest("instance")
        val second = store.beginRequest("instance")

        assertFalse(store.storeIfCurrent("instance", first, "old"))
        assertTrue(store.storeIfCurrent("instance", second, "new"))

        val handle = assertNotNull(store.beginRequestWithContent("instance"))
        assertEquals("new", handle.content)
    }

    @Test
    fun presentationStoreRejectsCompletionAfterDispose() {
        val store = PresentationContentStore<String>()
        val request = store.beginRequest("instance")

        store.invalidate("instance")

        assertEquals(0, store.stateCount)
        assertFalse(store.storeIfCurrent("instance", request, "stale"))
        assertNull(store.beginRequestWithContent("instance"))
    }

    @Test
    fun presentationStoreRejectsStaleCompletionAfterKeyReuse() {
        val store = PresentationContentStore<String>()
        val oldRequest = store.beginRequest("instance")

        store.invalidate("instance")
        val newRequest = store.beginRequest("instance")

        assertFalse(store.storeIfCurrent("instance", oldRequest, "old"))
        assertTrue(store.storeIfCurrent("instance", newRequest, "new"))
        assertEquals(1, store.stateCount)
    }

    @Test
    fun authActivityAdapterReportsMissingReflectionMembers() {
        val result =
            KlarnaPaymentAuthActivityAdapter.seed(
                Any(),
                mock(Activity::class.java),
            )

        assertTrue(result.isFailure)
        assertEquals(
            "Klarna dependency container field was not found.",
            result.exceptionOrNull()?.message,
        )
    }

    @Test
    fun collectCustomerProfileGeneratedShapePreservesNullAndEmpty() {
        val nullValue =
            KnPaymentRequestData(
                amount = 1,
                currency = "SEK",
                collectCustomerProfile = null,
            )
        val emptyValue =
            KnPaymentRequestData(
                amount = 1,
                currency = "SEK",
                collectCustomerProfile = emptyList(),
            )

        assertNull(KnPaymentRequestData.fromList(nullValue.toList()).collectCustomerProfile)
        assertEquals(
            emptyList(),
            KnPaymentRequestData.fromList(emptyValue.toList()).collectCustomerProfile,
        )
    }

    @Test
    fun authLinkDetectionRequiresMatchingUrlAndAuthContext() {
        val content =
            KnPresentationContent(
                instruction = KnPresentationInstruction.SHOW_KLARNA,
                paymentOption =
                    KnPresentationPaymentOption(
                        paymentOptionId = "test",
                        terms =
                            KnPresentationText(
                                type = "attributedText",
                                parts =
                                    listOf(
                                        KnPresentationTextPart(
                                            type = "link",
                                            text = "Authenticate",
                                            url = "app://auth",
                                            context =
                                                KnPresentationTextPartLinkContext.AUTH,
                                        ),
                                        KnPresentationTextPart(
                                            type = "link",
                                            text = "Information",
                                            url = "app://info",
                                            context =
                                                KnPresentationTextPartLinkContext.INFO,
                                        ),
                                    ),
                            ),
                    ),
            )

        assertTrue(content.containsAuthLink("app://auth"))
        assertFalse(content.containsAuthLink("app://info"))
        assertFalse(content.containsAuthLink("app://missing"))
    }

    @Test
    fun paymentRequestCarriesStructuredStateContext() {
        val request = KnPaymentRequest(
            paymentRequestId = "pr_123",
            state = KnPaymentRequestState.COMPLETED,
            previousState = KnPaymentRequestState.IN_PROGRESS,
            stateReason = KnPaymentRequestStateReason.PAYMENT_REQUEST_SUBMITTED,
            paymentRequestReference = "merchant_ref",
            stateContext = KnPaymentRequestStateContext(
                klarnaNetworkSessionToken = "session-token",
                klarnaCustomer = KnCustomer(
                    customerToken = "customer-token",
                    customerTokenReference = "customer-ref",
                    customerProfile = KnCustomerProfile(
                        address = KnAddress(
                            streetAddress = "Sveavagen 46",
                            city = "Stockholm",
                            postalCode = "11134",
                            country = "SE",
                        ),
                        customerId = "customer-id",
                        country = "SE",
                        email = "customer@example.com",
                        emailVerified = true,
                        familyName = "Customer",
                        givenName = "Klarna",
                        locale = "en-SE",
                        phone = "+46700000000",
                        phoneVerified = false,
                    ),
                ),
                shipping = KnShipping(
                    address = KnAddress(country = "SE"),
                    recipient = KnShippingRecipient(
                        familyName = "Customer",
                        givenName = "Klarna",
                    ),
                    shippingOption = KnShippingOption(shippingType = KnShippingType.TO_DOOR),
                    shippingReference = "ship-1",
                ),
            ),
        )

        assertEquals("pr_123", request.paymentRequestId)
        assertEquals(KnPaymentRequestState.IN_PROGRESS, request.previousState)
        assertEquals("session-token", request.stateContext?.klarnaNetworkSessionToken)
        assertEquals(true, request.stateContext?.klarnaCustomer?.customerProfile?.emailVerified)
        assertEquals(
            KnShippingType.TO_DOOR,
            request.stateContext?.shipping?.shippingOption?.shippingType,
        )
    }

    @Test
    fun paymentRequestDataRoundTripsThroughGeneratedListShape() {
        val data = KnPaymentRequestData(
            currency = "SEK",
            amount = 1000,
            paymentOptionId = "pay_now",
            paymentRequestReference = "merchant_ref",
            requestCustomerToken = KnRequestCustomerToken(
                scopes = listOf(KnRequestCustomerTokenScope.CUSTOMER_LOGIN),
                customerTokenReference = "customer-ref",
            ),
            shippingConfig = KnShippingConfig(
                mode = KnShippingConfigMode.EDITABLE,
                supportedCountries = listOf("SE", "NO"),
            ),
            collectCustomerProfile = listOf(KnCollectCustomerProfileType.EMAIL),
            supplementaryPurchaseData = KnSupplementaryPurchaseData(
                lineItems = listOf(
                    KnLineItem(
                        name = "T-shirt",
                        quantity = 1,
                        totalAmount = 1000,
                        currency = "SEK",
                    ),
                ),
            ),
        )

        val decoded = KnPaymentRequestData.fromList(data.toList())

        assertEquals(data.currency, decoded.currency)
        assertEquals(data.requestCustomerToken?.scopes, decoded.requestCustomerToken?.scopes)
        assertEquals(data.shippingConfig?.supportedCountries, decoded.shippingConfig?.supportedCountries)
        assertEquals("T-shirt", decoded.supplementaryPurchaseData?.lineItems?.firstOrNull()?.name)
    }

    @Test
    fun presentationContentCarriesAttributedTextAndButtonAssets() {
        val content = KnPresentationContent(
            instruction = KnPresentationInstruction.SHOW_KLARNA,
            paymentStatus = KnPresentationPaymentStatus.REQUIRES_CUSTOMER_ACTION,
            paymentOption = KnPresentationPaymentOption(
                paymentOptionId = "pay_now",
                header = KnPresentationText(type = "plainText", text = "Pay with Klarna"),
                terms = KnPresentationText(
                    type = "attributedText",
                    parts = listOf(
                        KnPresentationTextPart(
                            type = "plain",
                            text = "Read ",
                            styles = listOf(KnPresentationTextPartStyle.BOLD),
                        ),
                        KnPresentationTextPart(
                            type = "link",
                            text = "terms",
                            url = "https://klarna.com/terms",
                            context = KnPresentationTextPartLinkContext.INFO,
                            styles = listOf(KnPresentationTextPartStyle.UNDERLINE),
                        ),
                    ),
                ),
                paymentButton = KnPresentationPaymentButton(
                    text = "Continue",
                    imageUrl = "https://cdn.klarna.com/button.png",
                    imageAlignment = KnPresentationImageAlignment.LEFT,
                ),
                icon = KnPresentationIcon(alt = "Klarna"),
            ),
        )

        assertEquals(KnPresentationInstruction.SHOW_KLARNA, content.instruction)
        assertEquals("pay_now", content.paymentOption?.paymentOptionId)
        assertEquals("https://klarna.com/terms", content.paymentOption?.terms?.parts?.lastOrNull()?.url)
        assertEquals(
            KnPresentationImageAlignment.LEFT,
            content.paymentOption?.paymentButton?.imageAlignment,
        )
        assertNotNull(content.paymentOption?.icon)
    }
}
