package com.klarna.mobile.sdk.flutter.postpurchase.error

data class KlarnaPostPurchaseErrorWrapper(
    /** Name of the error that occurred.*/
    val name: String,
    /** Message describing this error.*/
    val message: String,
    /** Status of the error (Used for Post Purchase render operation).*/
    val status: String?,
    /** Informs whether this error is fatal. If an error is fatal, the flow should be aborted. */
    val isFatal: Boolean
)
