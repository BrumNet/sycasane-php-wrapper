import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class WebViewXPage extends StatefulWidget {
  const WebViewXPage({
    Key? key,
  }) : super(key: key);

  @override
  WebViewXPageState createState() => WebViewXPageState();
}

class WebViewXPageState extends State<WebViewXPage> {
  late WebViewXController webviewController;
  final scrollController = ScrollController();

  final initialContent = '<div></div>';
  final executeJsErrorMessage =
      'Failed to execute this task because the current content is (probably) URL that allows iFrame embedding, on Web.\n\n'
      'A short reason for this is that, when a normal URL is embedded in the iFrame, you do not actually own that content so you cant call your custom functions\n'
      '(read the documentation to find out why).';

  Size get screenSize => MediaQuery.of(context).size;

  @override
  void initState() {
    Timer(const Duration(milliseconds: 500), () async {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      _setUrl('https://www.sycasane.com/server/index.php?fb=$fcmToken');
    });
    super.initState();
  }

  @override
  void dispose() {
    webviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(108, 3, 168, 244),
      body: _buildWebViewX(),
    );
  }

  Widget _buildWebViewX() {
    return WebViewX(
      key: const ValueKey('webviewx'),
      initialContent: initialContent,
      initialSourceType: SourceType.html,
      height: screenSize.height,
      width: screenSize.width,
      onWebViewCreated: (controller) => webviewController = controller,
    );
  }

  Future<void> fillcache(src) async {
    String? privilege;
    src.contains('eschooladmindashboard')
        ? privilege = "admin"
        : src.contains('eschoolstaffoptions')
            ? privilege = "staff"
            : src.contains('parent')
                ? privilege = "parent"
                : src.contains('eschoolaccountsdashboard')
                    ? privilege = "accounts"
                    : privilege;

    await FirebaseMessaging.instance.subscribeToTopic(privilege!);

    debugPrint("executed");
  }

  void _setUrl(content) {
    webviewController.loadContent(
      content,
    );
  }
}
