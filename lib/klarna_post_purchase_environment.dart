enum KlarnaPostPurchaseEnvironment {
  EU,
  NA,
  OC,
  EU_PLAYGROUND,
  NA_PLAYGROUND,
  OC_PLAYGROUND
}

class KlarnaPostPurchaseEnvironmentHelper {
  static String? getSdkSource(KlarnaPostPurchaseEnvironment? environment) {
    switch (environment) {
      case KlarnaPostPurchaseEnvironment.EU:
        return "https://x.klarnacdn.net/postpurchaseexperience/lib/v1/sdk.js";
      case KlarnaPostPurchaseEnvironment.NA:
        return "https://x.klarnacdn.net/postpurchaseexperience/lib/v1/sdk-na.js";
      case KlarnaPostPurchaseEnvironment.OC:
        return "https://x.klarnacdn.net/postpurchaseexperience/lib/v1/sdk-oc.js";
      case KlarnaPostPurchaseEnvironment.EU_PLAYGROUND:
        return "https://x.klarnacdn.net/postpurchaseexperience/lib/v1/playground/sdk.js";
      case KlarnaPostPurchaseEnvironment.NA_PLAYGROUND:
        return "https://x.klarnacdn.net/postpurchaseexperience/lib/v1/playground/sdk-na.js";
      case KlarnaPostPurchaseEnvironment.OC_PLAYGROUND:
        return "https://x.klarnacdn.net/postpurchaseexperience/lib/v1/playground/sdk-oc.js";
      default:
        return null;
    }
  }
}
