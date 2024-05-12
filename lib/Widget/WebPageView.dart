import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';



class WebViewApp extends StatefulWidget {
  final String url;

  const WebViewApp({Key? key, required this.url}) : super(key: key);

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(widget.url),
      );


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ganga Koshi'),
      ),
      body: WebViewWidget(
        controller: controller,

      ),
    );
  }
}