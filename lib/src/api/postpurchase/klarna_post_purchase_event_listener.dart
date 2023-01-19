import '../../../klarna_post_purchase_sdk.dart';

class KlarnaPostPurchaseEventListener {
  final Function(KlarnaPostPurchaseSDK) onInitialized;
  final Function(KlarnaPostPurchaseSDK) onAuthorizeRequested;
  final Function(KlarnaPostPurchaseSDK) onRenderedOperation;
  final Function(KlarnaPostPurchaseSDK) onError;

  KlarnaPostPurchaseEventListener(this.onInitialized, this.onAuthorizeRequested,
      this.onRenderedOperation, this.onError);
}
