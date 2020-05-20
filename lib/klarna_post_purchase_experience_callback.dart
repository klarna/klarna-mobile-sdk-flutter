class KlarnaPostPurchaseExperienceCallback {

  Function(String) errorCallback;
  Function(String) eventCallback;

  KlarnaPostPurchaseExperienceCallback(this.eventCallback, this.errorCallback);

  void onError(String error){
      errorCallback?.call(error);
  }

  void onEvent(String event){
      eventCallback?.call(event);
  }
}