import 'dart:developer';
import 'package:dtlive/main.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/widget/mynetworkimg.dart';
import 'package:flutter/material.dart';
import 'package:moengage_flutter/moengage_flutter.dart';
import 'package:provider/provider.dart';
import 'package:singular_flutter_sdk/singular.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../provider/channelsectionprovider.dart';
import 'package:dtlive/model/channelsectionmodel.dart';
import 'package:flutter/cupertino.dart';

import '../utils/moenage_service.dart'; // Import Cupertino icons

class NewLivePlayer extends StatefulWidget {
  const NewLivePlayer({super.key});

  @override
  State<NewLivePlayer> createState() => _NewLivePlayerState();
}

class _NewLivePlayerState extends State<NewLivePlayer>
    with TickerProviderStateMixin {
  String? videoId;
  late ChannelSectionProvider channelSectionProvider;
  bool isLoading = true;
  int? selectedTileIndex;
  TabController? _tabController;
  String? videoURL;
  int playerInfo = 0;
  //0=loading
  //1=yt
  //2=m3u8
  YoutubePlayerController? _liveYoutubeController;
  VideoPlayerController? _liveNormalController;

  @override
  void initState() {
    super.initState();
    channelSectionProvider =
        Provider.of<ChannelSectionProvider>(context, listen: false);
    getData();
    trackMoEngageEventOnce();
  }
  bool _eventTracked = false;

  void trackMoEngageEventOnce() {
    if (_eventTracked) return;
    _eventTracked = true;

    final properties = MoEProperties()
      ..addAttribute('screen_name', 'Live Channels Screen')
      ..addAttribute('timestamp', DateTime.now().toIso8601String());


    Future.delayed(Duration(seconds: 2), () {

      MoEngageService.instance.trackEvent('screen_view', properties);
    });
  }

  Future<void> getData() async {
    await channelSectionProvider.getChannelSection().then((value) {
      if (channelSectionProvider.channelSectionModel.result != null) {
        _tabController = TabController(
          length: channelSectionProvider.channelSectionModel.result!
              .where(
                  (section) => section.data != null && section.data!.isNotEmpty)
              .length,
          vsync: this,
        );
        _tabController!.addListener(() {
          if (_tabController!.indexIsChanging) {
            setState(() {
              selectedTileIndex = 0;
            });
          }
        });
        selectedTileIndex = 0;
        addVideoLinkOfSelectedTile(0, 0);
      }

      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _liveYoutubeController?.close();
    _liveNormalController?.dispose();
    super.dispose();
  }

  Future<void> addVideoLinkOfSelectedTile(int index1, int index2) async {
    _liveNormalController?.dispose();
    setState(() {
      playerInfo = 0;
      videoURL = channelSectionProvider
          .channelSectionModel.result?[index1].data?[index2].video320;
    });
    log("SELECTED VIDEO URL $videoURL");

    if (videoURL != null && videoURL!.contains("youtube")) {
      log("SELECTED VIDEO URL IS YOUTUBE");

      if (_liveYoutubeController == null) {
        _liveYoutubeController = YoutubePlayerController.fromVideoId(
          videoId: YoutubePlayerController.convertUrlToId(videoURL!)!,
          autoPlay: true,
          params: const YoutubePlayerParams(
            showControls: false,
            showVideoAnnotations: false,
            playsInline: false,
            mute: false,
            showFullscreenButton: true,
            loop: false,
          ),
        );
      } else {
        _liveYoutubeController?.loadVideo(videoURL!);
      }

      setState(() {
        playerInfo = 1;
      });
    } else {
      log("SELECTED VIDEO URL NOT YOUTUBE");
      _liveNormalController?.dispose();
      _liveNormalController =
          VideoPlayerController.networkUrl(Uri.parse(videoURL ?? ""))
            ..initialize().then((_) {
              setState(() {
                _liveNormalController?.play();
              });
            }).catchError((error) {
              log('VideoPlayerController initialization error: $error');
            });
      setState(() {
        playerInfo = 2;
      });
    }
  }

  void _togglePlayPause() {
    if (_liveNormalController != null) {
      setState(() {
        if (_liveNormalController!.value.isPlaying) {
          _liveNormalController!.pause();
        } else {
          _liveNormalController!.play();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    analytics.logEvent(
      name: "screen_view",
      parameters: {
        "screen_name": "Live Channels Screen",
        "user_id": Constant.userID,
      },
    );

    Map<String, Object> screenViewEvent = {
      'screen_name': 'Live Channels Screen',
      'user_id': Constant.userID.toString(),
    };

    Singular.eventWithArgs('screen_view', screenViewEvent);


    log("LENGTHHH ${channelSectionProvider.channelSectionModel.result?.length}");
    final List<Result>? validResults = channelSectionProvider
        .channelSectionModel.result
        ?.where((section) => section.data != null && section.data!.isNotEmpty)
        .toList();

    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
            color: colorPrimary,
          ))
        : validResults == null || validResults.isEmpty
            ? const Center(
                child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : DefaultTabController(
                length: validResults.length,
                child: Scaffold(
                  backgroundColor: appBgColor,
                  appBar: AppBar(
                    backgroundColor: appBgColor,
                    foregroundColor: appBgColor,
                    surfaceTintColor: appBgColor,
                    automaticallyImplyLeading: true,
                    titleSpacing: 0.0,
                    bottom: _tabController != null
                        ? TabBar(
                            indicatorColor: colorPrimary,
                            controller: _tabController,
                            isScrollable: true,
                            tabs: List<Widget>.generate(
                              validResults.length,
                              (int index) {
                                return Tab(
                                  text: validResults[index].title,
                                );
                              },
                            ),
                            onTap: (value) {
                              log("SELECTED $value");
                              addVideoLinkOfSelectedTile(value, 0);
                            },
                          )
                        : null,
                    title: playerInfo == 0
                        ? const Center(
                            child: CircularProgressIndicator(
                            color: colorPrimary,
                          ))
                        : playerInfo == 1
                            ? YoutubePlayer(
                                controller: _liveYoutubeController!,
                                enableFullScreenOnVerticalDrag: false,
                              )
                            : _liveNormalController != null &&
                                    _liveNormalController!.value.isInitialized
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: _liveNormalController!
                                            .value.aspectRatio,
                                        child:
                                            VideoPlayer(_liveNormalController!),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _liveNormalController!.value.isPlaying
                                              ? CupertinoIcons.pause
                                              : CupertinoIcons.play_arrow,
                                          color: Colors.white,
                                          size: 25.0,
                                        ),
                                        onPressed: _togglePlayPause,
                                      ),
                                    ],
                                  )
                                : const Center(
                                    child: CircularProgressIndicator(
                                      color: colorPrimary,
                                    ),
                                  ),
                    toolbarHeight: 210.0,
                  ),
                  body: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _tabController != null
                        ? TabBarView(
                            controller: _tabController,
                            children: List<Widget>.generate(
                              validResults.length,
                              (int index) {
                                return ListView.builder(
                                  itemCount:
                                      validResults[index].data?.length ?? 0,
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index2) {
                                    bool isTileSelected =
                                        selectedTileIndex == index2;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedTileIndex = index2;
                                          addVideoLinkOfSelectedTile(
                                              index, index2);
                                        });
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isTileSelected
                                                ? Colors.white
                                                : Colors.grey[800],
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          height: 60,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 100,
                                                color: Colors.black,
                                                child:
                                                    MyNetworkImagewithoutradius(
                                                  imageUrl: validResults[index]
                                                      .data![index2]
                                                      .landscape!,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            height: 5,
                                                            width: 5,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.red,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Text(
                                                            "LIVE",
                                                            style: TextStyle(
                                                                color: isTileSelected
                                                                    ? Colors
                                                                        .black
                                                                    : Colors
                                                                        .white,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        validResults[index]
                                                                .data?[index2]
                                                                .name ??
                                                            "no name",
                                                        style: TextStyle(
                                                            color:
                                                                isTileSelected
                                                                    ? Colors
                                                                        .black
                                                                    : Colors
                                                                        .white,
                                                            fontSize: 13,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          )
                        : Container(),
                  ),
                ),
              );
  }
}
