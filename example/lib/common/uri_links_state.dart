import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

abstract class UriLinksState<T extends StatefulWidget> extends State<T> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _sub;

  void _handleIncomingLinks() {
    // It will handle app links while the app is already started - be it in
    // the foreground or in the background.
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      if (!mounted) return;
      print('got uri: $uri');
      onNewLinkUri(uri);
    }, onError: (Object err) {
      if (!mounted) return;
      print('got err: $err');
      onNewLinkError(err);
    });
  }

  void onNewLinkUri(Uri? uri) {}

  void onNewLinkError(Object error) {}

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  @override
  void dispose() {
    super.dispose();
    _sub?.cancel();
  }
}
