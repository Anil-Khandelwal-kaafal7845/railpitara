import 'package:dtlive/main.dart';
import 'package:dtlive/pages/pip_web_player.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PlayerVideo extends StatefulWidget {
  final int? videoId, videoType, typeId, otherId, stopTime;
  final String? playType, videoUrl, vUploadType, videoThumb;
  final dynamic trailerLibraryId, trailerUrlVideoId, videoLibraryId, videoUrlId, isLive;

  PlayerVideo(
      this.playType,
      this.videoId,
      this.videoType,
      this.typeId,
      this.otherId,
      this.videoUrl,
      this.stopTime,
      this.vUploadType,
      this.videoThumb,
      {Key? key, this.isLive,
        this.trailerLibraryId, this.videoLibraryId, this.trailerUrlVideoId, this.videoUrlId
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
                border: 0;
              }

              #backButton {
                position: absolute;
                top: 15px;
                left: 15px;
                line-height: 60px;
                z-index: 1000;
                cursor: pointer;
              }
            </style>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          </head>
          <body>
            <iframe
              src="https://iframe.mediadelivery.net/embed/${widget.trailerLibraryId}/${widget.trailerUrlVideoId}?autoplay=true&loop=false&muted=false&preload=true&responsive=true"
              allow="accelerometer;gyroscope;autoplay;encrypted-media;picture-in-picture;"
              allowfullscreen="true">
            </iframe>
            <script>
              document.getElementById('backButton').addEventListener('click', () => {
                if (!window.flutter_inappwebview.backButtonClicked) {
                  window.flutter_inappwebview.backButtonClicked = true;
                  window.flutter_inappwebview.callHandler('goBack');
                }
              });

              document.addEventListener("fullscreenchange", function () {
                if (document.fullscreenElement) {
                  document.getElementById("backButton").style.display = "none";
                } else {
                  document.getElementById("backButton").style.display = "block";
                }
              });
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
          userAgent: 'Mozilla/5.0 (Linux; Android 10; Mobile; rv:68.0) Gecko/68.0 Firefox/68.0',
        ),
      ),
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
    color: Colors.white, // Background color of the container
    shape: BoxShape.circle, // Makes the container circular
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
          ?  TestPlayerWeb(loadURL: widget.videoUrl ?? '') : 
          
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
                overflow: hidden;
                height: 100%;
                background-color: black;
              }

              iframe {
                display: block;
                width: 100%;
                height: 100%;
                border: 0;
              }

              #backButton {
                position: absolute;
                top: 15px;
                left: 15px;
                line-height: 60px;
                z-index: 1000;
                cursor: pointer;
              }
            </style>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          </head>
          <body>
            <iframe
              src="https://iframe.mediadelivery.net/embed/${widget.videoLibraryId}/${widget.videoUrlId}?autoplay=true&loop=false&muted=false&preload=true&responsive=true"
              allow="accelerometer;gyroscope;autoplay;encrypted-media;picture-in-picture;"
              allowfullscreen="true">
            </iframe>
            <script>
              document.getElementById('backButton').addEventListener('click', () => {
                if (!window.flutter_inappwebview.backButtonClicked) {
                  window.flutter_inappwebview.backButtonClicked = true;
                  window.flutter_inappwebview.callHandler('goBack');
                }
              });

              document.addEventListener("fullscreenchange", function () {
                if (document.fullscreenElement) {
                  document.getElementById("backButton").style.display = "none";
                } else {
                  document.getElementById("backButton").style.display = "block";
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
          userAgent: 'Mozilla/5.0 (Linux; Android 10; Mobile; rv:68.0) Gecko/68.0 Firefox/68.0',
        ),
      ),
      onWebViewCreated: (InAppWebViewController controller) {
        controller.addJavaScriptHandler(handlerName: 'goBack', callback: (args) {
          Navigator.pop(context);
        });
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
        child:Container(
  width: 45, // Diameter of the circle
  height: 45, // Diameter of the circle
  decoration: BoxDecoration(
    color: Colors.white, // Background color of the container
    shape: BoxShape.circle, // Makes the container circular
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

    
    );
  }
}