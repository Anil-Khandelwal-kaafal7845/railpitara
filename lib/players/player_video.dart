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

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  Widget build(BuildContext context) {
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
          ? Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: Uri.parse('https://unvii-player.web.app/app/${widget.videoUrl}'),
            ),
            onLoadStop: (controller, url) {
              controller.evaluateJavascript(source: '''
                    document.getElementById('backButton').addEventListener('click', () => {
                      if (!window.flutter_inappwebview.backButtonClicked) {
                        window.flutter_inappwebview.backButtonClicked = true;
                        window.flutter_inappwebview.callHandler('goBack');
                      }
                    });
                  ''');
            },
            onWebViewCreated: (InAppWebViewController controller) {
              controller.addJavaScriptHandler(handlerName: 'goBack', callback: (args) {
                Navigator.pop(context);
              });
            },
            onConsoleMessage: (controller, consoleMessage) {
              print("Console message: ${consoleMessage.message}");
            },
            onLoadError: (controller, url, code, message) {
              print("Load error: $message");
            },
            onProgressChanged: (controller, progress) {
              print("Loading progress: $progress%");
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
          disableVerticalScroll: true,
          disableHorizontalScroll: true,
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

    
    );
  }
}