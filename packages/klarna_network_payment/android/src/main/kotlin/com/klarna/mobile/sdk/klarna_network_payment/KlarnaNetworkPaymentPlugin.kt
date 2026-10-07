package com.klarna.mobile.sdk.klarna_network_payment

import android.app.Activity
import android.util.Log
import com.klarna.mobile.sdk.klarna.network.core.api.common.KlarnaResult
import com.klarna.mobile.sdk.klarna.network.core.api.common.KlarnaSDKError
import com.klarna.mobile.sdk.klarna.network.core.api.klarna.Klarna
import com.klarna.mobile.sdk.klarna.network.core.api.models.KlarnaAddress
import com.klarna.mobile.sdk.klarna.network.core.api.models.KlarnaCustomerProfile
import com.klarna.mobile.sdk.klarna.network.payment.api.KlarnaPaymentRequest
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaBillingPlan
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaCollectCustomerProfileType
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaCustomer
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaFreeTrial
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaInterval
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaLineItem
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaOndemandService
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaPartnerCustomer
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaPaymentRequestData
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaPaymentRequestState
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaPaymentRequestStateContext
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaPaymentRequestStateReason
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaRequestCustomerToken
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaRequestCustomerTokenScope
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaShipping
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaShippingConfig
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaShippingConfigMode
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaShippingOption
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaShippingRecipient
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaShippingType
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaShippingTypeAttribute
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaSubscription
import com.klarna.mobile.sdk.klarna.network.payment.api.models.KlarnaSupplementaryPurchaseData
import com.klarna.mobile.sdk.klarna.network.payment.api.payment
import com.klarna.mobile.sdk.klarna.network.payment.api.presentation.models.KlarnaPaymentPresentationContent
import com.klarna.mobile.sdk.klarna.network.payment.api.presentation.models.KlarnaPaymentPresentationData
import com.klarna.mobile.sdk.klarna.network.payment.api.presentation.models.KlarnaPaymentPresentationIcon
import com.klarna.mobile.sdk.klarna.network.payment.api.presentation.models.KlarnaPaymentPresentationImageAlignment
import com.klarna.mobile.sdk.klarna.network.payment.api.presentation.models.KlarnaPaymentPresentationInstruction
import com.klarna.mobile.sdk.klarna.network.payment.api.presentation.models.KlarnaPaymentPresentationIntent
import com.klarna.mobile.sdk.klarna.network.payment.api.presentation.models.KlarnaPaymentPresentationPaymentButton
import com.klarna.mobile.sdk.klarna.network.payment.api.presentation.models.KlarnaPaymentPresentationPaymentOption
import com.klarna.mobile.sdk.klarna.network.payment.api.presentation.models.KlarnaPaymentPresentationPaymentStatus
import com.klarna.mobile.sdk.klarna.network.payment.api.presentation.models.KlarnaPaymentPresentationText
import com.klarna.mobile.sdk.klarna.network.payment.api.presentation.models.KlarnaPaymentPresentationTextPart
import com.klarna.mobile.sdk.klarna.network.payment.api.presentation.models.KlarnaPaymentPresentationTextPartLinkContext
import com.klarna.mobile.sdk.klarna.network.payment.api.presentation.models.KlarnaPaymentPresentationTextPartStyle
import com.klarna.mobile.sdk.klarna_network_core.KnInstanceStore
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import java.text.ParsePosition
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

private val knDateOnlyPattern = Regex("""^\d{4}-\d{2}-\d{2}$""")
private val knInternetDateTimePattern =
    Regex("""^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})(?:\.(\d{1,9}))?(Z|[+-]\d{2}:\d{2})$""")

internal fun parseKnIso8601Date(value: String?): Date? {
    if (value == null) return null

    if (knDateOnlyPattern.matches(value)) {
        return parseKnDateExactly(value, "yyyy-MM-dd")
    }

    val match = knInternetDateTimePattern.matchEntire(value) ?: return null
    val dateTime = match.groupValues[1]
    val fraction = match.groupValues[2]
    val zone = match.groupValues[3]
    val milliseconds = fraction.padEnd(3, '0').take(3)
    val rfc822Zone = if (zone == "Z") "+0000" else zone.replace(":", "")

    return parseKnDateExactly(
        "$dateTime.$milliseconds$rfc822Zone",
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
    )
}

internal fun KnPresentationContent.containsAuthLink(url: String): Boolean =
    sequenceOf(paymentOption, savedPaymentOption)
        .filterNotNull()
        .flatMap { option ->
            sequenceOf(
                option.header,
                option.badge,
                option.subheader,
                option.message,
                option.terms,
            ).filterNotNull()
        }.flatMap { text -> text.parts.orEmpty().asSequence() }
        .any { part ->
            part.type == "link" &&
                part.url == url &&
                part.context == KnPresentationTextPartLinkContext.AUTH
        }

internal object KlarnaPaymentAuthActivityAdapter {
    private const val CONTAINER_INTERFACE =
        "com.klarna.mobile.sdk.klarna.network.core.internal.di.KlarnaDependencyContainer"

    fun seed(
        payment: Any,
        activity: Activity,
    ): Result<Unit> =
        try {
            val containerField =
                payment.javaClass.declaredFields.firstOrNull { field ->
                    CONTAINER_INTERFACE == field.type.name ||
                        field.type.interfaces.any { it.name == CONTAINER_INTERFACE }
                } ?: error("Klarna dependency container field was not found.")

            val container =
                containerField
                    .apply { isAccessible = true }
                    .get(payment)
                    ?: error("Klarna dependency container was null.")

            val viewManager =
                container.javaClass
                    .getMethod("provideViewManager")
                    .invoke(container)
                    ?: error("Klarna ViewManager was null.")

            viewManager.javaClass
                .getMethod("setActivity", Activity::class.java)
                .invoke(viewManager, activity)
            Result.success(Unit)
        } catch (error: Exception) {
            Result.failure(error)
        }
}

private fun parseKnDateExactly(
    value: String,
    pattern: String,
): Date? {
    val formatter =
        SimpleDateFormat(pattern, Locale.US).apply {
            isLenient = false
            timeZone = TimeZone.getTimeZone("UTC")
        }
    val position = ParsePosition(0)
    val date = formatter.parse(value, position) ?: return null
    return date.takeIf { position.index == value.length }
}

internal class KnPaymentValidationException(
    override val message: String,
) : IllegalArgumentException(message)

internal fun knCheckedInt32(
    value: Long,
    field: String,
): Int {
    if (value < Int.MIN_VALUE.toLong() || value > Int.MAX_VALUE.toLong()) {
        throw KnPaymentValidationException(
            "$field must be between ${Int.MIN_VALUE} and ${Int.MAX_VALUE}; got $value.",
        )
    }
    return value.toInt()
}

internal fun requireKnBillingPlanDate(value: String): Date =
    parseKnIso8601Date(value)
        ?: throw KnPaymentValidationException(
            "billingPlan.from must be YYYY-MM-DD or an RFC 3339 timestamp; got '$value'.",
        )

internal class PresentationContentStore<T> {
    internal data class Request<T>(
        val generation: Long,
        val content: T,
    )

    private data class State<T>(
        var generation: Long,
        var content: T?,
    )

    private val states = mutableMapOf<String, State<T>>()
    private var nextGeneration = 0L

    private fun nextGeneration(): Long {
        check(nextGeneration < Long.MAX_VALUE) {
            "Presentation request generation exhausted."
        }
        nextGeneration += 1
        return nextGeneration
    }

    @Synchronized
    fun beginRequest(instanceId: String): Long {
        val generation = nextGeneration()
        states[instanceId] =
            State(generation, states[instanceId]?.content)
        return generation
    }

    @Synchronized
    fun beginRequestWithContent(instanceId: String): Request<T>? {
        val content = states[instanceId]?.content ?: return null
        val generation = nextGeneration()
        states[instanceId] = State(generation, content)
        return Request(generation, content)
    }

    @Synchronized
    fun storeIfCurrent(
        instanceId: String,
        generation: Long,
        content: T,
    ): Boolean {
        val state = states[instanceId] ?: return false
        if (state.generation != generation) return false
        state.content = content
        return true
    }

    @Synchronized
    fun invalidate(instanceId: String) {
        states.remove(instanceId)
    }

    @get:Synchronized
    internal val stateCount: Int get() = states.size
}

/** Plugin entry point: registers the Pigeon host API and the Klarna Payment Button view. */
class KlarnaNetworkPaymentPlugin :
    FlutterPlugin,
    ActivityAware {
    private var impl: KnPaymentHostApiImpl? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val implementation = KnPaymentHostApiImpl()
        impl = implementation
        KnPaymentHostApi.setUp(binding.binaryMessenger, implementation)

        binding.platformViewRegistry.registerViewFactory(
            "com.klarna.mobile.sdk/payment_button",
            KlarnaPaymentButtonFactory(binding.binaryMessenger),
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        KnPaymentHostApi.setUp(binding.binaryMessenger, null)
        impl = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        impl?.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        impl?.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        impl?.activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        impl?.activity = null
    }
}

/** Host API backed by the native payment SDK; resolves [Klarna] from [KnInstanceStore]. */
private class KnPaymentHostApiImpl : KnPaymentHostApi {
    @Volatile
    var activity: Activity? = null

    private val presentationStore =
        PresentationContentStore<KlarnaPaymentPresentationContent>()

    companion object {
        private const val NAME = "KlarnaNetworkPayment"
        private const val ERROR_INVALID_REQUEST_DATA = "InvalidRequestData"
        private const val ERROR_ACTIVITY_NOT_FOUND = "Activity not found. The app must be in the foreground."
        private const val ERROR_INSTANCE_NOT_FOUND =
            "No instance found for the given instanceId. Call initialize first."
        private const val ERROR_NO_PRESENTATION_CONTENT =
            "No presentation content found. Call presentationFetch first."
        private const val ERROR_AUTH_ACTIVITY =
            "PresentationAuthActivityUnavailable"
    }

    override fun initiateWithId(
        instanceId: String,
        paymentRequestId: String,
        callback: (Result<KnPaymentRequest>) -> Unit,
    ) {
        val sdk = resolveSdk(instanceId, callback) ?: return
        val activity = resolveActivity(callback) ?: return
        sdk.payment.initiate(activity = activity, paymentRequestId = paymentRequestId) { result ->
            completePaymentRequest(result, callback)
        }
    }

    override fun initiateWithData(
        instanceId: String,
        data: KnPaymentRequestData,
        callback: (Result<KnPaymentRequest>) -> Unit,
    ) {
        val sdk = resolveSdk(instanceId, callback) ?: return
        val activity = resolveActivity(callback) ?: return
        val requestData =
            try {
                KlarnaPaymentRequestData(
                    amount = data.amount,
                    currency = data.currency,
                    paymentOptionId = data.paymentOptionId,
                    paymentRequestReference = data.paymentRequestReference,
                    requestCustomerToken = data.requestCustomerToken?.toKlarnaRequestCustomerToken(),
                    shippingConfig = data.shippingConfig?.toKlarnaShippingConfig(),
                    collectCustomerProfile = data.collectCustomerProfile?.toKlarnaCollectCustomerProfile(),
                    supplementaryPurchaseData =
                        data.supplementaryPurchaseData?.toKlarnaSupplementaryPurchaseData(),
                )
            } catch (error: KnPaymentValidationException) {
                failValidation(error, callback)
                return
            }
        sdk.payment.initiate(activity = activity, paymentRequestData = requestData) { result ->
            completePaymentRequest(result, callback)
        }
    }

    override fun fetch(
        instanceId: String,
        paymentRequestId: String,
        callback: (Result<KnPaymentRequest>) -> Unit,
    ) {
        val sdk = resolveSdk(instanceId, callback) ?: return
        sdk.payment.fetch(paymentRequestId = paymentRequestId) { result ->
            completePaymentRequest(result, callback)
        }
    }

    override fun cancel(
        instanceId: String,
        paymentRequestId: String,
        callback: (Result<KnPaymentRequest>) -> Unit,
    ) {
        val sdk = resolveSdk(instanceId, callback) ?: return
        sdk.payment.cancel(paymentRequestId = paymentRequestId) { result ->
            completePaymentRequest(result, callback)
        }
    }

    override fun presentationFetch(
        instanceId: String,
        data: KnPresentationData,
        callback: (Result<KnPresentationContent>) -> Unit,
    ) {
        val sdk = resolveSdk(instanceId, callback) ?: return
        val frequency =
            try {
                data.subscriptionBillingIntervalFrequency?.let {
                    knCheckedInt32(it, "subscriptionBillingIntervalFrequency")
                }
            } catch (error: KnPaymentValidationException) {
                failValidation(error, callback)
                return
            }
        val presentationData =
            KlarnaPaymentPresentationData(
                amount = data.amount,
                currency = data.currency,
                intent = data.intent?.toSdk(),
                paymentProgramEnablementCodes = data.paymentProgramEnablementCodes,
                subscriptionBillingInterval = data.subscriptionBillingInterval?.toSdk(),
                subscriptionBillingIntervalFrequency = frequency,
            )
        val generation = presentationStore.beginRequest(instanceId)
        sdk.payment.presentation.fetch(data = presentationData) { result ->
            when (result) {
                is KlarnaResult.Success -> {
                    // Only cache if the instance still exists — a dispose racing this
                    // in-flight fetch must not repopulate the store.
                    if (KnInstanceStore.getInstance(instanceId) != null) {
                        presentationStore.storeIfCurrent(
                            instanceId,
                            generation,
                            result.value,
                        )
                    }
                    callback(Result.success(result.value.toKnPresentationContent()))
                }

                is KlarnaResult.Failure -> {
                    callback(Result.failure(FlutterError(result.error.name, result.error.message)))
                }
            }
        }
    }

    override fun presentationHandleLink(
        instanceId: String,
        url: String,
        callback: (Result<KnPresentationContent>) -> Unit,
    ) {
        val sdk = resolveSdk(instanceId, callback) ?: return
        val activity = resolveActivity(callback) ?: return
        val request =
            presentationStore.beginRequestWithContent(instanceId) ?: run {
                callback(Result.failure(FlutterError(NAME, ERROR_NO_PRESENTATION_CONTENT)))
                return
            }
        val isAuthLink =
            request.content
                .toKnPresentationContent()
                .containsAuthLink(url)
        if (isAuthLink) {
            val failure =
                KlarnaPaymentAuthActivityAdapter
                    .seed(sdk.payment, activity)
                    .exceptionOrNull()
            if (failure != null) {
                val message =
                    "Could not prepare an Activity for the authentication link."
                Log.e(NAME, message, failure)
                callback(
                    Result.failure(
                        FlutterError(ERROR_AUTH_ACTIVITY, message),
                    ),
                )
                return
            }
        }
        sdk.payment.presentation.handleLink(activity = activity, content = request.content, url = url) { result ->
            when (result) {
                is KlarnaResult.Success -> {
                    // Guard against a dispose racing this in-flight handleLink (see fetch).
                    if (KnInstanceStore.getInstance(instanceId) != null) {
                        presentationStore.storeIfCurrent(
                            instanceId,
                            request.generation,
                            result.value,
                        )
                    }
                    callback(Result.success(result.value.toKnPresentationContent()))
                }

                is KlarnaResult.Failure -> {
                    callback(Result.failure(FlutterError(result.error.name, result.error.message)))
                }
            }
        }
    }

    private fun completePaymentRequest(
        result: KlarnaResult<KlarnaPaymentRequest, KlarnaSDKError>,
        callback: (Result<KnPaymentRequest>) -> Unit,
    ) {
        when (result) {
            is KlarnaResult.Success -> {
                callback(Result.success(result.value.toKnPaymentRequest()))
            }

            is KlarnaResult.Failure -> {
                callback(Result.failure(FlutterError(result.error.name, result.error.message)))
            }
        }
    }

    private fun <T> resolveSdk(
        instanceId: String,
        callback: (Result<T>) -> Unit,
    ): Klarna? {
        val sdk = KnInstanceStore.getInstance(instanceId)
        if (sdk == null) {
            callback(Result.failure(FlutterError(NAME, ERROR_INSTANCE_NOT_FOUND)))
        }
        return sdk
    }

    private fun <T> resolveActivity(
        callback: (Result<T>) -> Unit,
    ): Activity? {
        val current = activity
        if (current == null) {
            callback(Result.failure(FlutterError(NAME, ERROR_ACTIVITY_NOT_FOUND)))
        }
        return current
    }

    private fun <T> failValidation(
        error: KnPaymentValidationException,
        callback: (Result<T>) -> Unit,
    ) {
        callback(
            Result.failure(FlutterError(ERROR_INVALID_REQUEST_DATA, error.message)),
        )
    }

    private fun KlarnaPaymentRequest.toKnPaymentRequest(): KnPaymentRequest =
        KnPaymentRequest(
            paymentRequestId = paymentRequestId,
            state = state.toKnState(),
            previousState = previousState?.toKnState(),
            stateReason = stateReason?.toKnStateReason(),
            paymentRequestReference = paymentRequestReference,
            stateContext = stateContext?.toKnPaymentRequestStateContext(),
        )

    private fun KlarnaPaymentRequestState.toKnState(): KnPaymentRequestState =
        when (this) {
            KlarnaPaymentRequestState.SUBMITTED -> KnPaymentRequestState.SUBMITTED
            KlarnaPaymentRequestState.IN_PROGRESS -> KnPaymentRequestState.IN_PROGRESS
            KlarnaPaymentRequestState.COMPLETED -> KnPaymentRequestState.COMPLETED
            KlarnaPaymentRequestState.EXPIRED -> KnPaymentRequestState.EXPIRED
            KlarnaPaymentRequestState.CANCELED -> KnPaymentRequestState.CANCELED
            KlarnaPaymentRequestState.DECLINED -> KnPaymentRequestState.DECLINED
        }

    private fun KlarnaPaymentRequestStateReason.toKnStateReason(): KnPaymentRequestStateReason =
        when (this) {
            KlarnaPaymentRequestStateReason.PARTNER_CANCELED -> KnPaymentRequestStateReason.PARTNER_CANCELED
            KlarnaPaymentRequestStateReason.PAYMENT_REQUEST_SUBMITTED -> KnPaymentRequestStateReason.PAYMENT_REQUEST_SUBMITTED
            KlarnaPaymentRequestStateReason.PURCHASE_FLOW_ABORTED -> KnPaymentRequestStateReason.PURCHASE_FLOW_ABORTED
            KlarnaPaymentRequestStateReason.TECHNICAL_ERROR -> KnPaymentRequestStateReason.TECHNICAL_ERROR
            KlarnaPaymentRequestStateReason.PAYMENT_DECLINED -> KnPaymentRequestStateReason.PAYMENT_DECLINED
        }

    private fun KnPresentationIntent.toSdk(): KlarnaPaymentPresentationIntent =
        when (this) {
            KnPresentationIntent.PAY -> KlarnaPaymentPresentationIntent.PAY
            KnPresentationIntent.SUBSCRIBE -> KlarnaPaymentPresentationIntent.SUBSCRIBE
            KnPresentationIntent.ADD_TO_WALLET -> KlarnaPaymentPresentationIntent.ADD_TO_WALLET
        }

    private fun KnRequestCustomerTokenScope.toSdk(): KlarnaRequestCustomerTokenScope =
        when (this) {
            KnRequestCustomerTokenScope.CUSTOMER_LOGIN -> KlarnaRequestCustomerTokenScope.CUSTOMER_LOGIN
            KnRequestCustomerTokenScope.PAYMENT_CUSTOMER_NOT_PRESENT -> KlarnaRequestCustomerTokenScope.PAYMENT_CUSTOMER_NOT_PRESENT
            KnRequestCustomerTokenScope.PAYMENT_CUSTOMER_PRESENT -> KlarnaRequestCustomerTokenScope.PAYMENT_CUSTOMER_PRESENT
        }

    private fun KnShippingConfigMode.toSdk(): KlarnaShippingConfigMode =
        when (this) {
            KnShippingConfigMode.EDITABLE -> KlarnaShippingConfigMode.EDITABLE
        }

    private fun KnCollectCustomerProfileType.toSdk(): KlarnaCollectCustomerProfileType =
        when (this) {
            KnCollectCustomerProfileType.BILLING_ADDRESS -> KlarnaCollectCustomerProfileType.BILLING_ADDRESS
            KnCollectCustomerProfileType.COUNTRY -> KlarnaCollectCustomerProfileType.COUNTRY
            KnCollectCustomerProfileType.DATE_OF_BIRTH -> KlarnaCollectCustomerProfileType.DATE_OF_BIRTH
            KnCollectCustomerProfileType.EMAIL -> KlarnaCollectCustomerProfileType.EMAIL
            KnCollectCustomerProfileType.LOCALE -> KlarnaCollectCustomerProfileType.LOCALE
            KnCollectCustomerProfileType.NAME -> KlarnaCollectCustomerProfileType.NAME
            KnCollectCustomerProfileType.NATIONAL_IDENTIFICATION -> KlarnaCollectCustomerProfileType.NATIONAL_IDENTIFICATION
            KnCollectCustomerProfileType.PHONE -> KlarnaCollectCustomerProfileType.PHONE
        }

    private fun KnShippingType.toSdk(): KlarnaShippingType =
        when (this) {
            KnShippingType.DIGITAL_DOWNLOAD -> KlarnaShippingType.DIGITAL_DOWNLOAD
            KnShippingType.DIGITAL_EMAIL -> KlarnaShippingType.DIGITAL_EMAIL
            KnShippingType.DIGITAL_OTHER -> KlarnaShippingType.DIGITAL_OTHER
            KnShippingType.PHYSICAL_OTHER -> KlarnaShippingType.PHYSICAL_OTHER
            KnShippingType.PICKUP_BOX -> KlarnaShippingType.PICKUP_BOX
            KnShippingType.PICKUP_POINT -> KlarnaShippingType.PICKUP_POINT
            KnShippingType.PICKUP_STORE -> KlarnaShippingType.PICKUP_STORE
            KnShippingType.PICKUP_WAREHOUSE -> KlarnaShippingType.PICKUP_WAREHOUSE
            KnShippingType.TO_CURB -> KlarnaShippingType.TO_CURB
            KnShippingType.TO_DOOR -> KlarnaShippingType.TO_DOOR
            KnShippingType.TO_MAILBOX -> KlarnaShippingType.TO_MAILBOX
        }

    private fun KnShippingTypeAttribute.toSdk(): KlarnaShippingTypeAttribute =
        when (this) {
            KnShippingTypeAttribute.CONTACTLESS_DELIVERY -> KlarnaShippingTypeAttribute.CONTACTLESS_DELIVERY
            KnShippingTypeAttribute.EXPRESS -> KlarnaShippingTypeAttribute.EXPRESS
            KnShippingTypeAttribute.IDENTIFICATION_REQUIRED -> KlarnaShippingTypeAttribute.IDENTIFICATION_REQUIRED
            KnShippingTypeAttribute.LEAVE_AT_CURB -> KlarnaShippingTypeAttribute.LEAVE_AT_CURB
            KnShippingTypeAttribute.LEAVE_AT_DOOR -> KlarnaShippingTypeAttribute.LEAVE_AT_DOOR
            KnShippingTypeAttribute.LEAVE_WITH_NEIGHBOUR -> KlarnaShippingTypeAttribute.LEAVE_WITH_NEIGHBOUR
            KnShippingTypeAttribute.SIGNATURE_REQUIRED -> KlarnaShippingTypeAttribute.SIGNATURE_REQUIRED
            KnShippingTypeAttribute.TRACKED -> KlarnaShippingTypeAttribute.TRACKED
            KnShippingTypeAttribute.UNTRACKED -> KlarnaShippingTypeAttribute.UNTRACKED
        }

    private fun KnInterval.toSdk(): KlarnaInterval =
        when (this) {
            KnInterval.DAY -> KlarnaInterval.DAY
            KnInterval.WEEK -> KlarnaInterval.WEEK
            KnInterval.MONTH -> KlarnaInterval.MONTH
            KnInterval.YEAR -> KlarnaInterval.YEAR
        }

    private fun KnFreeTrial.toSdk(): KlarnaFreeTrial =
        when (this) {
            KnFreeTrial.ACTIVE -> KlarnaFreeTrial.ACTIVE
            KnFreeTrial.INACTIVE -> KlarnaFreeTrial.INACTIVE
        }

    private fun KnRequestCustomerToken.toKlarnaRequestCustomerToken(): KlarnaRequestCustomerToken =
        KlarnaRequestCustomerToken(
            scopes = scopes.filterNotNull().map { it.toSdk() },
            customerTokenReference = customerTokenReference,
        )

    private fun KnShippingConfig.toKlarnaShippingConfig(): KlarnaShippingConfig =
        KlarnaShippingConfig(supportedCountries = supportedCountries, mode = mode.toSdk())

    private fun List<KnCollectCustomerProfileType?>.toKlarnaCollectCustomerProfile(): List<KlarnaCollectCustomerProfileType> =
        filterNotNull().map { it.toSdk() }

    private fun KnSupplementaryPurchaseData.toKlarnaSupplementaryPurchaseData(): KlarnaSupplementaryPurchaseData =
        KlarnaSupplementaryPurchaseData(
            customer = customer?.toKlarnaPartnerCustomer(),
            lineItems = lineItems?.map { it.toKlarnaLineItem() },
            purchaseReference = purchaseReference,
            shipping = shipping?.map { it.toKlarnaShipping() },
            ondemandService = ondemandService?.toKlarnaOndemandService(),
            subscriptions = subscriptions?.map { it.toKlarnaSubscription() },
        )

    private fun KnPartnerCustomer.toKlarnaPartnerCustomer(): KlarnaPartnerCustomer =
        KlarnaPartnerCustomer(
            address = address?.toKlarnaAddress(),
            email = email,
            familyName = familyName,
            givenName = givenName,
            phone = phone,
        )

    private fun KnAddress.toKlarnaAddress(): KlarnaAddress =
        KlarnaAddress(
            city = city,
            country = country,
            postalCode = postalCode,
            region = region,
            streetAddress = streetAddress,
            streetAddress2 = streetAddress2,
        )

    private fun KnLineItem.toKlarnaLineItem(): KlarnaLineItem =
        KlarnaLineItem(
            currency = currency,
            imageUrl = imageUrl,
            lineItemReference = lineItemReference,
            name = name,
            productIdentifier = productIdentifier,
            productUrl = productUrl,
            quantity = knCheckedInt32(quantity, "lineItem.quantity"),
            shippingReference = shippingReference,
            subscriptionReference = subscriptionReference,
            totalAmount = totalAmount,
            totalTaxAmount = totalTaxAmount,
            unitPrice = unitPrice,
        )

    private fun KnShipping.toKlarnaShipping(): KlarnaShipping =
        KlarnaShipping(
            address = address?.toKlarnaAddress(),
            recipient = recipient?.toKlarnaShippingRecipient(),
            shippingOption = shippingOption?.toKlarnaShippingOption(),
            shippingReference = shippingReference,
        )

    private fun KnShippingRecipient.toKlarnaShippingRecipient(): KlarnaShippingRecipient =
        KlarnaShippingRecipient(
            attention = attention,
            email = email,
            familyName = familyName,
            givenName = givenName,
            phone = phone,
        )

    private fun KnShippingOption.toKlarnaShippingOption(): KlarnaShippingOption =
        KlarnaShippingOption(
            shippingCarrier = shippingCarrier,
            shippingType = shippingType.toSdk(),
            shippingTypeAttributes = shippingTypeAttributes?.filterNotNull()?.map { it.toSdk() },
        )

    private fun KnOndemandService.toKlarnaOndemandService(): KlarnaOndemandService =
        KlarnaOndemandService(
            currency = currency,
            averageAmount = averageAmount,
            minimumAmount = minimumAmount,
            maximumAmount = maximumAmount,
            purchaseInterval = purchaseInterval?.toSdk(),
            purchaseIntervalFrequency =
                purchaseIntervalFrequency?.let {
                    knCheckedInt32(it, "ondemandService.purchaseIntervalFrequency")
                },
        )

    private fun KnSubscription.toKlarnaSubscription(): KlarnaSubscription =
        KlarnaSubscription(
            subscriptionReference = subscriptionReference,
            name = name,
            freeTrial = freeTrial?.toSdk(),
            billingPlans = billingPlans?.map { it.toKlarnaBillingPlan() },
        )

    private fun KnBillingPlan.toKlarnaBillingPlan(): KlarnaBillingPlan =
        KlarnaBillingPlan(
            billingAmount = billingAmount,
            currency = currency,
            from = requireKnBillingPlanDate(from),
            interval = interval.toSdk(),
            intervalFrequency =
                knCheckedInt32(intervalFrequency, "billingPlan.intervalFrequency"),
        )

    private fun KlarnaPaymentRequestStateContext.toKnPaymentRequestStateContext(): KnPaymentRequestStateContext =
        KnPaymentRequestStateContext(
            klarnaNetworkSessionToken = klarnaNetworkSessionToken,
            klarnaCustomer = klarnaCustomer?.toKnCustomer(),
            shipping = shipping?.toKnShipping(),
        )

    private fun KlarnaCustomer.toKnCustomer(): KnCustomer =
        KnCustomer(
            customerToken = customerToken,
            customerTokenReference = customerTokenReference,
            customerProfile = customerProfile?.toKnCustomerProfile(),
        )

    private fun KlarnaCustomerProfile.toKnCustomerProfile(): KnCustomerProfile =
        KnCustomerProfile(
            address = address?.toKnAddress(),
            customerId = customerId,
            country = country,
            email = email,
            emailVerified = emailVerified,
            familyName = familyName,
            givenName = givenName,
            locale = locale,
            phone = phone,
            phoneVerified = phoneVerified,
        )

    private fun KlarnaAddress.toKnAddress(): KnAddress =
        KnAddress(
            streetAddress = streetAddress,
            streetAddress2 = streetAddress2,
            city = city,
            region = region,
            postalCode = postalCode,
            country = country,
        )

    private fun KlarnaShipping.toKnShipping(): KnShipping =
        KnShipping(
            address = address?.toKnAddress(),
            recipient = recipient?.toKnShippingRecipient(),
            shippingOption = shippingOption?.toKnShippingOption(),
            shippingReference = shippingReference,
        )

    private fun KlarnaShippingRecipient.toKnShippingRecipient(): KnShippingRecipient =
        KnShippingRecipient(
            familyName = familyName,
            givenName = givenName,
            attention = attention,
            email = email,
            phone = phone,
        )

    private fun KlarnaShippingOption.toKnShippingOption(): KnShippingOption =
        KnShippingOption(
            shippingType = shippingType.toKn(),
            shippingCarrier = shippingCarrier,
            shippingTypeAttributes = shippingTypeAttributes?.map { it.toKn() },
        )

    private fun KlarnaShippingType.toKn(): KnShippingType =
        when (this) {
            KlarnaShippingType.DIGITAL_DOWNLOAD -> KnShippingType.DIGITAL_DOWNLOAD
            KlarnaShippingType.DIGITAL_EMAIL -> KnShippingType.DIGITAL_EMAIL
            KlarnaShippingType.DIGITAL_OTHER -> KnShippingType.DIGITAL_OTHER
            KlarnaShippingType.PHYSICAL_OTHER -> KnShippingType.PHYSICAL_OTHER
            KlarnaShippingType.PICKUP_BOX -> KnShippingType.PICKUP_BOX
            KlarnaShippingType.PICKUP_POINT -> KnShippingType.PICKUP_POINT
            KlarnaShippingType.PICKUP_STORE -> KnShippingType.PICKUP_STORE
            KlarnaShippingType.PICKUP_WAREHOUSE -> KnShippingType.PICKUP_WAREHOUSE
            KlarnaShippingType.TO_CURB -> KnShippingType.TO_CURB
            KlarnaShippingType.TO_DOOR -> KnShippingType.TO_DOOR
            KlarnaShippingType.TO_MAILBOX -> KnShippingType.TO_MAILBOX
        }

    private fun KlarnaShippingTypeAttribute.toKn(): KnShippingTypeAttribute =
        when (this) {
            KlarnaShippingTypeAttribute.CONTACTLESS_DELIVERY -> KnShippingTypeAttribute.CONTACTLESS_DELIVERY
            KlarnaShippingTypeAttribute.EXPRESS -> KnShippingTypeAttribute.EXPRESS
            KlarnaShippingTypeAttribute.IDENTIFICATION_REQUIRED -> KnShippingTypeAttribute.IDENTIFICATION_REQUIRED
            KlarnaShippingTypeAttribute.LEAVE_AT_CURB -> KnShippingTypeAttribute.LEAVE_AT_CURB
            KlarnaShippingTypeAttribute.LEAVE_AT_DOOR -> KnShippingTypeAttribute.LEAVE_AT_DOOR
            KlarnaShippingTypeAttribute.LEAVE_WITH_NEIGHBOUR -> KnShippingTypeAttribute.LEAVE_WITH_NEIGHBOUR
            KlarnaShippingTypeAttribute.SIGNATURE_REQUIRED -> KnShippingTypeAttribute.SIGNATURE_REQUIRED
            KlarnaShippingTypeAttribute.TRACKED -> KnShippingTypeAttribute.TRACKED
            KlarnaShippingTypeAttribute.UNTRACKED -> KnShippingTypeAttribute.UNTRACKED
        }

    private fun KlarnaPaymentPresentationInstruction.toKn(): KnPresentationInstruction =
        when (this) {
            KlarnaPaymentPresentationInstruction.SHOW_KLARNA -> KnPresentationInstruction.SHOW_KLARNA
            KlarnaPaymentPresentationInstruction.PRESELECT_KLARNA -> KnPresentationInstruction.PRESELECT_KLARNA
            KlarnaPaymentPresentationInstruction.SHOW_ONLY_KLARNA -> KnPresentationInstruction.SHOW_ONLY_KLARNA
        }

    private fun KlarnaPaymentPresentationPaymentStatus.toKn(): KnPresentationPaymentStatus =
        when (this) {
            KlarnaPaymentPresentationPaymentStatus.PENDING_PARTNER_AUTHORIZATION -> KnPresentationPaymentStatus.PENDING_PARTNER_AUTHORIZATION
            KlarnaPaymentPresentationPaymentStatus.REQUIRES_CUSTOMER_ACTION -> KnPresentationPaymentStatus.REQUIRES_CUSTOMER_ACTION
        }

    private fun KlarnaPaymentPresentationImageAlignment.toKn(): KnPresentationImageAlignment =
        when (this) {
            KlarnaPaymentPresentationImageAlignment.LEFT -> KnPresentationImageAlignment.LEFT
            KlarnaPaymentPresentationImageAlignment.RIGHT -> KnPresentationImageAlignment.RIGHT
        }

    private fun KlarnaPaymentPresentationTextPartStyle.toKn(): KnPresentationTextPartStyle =
        when (this) {
            KlarnaPaymentPresentationTextPartStyle.BOLD -> KnPresentationTextPartStyle.BOLD
            KlarnaPaymentPresentationTextPartStyle.ITALIC -> KnPresentationTextPartStyle.ITALIC
            KlarnaPaymentPresentationTextPartStyle.UNDERLINE -> KnPresentationTextPartStyle.UNDERLINE
        }

    private fun KlarnaPaymentPresentationTextPartLinkContext.toKn(): KnPresentationTextPartLinkContext =
        when (this) {
            KlarnaPaymentPresentationTextPartLinkContext.AUTH -> KnPresentationTextPartLinkContext.AUTH
            KlarnaPaymentPresentationTextPartLinkContext.INFO -> KnPresentationTextPartLinkContext.INFO
        }

    private fun KlarnaPaymentPresentationContent.toKnPresentationContent(): KnPresentationContent =
        KnPresentationContent(
            instruction = instruction.toKn(),
            paymentStatus = paymentStatus?.toKn(),
            paymentOption = paymentOption?.toKnPresentationPaymentOption(),
            savedPaymentOption = savedPaymentOption?.toKnPresentationPaymentOption(),
        )

    private fun KlarnaPaymentPresentationPaymentOption.toKnPresentationPaymentOption(): KnPresentationPaymentOption =
        KnPresentationPaymentOption(
            paymentOptionId = paymentOptionId,
            header = header?.toKnPresentationText(),
            badge = badge?.toKnPresentationText(),
            subheader = subheader?.toKnPresentationText(),
            message = message?.toKnPresentationText(),
            terms = terms?.toKnPresentationText(),
            paymentButton = paymentButton?.toKnPresentationPaymentButton(),
            icon = icon?.toKnPresentationIcon(),
        )

    private fun KlarnaPaymentPresentationText.toKnPresentationText(): KnPresentationText =
        when (this) {
            is KlarnaPaymentPresentationText.PlainText -> {
                KnPresentationText(type = "plainText", text = text)
            }

            is KlarnaPaymentPresentationText.AttributedText -> {
                KnPresentationText(
                    type = "attributedText",
                    parts = parts?.map { it.toKnPresentationTextPart() },
                )
            }
        }

    private fun KlarnaPaymentPresentationTextPart.toKnPresentationTextPart(): KnPresentationTextPart =
        when (this) {
            is KlarnaPaymentPresentationTextPart.PlainText -> {
                KnPresentationTextPart(
                    type = "plain",
                    text = text,
                    styles = styles?.map { it.toKn() },
                )
            }

            is KlarnaPaymentPresentationTextPart.Link -> {
                KnPresentationTextPart(
                    type = "link",
                    text = text,
                    url = url,
                    context = context?.toKn(),
                    styles = styles?.map { it.toKn() },
                )
            }
        }

    private fun KlarnaPaymentPresentationPaymentButton.toKnPresentationPaymentButton(): KnPresentationPaymentButton =
        KnPresentationPaymentButton(
            text = text,
            imageUrl = imageUrl,
            imageAlignment = imageAlignment?.toKn(),
        )

    private fun KlarnaPaymentPresentationIcon.toKnPresentationIcon(): KnPresentationIcon =
        KnPresentationIcon(
            alt = alt,
            badgeImageUrl = badgeImageUrl,
            rectangleImageUrl = rectangleImageUrl,
            squareImageUrl = squareImageUrl,
        )
}
