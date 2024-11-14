import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Define a function that returns a widget for the WebView
Widget buildWebView(String htmlContent) {
  return WebViewPage(htmlContent: htmlContent);
}

class WebViewPage extends StatefulWidget {
  final String htmlContent;

  const WebViewPage({Key? key, required this.htmlContent}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..loadHtmlString(
        widget.htmlContent,);
  }


  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
