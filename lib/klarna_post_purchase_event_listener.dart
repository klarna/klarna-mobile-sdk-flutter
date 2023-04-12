import 'klarna_post_purchase_error.dart';
import 'klarna_post_purchase_render_result.dart';
import 'klarna_post_purchase_sdk.dart';

abstract class KlarnaPostPurchaseEventListener {
  void onInitialized(KlarnaPostPurchaseSDK klarnaPostPurchaseSDK);
  void onAuthorizeRequested(KlarnaPostPurchaseSDK klarnaPostPurchaseSDK);
  void onRenderedOperation(KlarnaPostPurchaseSDK klarnaPostPurchaseSDK, KlarnaPostPurchaseRenderResult renderResult);
  void onError(KlarnaPostPurchaseSDK klarnaPostPurchaseSDK, KlarnaPostPurchaseError error);
}
