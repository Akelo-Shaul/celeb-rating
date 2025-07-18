import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebView extends StatefulWidget {
  final String url;

  const WebView({super.key, required this.url});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  late final WebViewController _viewController;
  var _loadingPercentage = 0;


  @override
  void initState() {
    super.initState();
    _viewController = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted)
    // You can disable gestures if the page doesn't need scrolling
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            setState(() {
              _loadingPercentage = progress;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _loadingPercentage = 0;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _loadingPercentage = 100;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Web resource error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            // Optional: Control navigation, e.g., open external links in browser
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uhondo Kona'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _viewController),
            if (_loadingPercentage < 100)
              Center(
                child: LinearProgressIndicator(
                  value: _loadingPercentage / 100.0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
