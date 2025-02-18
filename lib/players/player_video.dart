import 'package:dtlive/main.dart';
import 'package:dtlive/pages/pip_web_player.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:singular_flutter_sdk/singular.dart';

class PlayerVideo extends StatefulWidget {
  final int? videoId, videoType, typeId, otherId, stopTime;
  final String? playType, videoUrl, vUploadType, videoThumb;
  final dynamic trailerLibraryId,
      trailerUrlVideoId,
      videoLibraryId,
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
    this.trailerLibraryId,
    this.videoLibraryId,
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

  @override
  void initState() {
    print("---Video Url --${widget.videoUrl}");
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
            <style>
              html, body {
                margin: 0;
                padding: 0;
                overflow: hidden;
                height: 100%;
                background-color: black;
              }

              iframe {
                display: block;
                width: 100%;
                height: 100%;
                border: none;
                border-radius: 0;
                position: absolute;
                top: 0;
                left: 0;
              }

              #backButton {
                position: absolute;
                top: 15px;
                left: 15px;
                background-color: rgba(0, 0, 0, 0.5); /* Semi-transparent background */
                border-radius: 50%;
                padding: 10px;
                cursor: pointer;
                z-index: 1000;
              }

              #backButton:hover {
                background-color: rgba(0, 0, 0, 0.8); /* Darker when hovered */
              }

              /* Ensure fullscreen button is hidden if fullscreen is active */
              .fullscreen-active #backButton {
                display: none;
              }
            </style>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          </head>
          <body>
            <iframe
              src="https://chull.tv/unviiplayer.html?url=${widget.trailerUrl}"
              allow="accelerometer; gyroscope; autoplay; encrypted-media; picture-in-picture;"
              allowfullscreen="true">
            </iframe>

            <script>
              // Back button functionality
              document.getElementById('backButton').addEventListener('click', () => {
                if (!window.flutter_inappwebview.backButtonClicked) {
                  window.flutter_inappwebview.backButtonClicked = true;
                  window.flutter_inappwebview.callHandler('goBack');
                }
              });

              // Handle fullscreen change to hide or show the back button
              document.addEventListener("fullscreenchange", function () {
                if (document.fullscreenElement) {
                  document.body.classList.add('fullscreen-active');
                } else {
                  document.body.classList.remove('fullscreen-active');
                }
              });
            </script>
          </body>
          </html>
        ''',
                    ),
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        disableVerticalScroll: false,
                        disableHorizontalScroll: false,
                        disableContextMenu: true,
                        useOnLoadResource: true,
                        javaScriptEnabled: true,
                        mediaPlaybackRequiresUserGesture: false,
                        userAgent:
                            'Mozilla/5.0 (Linux; Android 10; Mobile; rv:68.0) Gecko/68.0 Firefox/68.0',
                      ),
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      controller.addJavaScriptHandler(
                        handlerName: 'goBack',
                        callback: (args) {
                          Navigator.pop(context);
                        },
                      );
                    },
                    onLoadStop: (controller, url) async {
                      await controller.evaluateJavascript(source: '''
          document.getElementById('backButton').addEventListener('click', () => {
            if (!window.flutter_inappwebview.backButtonClicked) {
              window.flutter_inappwebview.backButtonClicked = true;
              window.flutter_inappwebview.callHandler('goBack');
            }
          });
        ''');
                    },
                  ),
                  Positioned(
                    top: 40.0,
                    left: 20.0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 45, // Diameter of the circle
                        height: 45, // Diameter of the circle
                        decoration: BoxDecoration(
                          color:
                              Colors.white, // Background color of the container
                          shape:
                              BoxShape.circle, // Makes the container circular
                        ),
                        child: Center(
                          child: Icon(
                            CupertinoIcons.back, // Icon to display
                            color: Colors.black, // Icon color
                            size: 25, // Icon size
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : widget.isLive == 1
                ? TestPlayerWeb(loadURL: widget.videoUrl ?? '')
                : 
                
              Stack(
  children: [
    InAppWebView(
      initialData: InAppWebViewInitialData(
        data: '''
<!DOCTYPE html>
<html>
<head>
  <style>
    html, body {
      margin: 0;
    padding: 0;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    background: #000;
    overflow: hidden;
    }

    iframe {
    display: flex;
    justify-content: center;
      width: 100%;
      height: 100%;
      border: none;
      position: absolute;
      top: 0;
      left: 0;
    }

    #my_player {
    display: flex;
    justify-content: center;
      width: 100%;
      height: 100vh; /* Full viewport height */
    }

    #backButton {
    display: none;
      position: absolute;
      top: 15px;
      left: 15px;
      background-color: rgba(0, 0, 0, 0.5);
      border-radius: 50%;
      padding: 10px;
      cursor: pointer;
      z-index: 1000;
    }

    #backButton:hover {
      background-color: rgba(0, 0, 0, 0.8);
    }

    .fullscreen-active #backButton {
      display: none;
    }
  </style>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
</head>
<body>
  <iframe
    id="my_player"
    src="https://chull.tv/unviiplayer.html?url=${widget.videoUrl}"
    allow="accelerometer; gyroscope; autoplay; encrypted-media; picture-in-picture;"
    allowfullscreen>
  </iframe>

  <script>
    document.addEventListener("fullscreenchange", function () {
      if (document.fullscreenElement) {
        document.body.classList.add('fullscreen-active');
      } else {
        document.body.classList.remove('fullscreen-active');
      }
    });
  </script>
</body>
</html>
        ''',
      ),
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          disableVerticalScroll: false,
          disableHorizontalScroll: false,
          disableContextMenu: true,
          useOnLoadResource: true,
          javaScriptEnabled: true,
          mediaPlaybackRequiresUserGesture: false,
          userAgent:
              'Mozilla/5.0 (Linux; Android 10; Mobile; rv:68.0) Gecko/68.0 Firefox/68.0',
        ),
      ),
      // onWebViewCreated: (InAppWebViewController controller) {
      //   controller.addJavaScriptHandler(
      //     handlerName: 'goBack',
      //     callback: (args) {
      //       Navigator.pop(context);
      //     },
      //   );
      // },
    ),
    
    // Positioned(
    //   top: 40.0,
    //   left: 20.0,
    //   child: GestureDetector(
    //     onTap: () {
    //       Navigator.pop(context);
    //     },
    //     child: Container(
    //       width: 45,
    //       height: 45,
    //       decoration: BoxDecoration(
    //         color: Colors.white,
    //         shape: BoxShape.circle,
    //       ),
    //       child: Center(
    //         child: Icon(
    //           CupertinoIcons.back,
    //           color: Colors.black,
    //           size: 25,
    //         ),
    //       ),
    //     ),
    //   ),
    // ),
  ],
)
 
                  );
 
 
  }
}
