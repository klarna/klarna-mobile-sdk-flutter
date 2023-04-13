import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

abstract class UriLinksState<T extends StatefulWidget> extends State<T> {
  StreamSubscription? _sub;
  Uri? _latestUri;
  Object? _err;

  void _handleIncomingLinks() {
    // It will handle app links while the app is already started - be it in
    // the foreground or in the background.
    _sub = uriLinkStream.listen((Uri? uri) {
      if (!mounted) return;
      print('got uri: $uri');
      setState(() {
        _latestUri = uri;
        _err = null;
      });
      onNewLinkUri(uri);
    }, onError: (Object err) {
      if (!mounted) return;
      print('got err: $err');
      setState(() {
        _latestUri = null;
        _err = err;
      });
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
