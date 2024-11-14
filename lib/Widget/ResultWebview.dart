import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ResultWebView extends StatefulWidget {
  final String htmlContent;

  const ResultWebView({Key? key, required this.htmlContent}) : super(key: key);

  @override
  _ResultWebViewState createState() => _ResultWebViewState();
}

class _ResultWebViewState extends State<ResultWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(widget.htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return  WebViewWidget(controller: _controller);
  }
}
