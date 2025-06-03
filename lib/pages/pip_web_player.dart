import 'package:dtlive/main.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart';
import 'package:moengage_flutter/moengage_flutter.dart';
import 'package:singular_flutter_sdk/singular.dart';

import '../utils/moenage_service.dart';
import '../utils/sharedpre.dart';

class TestPlayerWeb extends StatefulWidget {
  final String loadURL;

  const TestPlayerWeb({
    Key? key,
    required this.loadURL,
  }) : super(key: key);

  @override
  State<TestPlayerWeb> createState() => _TestPlayerWebState();
}

class _TestPlayerWebState extends State<TestPlayerWeb> {
  InAppWebViewController? webViewController;
  bool _isLoading = true;
  String? userName, userType, userMobileNo;
  SharedPre sharedPref = SharedPre();
  DateTime? videoStartTime; // Track if the web view is still loading
  DateTime? videoEndTime;
  @override
  void initState() {
    super.initState();
    // Lock the orientation to portrait when the screen is initialized
    setPortraitOrientation();
  }

  // Set portrait mode
  void setPortraitOrientation() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Restore system UI and orientation settings when leaving the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    videoEndTime = DateTime.now();
    _logVideoAnalytics();
    super.dispose();
  }
  void _logVideoAnalytics() {
    if (videoStartTime != null && videoEndTime != null) {
      final watchDuration = videoEndTime!.difference(videoStartTime!).inSeconds;
      final timestamp = DateTime.now().toIso8601String();

      final properties = MoEProperties()
        ..addAttribute('user_id', Constant.userID.toString())
        ..addAttribute('duration_watched', '${watchDuration} Second')
        ..addAttribute('VideoUrl', widget.loadURL)

        ..addAttribute('timestamp', timestamp);


      MoEngageService.instance.trackEvent('Live_Stream_Viewed', properties);

      print("MoEngage event tracked with and timestamp: $timestamp");
    }
  }
  @override
  Widget build(BuildContext context) {
    analytics.logEvent(
      name: "screen_view",
      parameters: {
        "screen_name": "Player Screen",
        "user_id": Constant.userID,
      },
    );
    Map<String, Object> screenViewEvent = {
      'screen_name': 'Player Screen',
      'user_id': Constant.userID.toString(),
    };
    Singular.eventWithArgs('screen_view', screenViewEvent);
    // HTML player code with autoplay and muted settings
    String htmlPlayer = '''
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          <title>Live Player</title>
          <style>
              body, html {
                  margin: 0;
                  padding: 0;
                  height: 100%;
                  overflow: hidden; /* Prevents scrolling */
              }
              #my_player {
                  width: 100%;
                  height: 100vh; /* Full viewport height */
              }
          </style>
          <script src='https://player-static.qencode.com/release/qencode-bootstrapper.min.js'></script>
      </head>
      <body>
          <div id="my_player"></div>
          <script>
              var params = {
                  licenseKey: "7b6199e3-9329-3f02-65e7-e7d674722277",
                  size: { fill: true },
                  playback: { muted: true, autoplay: true }, // Muted to ensure autoplay works
                  env: "prod",
                  titleBar: { text: "" },
                  videoSources: { src: "${widget.loadURL}" }
              };

              var player = qPlayer("my_player", params, function() {
                  console.log("Player is loaded with source: ${widget.loadURL}");
              });

              player.on('ready', function() {
                  player.play();  // Ensure play is triggered after player is ready
              });
          </script>
      </body>
      </html>
    ''';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // WebView to load the player
            Positioned.fill(
              child: InAppWebView(
                initialData: InAppWebViewInitialData(data: htmlPlayer),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    supportZoom: false, // Disable zoom
                    disableVerticalScroll: true, // Prevent vertical scrolling
                    disableHorizontalScroll: true, // Prevent horizontal scrolling
                  ),
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    _isLoading = true; // Web view is still loading
                  });
                },
                onLoadStop: (controller, url) async {
                  setState(() {
                    _isLoading = false; // Web view finished loading
                  });
                },
                onConsoleMessage: (controller, consoleMessage) {
                  print("Console message: ${consoleMessage.message}");
                },
              ),
            ),
      
            // Black background with a loading indicator while the web view is loading
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
      
            // Back button positioned on top, even in full-screen mode
            Positioned(
              top: 30.0, // Adjust as per your design
              left: 12.0,
              child: GestureDetector(
                onTap: () {
                  // When the back button is pressed, navigate back
                  Navigator.pop(context); // Exit the screen
                },
                child: Container(
                  padding: EdgeInsets.all(0),
                  child: Icon(
                    CupertinoIcons.back,
                    color: Colors.white,
                    size: 30.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
