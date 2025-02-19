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
  final ValueNotifier<bool> isFullScreen = ValueNotifier(false);
  late InAppWebViewController webViewController;

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
                width: 100%;
                height: 100%;
                background-color: black;
                display: flex;
                justify-content: center;
                align-items: center;
              }

              iframe {
                width: 100vw;
                height: 100vh;
                border: none;
              }
            </style>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          </head>
          <body>
            <iframe
              id="videoFrame"
              src="https://chull.tv/unviiplayer.html?url=${widget.trailerUrl}&autoplay=true&loop=false&muted=false&preload=true&responsive=true"
              allow="accelerometer;gyroscope;autoplay;encrypted-media;picture-in-picture"
              allowfullscreen>
            </iframe>

            <script>
              const videoFrame = document.getElementById("videoFrame");

              // Resize iframe correctly
              function adjustIframeSize() {
                videoFrame.style.width = window.innerWidth + "px";
                videoFrame.style.height = window.innerHeight + "px";
              }

              window.addEventListener("resize", adjustIframeSize);
              adjustIframeSize();
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
                  ),

                  // Flutter Back Button (Only in Normal Mode)
                  Positioned(
                    top: 40.0,
                    left: 20.0,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: isFullScreen,
                      builder: (context, fullScreen, child) {
                        return fullScreen
                            ? SizedBox() // Hide back button in fullscreen
                            : GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      CupertinoIcons.back,
                                      color: Colors.black,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              );
                      },
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
            <style>
              html, body {
                margin: 0;
                padding: 0;
                overflow: hidden;
                width: 100%;
                height: 100%;
                background-color: black;
                display: flex;
                justify-content: center;
                align-items: center;
              }

              iframe {
                width: 100vw;
                height: 100vh;
                border: none;
              }
            </style>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          </head>
          <body>
            <iframe
              id="videoFrame"
              src="https://chull.tv/unviiplayer.html?url=${widget.videoUrl}&autoplay=true&loop=false&muted=false&preload=true&responsive=true"
              allow="accelerometer;gyroscope;autoplay;encrypted-media;picture-in-picture"
              allowfullscreen>
            </iframe>

            <script>
              const videoFrame = document.getElementById("videoFrame");

              // Resize iframe correctly
              function adjustIframeSize() {
                videoFrame.style.width = window.innerWidth + "px";
                videoFrame.style.height = window.innerHeight + "px";
              }

              window.addEventListener("resize", adjustIframeSize);
              adjustIframeSize();
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
                      ),

                      // Flutter Back Button (Only in Normal Mode)
                      Positioned(
                        top: 40.0,
                        left: 20.0,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isFullScreen,
                          builder: (context, fullScreen, child) {
                            return fullScreen
                                ? SizedBox() // Hide back button in fullscreen
                                : GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      width: 45,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          CupertinoIcons.back,
                                          color: Colors.black,
                                          size: 25,
                                        ),
                                      ),
                                    ),
                                  );
                          },
                        ),
                      ),
                    ],
                  ));
  }
}
