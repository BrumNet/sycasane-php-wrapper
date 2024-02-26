import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'cache.dart';

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
      prefs.fcmToken = fcmToken;
      _setUrl(
          'http://www.sycasane.com/server/parentslogin.php?compcode=CARERUS&fb=$fcmToken');
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
      body: Padding(
        padding: const EdgeInsetsDirectional.only(top: 25.0),
        child: _buildWebViewX(),
      ),
    );
  }

  Widget _buildWebViewX() {
    return WebViewX(
      key: const ValueKey('webviewx'),
      initialContent: initialContent,
      initialSourceType: SourceType.html,
      height: screenSize.height - 25,
      width: screenSize.width,
      onWebViewCreated: (controller) => webviewController = controller,
      onPageFinished: (src) {
        fillcache(src);
      },
    );
  }

  Future<void> fillcache(src) async {
    String? privilege;
    if (prefs.privilege == null) {
      src.contains('eschooladmindashboard')
          ? privilege = "admin"
          : src.contains('eschoolstaffoptions')
              ? privilege = "staff"
              : src.contains("eschoolparent")
                  ? privilege = "parent"
                  : src.contains('eschoolaccountsdashboard')
                      ? privilege = "accounts"
                      : privilege = "parent";

      prefs.privilege = privilege;
      debugPrint("privilege :$privilege");
      await FirebaseMessaging.instance.subscribeToTopic(privilege);
      //}
    }
  }

  void _setUrl(content) {
    webviewController.loadContent(
      content,
    );
  }
}
