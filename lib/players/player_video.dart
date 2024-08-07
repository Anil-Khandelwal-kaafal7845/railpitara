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
    print("sourabh ${widget.playType}");
    print("sourabh ${widget.trailerUrlVideoId}");
    print("sourabh ${widget.trailerLibraryId}");
    print("sourabh ${widget.videoLibraryId}");
    print("anilk ${widget.videoUrlId}");


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
      ),
    );
  }
}








// import 'dart:io';

// import 'package:chewie/chewie.dart';
// import 'package:dtlive/provider/playerprovider.dart';
// import 'package:dtlive/utils/color.dart';
// import 'package:dtlive/utils/constant.dart';
// import 'package:dtlive/utils/strings.dart';
// import 'package:dtlive/utils/utils.dart';
// import 'package:dtlive/widget/mytext.dart';
// import 'package:floating/floating.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
// import 'package:video_player/video_player.dart';

// class PlayerVideo extends StatefulWidget {
//   final int? videoId, videoType, typeId, otherId, stopTime;
//   final String? playType, videoUrl, vUploadType, videoThumb;
//   const PlayerVideo(
//       this.playType,
//       this.videoId,
//       this.videoType,
//       this.typeId,
//       this.otherId,
//       this.videoUrl,
//       this.stopTime,
//       this.vUploadType,
//       this.videoThumb,
//       {Key? key})
//       : super(key: key);

//   @override
//   State<PlayerVideo> createState() => _PlayerVideoState();
// }

// class _PlayerVideoState extends State<PlayerVideo> with WidgetsBindingObserver {
//   // final _noScreenshot = NoScreenshot.instance;
//   late PlayerProvider playerProvider;
//   int? playerCPosition, videoDuration;
//   ChewieController? _chewieController;
//   late VideoPlayerController _videoPlayerController;
//   SubtitleController? subtitleController;
//   bool isInPiPMode = false;

//   late Floating pip; // Initializing a variable to handle PiP functionalities
//   bool isPipAvailable = false; // Variable to track PiP availability status

//   void _updatePiPMode(bool isPiPMode) {
//     setState(() {
//       isInPiPMode = isPiPMode;
//     });
//   }

//   @override
//   void initState() {
//     WidgetsBinding.instance.addObserver(
//         this); // Registering this class as an observer for app lifecycle changes
//     pip =
//         Floating(); // Instantiating the "Floating" instance to manage PiP functionality
//     _checkPiPAvailability();
//     restrictScreenRecordingandScreenshot();
//     // Keep the screen on.
//     debugPrint("videoUrl ========> ${widget.videoUrl}");
//     debugPrint("vUploadType ========> ${widget.vUploadType}");
//     playerProvider = Provider.of<PlayerProvider>(context, listen: false);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _playerInit();
//     });
//     super.initState();
//   }

//   // Method to verify the availability of PiP feature asynchronously
//   _checkPiPAvailability() async {
//     isPipAvailable = await pip
//         .isPipAvailable; // Checking if PiP mode is available on the device
//     setState(
//         () {}); // Triggering a UI update based on the PiP availability status
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // log(" CYCLEC${state.name}");
//     // log(" CYCLEC${state}");
//     // Listening to app lifecycle changes to detect when the app enters the hidden state (minimized)
//     if (state == AppLifecycleState.inactive) {
//       // Triggering PiP mode with a landscape aspect ratio when the app is minimized
//       pip.enable(aspectRatio: const Rational.landscape());
//     } else if (state == AppLifecycleState.paused ||
//         state == AppLifecycleState.hidden) {
//       SystemNavigator.pop();
//     }
//   }

//   _playerInit() async {
//     debugPrint("sSubTitleUrls Length =======> ${Constant.subtitleUrls.length}");

//     /* Subtitles & Quality */
//     if (!kIsWeb) {
//       _loadSubtitle();
//       if (widget.playType == "Video" || widget.playType != "Show") {
//         if (Constant.resolutionsUrls.isNotEmpty) {
//           await playerProvider
//               .setCurrentQuality(Constant.resolutionsUrls[0].qualityName);
//         }
//       } else {
//         Constant.resolutionsUrls.clear();
//         Constant.resolutionsUrls = [];
//       }
//     }
//     /* *********/

//     VideoPlayerController videoPlayerController;
//     if (widget.playType == "Download") {
//       videoPlayerController =
//           VideoPlayerController.file(File(widget.videoUrl ?? ""));
//     } else {
//       if (widget.playType == "Video" || widget.playType != "Show") {
//         if (Constant.resolutionsUrls.isNotEmpty) {
//           videoPlayerController = VideoPlayerController.networkUrl(
//             Uri.parse(Constant.resolutionsUrls[0].qualityUrl),
//           );
//         } else {
//           videoPlayerController = VideoPlayerController.networkUrl(
//             Uri.parse(widget.videoUrl ?? ""),
//           );
//         }
//       } else {
//         videoPlayerController = VideoPlayerController.networkUrl(
//           Uri.parse(widget.videoUrl ?? ""),
//         );
//       }
//     }
//     await Future.wait([videoPlayerController.initialize()]).then((value) async {
//       if (mounted) {
//         setState(() {
//           _videoPlayerController = videoPlayerController;

//           /* Chewie Controller */
//           if (widget.playType == "Video" || widget.playType != "Show") {
//             _setupController(
//                 startAt: Duration(milliseconds: widget.stopTime ?? 0));
//           } else {
//             _setupController(startAt: Duration.zero);
//           }
//         });
//       }
//     });

//     Future.delayed(Duration.zero).then((value) {
//       if (!mounted) return;
//       setState(() {});
//     });

//     if (widget.playType == "Video" || widget.playType != "Show") {
//       /* Add Video view */
//       playerProvider.addVideoView(widget.videoId.toString(),
//           widget.videoType.toString(), widget.otherId.toString());
//     }
//   }

//   Future<void> _loadSubtitle() async {
//     if (Constant.subtitleUrls.isNotEmpty) {
//       await playerProvider
//           .setCurrentSubtitle(Constant.subtitleUrls[0].subtitleLang);
//       debugPrint(
//           "Current subtitleUrl ============> ${Constant.subtitleUrls[0].subtitleUrl}");
//       subtitleController = SubtitleController(
//         subtitleUrl: Constant.subtitleUrls[0].subtitleUrl,
//         subtitleType: SubtitleType.srt,
//         showSubtitles: true,
//       );
//     }
//   }

//   _setupController({required Duration startAt}) async {
//     _chewieController = ChewieController(
//       videoPlayerController: _videoPlayerController,
//       startAt: startAt,
//       autoPlay: true,
//       autoInitialize: true,
//       looping: false,
//       fullScreenByDefault: true,
//       allowFullScreen: true,
//       hideControlsTimer: const Duration(seconds: 1),
//       showControls: true,
//       allowedScreenSleep: false,
//       zoomAndPan: true,
//       transformationController: TransformationController(),
//       additionalOptions: (context) {
//         return <OptionItem>[
//           if (!kIsWeb && Constant.subtitleUrls.isNotEmpty)
//             OptionItem(
//               onTap: () {
//                 // Navigator.pop(context);
//                 subtitleDialog();
//               },
//               iconData: Icons.subtitles,
//               title: 'Subtitles',
//             ),
//           if (Constant.resolutionsUrls.isNotEmpty)
//             OptionItem(
//               onTap: () {
//                 // Navigator.pop(context);
//                 qualityDialog();
//               },
//               iconData: Icons.video_collection_rounded,
//               title: 'Quality',
//             ),
//         ];
//       },
//       deviceOrientationsOnEnterFullScreen: [
//         DeviceOrientation.landscapeLeft,
//         DeviceOrientation.landscapeRight,
//       ],
//       deviceOrientationsAfterFullScreen: [
//         (kIsWeb || Constant.isTV)
//             ? DeviceOrientation.landscapeLeft
//             : DeviceOrientation.portraitUp,
//         (kIsWeb || Constant.isTV)
//             ? DeviceOrientation.landscapeRight
//             : DeviceOrientation.portraitDown,
//       ],
//       cupertinoProgressColors: ChewieProgressColors(
//         playedColor: colorPrimary,
//         handleColor: complimentryColor,
//         backgroundColor: grayDark,
//         bufferedColor: whiteTransparent,
//       ),
//       materialProgressColors: ChewieProgressColors(
//         playedColor: colorPrimary,
//         handleColor: complimentryColor,
//         backgroundColor: grayDark,
//         bufferedColor: whiteTransparent,
//       ),
//       errorBuilder: (context, errorMessage) {
//         return Center(
//           child: MyText(
//             color: white,
//             text: errorMessage,
//             textalign: TextAlign.center,
//             fontsizeNormal: 14,
//             fontweight: FontWeight.w600,
//             fontsizeWeb: 16,
//             multilanguage: false,
//             maxline: 1,
//             overflow: TextOverflow.ellipsis,
//             fontstyle: FontStyle.normal,
//           ),
//         );
//       },
//     );
//     _videoPlayerController.addListener(() {
//       playerCPosition =
//           (_chewieController?.videoPlayerController.value.position)
//                   ?.inMilliseconds ??
//               0;
//       videoDuration = (_chewieController?.videoPlayerController.value.duration)
//               ?.inMilliseconds ??
//           0;
//       // debugPrint("playerCPosition :===> $playerCPosition");
//       // debugPrint("videoDuration :=====> $videoDuration");
//     });
//     Future.delayed(Duration.zero).then((value) {
//       if (!mounted) return;
//       setState(() {});
//     });
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     allowScreenRecordingandScreenshot();
//     // KeepScreenOn.turnOff();
//     if (_chewieController != null) {
//       subtitleController?.detach();
//       _chewieController?.removeListener(() {});
//       _chewieController?.videoPlayerController.dispose();
//     }
//     if (!(kIsWeb) || !(Constant.isTV)) {
//       SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//     }
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: SystemUiOverlay.values);
//     playerProvider.clearProvider();
//     pip.dispose();
//     super.dispose();
//   }

//   void updateSubtitleUrl({required String subtitleUrl}) {
//     debugPrint("new subtitleUrl ============> $subtitleUrl");
//     if (subtitleController != null) {
//       subtitleController?.updateSubtitleUrl(
//         url: subtitleUrl,
//       );
//     }
//   }

//   void updateQualityUrl({
//     required String qualityName,
//     required String qualityUrl,
//   }) async {
//     debugPrint("new qualityUrl ============> $qualityUrl");
//     debugPrint("new qualityName ===========> $qualityName");
//     debugPrint("currentQuality ============> ${playerProvider.currentQuality}");
//     playerCPosition = (_chewieController?.videoPlayerController.value.position)
//             ?.inMilliseconds ??
//         0;
//     videoDuration = (_chewieController?.videoPlayerController.value.duration)
//             ?.inMilliseconds ??
//         0;
//     debugPrint("playerCPosition ============> $playerCPosition");
//     debugPrint("videoDuration ==============> $videoDuration");

//     if (_chewieController != null &&
//         playerProvider.currentQuality != qualityName) {
//       final videoPlayerController = VideoPlayerController.networkUrl(
//         Uri.parse(qualityUrl),
//       );
//       await Future.wait([videoPlayerController.initialize()])
//           .then((value) async {
//         if (mounted) {
//           await playerProvider.setCurrentQuality(qualityName);
//           _videoPlayerController.dispose();
//           _videoPlayerController = videoPlayerController;
//           _chewieController?.dispose();
//           _setupController(
//               startAt: Duration(milliseconds: playerCPosition ?? 0));
//           Future.delayed(Duration.zero).then((value) {
//             if (!mounted) return;
//             setState(() {});
//           });
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: onBackPressed,
//       child: PiPSwitcher(
//         // Widget displayed when PiP is disabled or app is in foreground state
//         childWhenDisabled: Scaffold(
//           backgroundColor: black,
//           body: SafeArea(
//             child: Stack(
//               children: [
//                 // Show back button only when not in PiP mode
//                 if (!isInPiPMode && !kIsWeb)
//                   Positioned(
//                     top: 15,
//                     left: 15,
//                     child: SafeArea(
//                       child: CupertinoButton(
//                         padding: EdgeInsets.zero,
//                         onPressed: onBackPressed,
//                         child: Icon(
//                           CupertinoIcons.back,
//                           color: Colors.white,
//                           size: 30,
//                         ),
//                       ),
//                     ),
//                   ),
//                 Center(
//                   child: _buildPage(),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         // Widget displayed when PiP window is enabled or app is in background state
//         childWhenEnabled: Scaffold(
//           body: Center(
//             child: Stack(
//               children: [
//                 // Show back button only when not in PiP mode
//                 if (!isInPiPMode && !kIsWeb)
//                   Positioned(
//                     top: 15,
//                     left: 15,
//                     child: SafeArea(
//                       child: CupertinoButton(
//                         padding: EdgeInsets.zero,
//                         onPressed: onBackPressed,
//                         child: Icon(
//                           CupertinoIcons.back,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 _buildPage(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   return WillPopScope(
//   //       onWillPop: onBackPressed,
//   //       child: PiPSwitcher(

//   //           // Widget displayed when PiP is disabled or app is in foreground state
//   //           childWhenDisabled: Scaffold(
//   //             backgroundColor: black,
//   //             body: SafeArea(
//   //               child: Stack(
//   //                 children: [
//   //                   Center(
//   //                     child: _buildPage(),
//   //                   ),
//   //                 ],
//   //               ),
//   //             ),
//   //           ),
//   //           childWhenEnabled: Scaffold(
//   //             body: Center(child: _buildPage()),
//   //           )));
//   // }

//   Widget _buildPage() {
//     if (_chewieController != null &&
//         _chewieController?.videoPlayerController.value != null &&
//         _chewieController!.videoPlayerController.value.isInitialized) {
//       if (kIsWeb) {
//         return _buildPlayer();
//       } else {
//         if (subtitleController != null) {
//           debugPrint("==================== With SUBTITLE ====================");
//           return SubtitleWrapper(
//             videoPlayerController: _chewieController!.videoPlayerController,
//             subtitleController: subtitleController!,
//             subtitleStyle: const SubtitleStyle(
//               textColor: Colors.white,
//               hasBorder: true,
//             ),
//             videoChild: _buildPlayer(),
//           );
//         } else {
//           debugPrint("================== Without SUBTITLE ==================");
//           return _buildPlayer();
//         }
//       }
//     } else {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             height: 70,
//             width: 70,
//             child: Utils.pageLoader(),
//           ),
//           const SizedBox(height: 20),
//           MyText(
//             color: white,
//             text: loading,
//             textalign: TextAlign.center,
//             fontsizeNormal: 14,
//             fontweight: FontWeight.w600,
//             fontsizeWeb: 16,
//             multilanguage: false,
//             maxline: 1,
//             overflow: TextOverflow.ellipsis,
//             fontstyle: FontStyle.normal,
//           ),
//         ],
//       );
//     }
//   }

//   Widget _buildPlayer() {
//     return AspectRatio(
//       aspectRatio: _chewieController?.aspectRatio ??
//           (_chewieController?.videoPlayerController.value.aspectRatio ??
//               16 / 9),
//       child: Chewie(
//         controller: _chewieController!,
//       ),
//     );
//   }

//   Future<void> subtitleDialog() async {
//     await showCupertinoModalPopup<void>(
//       context: context,
//       semanticsDismissible: true,
//       useRootNavigator: true,
//       builder: (context) {
//         return CupertinoActionSheet(
//           actions: Constant.subtitleUrls
//               .map(
//                 (option) => CupertinoActionSheetAction(
//                   onPressed: () async {
//                     await playerProvider
//                         .setCurrentSubtitle(option.subtitleLang);
//                     updateSubtitleUrl(subtitleUrl: option.subtitleUrl);
//                     if (!mounted) return;
//                     Navigator.pop(context);
//                     Navigator.pop(context);
//                   },
//                   child: Text(
//                     option.subtitleLang,
//                     textAlign: TextAlign.center,
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                     style: GoogleFonts.montserrat(
//                       fontSize: 15,
//                       fontStyle: FontStyle.normal,
//                       color: (playerProvider.currentSubtitle ==
//                               option.subtitleLang)
//                           ? black
//                           : black.withOpacity(0.5),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               )
//               .toList(),
//           cancelButton: CupertinoActionSheetAction(
//             onPressed: () => Navigator.pop(context),
//             isDestructiveAction: true,
//             child: Text(
//               "Cancel",
//               textAlign: TextAlign.center,
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//               style: GoogleFonts.montserrat(
//                 fontSize: 15,
//                 fontStyle: FontStyle.normal,
//                 color: redColor,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         );
//       },
//     ).then((value) {
//       debugPrint("============= SUBTITLE =============");
//       if (!mounted) return;
//       setState(() {});
//     });
//   }

//   Future<void> qualityDialog() async {
//     await showCupertinoModalPopup<void>(
//       context: context,
//       semanticsDismissible: true,
//       useRootNavigator: true,
//       builder: (context) {
//         return CupertinoActionSheet(
//           actions: Constant.resolutionsUrls
//               .map(
//                 (option) => CupertinoActionSheetAction(
//                   onPressed: () async {
//                     updateQualityUrl(
//                       qualityName: option.qualityName,
//                       qualityUrl: option.qualityUrl,
//                     );
//                     if (!mounted) return;
//                     Navigator.pop(context);
//                     Navigator.pop(context);
//                   },
//                   child: Text(
//                     option.qualityName,
//                     textAlign: TextAlign.center,
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                     style: GoogleFonts.montserrat(
//                       fontSize: 15,
//                       fontStyle: FontStyle.normal,
//                       color:
//                           (playerProvider.currentQuality == option.qualityName)
//                               ? black
//                               : black.withOpacity(0.5),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               )
//               .toList(),
//           cancelButton: CupertinoActionSheetAction(
//             onPressed: () => Navigator.pop(context),
//             isDestructiveAction: true,
//             child: Text(
//               "Cancel",
//               textAlign: TextAlign.center,
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//               style: GoogleFonts.montserrat(
//                 fontSize: 15,
//                 fontStyle: FontStyle.normal,
//                 color: redColor,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         );
//       },
//     ).then((value) {
//       debugPrint("============= QUALITY =============");
//       if (!mounted) return;
//       setState(() {});
//     });
//   }

//   Future<bool> onBackPressed() async {
//     if (!(kIsWeb) || !(Constant.isTV)) {
//       SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//     }
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: SystemUiOverlay.values);
//     debugPrint("onBackPressed playerCPosition :===> $playerCPosition");
//     debugPrint("onBackPressed videoDuration :===> $videoDuration");
//     debugPrint("onBackPressed playType :===> ${widget.playType}");

//     if (widget.playType == "Video" || widget.playType == "Show") {
//       if ((playerCPosition ?? 0) > 0 &&
//           (playerCPosition == videoDuration ||
//               (playerCPosition ?? 0) > (videoDuration ?? 0))) {
//         /* Remove From Continue */
//         await playerProvider.removeFromContinue(
//             "${widget.videoId}", "${widget.videoType}");
//         if (!mounted) return Future.value(false);
//         Navigator.pop(context, true);
//         return Future.value(true);
//       } else if ((playerCPosition ?? 0) > 0) {
//         /* Add to Continue */
//         await playerProvider.addToContinue(
//             "${widget.videoId}", "${widget.videoType}", "$playerCPosition");
//         if (!mounted) return Future.value(false);
//         Navigator.pop(context, true);
//         return Future.value(true);
//       } else {
//         if (!mounted) return Future.value(false);
//         Navigator.pop(context, false);
//         return Future.value(true);
//       }
//     } else {
//       if (!mounted) return Future.value(false);
//       Navigator.pop(context, false);
//       return Future.value(true);
//     }
//   }
// }
