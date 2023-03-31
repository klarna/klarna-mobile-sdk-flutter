import 'package:flutter_klarna_inapp_sdk/klarna_post_purchase_error.dart';

import 'klarna_post_purchase_sdk.dart';
import 'klarna_post_purchase_render_result.dart';

class KlarnaPostPurchaseEventListener {
  final Function(KlarnaPostPurchaseSDK) onInitialized;
  final Function(KlarnaPostPurchaseSDK) onAuthorizeRequested;
  final Function(KlarnaPostPurchaseSDK, KlarnaPostPurchaseRenderResult)
      onRenderedOperation;
  final Function(KlarnaPostPurchaseSDK, KlarnaPostPurchaseError) onError;

  KlarnaPostPurchaseEventListener(this.onInitialized, this.onAuthorizeRequested,
      this.onRenderedOperation, this.onError);
}
