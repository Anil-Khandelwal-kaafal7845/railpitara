import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:dtlive/main.dart';
import 'package:dtlive/model/coinrentmodel.dart';
import 'package:dtlive/model/sectionlistmodel.dart';
import 'package:dtlive/pages/coinstorescreen.dart';
import 'package:dtlive/pages/mydownloads.dart';
import 'package:dtlive/pages/successScreen.dart';
import 'package:dtlive/provider/generalprovider.dart';
import 'package:dtlive/provider/userwallectProvider.dart';
import 'package:dtlive/provider/videodownloadprovider.dart';
import 'package:dtlive/provider/homeprovider.dart';
import 'package:dtlive/shimmer/shimmerutils.dart';
import 'package:dtlive/utils/adhelper.dart';
import 'package:dtlive/utils/sharedpre.dart';
import 'package:dtlive/webwidget/footerweb.dart';
import 'package:dtlive/widget/animatedgif.dart';
import 'package:dtlive/widget/castcrew.dart';
import 'package:dtlive/widget/moredetails.dart';
import 'package:dtlive/widget/myusernetworkimg.dart';
import 'package:dtlive/widget/relatedvideoshow.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:dtlive/model/sectiondetailmodel.dart';
import 'package:dtlive/pages/castdetails.dart';
import 'package:dtlive/pages/loginsocial.dart';
import 'package:dtlive/subscription/subscription.dart';
import 'package:dtlive/utils/dimens.dart';
import 'package:dtlive/widget/nodata.dart';
import 'package:dtlive/provider/videodetailsprovider.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/widget/myimage.dart';
import 'package:dtlive/widget/mytext.dart';
import 'package:dtlive/utils/strings.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/widget/mynetworkimg.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:singular_flutter_sdk/singular.dart';
import 'package:social_share/social_share.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../model/force_update_model.dart';

class MovieDetails extends StatefulWidget {
  final int videoId, upcomingType, videoType, typeId;
  const MovieDetails(
      this.videoId, this.upcomingType, this.videoType, this.typeId,
      {Key? key})
      : super(key: key);

  @override
  State<MovieDetails> createState() => MovieDetailsState();
}

class MovieDetailsState extends State<MovieDetails> with RouteAware {
  /* Trailer init */
  VideoPlayerController? _trailerNormalController;
  YoutubePlayerController? _trailerYoutubeController;
  static SharedPre sharePref = SharedPre();

  /* Download init */
  late VideoDownloadProvider downloadProvider;
  // late bool _permissionReady;
  final ReceivePort _port = ReceivePort();
  ForceUpdatemodel? forceUpdateData;

  String? audioLanguages;
  List<Cast>? directorList;
  late VideoDetailsProvider videoDetailsProvider;
  late HomeProvider homeProvider;
  late GeneralProvider generalProvider;
  late WalletProvider walletProvider;
  Map<String, String> qualityUrlList = <String, String>{};
  late DateTime startTime;
  static var rewardad = "";
  static var rewardadIos = "";
  @override
  void initState() {
    print("Rewarded Ad loading...");
    AdHelper.createRewardedAd();
    print("Rewarded Ad loaded!");

    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    print("HEY>>>>>>>>>>>>>>");
    startTime = DateTime.now();
    if (!kIsWeb) {
      /* Download init ****/
      _bindBackgroundIsolate();
      FlutterDownloader.registerCallback(downloadCallback, step: 1);
      /* ****/
    }

    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    videoDetailsProvider =
        Provider.of<VideoDetailsProvider>(context, listen: false);
    downloadProvider =
        Provider.of<VideoDownloadProvider>(context, listen: false);
    super.initState();
    debugPrint("initState videoId ==> ${widget.videoId}");
    debugPrint("initState videoType ==> ${widget.videoType}");
    debugPrint("initState typeId ==> ${widget.typeId}");
    _getData();
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    super.didChangeDependencies();
  }

  /// Called when the current route has been popped off.
  @override
  void didPop() {
    debugPrint("didPop");
    super.didPop();
  }

  void _fetchDataAgain() async {
    homeProvider.fetchUserWalletBalance(Constant.userID ?? "");
    await AdHelper.createRewardedAd();
    _getData();
    setState(() {});
  }

  /// Called when the top route has been popped off, and the current route
  /// shows up.
  @override
  void didPopNext() {
    _fetchDataAgain();

    // debugPrint("didPopNext");
    // if (videoDetailsProvider.sectionDetailModel.result?.trailerType ==
    //     "youtube") {
    //   if (_trailerYoutubeController == null) {
    //     loadTrailer(
    //         videoDetailsProvider.sectionDetailModel.result?.trailerUrl ?? "",
    //         videoDetailsProvider.sectionDetailModel.result?.trailerType ?? "");
    //   } else {
    //     if (_trailerYoutubeController != null) {
    //       _trailerYoutubeController?.seekTo(seconds: 0.0);
    //       _trailerYoutubeController?.playVideo();
    //     }
    //   }
    // } else {
    //   if (_trailerNormalController == null) {
    //     loadTrailer(
    //         videoDetailsProvider.sectionDetailModel.result?.trailerUrl ?? "",
    //         videoDetailsProvider.sectionDetailModel.result?.trailerType ?? "");
    //   } else {
    //     if (_trailerNormalController != null) {
    //       _trailerNormalController?.play();
    //     }
    //   }
    // }
    super.didPopNext();
  }

  /// Called when the current route has been pushed.
  @override
  void didPush() {
    debugPrint("didPush");
    super.didPush();
  }

  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  @override
  void didPushNext() {
    debugPrint("didPushNext");
    if (_trailerYoutubeController != null) {
      _trailerYoutubeController?.close();
      _trailerYoutubeController = null;
    }
    if (_trailerNormalController != null) {
      _trailerNormalController?.dispose();
      _trailerNormalController = null;
    }
    super.didPushNext();
  }

  _getData() async {
    Utils.getCurrencySymbol();
    //      rewardad = await sharePref.read("reward_ad") ?? "";
    // rewardadIos = await sharePref.read("ios_reward_ad") ?? "";
    //    debugPrint("AD ==> ${rewardad}");
    // debugPrint("AD ==> ${rewardadIos}");
    await videoDetailsProvider.getSectionDetails(
        widget.typeId, widget.videoType, widget.videoId, widget.upcomingType);
    await generalProvider.getGeneralsetting(context);

    if (videoDetailsProvider.sectionDetailModel.status == 200) {
      if (videoDetailsProvider.sectionDetailModel.result != null) {
        /* Trailer set-up */
        // _setUpTrailer();

        /* Set-up Subtitle URLs */
        Utils.setSubtitleURLs(
          subtitleUrl1:
              (videoDetailsProvider.sectionDetailModel.result?.subtitle1 ?? ""),
          subtitleUrl2:
              (videoDetailsProvider.sectionDetailModel.result?.subtitle2 ?? ""),
          subtitleUrl3:
              (videoDetailsProvider.sectionDetailModel.result?.subtitle3 ?? ""),
          subtitleLang1:
              (videoDetailsProvider.sectionDetailModel.result?.subtitleLang1 ??
                  ""),
          subtitleLang2:
              (videoDetailsProvider.sectionDetailModel.result?.subtitleLang2 ??
                  ""),
          subtitleLang3:
              (videoDetailsProvider.sectionDetailModel.result?.subtitleLang3 ??
                  ""),
        );
      }
    }

    Future.delayed(Duration.zero).then((value) async {
      if (!mounted) return;
      rewardad = await sharePref.read("reward_ad") ?? "";
      rewardadIos = await sharePref.read("ios_reward_ad") ?? "";
      debugPrint("AD ==> ${rewardad}");
      debugPrint("AD ==> ${rewardadIos}");
      Utils.loadAds(context);
      setState(() {});
    });
  }

  // /* Trailer Set-Up & Loading START */
  // _setUpTrailer() {
  //   debugPrint(
  //       "trailerUrl ===========> ${videoDetailsProvider.sectionDetailModel.result?.trailerUrl}");
  //   debugPrint(
  //       "trailerType ==========> ${videoDetailsProvider.sectionDetailModel.result?.trailerType}");
  //   if (videoDetailsProvider.sectionDetailModel.result?.trailerUrl != null ||
  //       videoDetailsProvider.sectionDetailModel.result?.trailerUrl != "") {
  //     if (videoDetailsProvider.sectionDetailModel.result?.trailerType ==
  //         "youtube") {
  //       if (_trailerYoutubeController == null) {
  //         loadTrailer(
  //             videoDetailsProvider.sectionDetailModel.result?.trailerUrl ?? "",
  //             videoDetailsProvider.sectionDetailModel.result?.trailerType ??
  //                 "");
  //       } else {
  //         _trailerYoutubeController?.seekTo(seconds: 0.0);
  //       }
  //     } else {
  //       if (_trailerNormalController == null) {
  //         loadTrailer(
  //             videoDetailsProvider.sectionDetailModel.result?.trailerUrl ?? "",
  //             videoDetailsProvider.sectionDetailModel.result?.trailerType ??
  //                 "");
  //       } else {
  //         _trailerNormalController?.seekTo(Duration.zero);
  //       }
  //     }
  //   }
  // }

  // Future<void> loadTrailer(trailerUrl, trailerType) async {
  //   debugPrint("loadTrailer URL ==========> $trailerUrl");
  //   debugPrint("loadTrailer Type =========> $trailerType");
  //   if (trailerType == "youtube") {
  //     var videoId = YoutubePlayerController.convertUrlToId(trailerUrl ?? "");
  //     debugPrint("Youtube Trailer videoId :====> $videoId");
  //     _trailerYoutubeController = YoutubePlayerController.fromVideoId(
  //       videoId: videoId ?? '',
  //       autoPlay: true,
  //       params: const YoutubePlayerParams(
  //         showControls: false,
  //         showVideoAnnotations: false,
  //         playsInline: false,
  //         mute: false,
  //         showFullscreenButton: false,
  //         loop: false,
  //       ),
  //     );
  //     _trailerYoutubeController?.playVideo();
  //     Future.delayed(Duration.zero).then((value) {
  //       if (!mounted) return;
  //       setState(() {});
  //     });
  //   } else {
  //     _trailerNormalController =
  //         VideoPlayerController.networkUrl(Uri.parse(trailerUrl ?? ""))
  //           ..initialize().then((value) {
  //             if (!mounted) return;
  //             setState(() {
  //               debugPrint(
  //                   "isPlaying =========> ${_trailerNormalController?.value.isPlaying}");
  //               _trailerNormalController?.play();
  //             });
  //           });
  //     _trailerNormalController?.setLooping(true);
  //     _trailerNormalController?.addListener(() async {
  //       if (_trailerNormalController?.value.hasError ?? false) {
  //         debugPrint(
  //             "VideoScreen errorDescription ====> ${_trailerNormalController?.value.errorDescription}");
  //       }
  //     });
  //   }
  // }
  // /* Trailer Set-Up & Loading END */

  void _bindBackgroundIsolate() {
    final isSuccess = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      Constant.videoDownloadPort,
    );
    debugPrint('_bindBackgroundIsolate isSuccess ============> $isSuccess');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      final taskId = (data as List<dynamic>)[0] as String;
      final status = data[1] as int;
      final progress = data[2] as int;

      debugPrint(
        'Callback on UI isolate: '
        'task ($taskId) is in status ($status) and process ($progress)',
      );

      if (downloadProvider.currentTasks != null &&
          downloadProvider.currentTasks!.isNotEmpty) {
        debugPrint(
            'currentTask ============> ${downloadProvider.currentTasks?.length}');
        final task = downloadProvider.currentTasks!
            .firstWhere((task) => task.taskId == taskId);
        debugPrint('task status ============> ${task.status}');
        if (progress > 0) {
          downloadProvider.setDownloadProgress(progress);
        }
        // For Download completed DownloadTaskStatus.complete = 3
        if (status == 3 && progress == 100) {
          Utils.setDownloadComplete(
            context,
            "Video",
            videoDetailsProvider.sectionDetailModel.result?.id,
            videoDetailsProvider.sectionDetailModel.result?.videoType,
            videoDetailsProvider.sectionDetailModel.result?.typeId,
            0,
          );
        }
      }
    });
  }

  void _unbindBackgroundIsolate() {
    debugPrint('_unbindBackgroundIsolate');
    IsolateNameServer.removePortNameMapping(Constant.videoDownloadPort);
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
    String id,
    int status,
    int progress,
  ) {
    debugPrint(
      'Callback on background isolate: '
      'task ($id) is in status ($status) and process ($progress)',
    );

    if (!kIsWeb) {
      IsolateNameServer.lookupPortByName(Constant.videoDownloadPort)
          ?.send([id, status, progress]);
    }
  }

  @override
  void dispose() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    if (!(kIsWeb) || !(Constant.isTV)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    routeObserver.unsubscribe(this);
    debugPrint(
        "dispose isBroadcast ============================> ${_port.isBroadcast}");
    if (!_port.isBroadcast) {
      downloadProvider.clearProvider();
      videoDetailsProvider.clearProvider();
    }
    if (_trailerYoutubeController != null) {
      _trailerYoutubeController?.close();
      _trailerYoutubeController = null;
    }
    if (_trailerNormalController != null) {
      _trailerNormalController?.dispose();
      _trailerNormalController = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    analytics.logEvent(
      name: "screen_view",
      parameters: {
        "screen_name": "Details Screen",
        "user_id": Constant.userID,
      },
    );
    Map<String, Object> screenViewEvent = {
      'screen_name': 'Details Screen',
      'user_id': Constant.userID.toString(),
    };
    Singular.eventWithArgs('screen_view', screenViewEvent);
    if (videoDetailsProvider.sectionDetailModel.status == 200) {
      if (videoDetailsProvider.sectionDetailModel.cast != null &&
          (videoDetailsProvider.sectionDetailModel.cast?.length ?? 0) > 0) {
        directorList = <Cast>[];
        for (int i = 0;
            i < (videoDetailsProvider.sectionDetailModel.cast?.length ?? 0);
            i++) {
          if (videoDetailsProvider.sectionDetailModel.cast?[i].type ==
              "Director") {
            Cast cast = Cast();
            cast.id = videoDetailsProvider.sectionDetailModel.cast?[i].id ?? 0;
            cast.name =
                videoDetailsProvider.sectionDetailModel.cast?[i].name ?? "";
            cast.image =
                videoDetailsProvider.sectionDetailModel.cast?[i].image ?? "";
            cast.type =
                videoDetailsProvider.sectionDetailModel.cast?[i].type ?? "";
            cast.personalInfo =
                videoDetailsProvider.sectionDetailModel.cast?[i].personalInfo ??
                    "";
            cast.status =
                videoDetailsProvider.sectionDetailModel.cast?[i].status ?? 0;
            cast.createdAt =
                videoDetailsProvider.sectionDetailModel.cast?[i].createdAt ??
                    "";
            cast.updatedAt =
                videoDetailsProvider.sectionDetailModel.cast?[i].updatedAt ??
                    "";
            directorList?.add(cast);
            debugPrint("directorList size ===> ${directorList?.length ?? 0}");
          }
        }
      }
      if (videoDetailsProvider.sectionDetailModel.language != null &&
          (videoDetailsProvider.sectionDetailModel.language?.length ?? 0) > 0) {
        for (int i = 0;
            i < (videoDetailsProvider.sectionDetailModel.language?.length ?? 0);
            i++) {
          if (i == 0) {
            audioLanguages =
                videoDetailsProvider.sectionDetailModel.language?[i].name ?? "";
          } else {
            audioLanguages =
                "$audioLanguages, ${videoDetailsProvider.sectionDetailModel.language?[i].name ?? ""}";
          }
        }
      }
    }
    return Scaffold(
      key: widget.key,
      backgroundColor: appBgColor,
      body: SafeArea(
        child: _buildUIWithAppBar(),
      ),
    );
  }

  Widget _buildUIWithAppBar() {
    return (videoDetailsProvider.loading)
        ? SingleChildScrollView(
            child: ((kIsWeb || Constant.isTV) &&
                    MediaQuery.of(context).size.width > 720)
                ? ShimmerUtils.buildDetailWebShimmer(context, "video")
                : ShimmerUtils.buildDetailMobileShimmer(context, "video"),
          )
        : (videoDetailsProvider.sectionDetailModel.status == 200 &&
                videoDetailsProvider.sectionDetailModel.result != null)
            ? (((kIsWeb || Constant.isTV) &&
                    MediaQuery.of(context).size.width > 720)
                ? _buildWebData()
                : _buildMobileData())
            : const NoData(title: '', subTitle: '');
  }

  Widget _buildMobileData() {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints.expand(),
      child: RefreshIndicator(
        backgroundColor: white,
        color: complimentryColor,
        displacement: 80,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 1500))
              .then((value) {
            videoDetailsProvider.setLoading(true);
            Future.delayed(Duration.zero).then((value) {
              if (!mounted) return;
              setState(() {});
            });
            _getData();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              /* Poster */
              _buildMobilePoster(),

              // Platform.isAndroid?
              //   ((videoDetailsProvider.sectionDetailModel.result?.trailerUrl ??
              //               "")
              //           .isNotEmpty)
              //       ? _buildMobilePoster()
              //       : _buildMobilePoster()

              /* Other Details */
              Container(
                transform: Matrix4.translationValues(0, -kToolbarHeight, 0),
                child: Column(
                  children: [
                    /* Small Poster, Main title, ReleaseYear, Duration, Age Restriction, Video Quality */
                    Container(
                      width: MediaQuery.of(context).size.width,
                      constraints: const BoxConstraints(minHeight: 85),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 65,
                            height: 85,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: MyNetworkImage(
                                fit: BoxFit.cover,
                                imgHeight: 85,
                                imgWidth: 65,
                                imageUrl: videoDetailsProvider
                                        .sectionDetailModel.result?.thumbnail ??
                                    "",
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                MyText(
                                  color: white,
                                  text: videoDetailsProvider
                                          .sectionDetailModel.result?.name ??
                                      "",
                                  textalign: TextAlign.start,
                                  fontsizeNormal: 20,
                                  fontsizeWeb: 24,
                                  fontweight: FontWeight.w800,
                                  maxline: 2,
                                  multilanguage: false,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    /* Release Year */
                                    (videoDetailsProvider.sectionDetailModel
                                                    .result?.releaseYear !=
                                                null &&
                                            videoDetailsProvider
                                                    .sectionDetailModel
                                                    .result
                                                    ?.releaseYear !=
                                                "")
                                        ? Container(
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            child: MyText(
                                              color: whiteLight,
                                              text: videoDetailsProvider
                                                      .sectionDetailModel
                                                      .result
                                                      ?.releaseYear ??
                                                  "",
                                              textalign: TextAlign.center,
                                              fontsizeNormal: 13,
                                              fontsizeWeb: 15,
                                              fontweight: FontWeight.w500,
                                              multilanguage: false,
                                              maxline: 1,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal,
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                    /* Duration */
                                    (videoDetailsProvider.sectionDetailModel
                                                .result?.videoDuration !=
                                            null)
                                        ? Container(
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            child: MyText(
                                              color: otherColor,
                                              multilanguage: false,
                                              text: ((videoDetailsProvider
                                                              .sectionDetailModel
                                                              .result
                                                              ?.videoDuration ??
                                                          0) >
                                                      0)
                                                  ? Utils.convertTimeToText(
                                                      videoDetailsProvider
                                                              .sectionDetailModel
                                                              .result
                                                              ?.videoDuration ??
                                                          0)
                                                  : "",
                                              textalign: TextAlign.center,
                                              fontsizeNormal: 13,
                                              fontsizeWeb: 15,
                                              fontweight: FontWeight.w500,
                                              maxline: 1,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal,
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                    /* MaxQuality */
                                    (videoDetailsProvider.sectionDetailModel
                                                    .result?.maxVideoQuality !=
                                                null &&
                                            videoDetailsProvider
                                                    .sectionDetailModel
                                                    .result
                                                    ?.maxVideoQuality !=
                                                "")
                                        ? Container(
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 1, 5, 1),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: otherColor,
                                                width: .7,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              shape: BoxShape.rectangle,
                                            ),
                                            child: MyText(
                                              color: otherColor,
                                              text: videoDetailsProvider
                                                      .sectionDetailModel
                                                      .result
                                                      ?.maxVideoQuality ??
                                                  "",
                                              textalign: TextAlign.center,
                                              fontsizeNormal: 10,
                                              fontsizeWeb: 12,
                                              fontweight: FontWeight.w500,
                                              multilanguage: false,
                                              maxline: 1,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal,
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    /* Release Date */
                    _buildReleaseDate(),

                    /* Prime TAG */
                    (videoDetailsProvider
                                    .sectionDetailModel.result?.isPremium ??
                                0) ==
                            1
                        ? Container(
                            margin: const EdgeInsets.fromLTRB(20, 11, 20, 0),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                MyText(
                                  color: colorPrimary,
                                  text: "primetag",
                                  textalign: TextAlign.start,
                                  fontsizeNormal: 12,
                                  fontsizeWeb: 15,
                                  fontweight: FontWeight.w700,
                                  multilanguage: true,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                                const SizedBox(height: 2),
                                MyText(
                                  color: white,
                                  text: "primetagdesc",
                                  multilanguage: true,
                                  textalign: TextAlign.center,
                                  fontsizeNormal: 12,
                                  fontsizeWeb: 13,
                                  fontweight: FontWeight.w500,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),

                    /* Rent TAG */
                    (videoDetailsProvider.sectionDetailModel.result?.isRent ??
                                0) ==
                            1
                        ? Container(
                            margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: complimentryColor,
                                    borderRadius: BorderRadius.circular(10),
                                    shape: BoxShape.rectangle,
                                  ),
                                  alignment: Alignment.center,
                                  child: MyText(
                                    color: white,
                                    text: Constant.currencySymbol,
                                    textalign: TextAlign.center,
                                    fontsizeNormal: 10,
                                    fontsizeWeb: 12,
                                    fontweight: FontWeight.w800,
                                    multilanguage: false,
                                    maxline: 1,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 5),
                                  child: MyText(
                                    color: white,
                                    text: "renttag",
                                    textalign: TextAlign.center,
                                    fontsizeNormal: 12,
                                    fontsizeWeb: 13,
                                    multilanguage: true,
                                    fontweight: FontWeight.w500,
                                    maxline: 1,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),

//coin tag--
                    generalProvider.isCoinShow == "1"
                        ? (videoDetailsProvider.sectionDetailModel.result
                                        ?.isabaletocoinpurches ??
                                    0) ==
                                1
                            ? Container(
                                margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    AnimatedGifWidget(
                                      height: 50,
                                      width: 50,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 5, right: 5),
                                      child: Row(
                                        children: [
                                          MyText(
                                            color: white,
                                            text: "cointag",
                                            textalign: TextAlign.center,
                                            fontsizeNormal: 12,
                                            fontsizeWeb: 13,
                                            multilanguage: true,
                                            fontweight: FontWeight.w500,
                                            maxline: 1,
                                            overflow: TextOverflow.ellipsis,
                                            fontstyle: FontStyle.normal,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            "${videoDetailsProvider.sectionDetailModel.result?.coinvalue ?? ''}",
                                            style: TextStyle(
                                              color: white,
                                              fontSize:
                                                  18, // Large font size for coin value
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink()
                        : const SizedBox.shrink(),

                    /* Continue Watching Button */
                    /* Watch Now button */
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      child: (widget.videoType == 5)
                          ? _buildWatchTrailer()
                          : _buildWatchNow(),
                    ),

                    /* Included Features buttons */
                    if (widget.videoType != 5)
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: (kIsWeb || Constant.isTV)
                              ? (MediaQuery.of(context).size.width / 2)
                              : MediaQuery.of(context).size.width,
                          constraints: const BoxConstraints(minHeight: 0),
                          margin: const EdgeInsets.fromLTRB(20, 25, 20, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // /* Rent Button */
                              // _buildRentBtn(),
                              // const SizedBox(width: 5),

                              /* Start Over & Trailer */
                              Expanded(
                                child: Consumer<VideoDetailsProvider>(
                                  builder:
                                      (context, videoDetailsProvider, child) {
                                    if ((videoDetailsProvider.sectionDetailModel
                                                    .result?.stopTime ??
                                                0) >
                                            0 &&
                                        videoDetailsProvider.sectionDetailModel
                                                .result?.videoDuration !=
                                            null) {
                                      /* Start Over */
                                      return InkWell(
                                        borderRadius: BorderRadius.circular(5),
                                        //focusColor:: gray.withOpacity(0.5),
                                        onTap: () async {
                                          analytics.logEvent(
                                            name: 'watch_from_start',
                                            parameters: {
                                              'video_id': widget.videoId,
                                              'video_name': videoDetailsProvider
                                                      .sectionDetailModel
                                                      .result
                                                      ?.name ??
                                                  "",
                                            },
                                          );
                                          Map<String, Object> screenViewEvent =
                                              {
                                            'video_id': widget.videoId,
                                            'video_name': videoDetailsProvider
                                                    .sectionDetailModel
                                                    .result
                                                    ?.name ??
                                                "",
                                            'user_id':
                                                Constant.userID.toString(),
                                          };
                                          Singular.eventWithArgs(
                                              'watch_from_start',
                                              screenViewEvent);
                                          openPlayer("startOver");
                                        },
                                        child: _buildFeatureBtn(
                                          icon: 'ic_restart.png',
                                          title: 'startover',
                                          multilanguage: true,
                                        ),
                                      );
                                    } else {
                                      /* Trailer */
                                      return InkWell(
                                        borderRadius: BorderRadius.circular(5),
                                        //focusColor:: gray.withOpacity(0.5),
                                        onTap: () {
                                          analytics.logEvent(
                                            name: 'watch_trailer',
                                            parameters: {
                                              'video_id': widget.videoId,
                                              'video_name': videoDetailsProvider
                                                      .sectionDetailModel
                                                      .result
                                                      ?.name ??
                                                  "",
                                            },
                                          );
                                          Map<String, Object> screenViewEvent =
                                              {
                                            'video_id': widget.videoId,
                                            'video_name': videoDetailsProvider
                                                    .sectionDetailModel
                                                    .result
                                                    ?.name ??
                                                "",
                                            'user_id':
                                                Constant.userID.toString(),
                                          };
                                          Singular.eventWithArgs(
                                              'watch_trailer', screenViewEvent);
                                          openPlayer("Trailer");
                                        },
                                        child: _buildFeatureBtn(
                                          icon: 'ic_borderplay.png',
                                          title: 'trailer',
                                          multilanguage: true,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),

                              /* Download */
                              if (!(kIsWeb) || !(Constant.isTV))
                                (videoDetailsProvider.sectionDetailModel.result
                                                ?.download ??
                                            0) ==
                                        1
                                    ? _buildDownloadWithSubCheck()
                                    : const SizedBox.shrink(),

                              /* Watchlist */
                              Expanded(
                                child: InkWell(
                                  //focusColor:: gray.withOpacity(0.5),
                                  onTap: () async {
                                    debugPrint(
                                        "isBookmark ====> ${videoDetailsProvider.sectionDetailModel.result?.isBookmark ?? 0}");

                                    if (Constant.userID != null) {
                                      final isCurrentlyBookmarked =
                                          videoDetailsProvider
                                                  .sectionDetailModel
                                                  .result
                                                  ?.isBookmark ??
                                              0;

                                      // Log event for adding/removing from watchlist
                                      analytics.logEvent(
                                        name: isCurrentlyBookmarked == 1
                                            ? "watchlist_removed"
                                            : "watchlist_added",
                                        parameters: {
                                          "video_id": widget.videoId,
                                          "video_type": widget.videoType,
                                          "type_id": widget.typeId,
                                          "user_id": Constant.userID,
                                        },
                                      );
                                      Map<String, Object> screenViewEvent = {
                                        'event_name': isCurrentlyBookmarked == 1
                                            ? "watchlist_removed"
                                            : "watchlist_added",
                                        "video_id": widget.videoId,
                                        "video_type": widget.videoType,
                                        "type_id": widget.typeId,
                                        "user_id": Constant.userID.toString(),
                                      };
                                      Singular.eventWithArgs(
                                          'Watchlist', screenViewEvent);
                                      await videoDetailsProvider.setBookMark(
                                        context,
                                        widget.typeId,
                                        widget.videoType,
                                        widget.videoId,
                                      );
                                    } else {
                                      if ((kIsWeb || Constant.isTV)) {
                                        Utils.buildWebAlertDialog(
                                            context, "login", "");
                                        return;
                                      }
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return const LoginSocial();
                                          },
                                        ),
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(5),
                                  child: Consumer<VideoDetailsProvider>(
                                    builder:
                                        (context, videoDetailsProvider, child) {
                                      if ((videoDetailsProvider
                                                  .sectionDetailModel
                                                  .result
                                                  ?.isBookmark ??
                                              0) ==
                                          1) {
                                        return _buildFeatureBtn(
                                          icon: 'watchlist_remove.png',
                                          title: 'watchlist',
                                          multilanguage: true,
                                        );
                                      } else {
                                        return _buildFeatureBtn(
                                          icon: 'ic_plus.png',
                                          title: 'watchlist',
                                          multilanguage: true,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),

                              /* More */
                              if (!(kIsWeb) || !(Constant.isTV))
                                Expanded(
                                  child: InkWell(
                                    //focusColor:: gray.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(5),
                                    onTap: () {
                                      buildMoreDialog(videoDetailsProvider
                                              .sectionDetailModel
                                              .result
                                              ?.stopTime ??
                                          0);
                                    },
                                    child: _buildFeatureBtn(
                                      icon: 'ic_more.png',
                                      title: 'more',
                                      multilanguage: true,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                    /* Description, IMDb, Languages & Subtitles */
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            constraints: const BoxConstraints(minHeight: 0),
                            alignment: Alignment.centerLeft,
                            child: ExpandableText(
                              videoDetailsProvider
                                      .sectionDetailModel.result?.description ??
                                  "",
                              expandText: more,
                              collapseText: less_,
                              maxLines: (kIsWeb || Constant.isTV) ? 50 : 3,
                              linkColor: otherColor,
                              expandOnTextTap: true,
                              collapseOnTextTap: true,
                              style: TextStyle(
                                fontSize: (kIsWeb || Constant.isTV) ? 12 : 14,
                                fontStyle: FontStyle.normal,
                                color: otherColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Row(
                          //   children: [
                          //     MyImage(
                          //       width: 50,
                          //       height: 23,
                          //       imagePath: "imdb.png",
                          //     ),
                          //     const SizedBox(width: 5),
                          //     MyText(
                          //       color: otherColor,
                          //       text:
                          //           "${videoDetailsProvider.sectionDetailModel.result?.imdbRating ?? 0}",
                          //       textalign: TextAlign.start,
                          //       fontsizeNormal: 14,
                          //       fontsizeWeb: 16,
                          //       fontweight: FontWeight.w600,
                          //       multilanguage: false,
                          //       maxline: 1,
                          //       overflow: TextOverflow.ellipsis,
                          //       fontstyle: FontStyle.normal,
                          //     ),
                          //   ],
                          // ),

                          // Container(
                          //   constraints: const BoxConstraints(minHeight: 0),
                          //   margin: const EdgeInsets.only(top: 10),
                          //   child: Row(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       MyText(
                          //         color: white,
                          //         text: "MaturityRating",
                          //         textalign: TextAlign.center,
                          //         fontsizeNormal: 13,
                          //         fontweight: FontWeight.w500,
                          //         fontsizeWeb: 15,
                          //         maxline: 1,
                          //         multilanguage: true,
                          //         overflow: TextOverflow.ellipsis,
                          //         fontstyle: FontStyle.normal,
                          //       ),
                          //       const SizedBox(width: 5),
                          //       MyText(
                          //         color: white,
                          //         text: ":",
                          //         textalign: TextAlign.center,
                          //         fontsizeNormal: 13,
                          //         fontweight: FontWeight.w500,
                          //         fontsizeWeb: 15,
                          //         maxline: 1,
                          //         multilanguage: false,
                          //         overflow: TextOverflow.ellipsis,
                          //         fontstyle: FontStyle.normal,
                          //       ),
                          //       const SizedBox(width: 5),
                          //       Expanded(
                          //         child: MyText(
                          //           color: white,
                          //           text: (videoDetailsProvider
                          //                           .sectionDetailModel
                          //                           .result
                          //                           ?.maturityRating ??
                          //                       "")
                          //                   .isNotEmpty
                          //               ? videoDetailsProvider
                          //                       .sectionDetailModel
                          //                       .result
                          //                       ?.maturityRating ??
                          //                   ""
                          //               : "N/A",
                          //           textalign: TextAlign.start,
                          //           fontsizeNormal: 13,
                          //           fontweight: FontWeight.w500,
                          //           fontsizeWeb: 14,
                          //           multilanguage: false,
                          //           maxline: 5,
                          //           overflow: TextOverflow.ellipsis,
                          //           fontstyle: FontStyle.normal,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),

                          Container(
                            constraints: const BoxConstraints(minHeight: 0),
                            margin: const EdgeInsets.only(top: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  color: white,
                                  text: "category",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: 13,
                                  fontweight: FontWeight.w500,
                                  fontsizeWeb: 15,
                                  maxline: 1,
                                  multilanguage: true,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                                const SizedBox(width: 5),
                                MyText(
                                  color: white,
                                  text: ":",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: 13,
                                  fontweight: FontWeight.w500,
                                  fontsizeWeb: 15,
                                  maxline: 1,
                                  multilanguage: false,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: MyText(
                                    color: white,
                                    text: videoDetailsProvider
                                            .sectionDetailModel
                                            .result
                                            ?.categoryName ??
                                        "",
                                    textalign: TextAlign.start,
                                    fontsizeNormal: 13,
                                    fontweight: FontWeight.w500,
                                    fontsizeWeb: 14,
                                    multilanguage: false,
                                    maxline: 5,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            constraints: const BoxConstraints(minHeight: 0),
                            margin: const EdgeInsets.only(top: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  color: white,
                                  text: "language_",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: 13,
                                  fontweight: FontWeight.w500,
                                  fontsizeWeb: 15,
                                  maxline: 1,
                                  multilanguage: true,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                                const SizedBox(width: 5),
                                MyText(
                                  color: white,
                                  text: ":",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: 13,
                                  fontweight: FontWeight.w500,
                                  fontsizeWeb: 15,
                                  maxline: 1,
                                  multilanguage: false,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: MyText(
                                    color: white,
                                    text: audioLanguages ?? "",
                                    textalign: TextAlign.start,
                                    fontsizeNormal: 13,
                                    fontweight: FontWeight.w500,
                                    fontsizeWeb: 14,
                                    multilanguage: false,
                                    maxline: 5,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Constant.subtitleUrls.isNotEmpty
                              ? Container(
                                  constraints:
                                      const BoxConstraints(minHeight: 0),
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      MyText(
                                        color: white,
                                        text: "subtitle",
                                        textalign: TextAlign.center,
                                        fontsizeNormal: 13,
                                        fontweight: FontWeight.w500,
                                        fontsizeWeb: 15,
                                        maxline: 1,
                                        multilanguage: true,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      MyText(
                                        color: white,
                                        text: ":",
                                        textalign: TextAlign.center,
                                        fontsizeNormal: 13,
                                        fontweight: FontWeight.w500,
                                        fontsizeWeb: 15,
                                        maxline: 1,
                                        multilanguage: false,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      MyText(
                                        color: white,
                                        text: "Available",
                                        textalign: TextAlign.center,
                                        fontsizeNormal: 13,
                                        fontweight: FontWeight.w500,
                                        fontsizeWeb: 14,
                                        maxline: 1,
                                        multilanguage: false,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal,
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),

                    /* AdMob Banner */

                    Utils.showBannerAd(context),
                    const SizedBox(height: 10),

                    /* Related ~ More Details */
                    Container(
                      margin: (kIsWeb || Constant.isTV)
                          ? const EdgeInsets.fromLTRB(20, 0, 20, 0)
                          : const EdgeInsets.all(0),
                      child: Consumer<VideoDetailsProvider>(
                        builder: (context, videoDetailsProvider, child) {
                          return _buildTabs();
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    /* Web Footer */
                    (kIsWeb) ? const FooterWeb() : const SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReleaseDate() {
    if (widget.videoType == 5) {
      if (videoDetailsProvider.sectionDetailModel.result?.releaseDate != null &&
          (videoDetailsProvider.sectionDetailModel.result?.releaseDate ?? "") !=
              "") {
        return Container(
          margin: EdgeInsets.fromLTRB(
              (kIsWeb || Constant.isTV) ? 0 : 20, 20, 20, 0),
          width: MediaQuery.of(context).size.width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              MyText(
                color: white,
                text: "release_date",
                multilanguage: true,
                textalign: TextAlign.start,
                fontsizeNormal: 14,
                fontsizeWeb: 15,
                fontweight: FontWeight.w500,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal,
              ),
              const SizedBox(width: 5),
              MyText(
                color: white,
                text: ":",
                multilanguage: false,
                textalign: TextAlign.start,
                fontsizeNormal: 14,
                fontsizeWeb: 15,
                fontweight: FontWeight.w500,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: MyText(
                  color: complimentryColor,
                  text: DateFormat("dd MMM, yyyy").format(DateTime.parse(
                      videoDetailsProvider
                              .sectionDetailModel.result?.releaseDate ??
                          "")),
                  multilanguage: false,
                  textalign: TextAlign.start,
                  fontsizeNormal: 14,
                  fontsizeWeb: 15,
                  fontweight: FontWeight.w700,
                  maxline: 2,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ),
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  /* Trailer View */
  Widget setUpTrailerView() {
    if ((videoDetailsProvider.sectionDetailModel.result?.trailerType ?? "") ==
        "youtube") {
      if (_trailerYoutubeController != null) {
        return _buildTrailerView(
            videoDetailsProvider.sectionDetailModel.result?.trailerType ?? "");
      } else {
        return _buildMobilePoster();
      }
    } else {
      if (_trailerNormalController != null &&
          (_trailerNormalController?.value.isInitialized ?? false)) {
        return _buildTrailerView(
            videoDetailsProvider.sectionDetailModel.result?.trailerType ?? "");
      } else {
        return _buildMobilePoster();
      }
    }
  }

  Widget _buildTrailerView(String trailerType) {
    if (trailerType == "youtube") {
      return Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(0),
            width: MediaQuery.of(context).size.width,
            height: (kIsWeb || Constant.isTV)
                ? Dimens.detailWebPoster
                : Dimens.detailPoster,
            child: YoutubePlayer(
              controller: _trailerYoutubeController!,
              enableFullScreenOnVerticalDrag: false,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(0),
            width: MediaQuery.of(context).size.width,
            height: (kIsWeb || Constant.isTV)
                ? Dimens.detailWebPoster
                : Dimens.detailPoster,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [
                  transparentColor,
                  transparentColor,
                  appBgColor,
                ],
              ),
            ),
          ),
          if (!kIsWeb)
            Positioned(
              top: 15,
              left: 15,
              child: Utils.buildBackBtn(context),
            ),
        ],
      );
    } else {
      return Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(0),
            width: MediaQuery.of(context).size.width,
            height: (kIsWeb || Constant.isTV)
                ? Dimens.detailWebPoster
                : Dimens.detailPoster,
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _trailerNormalController?.value.size.width,
                  height: _trailerNormalController?.value.size.height,
                  child: AspectRatio(
                    aspectRatio:
                        _trailerNormalController?.value.aspectRatio ?? 16 / 9,
                    child: VideoPlayer(_trailerNormalController!),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(0),
            width: MediaQuery.of(context).size.width,
            height: (kIsWeb || Constant.isTV)
                ? Dimens.detailWebPoster
                : Dimens.detailPoster,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [
                  transparentColor,
                  transparentColor,
                  appBgColor,
                ],
              ),
            ),
          ),
          if (!kIsWeb)
            Positioned(
              top: 15,
              left: 15,
              child: Utils.buildBackBtn(context),
            ),
        ],
      );
    }
  }

  Widget _buildMobilePoster() {
    return Stack(
      alignment: Alignment.center,
      children: [
        /* Poster & Trailer player */
        Container(
          padding: const EdgeInsets.all(0),
          width: MediaQuery.of(context).size.width,
          height: (kIsWeb || Constant.isTV)
              ? Dimens.detailWebPoster
              : Dimens.detailPoster,
          child: MyNetworkImage(
              fit: BoxFit.fill,
              imageUrl:
                  videoDetailsProvider.sectionDetailModel.result?.fullWidth ??
                      ""),
        ),
        Container(
          padding: const EdgeInsets.all(0),
          width: MediaQuery.of(context).size.width,
          height: (kIsWeb || Constant.isTV)
              ? Dimens.detailWebPoster
              : Dimens.detailPoster,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [
                transparentColor,
                transparentColor,
                appBgColor,
              ],
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(30),
          //focusColor:: white,
          onTap: () {
            openPlayer("Trailer");
          },
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: MyImage(
              fit: BoxFit.fill,
              height: 60,
              width: 60,
              imagePath: "play_new.png",
            ),
          ),
        ),
        if (!kIsWeb)
          Positioned(
            top: 15,
            left: 15,
            child: Utils.buildBackBtn(context),
          ),
      ],
    );
  }

  Widget _buildWebData() {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints.expand(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            /* Poster */
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Stack(
                alignment: AlignmentDirectional.centerEnd,
                children: [
                  /* Poster */
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width *
                        (Dimens.webBannerImgPr),
                    height: Dimens.detailWebPoster,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.detailWebPoster,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                appBgColor,
                                transparentColor,
                                transparentColor,
                                transparentColor,
                                transparentColor,
                                transparentColor,
                                appBgColor,
                              ],
                            ),
                          ),
                        ),
                        MyNetworkImage(
                          fit: BoxFit.fill,
                          imageUrl: videoDetailsProvider
                                      .sectionDetailModel.result?.landscape !=
                                  ""
                              ? (videoDetailsProvider
                                      .sectionDetailModel.result?.landscape ??
                                  "")
                              : (videoDetailsProvider
                                      .sectionDetailModel.result?.thumbnail ??
                                  ""),
                        ),
                        Container(
                          padding: const EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.detailWebPoster,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                appBgColor,
                                transparentColor,
                                transparentColor,
                                appBgColor,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /* Gradient */
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width,
                    height: Dimens.detailWebPoster,
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          appBgColor,
                          appBgColor,
                          appBgColor,
                          appBgColor,
                          transparentColor,
                          transparentColor,
                          transparentColor,
                          transparentColor,
                        ],
                      ),
                    ),
                  ),

                  /* Details */
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: Dimens.detailWebPoster,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            padding: const EdgeInsets.all(10),
                            alignment: Alignment.centerLeft,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /* Small Poster, Main title, ReleaseYear, Duration, Age Restriction, Video Quality */
                                Expanded(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    constraints:
                                        const BoxConstraints(minHeight: 0),
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 0, 20, 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        MyText(
                                          color: white,
                                          text: videoDetailsProvider
                                                  .sectionDetailModel
                                                  .result
                                                  ?.name ??
                                              "",
                                          textalign: TextAlign.start,
                                          fontsizeNormal: 24,
                                          fontsizeWeb: 24,
                                          fontweight: FontWeight.w800,
                                          maxline: 2,
                                          multilanguage: false,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            /* Category */
                                            (videoDetailsProvider
                                                            .sectionDetailModel
                                                            .result
                                                            ?.categoryName !=
                                                        null &&
                                                    videoDetailsProvider
                                                            .sectionDetailModel
                                                            .result
                                                            ?.categoryName !=
                                                        "")
                                                ? Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    child: MyText(
                                                      color: whiteLight,
                                                      text: videoDetailsProvider
                                                              .sectionDetailModel
                                                              .result
                                                              ?.categoryName ??
                                                          "",
                                                      textalign:
                                                          TextAlign.center,
                                                      fontsizeNormal: 13,
                                                      fontsizeWeb: 13,
                                                      fontweight:
                                                          FontWeight.w600,
                                                      multilanguage: false,
                                                      maxline: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontstyle:
                                                          FontStyle.normal,
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),

                                            /* Release Year */
                                            (videoDetailsProvider
                                                            .sectionDetailModel
                                                            .result
                                                            ?.releaseYear !=
                                                        null &&
                                                    videoDetailsProvider
                                                            .sectionDetailModel
                                                            .result
                                                            ?.releaseYear !=
                                                        "")
                                                ? Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    child: MyText(
                                                      color: whiteLight,
                                                      text: videoDetailsProvider
                                                              .sectionDetailModel
                                                              .result
                                                              ?.releaseYear ??
                                                          "",
                                                      textalign:
                                                          TextAlign.center,
                                                      fontsizeNormal: 13,
                                                      fontsizeWeb: 13,
                                                      fontweight:
                                                          FontWeight.w500,
                                                      multilanguage: false,
                                                      maxline: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontstyle:
                                                          FontStyle.normal,
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),

                                            // /* Release Year */
                                            // (videoDetailsProvider
                                            //                 .sectionDetailModel
                                            //                 .result
                                            //                 ?.maturityRating !=
                                            //             null &&
                                            //         videoDetailsProvider
                                            //                 .sectionDetailModel
                                            //                 .result
                                            //                 ?.maturityRating !=
                                            //             "")
                                            //     ? Container(
                                            //         margin:
                                            //             const EdgeInsets.only(
                                            //                 right: 10),
                                            //         child: MyText(
                                            //           color: whiteLight,
                                            //           text: videoDetailsProvider
                                            //                   .sectionDetailModel
                                            //                   .result
                                            //                   ?.maturityRating ??
                                            //               "",
                                            //           textalign:
                                            //               TextAlign.center,
                                            //           fontsizeNormal: 13,
                                            //           fontsizeWeb: 13,
                                            //           fontweight:
                                            //               FontWeight.w500,
                                            //           multilanguage: false,
                                            //           maxline: 1,
                                            //           overflow:
                                            //               TextOverflow.ellipsis,
                                            //           fontstyle:
                                            //               FontStyle.normal,
                                            //         ),
                                            //       )
                                            //     : const SizedBox.shrink(),

                                            /* Duration */
                                            (videoDetailsProvider
                                                        .sectionDetailModel
                                                        .result
                                                        ?.videoDuration !=
                                                    null)
                                                ? Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    child: MyText(
                                                      color: otherColor,
                                                      multilanguage: false,
                                                      text: ((videoDetailsProvider
                                                                      .sectionDetailModel
                                                                      .result
                                                                      ?.videoDuration ??
                                                                  0) >
                                                              0)
                                                          ? Utils.convertTimeToText(
                                                              videoDetailsProvider
                                                                      .sectionDetailModel
                                                                      .result
                                                                      ?.videoDuration ??
                                                                  0)
                                                          : "",
                                                      textalign:
                                                          TextAlign.center,
                                                      fontsizeNormal: 13,
                                                      fontsizeWeb: 13,
                                                      fontweight:
                                                          FontWeight.w500,
                                                      maxline: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontstyle:
                                                          FontStyle.normal,
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),

                                            /* MaxQuality */
                                            (videoDetailsProvider
                                                            .sectionDetailModel
                                                            .result
                                                            ?.maxVideoQuality !=
                                                        null &&
                                                    videoDetailsProvider
                                                            .sectionDetailModel
                                                            .result
                                                            ?.maxVideoQuality !=
                                                        "")
                                                ? Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    padding: const EdgeInsets
                                                        .fromLTRB(5, 1, 5, 1),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: otherColor,
                                                        width: .7,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      shape: BoxShape.rectangle,
                                                    ),
                                                    child: MyText(
                                                      color: otherColor,
                                                      text: videoDetailsProvider
                                                              .sectionDetailModel
                                                              .result
                                                              ?.maxVideoQuality ??
                                                          "",
                                                      textalign:
                                                          TextAlign.center,
                                                      fontsizeNormal: 10,
                                                      fontsizeWeb: 12,
                                                      fontweight:
                                                          FontWeight.w500,
                                                      multilanguage: false,
                                                      maxline: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontstyle:
                                                          FontStyle.normal,
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),

                                            /* IMDb */
                                            MyImage(
                                              width: 40,
                                              height: 15,
                                              imagePath: "imdb.png",
                                            ),
                                            MyText(
                                              color: otherColor,
                                              text:
                                                  "${videoDetailsProvider.sectionDetailModel.result?.imdbRating ?? 0}",
                                              textalign: TextAlign.start,
                                              fontsizeNormal: 14,
                                              fontsizeWeb: 14,
                                              fontweight: FontWeight.w600,
                                              multilanguage: false,
                                              maxline: 1,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal,
                                            ),
                                            /* IMDb */
                                          ],
                                        ),

                                        /* Language */
                                        const SizedBox(height: 5),
                                        Container(
                                          constraints: const BoxConstraints(
                                              minHeight: 0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              MyText(
                                                color: whiteLight,
                                                text: "language_",
                                                textalign: TextAlign.center,
                                                fontsizeNormal: 13,
                                                fontweight: FontWeight.w500,
                                                fontsizeWeb: 13,
                                                maxline: 1,
                                                multilanguage: true,
                                                overflow: TextOverflow.ellipsis,
                                                fontstyle: FontStyle.normal,
                                              ),
                                              const SizedBox(width: 5),
                                              MyText(
                                                color: whiteLight,
                                                text: ":",
                                                textalign: TextAlign.center,
                                                fontsizeNormal: 13,
                                                fontweight: FontWeight.w600,
                                                fontsizeWeb: 13,
                                                maxline: 1,
                                                multilanguage: false,
                                                overflow: TextOverflow.ellipsis,
                                                fontstyle: FontStyle.normal,
                                              ),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                child: MyText(
                                                  color: whiteLight,
                                                  text: audioLanguages ?? "",
                                                  textalign: TextAlign.start,
                                                  fontsizeNormal: 13,
                                                  fontweight: FontWeight.w500,
                                                  fontsizeWeb: 13,
                                                  multilanguage: false,
                                                  maxline: 5,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontstyle: FontStyle.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        /* Subtitle */
                                        Constant.subtitleUrls.isNotEmpty
                                            ? Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        minHeight: 0),
                                                margin: const EdgeInsets.only(
                                                    top: 8),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    MyText(
                                                      color: whiteLight,
                                                      text: "subtitle",
                                                      textalign:
                                                          TextAlign.center,
                                                      fontsizeNormal: 13,
                                                      fontweight:
                                                          FontWeight.w500,
                                                      fontsizeWeb: 13,
                                                      maxline: 1,
                                                      multilanguage: true,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontstyle:
                                                          FontStyle.normal,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    MyText(
                                                      color: whiteLight,
                                                      text: ":",
                                                      textalign:
                                                          TextAlign.center,
                                                      fontsizeNormal: 13,
                                                      fontweight:
                                                          FontWeight.w600,
                                                      fontsizeWeb: 13,
                                                      maxline: 1,
                                                      multilanguage: false,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontstyle:
                                                          FontStyle.normal,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Expanded(
                                                      child: MyText(
                                                        color: whiteLight,
                                                        text: "Available",
                                                        textalign:
                                                            TextAlign.start,
                                                        fontsizeNormal: 13,
                                                        fontweight:
                                                            FontWeight.w500,
                                                        fontsizeWeb: 13,
                                                        maxline: 1,
                                                        multilanguage: false,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontstyle:
                                                            FontStyle.normal,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : const SizedBox.shrink(),

                                        /* Release Date */
                                        _buildReleaseDate(),

                                        /* Prime TAG */
                                        (videoDetailsProvider.sectionDetailModel
                                                        .result?.isPremium ??
                                                    0) ==
                                                1
                                            ? Container(
                                                margin: const EdgeInsets.only(
                                                    top: 10),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    MyText(
                                                      color: colorPrimary,
                                                      text: "primetag",
                                                      textalign:
                                                          TextAlign.start,
                                                      fontsizeNormal: 12,
                                                      fontsizeWeb: 12,
                                                      fontweight:
                                                          FontWeight.w700,
                                                      multilanguage: true,
                                                      maxline: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontstyle:
                                                          FontStyle.normal,
                                                    ),
                                                    const SizedBox(height: 2),
                                                    MyText(
                                                      color: white,
                                                      text: "primetagdesc",
                                                      multilanguage: true,
                                                      textalign:
                                                          TextAlign.center,
                                                      fontsizeNormal: 12,
                                                      fontsizeWeb: 12,
                                                      fontweight:
                                                          FontWeight.w400,
                                                      maxline: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontstyle:
                                                          FontStyle.normal,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : const SizedBox.shrink(),

                                        /* Rent TAG */
                                        (videoDetailsProvider.sectionDetailModel
                                                        .result?.isRent ??
                                                    0) ==
                                                1
                                            ? Container(
                                                margin: const EdgeInsets.only(
                                                    top: 10, bottom: 10),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Container(
                                                      width: 18,
                                                      height: 18,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            complimentryColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        shape:
                                                            BoxShape.rectangle,
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: MyText(
                                                        color: white,
                                                        text: Constant
                                                            .currencySymbol,
                                                        textalign:
                                                            TextAlign.center,
                                                        fontsizeNormal: 11,
                                                        fontsizeWeb: 11,
                                                        fontweight:
                                                            FontWeight.w700,
                                                        multilanguage: false,
                                                        maxline: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontstyle:
                                                            FontStyle.normal,
                                                      ),
                                                    ),
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      child: MyText(
                                                        color: white,
                                                        text: "renttag",
                                                        textalign:
                                                            TextAlign.center,
                                                        fontsizeNormal: 12,
                                                        fontsizeWeb: 13,
                                                        multilanguage: true,
                                                        fontweight:
                                                            FontWeight.w500,
                                                        maxline: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        fontstyle:
                                                            FontStyle.normal,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : const SizedBox.shrink(),

                                        /* Description */
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              margin: const EdgeInsets.only(
                                                  top: 15, bottom: 8),
                                              child: ExpandableText(
                                                videoDetailsProvider
                                                        .sectionDetailModel
                                                        .result
                                                        ?.description ??
                                                    "",
                                                animation: true,
                                                textAlign: TextAlign.start,
                                                expandOnTextTap: true,
                                                collapseOnTextTap: true,
                                                expandText: "",
                                                maxLines: 10,
                                                linkColor: colorPrimary,
                                                style: TextStyle(
                                                  fontSize:
                                                      (kIsWeb || Constant.isTV)
                                                          ? 12
                                                          : 13,
                                                  fontStyle: FontStyle.normal,
                                                  color: white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width *
                              Dimens.webBannerImgPr,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            /* WatchNow & Feature buttons */
            Container(
              alignment: Alignment.centerLeft,
              constraints: const BoxConstraints(minHeight: 0, minWidth: 0),
              margin: const EdgeInsets.fromLTRB(30, 10, 0, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  /* WatchNow & ContinueWatching */
                  (widget.videoType == 5)
                      ? _buildWatchTrailer()
                      : _buildWatchNow(),
                  if (widget.videoType != 5) const SizedBox(width: 10),

                  // /* Rent Button */
                  // if (widget.videoType != 5)
                  //   Container(
                  //     constraints: const BoxConstraints(minWidth: 0),
                  //     child: _buildRentBtn(),
                  //   ),
                  // if (widget.videoType != 5) const SizedBox(width: 10),

                  /* Trailer & StartOver Button */
                  if (widget.videoType != 5)
                    Container(
                      constraints: const BoxConstraints(minWidth: 50),
                      child: Consumer<VideoDetailsProvider>(
                        builder: (context, videoDetailsProvider, child) {
                          if ((videoDetailsProvider.sectionDetailModel.result
                                          ?.stopTime ??
                                      0) >
                                  0 &&
                              videoDetailsProvider.sectionDetailModel.result
                                      ?.videoDuration !=
                                  null) {
                            /* Start Over */
                            return InkWell(
                              //focusColor:: gray.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(5),
                              onTap: () async {
                                openPlayer("startOver");
                              },
                              child: _buildFeatureBtn(
                                icon: 'ic_restart.png',
                                title: 'startover',
                                multilanguage: true,
                              ),
                            );
                          } else {
                            /* Trailer */
                            return InkWell(
                              //focusColor:: gray.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(5),
                              onTap: () {
                                openPlayer("Trailer");
                              },
                              child: _buildFeatureBtn(
                                icon: 'ic_borderplay.png',
                                title: 'trailer',
                                multilanguage: true,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  if (widget.videoType != 5) const SizedBox(width: 10),

                  /* Watchlist */
                  if (widget.videoType != 5)
                    Container(
                      constraints: const BoxConstraints(minWidth: 50),
                      child: InkWell(
                        //focusColor:: gray.withOpacity(0.5),
                        onTap: () async {
                          debugPrint(
                              "isBookmark ====> ${videoDetailsProvider.sectionDetailModel.result?.isBookmark ?? 0}");
                          if (Constant.userID != null) {
                            await videoDetailsProvider.setBookMark(
                              context,
                              widget.typeId,
                              widget.videoType,
                              widget.videoId,
                            );
                          } else {
                            if ((kIsWeb || Constant.isTV)) {
                              Utils.buildWebAlertDialog(context, "login", "")
                                  .then((value) => _getData());
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const LoginSocial();
                                },
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(5),
                        child: Consumer<VideoDetailsProvider>(
                          builder: (context, videoDetailsProvider, child) {
                            if ((videoDetailsProvider.sectionDetailModel.result
                                        ?.isBookmark ??
                                    0) ==
                                1) {
                              return _buildFeatureBtn(
                                icon: 'watchlist_remove.png',
                                title: 'watchlist',
                                multilanguage: true,
                              );
                            } else {
                              return _buildFeatureBtn(
                                icon: 'ic_plus.png',
                                title: 'watchlist',
                                multilanguage: true,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),

            /* Other Details */
            /* Related ~ More Details */
            Container(
              margin: (kIsWeb || Constant.isTV)
                  ? const EdgeInsets.fromLTRB(10, 10, 20, 0)
                  : const EdgeInsets.all(0),
              child: Consumer<VideoDetailsProvider>(
                builder: (context, videoDetailsProvider, child) {
                  return _buildTabs();
                },
              ),
            ),
            const SizedBox(height: 20),

            /* Web Footer */
            (kIsWeb) ? const FooterWeb() : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  double getDynamicHeight(String? videoType, String? layoutType) {
    if (videoType == "1" || videoType == "2") {
      if (layoutType == "landscape") {
        return Dimens.heightLand;
      } else if (layoutType == "potrait") {
        return Dimens.heightPort;
      } else if (layoutType == "square") {
        return Dimens.heightSquare;
      } else {
        return Dimens.heightLand;
      }
    } else if (videoType == "3" || videoType == "4") {
      return Dimens.heightLangGen;
    } else {
      if (layoutType == "landscape") {
        return Dimens.heightLand;
      } else if (layoutType == "potrait") {
        return Dimens.heightPort;
      } else if (layoutType == "square") {
        return Dimens.heightSquare;
      } else {
        return Dimens.heightLand;
      }
    }
  }

  Widget _buildWatchTrailer() {
    return Container(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () {
          openPlayer("Trailer");
        },
        //focusColor:: white,
        borderRadius: BorderRadius.circular(5),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            height: (kIsWeb || Constant.isTV) ? 40 : 40,
            constraints: BoxConstraints(
              maxWidth: (kIsWeb || Constant.isTV)
                  ? 180
                  : MediaQuery.of(context).size.width,
            ),
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
            decoration: BoxDecoration(
              color: primaryDark,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MyImage(
                  width: 18,
                  height: 18,
                  imagePath: "ic_play.png",
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: MyText(
                    color: white,
                    text: "watch_trailer",
                    multilanguage: true,
                    textalign: TextAlign.start,
                    fontsizeNormal: 15,
                    fontweight: FontWeight.w600,
                    fontsizeWeb: 16,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWatchNow() {
    if ((videoDetailsProvider.sectionDetailModel.result?.stopTime ?? 0) > 0 &&
        videoDetailsProvider.sectionDetailModel.result?.videoDuration != null) {
      return Container(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () async {
            if (Constant.userID != null) {
              // Check if the videoDetailsProvider.sectionDetailModel.result?.maturityRating is "A"
              // Check if the maturity rating is "A"
              if (videoDetailsProvider
                      .sectionDetailModel.result?.maturityRating ==
                  "A") {
                // Print statement for maturity rating check
                print("Maturity Rating is A, showing pop-up");

                // Show the pop-up with details
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.black,
                      elevation: 5, // Adding shadow
                      title: Column(
                        children: [
                          Image.asset(
                            "assets/images/age.png",
                            height: 50,
                            width: 50,
                          ),
                          SizedBox(height: 10),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Maturity Rating:',
                                  style: TextStyle(
                                      fontSize: 19,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text: ' 18+',
                                  style: TextStyle(
                                      fontSize: 19,
                                      color: colorPrimary,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 14),
                          Text(
                            'May contain mature content, nudity, violence, foul language, substances.',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w400),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'I Confirm that i am 18 years and above',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  // User confirmed they're over 18, open player screen
                                  openPlayer("Video");
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: colorPrimary,
                                  primary: Colors.black,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                ),
                                child: Text('I am over 18'),
                              ),
                              SizedBox(width: 10),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog and do nothing
                                },
                                style: TextButton.styleFrom(
                                  side: BorderSide(color: Colors.white),
                                  primary: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                ),
                                child: Text('Cancel'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      actionsPadding: EdgeInsets.zero,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 30), // Increase content height
                    );
                  },
                );

                return; // Skip the rest of the logic as the pop-up is shown
              }

              // Print the maturity rating when not "A"
              print(
                  "Maturity Rating is not A, proceeding with regular functionality");

              // Check if the user is a "prime" user or has other access
              bool isPrimeUser =
                  videoDetailsProvider.sectionDetailModel.result?.isBuy == 1;
              bool isPrimeUserCoin =
                  videoDetailsProvider.sectionDetailModel.result?.iscoinbuy ==
                      1;
              bool isAdShow =
                  videoDetailsProvider.sectionDetailModel.result?.isadshow == 1;
              bool isRenteBuy =
                  videoDetailsProvider.sectionDetailModel.result?.rentBuy == 1;

              // Check if rewardad is disabled for Android or iOS
              if ((Platform.isAndroid && generalProvider.rewardad == "0") ||
                  (Platform.isIOS && generalProvider.rewardadIos == "0")) {
                print(
                    "Rewarded ad is disabled for this platform. Opening player directly.");
                openPlayer("Video");
                return;
              }

              if ((Platform.isAndroid && generalProvider.rewardad == "1") ||
                  (Platform.isIOS && generalProvider.rewardadIos == "1")) {
                if (isPrimeUser || isPrimeUserCoin || isRenteBuy) {
                  openPlayer("Video");
                } else {
                  if (isAdShow) {
                    AdHelper.showRewardedAd(
                      onAdCompleted: () async {
                        await walletProvider.addCoinsAfterWatchAd(
                          Constant.userID!,
                          videoDetailsProvider.sectionDetailModel.result?.id ??
                              '',
                          0,
                          generalProvider.isAdsCoin,
                        );
                        openPlayer("Video");
                      },
                      onAdFailed: () {
                        openPlayer("Video");
                      },
                    );
                  } else {
                    openPlayer("Video");
                  }
                }
              }
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LoginSocial(),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(5),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              height: 40,
              constraints: BoxConstraints(
                maxWidth: (kIsWeb || Constant.isTV)
                    ? 190
                    : MediaQuery.of(context).size.width,
              ),
              decoration: BoxDecoration(
                color: primaryDark,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 20),
                        MyImage(
                          width: 18,
                          height: 18,
                          imagePath: "ic_play.png",
                          color: black,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              MyText(
                                color: black,
                                text: "continuewatching",
                                multilanguage: true,
                                textalign: TextAlign.start,
                                fontsizeNormal: 13,
                                fontsizeWeb: 15,
                                fontweight: FontWeight.w600,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              Row(
                                children: [
                                  MyText(
                                    color: black,
                                    text: Utils.remainTimeInMin(
                                        ((videoDetailsProvider
                                                        .sectionDetailModel
                                                        .result
                                                        ?.videoDuration ??
                                                    0) -
                                                (videoDetailsProvider
                                                        .sectionDetailModel
                                                        .result
                                                        ?.stopTime ??
                                                    0))
                                            .abs()),
                                    textalign: TextAlign.start,
                                    fontsizeNormal: 10,
                                    fontweight: FontWeight.w500,
                                    fontsizeWeb: 12,
                                    multilanguage: false,
                                    maxline: 1,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                  const SizedBox(width: 5),
                                  MyText(
                                    color: black,
                                    text: "left",
                                    textalign: TextAlign.start,
                                    fontsizeNormal: 10,
                                    fontweight: FontWeight.w500,
                                    fontsizeWeb: 12,
                                    multilanguage: true,
                                    maxline: 1,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                  Container(
                    height: 4,
                    constraints: const BoxConstraints(minWidth: 0),
                    margin: const EdgeInsets.all(3),
                    child: LinearPercentIndicator(
                      padding: const EdgeInsets.all(0),
                      barRadius: const Radius.circular(2),
                      lineHeight: 4,
                      percent: Utils.getPercentage(
                          videoDetailsProvider
                                  .sectionDetailModel.result?.videoDuration ??
                              0,
                          videoDetailsProvider
                                  .sectionDetailModel.result?.stopTime ??
                              0),
                      backgroundColor: secProgressColor,
                      progressColor: colorPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () async {
            // Similar logic as above without the maturity rating check
            if (Constant.userID != null) {
              if (videoDetailsProvider
                      .sectionDetailModel.result?.maturityRating ==
                  "A") {
                // Print statement for maturity rating check
                print("Maturity Rating is A, showing pop-up");

                // Show the pop-up with details
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.black,
                      elevation: 5, // Adding shadow
                      title: Column(
                        children: [
                          Image.asset(
                            "assets/images/age.png",
                            height: 50,
                            width: 50,
                          ),
                          SizedBox(height: 10),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Maturity Rating:',
                                  style: TextStyle(
                                      fontSize: 19,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                                TextSpan(
                                  text: ' 18+',
                                  style: TextStyle(
                                      fontSize: 19,
                                      color: colorPrimary,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 14),
                          Text(
                            'May contain mature content, nudity, violence, foul language, substances.',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w400),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'I Confirm that i am 18 years and above',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  // User confirmed they're over 18, open player screen
                                  openPlayer("Video");
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: colorPrimary,
                                  primary: Colors.black,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                ),
                                child: Text('I am over 18'),
                              ),
                              SizedBox(width: 10),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog and do nothing
                                },
                                style: TextButton.styleFrom(
                                  side: BorderSide(color: Colors.white),
                                  primary: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                ),
                                child: Text('Cancel'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      actionsPadding: EdgeInsets.zero,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 30), // Increase content height
                    );
                  },
                );

                return; // Skip the rest of the logic as the pop-up is shown
              }

              bool isPrimeUser =
                  videoDetailsProvider.sectionDetailModel.result?.isBuy == 1;
              bool isPrimeUserCoin =
                  videoDetailsProvider.sectionDetailModel.result?.iscoinbuy ==
                      1;
              bool isAdShow =
                  videoDetailsProvider.sectionDetailModel.result?.isadshow == 1;
              bool isRenteBuy =
                  videoDetailsProvider.sectionDetailModel.result?.rentBuy == 1;

              if ((Platform.isAndroid && generalProvider.rewardad == "0") ||
                  (Platform.isIOS && generalProvider.rewardadIos == "0")) {
                openPlayer("Video");
                return;
              }

              if ((Platform.isAndroid && generalProvider.rewardad == "1") ||
                  (Platform.isIOS && generalProvider.rewardadIos == "1")) {
                if (isPrimeUser || isPrimeUserCoin || isRenteBuy) {
                  openPlayer("Video");
                } else {
                  if (isAdShow) {
                    AdHelper.showRewardedAd(
                      onAdCompleted: () async {
                        await walletProvider.addCoinsAfterWatchAd(
                          Constant.userID!,
                          videoDetailsProvider.sectionDetailModel.result?.id ??
                              '',
                          0,
                          generalProvider.isAdsCoin,
                        );
                        openPlayer("Video");
                      },
                      onAdFailed: () {
                        openPlayer("Video");
                      },
                    );
                  } else {
                    openPlayer("Video");
                  }
                }
              }
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LoginSocial(),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(5),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              height: (kIsWeb || Constant.isTV) ? 40 : 40,
              constraints: BoxConstraints(
                maxWidth: (kIsWeb || Constant.isTV)
                    ? 180
                    : MediaQuery.of(context).size.width,
              ),
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
              decoration: BoxDecoration(
                color: primaryDark,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyImage(
                    width: 18,
                    height: 18,
                    imagePath: "ic_play.png",
                    color: black,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: MyText(
                      color: black,
                      text: "watch_now",
                      multilanguage: true,
                      textalign: TextAlign.start,
                      fontsizeNormal: 15,
                      fontweight: FontWeight.w600,
                      fontsizeWeb: 16,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  // Widget _buildWatchNow() {
  //   if ((videoDetailsProvider.sectionDetailModel.result?.stopTime ?? 0) > 0 &&
  //       videoDetailsProvider.sectionDetailModel.result?.videoDuration != null) {
  //     return Container(
  //       alignment: Alignment.centerLeft,
  //       child: InkWell(
  //         onTap: () async {
  //           if (Constant.userID != null) {
  //             // Check if the user is a "prime" user or has other access
  //             bool isPrimeUser =
  //                 videoDetailsProvider.sectionDetailModel.result?.isBuy == 1;
  //             bool isPrimeUserCoin =
  //                 videoDetailsProvider.sectionDetailModel.result?.iscoinbuy ==
  //                     1; // Prime user with coins
  //             bool isAdShow =
  //                 videoDetailsProvider.sectionDetailModel.result?.isadshow ==
  //                     1; // Check if ad should be shown
  //             bool isRenteBuy =
  //                 videoDetailsProvider.sectionDetailModel.result?.rentBuy ==
  //                     1; // Rent buy access

  //             bool isCoinFeatureEnable = generalProvider.isCoinShow == "1";

  //             print(
  //                 "Prime User---:mat ${videoDetailsProvider.sectionDetailModel.result?.maturityRating}");
  //             print("Prime User: $isPrimeUser");
  //             print("Prime User with Coins: $isPrimeUserCoin");
  //             print("Show Ad: $isAdShow");
  //             print("Rent Buy: $isRenteBuy");

  //             // Check if rewardad is disabled for Android or iOS
  //             if ((Platform.isAndroid && generalProvider.rewardad == "0") ||
  //                 (Platform.isIOS && generalProvider.rewardadIos == "0")) {
  //               print(
  //                   "Rewarded ad is disabled for this platform. Opening player directly.");
  //               openPlayer("Video");
  //               return; // Exit early since the ad logic is bypassed
  //             }

  //             if ((Platform.isAndroid && generalProvider.rewardad == "1") ||
  //                 (Platform.isIOS && generalProvider.rewardadIos == "1")) {
  //               print("Rewarded ad is enable for this platform. Ope.");
  //               if (isPrimeUser || isPrimeUserCoin || isRenteBuy) {
  //                 // If the user is prime, directly navigate to the player
  //                 openPlayer("Video");
  //               } else {
  //                 // Non-prime user, show ad if necessary
  //                 if (isAdShow) {
  //                   print("Ad should be shown");

  //                   // Show the rewarded ad

  //                   // Show the rewarded ad
  //                   AdHelper.showRewardedAd(
  //                     onAdCompleted: () async {
  //                       print(
  //                           "Rewarded ad completed. Proceeding with API call...");

  //                       try {
  //                         print("API call to add coins started...");
  //                         await walletProvider.addCoinsAfterWatchAd(
  //                           Constant.userID!,
  //                           videoDetailsProvider
  //                                   .sectionDetailModel.result?.id ??
  //                               '',
  //                           0,
  //                           generalProvider.isAdsCoin,
  //                         );
  //                         print("Coins added successfully!");
  //                         // Open the player after coins are added
  //                         openPlayer("Video");
  //                       } catch (error) {
  //                         print("Error while adding coins: $error");
  //                       }
  //                     },
  //                     onAdFailed: () {
  //                       print(
  //                           "Ad failed or was not completed. Skipping API call.");
  //                     },
  //                   );
  //                 } else {
  //                   // If the ad shouldn't be shown, directly proceed
  //                   openPlayer("Video");
  //                 }
  //               }
  //               return;
  //             }
  //           } else {
  //             Navigator.of(context).push(
  //               MaterialPageRoute(
  //                 builder: (context) => const LoginSocial(),
  //               ),
  //             );
  //           }
  //         },
  //         borderRadius: BorderRadius.circular(5),
  //         child: Padding(
  //           padding: const EdgeInsets.all(2.0),
  //           child: Container(
  //             height: (kIsWeb || Constant.isTV) ? 40 : 55,
  //             constraints: BoxConstraints(
  //               maxWidth: (kIsWeb || Constant.isTV)
  //                   ? 190
  //                   : MediaQuery.of(context).size.width,
  //             ),
  //             decoration: BoxDecoration(
  //               color: primaryDark,
  //               borderRadius: BorderRadius.circular(5),
  //             ),
  //             child: Column(
  //               children: [
  //                 Expanded(
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.start,
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     children: [
  //                       const SizedBox(width: 20),
  //                       MyImage(
  //                         width: 18,
  //                         height: 18,
  //                         imagePath: "ic_play.png",
  //                         color: black,
  //                       ),
  //                       const SizedBox(width: 15),
  //                       Expanded(
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                           children: [
  //                             MyText(
  //                               color: black,
  //                               text: "continuewatching",
  //                               multilanguage: true,
  //                               textalign: TextAlign.start,
  //                               fontsizeNormal: 13,
  //                               fontsizeWeb: 15,
  //                               fontweight: FontWeight.w600,
  //                               maxline: 1,
  //                               overflow: TextOverflow.ellipsis,
  //                               fontstyle: FontStyle.normal,
  //                             ),
  //                             Row(
  //                               children: [
  //                                 MyText(
  //                                   color: black,
  //                                   text: Utils.remainTimeInMin(
  //                                       ((videoDetailsProvider
  //                                                       .sectionDetailModel
  //                                                       .result
  //                                                       ?.videoDuration ??
  //                                                   0) -
  //                                               (videoDetailsProvider
  //                                                       .sectionDetailModel
  //                                                       .result
  //                                                       ?.stopTime ??
  //                                                   0))
  //                                           .abs()),
  //                                   textalign: TextAlign.start,
  //                                   fontsizeNormal: 10,
  //                                   fontweight: FontWeight.w500,
  //                                   fontsizeWeb: 12,
  //                                   multilanguage: false,
  //                                   maxline: 1,
  //                                   overflow: TextOverflow.ellipsis,
  //                                   fontstyle: FontStyle.normal,
  //                                 ),
  //                                 const SizedBox(width: 5),
  //                                 MyText(
  //                                   color: black,
  //                                   text: "left",
  //                                   textalign: TextAlign.start,
  //                                   fontsizeNormal: 10,
  //                                   fontweight: FontWeight.w500,
  //                                   fontsizeWeb: 12,
  //                                   multilanguage: true,
  //                                   maxline: 1,
  //                                   overflow: TextOverflow.ellipsis,
  //                                   fontstyle: FontStyle.normal,
  //                                 ),
  //                               ],
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       const SizedBox(width: 20),
  //                     ],
  //                   ),
  //                 ),
  //                 Container(
  //                   height: 4,
  //                   constraints: const BoxConstraints(minWidth: 0),
  //                   margin: const EdgeInsets.all(3),
  //                   child: LinearPercentIndicator(
  //                     padding: const EdgeInsets.all(0),
  //                     barRadius: const Radius.circular(2),
  //                     lineHeight: 4,
  //                     percent: Utils.getPercentage(
  //                         videoDetailsProvider
  //                                 .sectionDetailModel.result?.videoDuration ??
  //                             0,
  //                         videoDetailsProvider
  //                                 .sectionDetailModel.result?.stopTime ??
  //                             0),
  //                     backgroundColor: secProgressColor,
  //                     progressColor: colorPrimary,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   } else {
  //     return Container(
  //       alignment: Alignment.centerLeft,
  //       child: InkWell(
  //         onTap: () async {
  //           if (Constant.userID != null) {
  //             // Check if the user is a "prime" user or has other access
  //             bool isPrimeUser =
  //                 videoDetailsProvider.sectionDetailModel.result?.isBuy == 1;
  //             bool isPrimeUserCoin =
  //                 videoDetailsProvider.sectionDetailModel.result?.iscoinbuy ==
  //                     1; // Prime user with coins
  //             bool isAdShow =
  //                 videoDetailsProvider.sectionDetailModel.result?.isadshow ==
  //                     1; // Check if ad should be shown
  //             bool isRenteBuy =
  //                 videoDetailsProvider.sectionDetailModel.result?.rentBuy ==
  //                     1; // Rent buy access

  //             print("Prime User: $isPrimeUser");
  //             print("Prime User with Coins: $isPrimeUserCoin");
  //             print("Show Ad: $isAdShow");
  //             print("Rent Buy: $isRenteBuy");

  //             // Check if rewardad is disabled for Android or iOS
  //             if ((Platform.isAndroid && rewardad == "0") ||
  //                 (Platform.isIOS && rewardadIos == "0")) {
  //               print(
  //                   "Rewarded ad is disabled for this platform. Opening player directly.");
  //               openPlayer("Video");
  //               return; // Exit early since the ad logic is bypassed
  //             }

  //             // Check access conditions
  //             if (isPrimeUser || isPrimeUserCoin || isRenteBuy) {
  //               // If the user is prime, directly navigate to the player
  //               openPlayer("Video");
  //             } else {
  //               // Non-prime user, show ad if necessary
  //               if (isAdShow) {
  //                 print("Ad should be shown");

  //                 // Show the rewarded ad
  //                 // Show the rewarded ad
  //                 AdHelper.showRewardedAd(
  //                   onAdCompleted: () async {
  //                     print(
  //                         "Rewarded ad completed. Proceeding with API call...");

  //                     try {
  //                       print("API call to add coins started...");
  //                       await walletProvider.addCoinsAfterWatchAd(
  //                         Constant.userID!,
  //                         videoDetailsProvider.sectionDetailModel.result?.id ??
  //                             '',
  //                         0,
  //                         generalProvider.isAdsCoin,
  //                       );
  //                       print("Coins added successfully!");
  //                       // Open the player after coins are added
  //                       openPlayer("Video");
  //                     } catch (error) {
  //                       print("Error while adding coins: $error");
  //                     }
  //                   },
  //                   onAdFailed: () {
  //                     print(
  //                         "Ad failed or was not completed. Skipping API call.");
  //                     openPlayer("Video");
  //                   },
  //                 );

  //                 // AdHelper.showRewardedAd(() async {
  //                 //   print("Rewarded ad dismissed");

  //                 //   // Handle the logic for adding coins after the ad is dismissed
  //                 //   try {
  //                 //     print("API call to add coins started...");
  //                 //     await walletProvider.addCoinsAfterWatchAd(
  //                 //       Constant.userID!,
  //                 //       videoDetailsProvider.sectionDetailModel.result?.id,
  //                 //       0,
  //                 //       generalProvider.isAdsCoin,
  //                 //     );
  //                 //     print("Coins added successfully!");
  //                 //     // After adding coins, open the player
  //                 //     openPlayer("Video");
  //                 //   } catch (error) {
  //                 //     print("Error while adding coins: $error");
  //                 //   }
  //                 // });
  //               } else {
  //                 // If the ad shouldn't be shown, directly proceed
  //                 openPlayer("Video");
  //               }
  //             }
  //           } else {
  //             Navigator.of(context).push(
  //               MaterialPageRoute(
  //                 builder: (context) => const LoginSocial(),
  //               ),
  //             );
  //           }
  //         },

  //         // onTap: () async {
  //         //   if (Constant.userID != null) {
  //         //     // Check if the user is a "prime" user
  //         //     bool isPrimeUser =
  //         //         videoDetailsProvider.sectionDetailModel.result?.isBuy == 1;
  //         //     bool isPrimeUserCoin =
  //         //         videoDetailsProvider.sectionDetailModel.result?.iscoinbuy ==
  //         //             1; // Prime user
  //         //     bool isAdShow =
  //         //         videoDetailsProvider.sectionDetailModel.result?.isadshow == 1;
  //         //     bool isRenteBuy =
  //         //         videoDetailsProvider.sectionDetailModel.result?.rentBuy == 1;

  //         //     print("after show the add--${isPrimeUser}");
  //         //     print("after show the add--${isPrimeUserCoin}");
  //         //     print("after show the add--${isAdShow}");
  //         //     print("after show the add--${isRenteBuy}");

  //         //     if (isPrimeUser || isPrimeUserCoin || isRenteBuy) {
  //         //       // Prime user, directly navigate to the player
  //         //       openPlayer("Video");
  //         //     } else {
  //         //       // Non-prime user, show the ad if necessary
  //         //       if (isAdShow) {
  //         //         print("IS AD SHOW--");
  //         //         print("IS AD SHOW--${isAdShow}");

  //         //         // Show the rewarded ad
  //         //         AdHelper.showRewardedAd(() async {
  //         //           print("Rewarded ad dismissed");

  //         //           // Handle the logic for adding coins after the ad is dismissed
  //         //           try {
  //         //             print("Api call start--");
  //         //             await walletProvider.addCoinsAfterWatchAd(
  //         //               Constant.userID!,
  //         //               videoDetailsProvider.sectionDetailModel.result?.id,
  //         //               0,
  //         //               generalProvider.isAdsCoin,
  //         //             );
  //         //             print("Coins added successfully!");
  //         //           } catch (e) {
  //         //             print("Error adding coins: $e");
  //         //           }

  //         //           // Navigate to the player after the ad
  //         //           openPlayer("Video");
  //         //         });
  //         //       } else {
  //         //         // No ad to show, directly navigate to the player
  //         //         openPlayer("Video");
  //         //       }
  //         //     }
  //         //   } else {
  //         //     // User is not logged in, navigate to login screen
  //         //     Navigator.of(context).push(
  //         //       MaterialPageRoute(
  //         //         builder: (context) => const LoginSocial(),
  //         //       ),
  //         //     );
  //         //   }
  //         // }

  //         //focusColor:: white,
  //         borderRadius: BorderRadius.circular(5),
  //         child: Padding(
  //           padding: const EdgeInsets.all(2.0),
  //           child: Container(
  //             height: (kIsWeb || Constant.isTV) ? 40 : 55,
  //             constraints: BoxConstraints(
  //               maxWidth: (kIsWeb || Constant.isTV)
  //                   ? 180
  //                   : MediaQuery.of(context).size.width,
  //             ),
  //             padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
  //             decoration: BoxDecoration(
  //               color: primaryDark,
  //               borderRadius: BorderRadius.circular(5),
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.start,
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 MyImage(
  //                   width: 18,
  //                   height: 18,
  //                   imagePath: "ic_play.png",
  //                   color: black,
  //                 ),
  //                 const SizedBox(width: 15),
  //                 Expanded(
  //                   child: MyText(
  //                     color: black,
  //                     text: "watch_now",
  //                     multilanguage: true,
  //                     textalign: TextAlign.start,
  //                     fontsizeNormal: 15,
  //                     fontweight: FontWeight.w600,
  //                     fontsizeWeb: 16,
  //                     maxline: 1,
  //                     overflow: TextOverflow.ellipsis,
  //                     fontstyle: FontStyle.normal,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }

  Widget _buildTabs() {
    return Column(
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: (kIsWeb || Constant.isTV)
                ? (MediaQuery.of(context).size.width * 0.5)
                : MediaQuery.of(context).size.width,
          ),
          height: (kIsWeb || Constant.isTV) ? 35 : Dimens.detailTabs,
          child: Row(
            children: [
              /* Related */
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  //focusColor:: Colors.grey.withOpacity(0.5),
                  onTap: () async {
                    await videoDetailsProvider.setTabClick("related");
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: MyText(
                              color:
                                  videoDetailsProvider.tabClickedOn != "related"
                                      ? otherColor
                                      : white,
                              text: "related",
                              multilanguage: true,
                              textalign: TextAlign.center,
                              fontsizeNormal: 16,
                              fontweight: FontWeight.w600,
                              fontsizeWeb: 16,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        Visibility(
                          visible:
                              videoDetailsProvider.tabClickedOn == "related",
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 2,
                            color: white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              /* More Details */
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  //focusColor:: Colors.grey.withOpacity(0.5),
                  onTap: () async {
                    await videoDetailsProvider.setTabClick("moredetails");
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: MyText(
                              color: videoDetailsProvider.tabClickedOn !=
                                      "moredetails"
                                  ? otherColor
                                  : white,
                              text: "moredetails",
                              textalign: TextAlign.center,
                              fontsizeNormal: 16,
                              fontweight: FontWeight.w600,
                              fontsizeWeb: 16,
                              multilanguage: true,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: videoDetailsProvider.tabClickedOn ==
                              "moredetails",
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 2,
                            color: white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 0.5,
          color: otherColor,
          constraints: BoxConstraints(
            maxWidth: (kIsWeb || Constant.isTV)
                ? (MediaQuery.of(context).size.width * 0.5)
                : MediaQuery.of(context).size.width,
          ),
        ),
        /* Data */
        if (videoDetailsProvider.tabClickedOn == "related")
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* Customers also watched */
              RelatedVideoShow(
                relatedDataList:
                    videoDetailsProvider.sectionDetailModel.getRelatedVideo,
              ),
              /* Cast & Crew */
              CastCrew(castList: videoDetailsProvider.sectionDetailModel.cast),
              /* Director */
              _buildDirector(),
            ],
          )
        else
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: MoreDetails(
                moreDetailList:
                    videoDetailsProvider.sectionDetailModel.moreDetails),
          )
      ],
    );
  }

  Widget _buildDirector() {
    if (directorList != null && (directorList?.length ?? 0) > 0) {
      return Container(
        width: MediaQuery.of(context).size.width,
        constraints: BoxConstraints(
            minHeight: (kIsWeb || Constant.isTV)
                ? Dimens.heightCastWeb
                : Dimens.heightCast),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(Dimens.cardRadius),
              //focusColor:: white,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CastDetails(
                        castID: directorList?[0].id.toString() ?? ""),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.antiAlias,
                  children: <Widget>[
                    SizedBox(
                      height: (kIsWeb || Constant.isTV)
                          ? Dimens.heightCastWeb
                          : Dimens.heightCast,
                      width: (kIsWeb || Constant.isTV)
                          ? Dimens.widthCastWeb
                          : Dimens.widthCast,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Dimens.cardRadius),
                        child: MyUserNetworkImage(
                          imageUrl: directorList?[0].image ?? "",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(0),
                      height: (kIsWeb || Constant.isTV)
                          ? Dimens.heightCastWeb
                          : Dimens.heightCast,
                      width: (kIsWeb || Constant.isTV)
                          ? Dimens.widthCastWeb
                          : Dimens.widthCast,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [
                            transparentColor,
                            blackTransparent,
                            black,
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: (kIsWeb || Constant.isTV)
                          ? Dimens.widthCastWeb
                          : Dimens.widthCast,
                      padding: const EdgeInsets.all(5),
                      child: MyText(
                        multilanguage: false,
                        text: directorList?[0].name ?? "",
                        fontstyle: FontStyle.normal,
                        fontsizeNormal: 12,
                        fontweight: FontWeight.w500,
                        fontsizeWeb: 13,
                        maxline: 3,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.center,
                        color: white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  MyText(
                    color: white,
                    text: "directors",
                    multilanguage: true,
                    textalign: TextAlign.start,
                    fontsizeNormal: 13,
                    fontweight: FontWeight.w600,
                    fontsizeWeb: 15,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 6),
                  MyText(
                    color: otherColor,
                    text: directorList?[0].personalInfo ?? "",
                    textalign: TextAlign.start,
                    multilanguage: false,
                    fontsizeNormal: 12,
                    fontweight: FontWeight.w500,
                    fontsizeWeb: 14,
                    maxline: 7,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildFeatureBtn({
    required String title,
    required String icon,
    required bool multilanguage,
  }) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ((kIsWeb || Constant.isTV))
                ? Dimens.featureWebSize
                : Dimens.featureSize,
            height: ((kIsWeb || Constant.isTV))
                ? Dimens.featureWebSize
                : Dimens.featureSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: primaryLight,
              ),
              borderRadius: BorderRadius.circular((((kIsWeb || Constant.isTV))
                      ? Dimens.featureWebSize
                      : Dimens.featureSize) /
                  2),
            ),
            child: MyImage(
              width: ((kIsWeb || Constant.isTV))
                  ? Dimens.featureIconWebSize
                  : Dimens.featureIconSize,
              height: ((kIsWeb || Constant.isTV))
                  ? Dimens.featureIconWebSize
                  : Dimens.featureIconSize,
              color: lightGray,
              imagePath: icon,
            ),
          ),
          const SizedBox(height: 5),
          MyText(
            color: white,
            text: title,
            multilanguage: multilanguage,
            fontsizeNormal: 10,
            fontsizeWeb: 14,
            fontweight: FontWeight.w600,
            maxline: 2,
            overflow: TextOverflow.ellipsis,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
        ],
      ),
    );
  }

  /* ========= Download ========= */
  Widget _buildDownloadWithSubCheck() {
    if ((videoDetailsProvider.sectionDetailModel.result?.isPremium ?? 0) == 1 &&
        (videoDetailsProvider.sectionDetailModel.result?.isRent ?? 0) == 1) {
      if ((videoDetailsProvider.sectionDetailModel.result?.isBuy ?? 0) == 1 ||
          (videoDetailsProvider.sectionDetailModel.result?.rentBuy ?? 0) == 1) {
        return _buildDownloadBtn();
      } else {
        return const SizedBox.shrink();
      }
    } else if ((videoDetailsProvider.sectionDetailModel.result?.isPremium ??
            0) ==
        1) {
      if ((videoDetailsProvider.sectionDetailModel.result?.isBuy ?? 0) == 1) {
        return _buildDownloadBtn();
      } else {
        return const SizedBox.shrink();
      }
    } else if ((videoDetailsProvider.sectionDetailModel.result?.isRent ?? 0) ==
        1) {
      if ((videoDetailsProvider.sectionDetailModel.result?.rentBuy ?? 0) == 1) {
        return _buildDownloadBtn();
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return _buildDownloadBtn();
    }
  }

  Widget _buildDownloadBtn() {
    if (videoDetailsProvider.sectionDetailModel.result?.videoUploadType ==
            "server_video" ||
        videoDetailsProvider.sectionDetailModel.result?.videoUploadType ==
            "external") {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          //focusColor:: gray.withOpacity(0.5),
          onTap: () {
            if (Constant.userID != null) {
              if (videoDetailsProvider
                      .sectionDetailModel.result?.isDownloaded ==
                  0) {
                if (downloadProvider.dProgress == 0) {
                  _checkAndDownload();
                } else {
                  Utils.showSnackbar(context, "info", "please_wait", true);
                }
              } else {
                buildDownloadCompleteDialog();
              }
            } else {
              if ((kIsWeb || Constant.isTV)) {
                Utils.buildWebAlertDialog(context, "login", "")
                    .then((value) => _getData());
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const LoginSocial();
                  },
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Consumer2<VideoDetailsProvider, VideoDownloadProvider>(
                  builder:
                      (context, videoDetailsProvider, downloadProvider, child) {
                    if (downloadProvider.currentTasks != null &&
                        downloadProvider.currentTasks?[0].id ==
                            videoDetailsProvider
                                .sectionDetailModel.result?.id &&
                        downloadProvider.dProgress != 0 &&
                        downloadProvider.dProgress > 0) {
                      return CircularPercentIndicator(
                        radius: (Dimens.featureSize / 2),
                        lineWidth: 2.0,
                        percent: (downloadProvider.dProgress / 100).toDouble(),
                        center: MyText(
                          color: white,
                          text: "${downloadProvider.dProgress}%",
                          multilanguage: false,
                          fontsizeNormal: 10,
                          fontweight: FontWeight.w600,
                          fontsizeWeb: 14,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                        progressColor: colorPrimary,
                      );
                    } else {
                      return Container(
                        width: Dimens.featureSize,
                        height: Dimens.featureSize,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: primaryLight),
                          borderRadius:
                              BorderRadius.circular(Dimens.featureSize / 2),
                        ),
                        child: MyImage(
                          width: Dimens.featureIconSize,
                          height: Dimens.featureIconSize,
                          color: lightGray,
                          imagePath: (videoDetailsProvider.sectionDetailModel
                                      .result?.isDownloaded ==
                                  1)
                              ? "ic_download_done.png"
                              : "ic_download.png",
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 5),
                Consumer<VideoDetailsProvider>(
                  builder: (context, videoDetailsProvider, child) {
                    return MyText(
                      color: white,
                      text: (videoDetailsProvider
                                  .sectionDetailModel.result?.isDownloaded ==
                              1)
                          ? "complete"
                          : "download",
                      multilanguage: true,
                      fontsizeNormal: 10,
                      fontweight: FontWeight.w600,
                      fontsizeWeb: 14,
                      maxline: 2,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.center,
                      fontstyle: FontStyle.normal,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  _checkAndDownload() async {
    // _permissionReady = await Utils.checkPermission();
    // debugPrint("_permissionReady ====> $_permissionReady");
    // if (_permissionReady) {
    if (videoDetailsProvider.sectionDetailModel.result?.isDownloaded == 0) {
      if ((videoDetailsProvider.sectionDetailModel.result?.video320 ?? "")
          .isNotEmpty) {
        File? mTargetFile;
        String? localPath;
        String? mFileName =
            '${(videoDetailsProvider.sectionDetailModel.result?.name ?? "").replaceAll(" ", "")}'
            '${(videoDetailsProvider.sectionDetailModel.result?.id ?? 0)}${(Constant.userID)}';
        try {
          localPath = await Utils.prepareSaveDir();
          debugPrint("localPath ====> $localPath");
          mTargetFile = File(path.join(localPath,
              '$mFileName.${(videoDetailsProvider.sectionDetailModel.result?.videoExtension ?? "mp4")}'));
          // This is a sync operation on a real
          // app you'd probably prefer to use writeAsByte and handle its Future
        } catch (e) {
          debugPrint("saveVideoStorage Exception ===> $e");
        }
        debugPrint("mFileName ========> $mFileName");
        debugPrint("mTargetFile ========> ${mTargetFile?.absolute.path ?? ""}");
        if (mTargetFile != null) {
          try {
            downloadProvider.prepareDownload(
                videoDetailsProvider.sectionDetailModel.result,
                localPath,
                mFileName);
            debugPrint("mTargetFile length ========> ${mTargetFile.length()}");
          } catch (e) {
            debugPrint("Downloading... Exception ======> $e");
          }
        }
      } else {
        if (!mounted) return;
        Utils.showSnackbar(context, "fail", "invalid_url", true);
      }
    }
    // }
  }

  buildDownloadCompleteDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: lightBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(23),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MyText(
                    text: "download_options",
                    multilanguage: true,
                    fontsizeNormal: 16,
                    color: white,
                    fontstyle: FontStyle.normal,
                    fontweight: FontWeight.w700,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.start,
                  ),
                  const SizedBox(height: 5),
                  MyText(
                    text: "download_options_note",
                    multilanguage: true,
                    fontsizeNormal: 10,
                    color: otherColor,
                    fontstyle: FontStyle.normal,
                    fontweight: FontWeight.w500,
                    maxline: 5,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.start,
                  ),
                  const SizedBox(height: 12),

                  /* To Download */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    //focusColor:: white,
                    onTap: () async {
                      Navigator.pop(context);
                      if (Constant.userID != null) {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MyDownloads(),
                          ),
                        );
                        setState(() {});
                      } else {
                        if ((kIsWeb || Constant.isTV)) {
                          Utils.buildWebAlertDialog(context, "login", "")
                              .then((value) => _getData());
                          return;
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginSocial(),
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: Dimens.minHtDialogContent,
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MyImage(
                            width: Dimens.dialogIconSize,
                            height: Dimens.dialogIconSize,
                            imagePath: "ic_setting.png",
                            fit: BoxFit.fill,
                            color: lightGray,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: MyText(
                              text: "take_me_to_the_downloads_page",
                              multilanguage: true,
                              fontsizeNormal: 14,
                              color: white,
                              fontstyle: FontStyle.normal,
                              fontweight: FontWeight.w600,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              textalign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /* Delete */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    //focusColor:: white,
                    onTap: () async {
                      Navigator.pop(context);
                      await videoDetailsProvider.setDownloadComplete(
                          context,
                          videoDetailsProvider.sectionDetailModel.result?.id,
                          videoDetailsProvider
                              .sectionDetailModel.result?.videoType,
                          videoDetailsProvider
                              .sectionDetailModel.result?.typeId);
                      await downloadProvider.deleteVideoFromDownload(
                          videoDetailsProvider.sectionDetailModel.result?.id
                                  .toString() ??
                              "");
                    },
                    child: Container(
                      height: Dimens.minHtDialogContent,
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MyImage(
                            width: Dimens.dialogIconSize,
                            height: Dimens.dialogIconSize,
                            imagePath: "ic_delete.png",
                            fit: BoxFit.fill,
                            color: lightGray,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: MyText(
                              text: "delete_download",
                              multilanguage: true,
                              fontsizeNormal: 14,
                              color: white,
                              fontstyle: FontStyle.normal,
                              fontweight: FontWeight.w600,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              textalign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
  /* ========= Download ========= */

  /* ========= Dialogs ========= */
  buildLangSubtitleDialog(List<Language>? languageList) {
    debugPrint("languageList Size ===> ${languageList?.length ?? 0}");
    String? audioLanguages;
    if ((languageList?.length ?? 0) > 0) {
      for (int i = 0; i < (languageList?.length ?? 0); i++) {
        if (i == 0) {
          audioLanguages = languageList?[i].name ?? "";
        } else {
          audioLanguages = "$audioLanguages, ${languageList?[i].name ?? ""}";
        }
      }
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: lightBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MyText(
                    text: "avalablelanguage",
                    fontsizeNormal: 17,
                    fontweight: FontWeight.w700,
                    fontsizeWeb: 18,
                    fontstyle: FontStyle.normal,
                    maxline: 1,
                    multilanguage: true,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.start,
                    color: white,
                  ),
                  const SizedBox(height: 5),
                  MyText(
                    text: "languagechangenote",
                    fontsizeNormal: 13,
                    fontweight: FontWeight.w500,
                    fontsizeWeb: 14,
                    fontstyle: FontStyle.normal,
                    maxline: 1,
                    multilanguage: true,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.start,
                    color: otherColor,
                  ),
                  const SizedBox(height: 10),
                  MyText(
                    text: "audios",
                    fontsizeNormal: 17,
                    fontweight: FontWeight.w500,
                    fontsizeWeb: 18,
                    fontstyle: FontStyle.normal,
                    maxline: 1,
                    multilanguage: true,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.start,
                    color: white,
                  ),
                  const SizedBox(height: 2),
                  MyText(
                    text: audioLanguages ?? "-",
                    fontsizeNormal: 13,
                    fontweight: FontWeight.w500,
                    fontsizeWeb: 14,
                    fontstyle: FontStyle.normal,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.start,
                    color: otherColor,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 0.7,
                    margin: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                    color: otherColor,
                  ),
                  MyText(
                    text: "subtitle",
                    fontsizeNormal: 17,
                    fontweight: FontWeight.w700,
                    fontsizeWeb: 16,
                    multilanguage: true,
                    fontstyle: FontStyle.normal,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.start,
                    color: white,
                  ),
                  const SizedBox(height: 2),
                  MyText(
                    text: Constant.subtitleUrls.isNotEmpty ? "Available" : "-",
                    fontsizeNormal: 16,
                    fontweight: FontWeight.w500,
                    fontsizeWeb: 17,
                    fontstyle: FontStyle.normal,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.start,
                    color: otherColor,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  buildMoreDialog(stopTime) {
    showModalBottomSheet(
      context: context,
      backgroundColor: lightBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  /* Share */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    //focusColor:: white,
                    onTap: () {
                      Navigator.pop(context);
                      analytics.logEvent(
                        name: 'share_video',
                        parameters: {
                          'video_id': widget.videoId,
                          'video_name': videoDetailsProvider
                                  .sectionDetailModel.result?.name ??
                              "",
                          'type_id': widget.typeId,
                          'video_type': widget.videoType,
                        },
                      );
                      Map<String, Object> screenViewEvent = {
                        'event_name': 'share_video',
                        'video_id': widget.videoId,
                        'video_name': videoDetailsProvider
                                .sectionDetailModel.result?.name ??
                            "",
                        'type_id': widget.typeId,
                        'user_id': Constant.userID.toString(),
                      };
                      Singular.eventWithArgs('share_video', screenViewEvent);
                      buildShareWithDialog();
                    },
                    child: _buildDialogItems(
                      icon: "ic_share.png",
                      title: "share",
                      isMultilang: true,
                    ),
                  ),

                  /* Trailer */
                  stopTime > 0
                      ? InkWell(
                          borderRadius: BorderRadius.circular(5),
                          //focusColor:: white,
                          onTap: () {
                            Navigator.pop(context);
                            analytics.logEvent(
                              name: 'watch_trailer',
                              parameters: {
                                'video_id': widget.videoId,
                                'video_name': videoDetailsProvider
                                        .sectionDetailModel.result?.name ??
                                    "",
                                'stop_time': stopTime,
                              },
                            );
                            Map<String, Object> screenViewEvent = {
                              'event_name': 'watch_trailer',
                              'video_id': widget.videoId,
                              'video_name': videoDetailsProvider
                                      .sectionDetailModel.result?.name ??
                                  "",
                              'stop_time': stopTime,
                              'user_id': Constant.userID.toString(),
                            };
                            Singular.eventWithArgs(
                                'watch_trailer', screenViewEvent);
                            openPlayer("Trailer");
                          },
                          child: _buildDialogItems(
                            icon: "ic_borderplay.png",
                            title: "trailer",
                            isMultilang: true,
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  buildShareWithDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: lightBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(23),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MyText(
                    text:
                        videoDetailsProvider.sectionDetailModel.result?.name ??
                            "",
                    multilanguage: false,
                    fontsizeNormal: 18,
                    fontsizeWeb: 18,
                    color: white,
                    fontstyle: FontStyle.normal,
                    fontweight: FontWeight.w700,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.start,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      (videoDetailsProvider.sectionDetailModel.result
                                      ?.ageRestriction ??
                                  "")
                              .isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: Utils.setBGWithBorder(
                                  transparentColor, otherColor, 3, 0.7),
                              child: MyText(
                                text: videoDetailsProvider.sectionDetailModel
                                        .result?.ageRestriction ??
                                    "",
                                multilanguage: false,
                                fontsizeNormal: 10,
                                fontsizeWeb: 12,
                                color: otherColor,
                                fontstyle: FontStyle.normal,
                                fontweight: FontWeight.w500,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                textalign: TextAlign.start,
                              ),
                            )
                          : const SizedBox.shrink(),
                      MyImage(
                        width: 18,
                        height: 18,
                        imagePath: "ic_comment.png",
                        fit: BoxFit.fill,
                        color: lightGray,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  /* SMS */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    //focusColor:: white,
                    onTap: () {
                      Navigator.pop(context);
                      analytics.logEvent(
                        name: 'share_video_sms',
                        parameters: {
                          'video_id': widget.videoId,
                          'video_name': videoDetailsProvider
                                  .sectionDetailModel.result?.name ??
                              "",
                          'type_id': widget.typeId,
                          'video_type': widget.videoType,
                        },
                      );
                      Map<String, Object> screenViewEvent = {
                        'event_name': 'share_video_sms',
                        'video_id': widget.videoId,
                        'video_name': videoDetailsProvider
                                .sectionDetailModel.result?.name ??
                            "",
                        'type_id': widget.typeId,
                        'video_type': widget.videoType,
                        'user_id': Constant.userID.toString(),
                      };
                      Singular.eventWithArgs(
                          'share_video_sms', screenViewEvent);
                      if (Platform.isAndroid) {
                        Utils.redirectToUrl(
                            'sms:?body=${Uri.encodeComponent("Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. Check it out now: ${Constant.dynamicBaseUrl}videodetails/${widget.typeId}/${widget.videoId}/${widget.upcomingType}/${widget.videoType} \n")}');
                        // 'sms:?body=${Uri.encodeComponent("Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n")}');
                      } else if (Platform.isIOS) {
                        Utils.redirectToUrl(
                            'sms:&body=${Uri.encodeComponent("Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}.\n Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/in/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n")}');
                        //'sms:&body=${Uri.encodeComponent("Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/in/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n")}');
                      }
                    },
                    child: _buildDialogItems(
                      icon: "ic_sms.png",
                      title: "sms",
                      isMultilang: true,
                    ),
                  ),

                  // /* Instgram Stories */
                  // InkWell(
                  //   borderRadius: BorderRadius.circular(5),
                  //   //focusColor:: white,
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //     Utils.shareApp(Platform.isIOS
                  //         ? "Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/in/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                  //         : "Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. \nCheck it out now: ${Constant.dynamicBaseUrl}videodetails/${widget.typeId}/${widget.videoId}/${widget.upcomingType}/${widget.videoType}\n");
                  //     // "Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
                  //   },
                  //   child: _buildDialogItems(
                  //     icon: "ic_insta.png",
                  //     title: "instagram_stories",
                  //     isMultilang: true,
                  //   ),
                  // ),

                  /* Copy Link */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    //focusColor:: white,
                    onTap: () {
                      Navigator.pop(context);
                      analytics.logEvent(
                        name: 'share_video_copy_link',
                        parameters: {
                          'video_id': widget.videoId,
                          'video_name': videoDetailsProvider
                                  .sectionDetailModel.result?.name ??
                              "",
                          'type_id': widget.typeId,
                          'video_type': widget.videoType,
                        },
                      );
                      final textToCopy = Platform.isIOS
                          ? "Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. \nCheck it out now: ${Constant.dynamicBaseUrl}home/${videoDetailsProvider.sectionDetailModel.result?.name?.toLowerCase().replaceAll(" ", "-")}/${base64Encode(utf8.encode('${widget.videoId}-${widget.typeId}-${widget.videoType}-${widget.upcomingType}'))} \n"
                          : "Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. \nCheck it out now: ${Constant.dynamicBaseUrl}home/${videoDetailsProvider.sectionDetailModel.result?.name?.toLowerCase().replaceAll(" ", "-")}/${base64Encode(utf8.encode('${widget.videoId}-${widget.typeId}-${widget.videoType}-${widget.upcomingType}'))} \n";

                      //"Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n",
                      // Use Flutter's Clipboard to copy text
                      Clipboard.setData(ClipboardData(text: textToCopy))
                          .then((_) {
                        Utils.showSnackbar(
                            context, "success", "link_copied", true);
                      }).catchError((error) {
                        debugPrint("Error copying to clipboard: $error");
                        Utils.showSnackbar(
                            context, "Error", "Failed to copy link", true);
                      });
                    },
                    child: _buildDialogItems(
                      icon: "ic_link.png",
                      title: "copy_link",
                      isMultilang: true,
                    ),
                  ),

                  /* More */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    //focusColor:: white,
                    onTap: () {
                      Navigator.pop(context);
                      Utils.shareApp(Platform.isIOS
                          ? "Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/in/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                          : "Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. \nCheck it out now: ${Constant.dynamicBaseUrl}videodetails/${widget.typeId}/${widget.videoId}/${widget.upcomingType}/${widget.videoType} \n");
                      //"Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
                    },
                    child: _buildDialogItems(
                      icon: "ic_dots_h.png",
                      title: "more",
                      isMultilang: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // buildShareWithDialog() {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: lightBlack,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
  //     ),
  //     clipBehavior: Clip.antiAliasWithSaveLayer,
  //     builder: (BuildContext context) {
  //       return Wrap(
  //         children: <Widget>[
  //           Container(
  //             padding: const EdgeInsets.all(23),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.start,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: <Widget>[
  //                 MyText(
  //                   text:
  //                       videoDetailsProvider.sectionDetailModel.result?.name ??
  //                           "",
  //                   multilanguage: false,
  //                   fontsizeNormal: 18,
  //                   fontsizeWeb: 18,
  //                   color: white,
  //                   fontstyle: FontStyle.normal,
  //                   fontweight: FontWeight.w700,
  //                   maxline: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                   textalign: TextAlign.start,
  //                 ),
  //                 const SizedBox(height: 5),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.start,
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     (videoDetailsProvider.sectionDetailModel.result
  //                                     ?.ageRestriction ??
  //                                 "")
  //                             .isNotEmpty
  //                         ? Container(
  //                             padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
  //                             margin: const EdgeInsets.only(right: 8),
  //                             decoration: Utils.setBGWithBorder(
  //                                 transparentColor, otherColor, 3, 0.7),
  //                             child: MyText(
  //                               text: videoDetailsProvider.sectionDetailModel
  //                                       .result?.ageRestriction ??
  //                                   "",
  //                               multilanguage: false,
  //                               fontsizeNormal: 10,
  //                               fontsizeWeb: 12,
  //                               color: otherColor,
  //                               fontstyle: FontStyle.normal,
  //                               fontweight: FontWeight.w500,
  //                               maxline: 1,
  //                               overflow: TextOverflow.ellipsis,
  //                               textalign: TextAlign.start,
  //                             ),
  //                           )
  //                         : const SizedBox.shrink(),
  //                     MyImage(
  //                       width: 18,
  //                       height: 18,
  //                       imagePath: "ic_comment.png",
  //                       fit: BoxFit.fill,
  //                       color: lightGray,
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 12),

  //                 /* SMS */
  //                 InkWell(
  //                   borderRadius: BorderRadius.circular(5),
  //                   //focusColor:: white,
  //                   onTap: () {
  //                     Navigator.pop(context);
  //                     if (Platform.isAndroid) {
  //                       Utils.redirectToUrl(
  //                           'sms:?body=${Uri.encodeComponent("Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. Check it out now: ${Constant.dynamicBaseUrl}videodetails/${widget.typeId}/${widget.videoId}/${widget.upcomingType}/${widget.videoType} \n")}');
  //                       // 'sms:?body=${Uri.encodeComponent("Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n")}');
  //                     } else if (Platform.isIOS) {
  //                       Utils.redirectToUrl(
  //                           'sms:&body=${Uri.encodeComponent("Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}.\n Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/in/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n")}');
  //                       //'sms:&body=${Uri.encodeComponent("Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/in/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n")}');
  //                     }
  //                   },
  //                   child: _buildDialogItems(
  //                     icon: "ic_sms.png",
  //                     title: "sms",
  //                     isMultilang: true,
  //                   ),
  //                 ),

  //                 /* Instgram Stories */
  //                 InkWell(
  //                   borderRadius: BorderRadius.circular(5),
  //                   //focusColor:: white,
  //                   onTap: () {
  //                     Navigator.pop(context);
  //                     Utils.shareApp(Platform.isIOS
  //                         ? "Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/in/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
  //                         : "Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. \nCheck it out now: ${Constant.dynamicBaseUrl}videodetails/${widget.typeId}/${widget.videoId}/${widget.upcomingType}/${widget.videoType}\n");
  //                     // "Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
  //                   },
  //                   child: _buildDialogItems(
  //                     icon: "ic_insta.png",
  //                     title: "instagram_stories",
  //                     isMultilang: true,
  //                   ),
  //                 ),

  //                 /* Copy Link */
  //                 InkWell(
  //                   borderRadius: BorderRadius.circular(5),
  //                   //focusColor:: white,
  //                   onTap: () {
  //                     Navigator.pop(context);
  //                     SocialShare.copyToClipboard(
  //                       text: Platform.isIOS
  //                           ? "Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/in/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
  //                           : "Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. \nCheck it out now: ${Constant.dynamicBaseUrl}videodetails/${widget.typeId}/${widget.videoId}/${widget.upcomingType}/${widget.videoType} \n",

  //                       //"Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n",
  //                     ).then((data) {
  //                       debugPrint(data);
  //                       Utils.showSnackbar(
  //                           context, "success", "link_copied", true);
  //                     });
  //                   },
  //                   child: _buildDialogItems(
  //                     icon: "ic_link.png",
  //                     title: "copy_link",
  //                     isMultilang: true,
  //                   ),
  //                 ),

  //                 /* More */
  //                 InkWell(
  //                   borderRadius: BorderRadius.circular(5),
  //                   //focusColor:: white,
  //                   onTap: () {
  //                     Navigator.pop(context);
  //                     Utils.shareApp(Platform.isIOS
  //                         ? "Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/in/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
  //                         : "Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. \nCheck it out now: ${Constant.dynamicBaseUrl}videodetails/${widget.typeId}/${widget.videoId}/${widget.upcomingType}/${widget.videoType} \n");
  //                     //"Hey! I'm watching ${videoDetailsProvider.sectionDetailModel.result?.name ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
  //                   },
  //                   child: _buildDialogItems(
  //                     icon: "ic_dots_h.png",
  //                     title: "more",
  //                     isMultilang: true,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _buildDialogItems({
    required String icon,
    required String title,
    required bool isMultilang,
  }) {
    return Container(
      height: Dimens.minHtDialogContent,
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MyImage(
            width: Dimens.dialogIconSize,
            height: Dimens.dialogIconSize,
            imagePath: icon,
            fit: BoxFit.contain,
            color: otherColor,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: MyText(
              text: title,
              multilanguage: isMultilang,
              fontsizeNormal: 14,
              fontsizeWeb: 16,
              color: white,
              fontstyle: FontStyle.normal,
              fontweight: FontWeight.w600,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
  /* ========= Dialogs ========= */

  /* ========= Open Player ========= */
  openPlayer(String playType) async {
    /* CHECK SUBSCRIPTION */
    if (playType != "Trailer") {
      // bool? isPrimiumUser = await _checkSubsRentLogin();
      bool? isPrimiumUser = await checkAndCallFunction();
      debugPrint("isPrimiumUser =============> $isPrimiumUser");
      if (!isPrimiumUser) return;
    }
    /* CHECK SUBSCRIPTION */
    debugPrint(
        "ID :===> ${(videoDetailsProvider.sectionDetailModel.result?.id ?? 0)}");

    int? vID = (videoDetailsProvider.sectionDetailModel.result?.id ?? 0);
    int? vType =
        (videoDetailsProvider.sectionDetailModel.result?.videoType ?? 0);
    int? vTypeID = widget.typeId;
    dynamic? trailerLibraryId,
        trailerUrlVideoId,
        videoLibraryId,
        videoUrlId,
        isLive;
    int? stopTime;
    if (playType == "startOver" || playType == "Trailer") {
      stopTime = 0;
    } else {
      stopTime =
          (videoDetailsProvider.sectionDetailModel.result?.stopTime ?? 0);
    }

    String? videoThumb =
        (videoDetailsProvider.sectionDetailModel.result?.landscape ?? "");

    String? vUrl, vUploadType;
    if (playType == "Trailer") {
      Utils.clearQualitySubtitle();
      vUploadType =
          (videoDetailsProvider.sectionDetailModel.result?.trailerType ?? "");
      vUrl = (videoDetailsProvider.sectionDetailModel.result?.trailerUrl ?? "");

      trailerLibraryId =
          (videoDetailsProvider.sectionDetailModel.result?.trailerLibraryId ??
              "");
      trailerUrlVideoId =
          (videoDetailsProvider.sectionDetailModel.result?.trailerVideoId ??
              "");
      print("Trailer Library Id>>>>>>>>>>>:${trailerLibraryId}");
      print("Trailer video Id>>>>>>>>>:${trailerUrlVideoId}");
    } else {
      /* Set-up Quality URLs */
      Utils.setQualityURLs(
        video320:
            (videoDetailsProvider.sectionDetailModel.result?.video320 ?? ""),
        video480:
            (videoDetailsProvider.sectionDetailModel.result?.video480 ?? ""),
        video720:
            (videoDetailsProvider.sectionDetailModel.result?.video720 ?? ""),
        video1080:
            (videoDetailsProvider.sectionDetailModel.result?.video1080 ?? ""),
      );
      videoLibraryId =
          (videoDetailsProvider.sectionDetailModel.result?.videoLibraryId ??
              "");
      videoUrlId =
          (videoDetailsProvider.sectionDetailModel.result?.urlVideoId ?? "");

      vUrl = (videoDetailsProvider.sectionDetailModel.result?.video320 ?? "");
      vUploadType =
          (videoDetailsProvider.sectionDetailModel.result?.videoUploadType ??
              "");
      isLive = videoDetailsProvider.sectionDetailModel.result?.isLiveUrl ?? "";
    }

    debugPrint("vUploadType ===> $vUploadType");
    debugPrint("stopTime ===> $stopTime");

    if (!mounted) return;
    if (vUrl.isEmpty || vUrl == "") {
      if (playType == "Trailer") {
        Utils.showSnackbar(context, "info", "trailer_not_found", true);
      } else {
        Utils.showSnackbar(context, "info", "video_not_found", true);
      }
      return;
    }

    dynamic isContinue;
    isContinue = await Utils.openPlayer(
        context: context,
        playType: playType == "Trailer" ? "Trailer" : "Video",
        videoId: vID,
        videoType: vType,
        typeId: vTypeID,
        otherId: 0,
        videoUrl: vUrl,
        trailerUrl: vUrl,
        uploadType: vUploadType,
        videoThumb: videoThumb,
        vStopTime: stopTime,
        trailerLibraryId: trailerLibraryId,
        trailerUrlVideoId: trailerUrlVideoId,
        videoLibraryId: videoLibraryId,
        videoUrlVideoId: videoUrlId,
        isLive: isLive);
    debugPrint("isContinue ===> $isContinue");
    if (isContinue != null && isContinue == true) {
      _getData();
    }
  }

  /* ========= Open Player ========= */

//1 with coin
  Future<bool> _checkSubsRentLogin() async {
    if (Constant.userID != null) {
      // Case 1: Premium + Rent Video with Coin Option
      if ((videoDetailsProvider.sectionDetailModel.result?.isPremium ?? 0) ==
              1 &&
          (videoDetailsProvider.sectionDetailModel.result?.isRent ?? 0) == 1 &&
          (videoDetailsProvider
                      .sectionDetailModel.result?.isabaletocoinpurches ??
                  0) ==
              1) {
        if ((videoDetailsProvider.sectionDetailModel.result?.isBuy ?? 0) == 1 ||
            (videoDetailsProvider.sectionDetailModel.result?.rentBuy ?? 0) ==
                1 ||
            (videoDetailsProvider.sectionDetailModel.result?.iscoinbuy ?? 0) ==
                1) {
          return true;
        } else {
          dynamic isSubscribed = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Subscription(),
            ),
          );
          if (isSubscribed == true) {
            _getData();
          }
          return false;
        }
      }

      // Case 2: Only Premium Video
      else if ((videoDetailsProvider.sectionDetailModel.result?.isPremium ??
              0) ==
          1) {
        if ((videoDetailsProvider.sectionDetailModel.result?.isBuy ?? 0) == 1) {
          return true;
        } else {
          dynamic isSubscribed = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Subscription(),
            ),
          );
          if (isSubscribed == true) {
            _getData();
          }
          return false;
        }
      }

      // Case 3: Rent Video with Coin Option but isRent == 0
      else if ((videoDetailsProvider.sectionDetailModel.result?.isRent ?? 0) ==
              0 &&
          (videoDetailsProvider
                      .sectionDetailModel.result?.isabaletocoinpurches ??
                  0) ==
              1) {
        if ((videoDetailsProvider.sectionDetailModel.result?.iscoinbuy ?? 0) ==
            1) {
          return true; // If already bought with coins, return false
        }

        // Show Bottom Sheet for Rent via Coin
        await showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          backgroundColor: Colors.black,
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Select Payment Method',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.grey, thickness: 1),

// Rent via Coin option
                  Consumer<WalletProvider>(
                    builder: (context, walletProvider, child) {
                      return ListTile(
                        leading: AnimatedGifWidget(
                          height: 50,
                          width: 50,
                        ),
                        title: const Text(
                          'Rent via Coin',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () async {
                          Navigator.pop(context); // Close the bottom sheet
                          try {
                            // Retrieve user balance and video coin value
                            dynamic userBalance =
                                homeProvider.userWalletBalanceModel?.balance ??
                                    0;
                            dynamic videoCoinValue = videoDetailsProvider
                                    .sectionDetailModel.result?.coinvalue ??
                                '0';

                            if (userBalance >= videoCoinValue) {
                              print("USER COME IN YTHE IF---");
                              // Sufficient balance, proceed with renting via coin
                              String userId = "${Constant.userID}";
                              String videoId = videoDetailsProvider
                                      .sectionDetailModel.result?.id
                                      .toString() ??
                                  '';
                              String noOfToken = videoDetailsProvider
                                      .sectionDetailModel.result?.coinvalue
                                      .toString() ??
                                  '0';

                              if (mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SuccessScreen(
                                      userId: userId,
                                      videoId: videoId,
                                      noOfToken: noOfToken,
                                    ),
                                  ),
                                );
                              }
                            } else {
                              // Insufficient balance, redirect to Coin Store
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CoinStoreScreen(),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Failed to process your request. Please try again.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );

        return false; // Continue as the user needs to choose payment
      }

      // Case 4: Only Rent Video with Coin Option
      else if ((videoDetailsProvider.sectionDetailModel.result?.isRent ?? 0) ==
          1) {
        // Sub-condition 1: Already rented or purchased with coins
        if ((videoDetailsProvider.sectionDetailModel.result?.rentBuy ?? 0) ==
                1 ||
            (videoDetailsProvider.sectionDetailModel.result?.iscoinbuy ?? 0) ==
                1) {
          return true;
        }

        // Sub-condition 2: Not rented/purchased, check payment options
        if ((videoDetailsProvider
                    .sectionDetailModel.result?.isabaletocoinpurches ??
                0) ==
            1) {
          await showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            backgroundColor: Colors.black,
            builder: (context) {
              final walletProvider =
                  Provider.of<WalletProvider>(context, listen: false);
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Select Payment Method',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.grey, thickness: 1),

                    // Rent via Payment option
                    ListTile(
                      leading: Image.asset(
                        'assets/images/rupee.png',
                        height: 30,
                        width: 30,
                      ),
                      title: const Text(
                        'Rent via Payment',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () async {
                        Navigator.pop(context); // Close the bottom sheet
                        dynamic isRented = await Utils.paymentForRent(
                          context: context,
                          videoId: videoDetailsProvider
                                  .sectionDetailModel.result?.id
                                  .toString() ??
                              '',
                          rentPrice: videoDetailsProvider
                                  .sectionDetailModel.result?.rentPrice
                                  .toString() ??
                              '',
                          vTitle: videoDetailsProvider
                                  .sectionDetailModel.result?.name
                                  .toString() ??
                              '',
                          typeId: videoDetailsProvider
                                  .sectionDetailModel.result?.typeId
                                  .toString() ??
                              '',
                          vType: videoDetailsProvider
                                  .sectionDetailModel.result?.videoType
                                  .toString() ??
                              '',
                        );
                        if (isRented == true) {
                          _getData();
                        }
                      },
                    ),
                    const Divider(color: Colors.grey, thickness: 1),

                    // Rent via Coin option
// Rent via Coin option
                    Consumer<WalletProvider>(
                      builder: (context, walletProvider, child) {
                        return ListTile(
                          leading: AnimatedGifWidget(
                            height: 50,
                            width: 50,
                          ),
                          title: const Text(
                            'Rent via Coin',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () async {
                            Navigator.pop(context); // Close the bottom sheet
                            try {
                              // Retrieve user balance and video coin value
                              dynamic userBalance = homeProvider
                                      .userWalletBalanceModel?.balance ??
                                  0;
                              dynamic videoCoinValue = videoDetailsProvider
                                      .sectionDetailModel.result?.coinvalue ??
                                  '0';

                              if (userBalance >= videoCoinValue) {
                                print("USER COME IN YTHE IF---");
                                // Sufficient balance, proceed with renting via coin
                                String userId = "${Constant.userID}";
                                String videoId = videoDetailsProvider
                                        .sectionDetailModel.result?.id
                                        .toString() ??
                                    '';
                                String noOfToken = videoDetailsProvider
                                        .sectionDetailModel.result?.coinvalue
                                        .toString() ??
                                    '0';

                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SuccessScreen(
                                        userId: userId,
                                        videoId: videoId,
                                        noOfToken: noOfToken,
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                // Insufficient balance, redirect to Coin Store
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CoinStoreScreen(),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Failed to process your request. Please try again.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );

          return false;
        }

        // Sub-condition 3: Redirect to Rent Payment
        dynamic isRented = await Utils.paymentForRent(
          context: context,
          videoId:
              videoDetailsProvider.sectionDetailModel.result?.id.toString() ??
                  '',
          rentPrice: videoDetailsProvider.sectionDetailModel.result?.rentPrice
                  .toString() ??
              '',
          vTitle:
              videoDetailsProvider.sectionDetailModel.result?.name.toString() ??
                  '',
          typeId: videoDetailsProvider.sectionDetailModel.result?.typeId
                  .toString() ??
              '',
          vType: videoDetailsProvider.sectionDetailModel.result?.videoType
                  .toString() ??
              '',
        );
        if (isRented == true) {
          _getData();
        }
        return false;
      }

      // General Case: Access allowed by default
      return true;
    } else {
      // User is not logged in
      if (kIsWeb || Constant.isTV) {
        Utils.buildWebAlertDialog(context, "login", "")
            .then((value) => _getData());
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginSocial(),
          ),
        );
      }
      return false;
    }
  }

//2nd without coin

  Future<bool> _checkSubsRentLoginWithoutCoin() async {
    if (Constant.userID != null) {
      if ((videoDetailsProvider.sectionDetailModel.result?.isPremium ?? 0) ==
              1 &&
          (videoDetailsProvider.sectionDetailModel.result?.isRent ?? 0) == 1) {
        if ((videoDetailsProvider.sectionDetailModel.result?.isBuy ?? 0) == 1 ||
            (videoDetailsProvider.sectionDetailModel.result?.rentBuy ?? 0) ==
                1) {
          return true;
        } else {
          dynamic isSubscribed = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const Subscription();
              },
            ),
          );
          if (isSubscribed != null && isSubscribed == true) {
            _getData();
          }
          return false;
        }
      } else if ((videoDetailsProvider.sectionDetailModel.result?.isPremium ??
              0) ==
          1) {
        if ((videoDetailsProvider.sectionDetailModel.result?.isBuy ?? 0) == 1) {
          return true;
        } else {
          dynamic isSubscribed = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const Subscription();
              },
            ),
          );
          if (isSubscribed != null && isSubscribed == true) {
            _getData();
          }
          return false;
        }
      } else if ((videoDetailsProvider.sectionDetailModel.result?.isRent ??
              0) ==
          1) {
        if ((videoDetailsProvider.sectionDetailModel.result?.rentBuy ?? 0) ==
            1) {
          return true;
        } else {
          dynamic isRented = await Utils.paymentForRent(
            context: context,
            videoId:
                videoDetailsProvider.sectionDetailModel.result?.id.toString() ??
                    '',
            rentPrice: videoDetailsProvider.sectionDetailModel.result?.rentPrice
                    .toString() ??
                '',
            vTitle: videoDetailsProvider.sectionDetailModel.result?.name
                    .toString() ??
                '',
            typeId: videoDetailsProvider.sectionDetailModel.result?.typeId
                    .toString() ??
                '',
            vType: videoDetailsProvider.sectionDetailModel.result?.videoType
                    .toString() ??
                '',
          );
          if (isRented != null && isRented == true) {
            _getData();
          }
          return false;
        }
      } else {
        return true;
      }
    } else {
      if ((kIsWeb || Constant.isTV)) {
        Utils.buildWebAlertDialog(context, "login", "")
            .then((value) => _getData());
        return false;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const LoginSocial();
          },
        ),
      );
      return false;
    }
  }

  Future<bool> checkAndCallFunction() async {
    if (generalProvider.isCoinShow == "0") {
      // Call the second method when `isCoinShow` is  "0"
      return await _checkSubsRentLoginWithoutCoin();
    } else {
      // Call the first method when `isCoinShow` is not "0"
      return await _checkSubsRentLogin();
    }
  }
}
