// import 'dart:developer';

import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/sharedpre.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:floating/floating.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TestPlayerWeb extends StatefulWidget {
  final String loadURL;

  const TestPlayerWeb({
    Key? key,
    required this.loadURL,
  }) : super(key: key);

  @override
  State<TestPlayerWeb> createState() => _TestPlayerWebState();
}

class _TestPlayerWebState extends State<TestPlayerWeb>
    with WidgetsBindingObserver {
  var loadingPercentage = 0;
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  SharedPre sharedPref = SharedPre();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(
        this); // Registering this class as an observer for app lifecycle changes
    pip =
        Floating(); // Instantiating the "Floating" instance to manage PiP functionality
    _checkPiPAvailability(); // Checking the availability of PiP upon initializing the widget
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    debugPrint("loadURL ========> ${widget.loadURL}");
    pullToRefreshController = (kIsWeb) ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            options: PullToRefreshOptions(color: complimentryColor),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  late Floating pip; // Initializing a variable to handle PiP functionalities
  bool isPipAvailable = false; // Variable to track PiP availability status

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // log(" CYCLEC${state.name}");
    // log(" CYCLEC${state}");
    // Listening to app lifecycle changes to detect when the app enters the hidden state (minimized)
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      // Triggering PiP mode with a landscape aspect ratio when the app is minimized
      pip.enable(aspectRatio: const Rational.landscape());
    }
  }

  // Method to verify the availability of PiP feature asynchronously
  _checkPiPAvailability() async {
    isPipAvailable = await pip
        .isPipAvailable; // Checking if PiP mode is available on the device
    setState(
        () {}); // Triggering a UI update based on the PiP availability status
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(
        this); // Unregistering this class as an observer for app lifecycle changes
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PiPSwitcher(
      // Widget displayed when PiP is disabled or app is in foreground state
      childWhenDisabled: Scaffold(
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     // Enabling PiP mode if available and configuring the aspect ratio for landscape orientation.
        //     if (isPipAvailable) {
        //       pip.enable(
        //           aspectRatio: const Rational
        //               .landscape()); // Enabling PiP with a landscape aspect ratio
        //     }
        //   },
        // ),
        resizeToAvoidBottomInset: true,
        backgroundColor: appBgColor,
        // appBar: Utils.myAppBarWithBack(context, widget.appBarTitle, false),
        body: Column(
          children: [
            /* AdMob Banner */
            Container(
              child: Utils.showBannerAd(context),
            ),
            Expanded(
              child: setWebView(),
            ),
          ],
        ),
      ),
      // Widget displayed when PiP window is enabled or app is in background state
      childWhenEnabled: Expanded(
        child: setWebView(),
      ),
    );
  }

  Widget setWebView() {
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(widget.loadURL)),
          pullToRefreshController: pullToRefreshController,
          onWebViewCreated: (controller) async {
            webViewController = controller;
          },
          onLoadStart: (controller, url) async {
            setState(() {
              loadingPercentage = 0;
            });
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            return NavigationActionPolicy.ALLOW;
          },
          onLoadStop: (controller, url) async {
            setState(() {
              loadingPercentage = 100;
            });
          },
          onProgressChanged: (controller, progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onUpdateVisitedHistory: (controller, url, isReload) {
            debugPrint("onUpdateVisitedHistory url =========> $url");
          },
          onConsoleMessage: (controller, consoleMessage) {
            debugPrint("consoleMessage =========> $consoleMessage");
          },
        ),
        if (loadingPercentage < 100)
          LinearProgressIndicator(
            color: complimentryColor,
            backgroundColor: appBgColor,
            value: loadingPercentage / 100.0,
          ),
      ],
    );
  }
}
