import 'package:dtlive/main.dart';
import 'package:dtlive/pages/pip_web_player.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:moengage_flutter/moengage_flutter.dart';
import 'package:singular_flutter_sdk/singular.dart';

import '../utils/moenage_service.dart';

class PlayerVideo extends StatefulWidget {
  final int? videoId, videoType, typeId, otherId, stopTime;
  final String? playType, videoUrl, vUploadType, videoThumb;

  final dynamic iframeTrailerUrl,
      iframeVideoUrl,
      trailerUrlVideoId,
      videoUrlId,
      isLive,
      trailerUrl;

  PlayerVideo(
    this.playType,
    this.videoId,
    this.videoType,
    this.typeId,
    this.otherId,
    this.videoUrl,
    this.stopTime,
    this.vUploadType,
    this.videoThumb, {
    Key? key,
    this.isLive,
    this.iframeTrailerUrl,
    this.iframeVideoUrl,
    this.trailerUrlVideoId,
    this.videoUrlId,
    required this.trailerUrl,
  }) : super(key: key);

  @override
  State<PlayerVideo> createState() => _PlayerVideoState();
}

class _PlayerVideoState extends State<PlayerVideo> {
  bool backButtonClicked = false;
  DateTime? videoStartTime; // To track when video starts
  DateTime? videoEndTime; // To track when video ends
  final ValueNotifier<bool> isFullScreen = ValueNotifier(false);
  late InAppWebViewController webViewController;

  @override
  void initState() {
    print("---Video ifreme Url --${widget.iframeVideoUrl}");
    print("---Trailer ifreme Url --${widget.iframeTrailerUrl}");
    print("---name of the content  --${widget.videoThumb}");

    // print("---Video Url --${widget.trailerUrl}");

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    videoStartTime = DateTime.now();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    videoEndTime = DateTime.now(); // Log video end time
    _logVideoAnalytics(); // Log analytics event
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  void _logVideoAnalytics() {
    if (videoStartTime != null && videoEndTime != null) {
      final watchDuration = videoEndTime!.difference(videoStartTime!).inSeconds;

      analytics.logEvent(
        name: "video_watch_event",
        parameters: {
          "video_id": widget.videoId,
          "user_id": Constant.userID,
          "watch_duration": watchDuration, // Duration in seconds
          "play_type": widget.playType,
          "video_url": widget.videoUrl,
          "video_type": widget.videoType,
          "is_live": widget.isLive == 1 ? "yes" : "no",
        },
      );
      Map<String, Object> screenViewEvent = {
        'event_name': 'video_watch_event',
        "video_id": '${widget.videoId}',

        "watch_duration": '${watchDuration}second', // Duration in seconds
        "play_type": '${widget.playType}',
        "video_url": '${widget.videoUrl}',
        "video_type": '${widget.videoType}',
        "is_live": widget.isLive == 1 ? "yes" : "no",
        'user_id': Constant.userID.toString(),
      };
      Singular.eventWithArgs('video_watch_event', screenViewEvent);

      final timestamp = DateTime.now().toIso8601String();

      final properties = MoEProperties()
        ..addAttribute('user_id', Constant.userID.toString())
        ..addAttribute('content_id', widget.videoId)
        ..addAttribute('content_title', widget.videoThumb)
        // ..addAttribute('content_type', widget.videoType)
        ..addAttribute('play_type', '${widget.playType}')
        ..addAttribute('video_url', widget.videoUrl)
        // ..addAttribute('genre', widget.isLive)
        ..addAttribute('duration_watched', '${watchDuration} Second')
        ..addAttribute('timestamp', timestamp);

      MoEngageService.instance.trackEvent('Content_Viewed', properties);

      print("MoEngage event tracked with and timestamp: $timestamp");
    }
  }

  @override
  Widget build(BuildContext context) {
    analytics.logEvent(
      name: "Player_screen_view",
      parameters: {
        "screen_name": "Player Screen",
        "user_id": Constant.userID,
      },
    );
    Map<String, Object> screenViewEvent = {
      'screen_name': 'Player Screen',
      'user_id': Constant.userID.toString(),
    };
    Singular.eventWithArgs('Player_screen_view', screenViewEvent);

    final properties = MoEProperties()
      ..addAttribute('screen_name', 'Player Screen')
      ..addAttribute('user_id', Constant.userID.toString())
      ..addAttribute('timestamp', DateTime.now().toIso8601String());

    MoEngageService.instance.trackEvent('Player_screen_view', properties);
    return Scaffold(
        body: widget.playType == "Trailer"
            ? Stack(
                children: [
                  InAppWebView(
                    initialData: InAppWebViewInitialData(
                      data: '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    html, body {
      margin: 0;
      padding: 0;
      background-color.xml: black;
      height: 100%;
      width: 100%;
      overflow: hidden;
    }
    #videoWrapper {
      position: absolute;
      top: 0;
      left: 0;
      bottom: 0;
      right: 0;
      display: flex;
      justify-content: center;
      align-items: center;
    }
    iframe {
      border: none;
      width: 100vw;
      height: 100vh;
    }
    #backButton {
      position: absolute;
      top: 15px;
      left: 15px;
      z-index: 1000;
      cursor: pointer;
      color.xml: white;
    }
  </style>
</head>
<body>
  <div id="videoWrapper">
    <iframe
      id="videoIframe"
      src="${widget.iframeTrailerUrl != null && widget.iframeTrailerUrl.toString().isNotEmpty ? widget.iframeTrailerUrl : 'https://Railpitara.tv/unviiplayer.html?url=${widget.videoUrl}&autoplay=true&loop=false&muted=false&preload=true&responsive=true'}"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
      allowfullscreen>
    </iframe>
  </div>

  <script>
    const iframe = document.getElementById("videoIframe");

    // Back Button Communication
    function setupBackButton() {
      document.addEventListener("fullscreenchange", function () {
        const backButton = document.getElementById("backButton");
        if (document.fullscreenElement) {
          backButton.style.display = "none";
        } else {
          backButton.style.display = "block";
        }
      });
    }

    setupBackButton();
  </script>
</body>
</html>
        ''',
                    ),
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        disableVerticalScroll: true,
                        disableHorizontalScroll: true,
                        disableContextMenu: true,
                        useOnLoadResource: true,
                        javaScriptEnabled: true,
                        mediaPlaybackRequiresUserGesture: false,
                        userAgent:
                            'Mozilla/5.0 (Linux; Android 10; Mobile; rv:68.0) Gecko/68.0 Firefox/68.0',
                      ),
                    ),
                    onWebViewCreated: (controller) {
                      controller.addJavaScriptHandler(
                        handlerName: 'toggleMute',
                        callback: (args) {
                          final isMuted = args[0];
                          controller.evaluateJavascript(source: '''
              const iframe = document.getElementById("videoIframe");
              iframe.contentWindow.postMessage({ type: "mute", value: ${isMuted} }, "*");
            ''');
                        },
                      );
                    },
                  ),
                  Positioned(
                    top: 40.0,
                    left: 16.0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        CupertinoIcons.back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            : widget.isLive == 1
                ? TestPlayerWeb(loadURL: widget.videoUrl ?? '')
                : Stack(
                    children: [
                      InAppWebView(
                        initialData: InAppWebViewInitialData(
                          data: '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    html, body {
      margin: 0;
      padding: 0;
      background-color.xml: black;
      height: 100%;
      width: 100%;
      overflow: hidden;
    }
    #videoWrapper {
      position: absolute;
      top: 0;
      left: 0;
      bottom: 0;
      right: 0;
      display: flex;
      justify-content: center;
      align-items: center;
    }
    iframe {
      border: none;
      width: 100vw;
      height: 100vh;
    }
    #backButton {
      position: absolute;
      top: 15px;
      left: 15px;
      z-index: 1000;
      cursor: pointer;
      color.xml: white;
    }
  </style>
</head>
<body>
  <div id="videoWrapper">
    <iframe
      id="videoIframe"
      src="${widget.iframeVideoUrl != null && widget.iframeVideoUrl.toString().isNotEmpty ? widget.iframeVideoUrl : 'https://Railpitara.tv/unviiplayer.html?url=${widget.videoUrl}&autoplay=true&loop=false&muted=false&preload=true&responsive=true'}"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
      allowfullscreen>
    </iframe>
  </div>

  <script>
    const iframe = document.getElementById("videoIframe");

    // Back Button Communication
    function setupBackButton() {
      document.addEventListener("fullscreenchange", function () {
        const backButton = document.getElementById("backButton");
        if (document.fullscreenElement) {
          backButton.style.display = "none";
        } else {
          backButton.style.display = "block";
        }
      });
    }

    setupBackButton();
  </script>
</body>
</html>
        ''',
                        ),
                        initialOptions: InAppWebViewGroupOptions(
                          crossPlatform: InAppWebViewOptions(
                            disableVerticalScroll: true,
                            disableHorizontalScroll: true,
                            disableContextMenu: true,
                            useOnLoadResource: true,
                            javaScriptEnabled: true,
                            mediaPlaybackRequiresUserGesture: false,
                            userAgent:
                                'Mozilla/5.0 (Linux; Android 10; Mobile; rv:68.0) Gecko/68.0 Firefox/68.0',
                          ),
                        ),
                        onWebViewCreated: (controller) {
                          controller.addJavaScriptHandler(
                            handlerName: 'toggleMute',
                            callback: (args) {
                              final isMuted = args[0];
                              controller.evaluateJavascript(source: '''
              const iframe = document.getElementById("videoIframe");
              iframe.contentWindow.postMessage({ type: "mute", value: ${isMuted} }, "*");
            ''');
                            },
                          );
                        },
                      ),
                      Positioned(
                        top: 40.0,
                        left: 16.0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            CupertinoIcons.back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ));
  }
}
