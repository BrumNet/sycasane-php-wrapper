import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'help.dart';
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
  //'<center><br/><br/>Click Home Button If Page is Stalling<br/><br/><br/><br/><br/><br/>Syscane Server Loading...</center>';
  final executeJsErrorMessage =
      'Failed to execute this task because the current content is (probably) URL that allows iFrame embedding, on Web.\n\n'
      'A short reason for this is that, when a normal URL is embedded in the iFrame, you do not actually own that content so you cant call your custom functions\n'
      '(read the documentation to find out why).';

  Size get screenSize => MediaQuery.of(context).size;

  @override
  void initState() {
    Timer(const Duration(milliseconds: 500), () {
      _setUrl('https://www.sycasane.com/server/index.php');
    });
    super.initState();
    /*
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.notification}');
      ElegantNotification.success(
              title: Text("${message.notification?.title}"),
              height: screenSize.height / 4,
              description: Text("${message.notification?.body}"))
          .show(context);

      notify.showFlutterNotification(message);
    });*/
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
      //width: min(screenSize.width * 0.8, 1024),
      onWebViewCreated: (controller) => webviewController = controller,
      onPageStarted: (src) {
        //debugPrint("URL :$src");
      },
      onPageFinished: (src) {
        fillcache(src);
        debugPrint('A new page has loaded: $src\n');
      },
      jsContent: const {
        EmbeddedJsContent(
          js: "function testPlatformIndependentMethod() { console.log('Hi from JS') }",
        ),
        EmbeddedJsContent(
          webJs:
              "function testPlatformSpecificMethod(msg) { TestDartCallback('Web callback says: ' + msg) }",
          mobileJs:
              "function testPlatformSpecificMethod(msg) { TestDartCallback.postMessage('Mobile callback says: ' + msg) }",
        ),
      },
      dartCallBacks: {
        DartCallback(
          name: 'TestDartCallback',
          callBack: (msg) => showSnackBar(msg.toString(), context),
        )
      },
      webSpecificParams: const WebSpecificParams(
        printDebugInfo: true,
      ),
      mobileSpecificParams: const MobileSpecificParams(
        androidEnableHybridComposition: true,
      ),
      navigationDelegate: (navigation) {
        debugPrint(navigation.content.sourceType.toString());
        return NavigationDecision.navigate;
      },
    );
  }

  Future<void> fillcache(src) async {
    String? privilege;
    String? tokenUrl;
    //debugPrint("GetString ${prefs.getString('privilege')}");
    //if (prefs.privilege == null) {
    src.contains('eschooladmindashboard')
        ? privilege = "admin"
        : src.contains('eschoolstaffoptions')
            ? privilege = "staff"
            : src.contains('parent')
                ? privilege = "parent"
                : src.contains('eschoolaccountsdashboard')
                    ? privilege = "accounts"
                    : privilege;

    //if (privilege != null) {
    //_setUrl("$src/?token=${prefs.fcmToken}");
    prefs.privilege = privilege;
    tokenUrl ??= "$src/?token=${prefs.fcmToken}";
    if (prefs.setToken == true) {
      try {
        _setUrl(tokenUrl);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    //do notification
    debugPrint("privilege :$privilege");
    await FirebaseMessaging.instance.subscribeToTopic(privilege!);
    //FirebaseMessaging.getInstance().subscribeToTopic(privilege);
    //}
    //}
    debugPrint("executed");
  }

  void _setUrl(content) {
    webviewController.loadContent(
      content,
    );
  }
/*
  void _setHtml() {
    webviewController.loadContent(
      initialContent,
      sourceType: SourceType.url,
    );
  }

  Future<void> _goForward() async {
    if (await webviewController.canGoForward()) {
      await webviewController.goForward();
    } else {
      showSnackBar('Cannot go forward', context);
    }
  }

  Future<void> _goBack() async {
    if (await webviewController.canGoBack()) {
      await webviewController.goBack();
    } else {
      showSnackBar('Cannot go back', context);
    }
  }

  void _reload() {
    webviewController.reload();
  }

  Future<void> _getWebviewContent() async {
    try {
      final content = await webviewController.getContent();
      showAlertDialog(content.source, context);
    } catch (e) {
      showAlertDialog('Failed to execute this task.', context);
    }
  }

  void _toggleIgnore() {
    final ignoring = webviewController.ignoresAllGestures;
    webviewController.setIgnoreAllGestures(!ignoring);
    showSnackBar('Ignore events = ${!ignoring}', context);
  }
  */
}