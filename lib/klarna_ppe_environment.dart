enum KlarnaPPEEnvironment {
  EU,
  NA,
  OC,
  EU_PLAYGROUND,
  NA_PLAYGROUND,
  OC_PLAYGROUND
}

class KlarnaPPEEnvironmentHelper {
  static String getSdkSource(KlarnaPPEEnvironment environment) {
    switch (environment) {
      case KlarnaPPEEnvironment.EU:
        return "https://x.klarnacdn.net/postpurchaseexperience/lib/v1/sdk.js";
      case KlarnaPPEEnvironment.NA:
        return "https://x.klarnacdn.net/postpurchaseexperience/lib/v1/sdk-na.js";
      case KlarnaPPEEnvironment.OC:
        return "https://x.klarnacdn.net/postpurchaseexperience/lib/v1/sdk-oc.js";
      case KlarnaPPEEnvironment.EU_PLAYGROUND:
        return "https://x.klarnacdn.net/postpurchaseexperience/lib/v1/playground/sdk.js";
      case KlarnaPPEEnvironment.NA_PLAYGROUND:
        return "https://x.klarnacdn.net/postpurchaseexperience/lib/v1/playground/sdk-na.js";
      case KlarnaPPEEnvironment.OC_PLAYGROUND:
        return "https://x.klarnacdn.net/postpurchaseexperience/lib/v1/playground/sdk-oc.js";
      default:
        return null;
    }
  }
}
