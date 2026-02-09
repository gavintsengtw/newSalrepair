import 'dart:io';
import 'package:flutter/foundation.dart';
import '../config.dart';

class ProxyHttpOverrides extends HttpOverrides {
  final String proxy;
  ProxyHttpOverrides(this.proxy);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.findProxy = (uri) {
      return "PROXY $proxy";
    };
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}

void setupProxy() {
  final proxy = AppConfig.httpProxy;
  if (proxy != null && proxy.isNotEmpty) {
    HttpOverrides.global = ProxyHttpOverrides(proxy);
    debugPrint("Proxy enabled: $proxy");
  }
}
