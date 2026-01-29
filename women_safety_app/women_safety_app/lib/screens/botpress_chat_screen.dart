import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BotpressChatScreen extends StatefulWidget {
  const BotpressChatScreen({super.key});

  @override
  State<BotpressChatScreen> createState() => _BotpressChatScreenState();
}

class _BotpressChatScreenState extends State<BotpressChatScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Initialize WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          'https://cdn.botpress.cloud/webchat/v3.5/shareable.html?configUrl=https://files.bpcontent.cloud/2026/01/27/04/20260127043505-JEN6ON39.json',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Safety Assistant'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
            tooltip: 'Reload Chat',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }
}
