import 'dart:io';

import 'package:dtlive/pages/coinstorescreen.dart';
import 'package:dtlive/pages/successCoinShow.dart';
import 'package:dtlive/provider/generalprovider.dart';
import 'package:dtlive/provider/homeprovider.dart';
import 'package:dtlive/provider/userwallectProvider.dart';
import 'package:dtlive/pages/login_mobile.dart';

import 'package:dtlive/utils/adhelper.dart';
import 'package:dtlive/utils/sharedpre.dart';
import 'package:dtlive/widget/animatedgif.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:dtlive/model/sectiondetailmodel.dart';
import 'package:dtlive/subscription/subscription.dart';
import 'package:dtlive/model/episodebyseasonmodel.dart' as episode;
import 'package:dtlive/provider/episodeprovider.dart';
import 'package:dtlive/provider/showdetailsprovider.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/dimens.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/widget/myimage.dart';
import 'package:dtlive/widget/mynetworkimg.dart';
import 'package:dtlive/widget/mytext.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class EpisodeBySeason extends StatefulWidget {
  final int? videoId, upcomingType, typeId, seasonPos;
  final List<Session>? seasonList;

  final Result? sectionDetails;
  const EpisodeBySeason(this.videoId, this.upcomingType, this.typeId,
      this.seasonPos, this.seasonList, this.sectionDetails,
      {Key? key})
      : super(key: key);

  @override
  State<EpisodeBySeason> createState() => _EpisodeBySeasonState();
}

class _EpisodeBySeasonState extends State<EpisodeBySeason> with RouteAware {
  late EpisodeProvider episodeProvider;
  static SharedPre sharePref = SharedPre();

  late GeneralProvider generalProvider;
  late ShowDetailsProvider showDetailsProvider;
  late WalletProvider walletProvider;
  late HomeProvider homeProvider;
  String? finalVUrl = "";
  static var rewardad = "";
  static var rewardadIos = "";
  Map<String, String> qualityUrlList = <String, String>{};

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    episodeProvider = Provider.of<EpisodeProvider>(context, listen: false);
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    showDetailsProvider =
        Provider.of<ShowDetailsProvider>(context, listen: false);

    // Call getAllEpisode every time dependencies change (i.e., when the screen comes back)
    getAllEpisode();

    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   homeProvider = Provider.of<HomeProvider>(context, listen: false);
  //   generalProvider = Provider.of<GeneralProvider>(context, listen: false);
  //   episodeProvider = Provider.of<EpisodeProvider>(context, listen: false);
  //   walletProvider = Provider.of<WalletProvider>(context, listen: false);
  //   showDetailsProvider =
  //       Provider.of<ShowDetailsProvider>(context, listen: false);

  //   // Call getAllEpisode every time dependencies change (i.e., when the screen comes back)
  //   getAllEpisode();
  // }

  @override
  void didPopNext() {
    _fetchDataBalance();
    getAllEpisode();
  }

  getAllEpisode() async {
    debugPrint("seasonPos =====EpisodeBySeason=======> ${widget.seasonPos}");
    debugPrint("videoId =====EpisodeBySeason=======> ${widget.videoId}");
    await episodeProvider.getEpisodeBySeason(
        widget.seasonList?[(widget.seasonPos ?? 0)].id ?? 0, widget.videoId);
    await showDetailsProvider
        .setEpisodeBySeason(episodeProvider.episodeBySeasonModel);
    await generalProvider.getGeneralsetting(context);
    Future.delayed(Duration.zero).then((value) async {
      if (!mounted) return;
      rewardad = await sharePref.read("reward_ad") ?? "";
      rewardadIos = await sharePref.read("ios_reward_ad") ?? "";
      debugPrint("AD ==> ${rewardad}");
      debugPrint("AD ==> ${rewardadIos}");
      setState(() {});
    });
  }

  void _fetchDataBalance() async {
    homeProvider.fetchUserWalletBalance(Constant.userID ?? "");
    print("Rewarded Ad loading...");
    await AdHelper.createRewardedAd();
    print("Rewarded Ad loaded!");
    episodeProvider = Provider.of<EpisodeProvider>(context, listen: false);
    await getAllEpisode();
    print("");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (Constant.isTV) {
      return _buildUITV();
    } else {
      return _buildUIOther();
    }
  }

  Widget _buildUIOther() {
    return ResponsiveGridList(
      minItemWidth: 60,
      verticalGridSpacing: 8,
      horizontalGridSpacing: 8,
      minItemsPerRow: 1,
      maxItemsPerRow:
          (kIsWeb && MediaQuery.of(context).size.width > 720) ? 2 : 1,
      listViewBuilderOptions: ListViewBuilderOptions(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      children: List.generate(
        (episodeProvider.episodeBySeasonModel.result?.length ?? 0),
        (index) {
          return ExpandableNotifier(
            child: Wrap(
              children: [
                Container(
                  color: lightBlack,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                    constraints: const BoxConstraints(minHeight: 60),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              //focusColor:: white.withOpacity(0.5),

                              onTap: () async {
                                // Check if the user is logged in
                                if (Constant.userID != null) {
                                  if (showDetailsProvider.sectionDetailModel
                                          .result?.maturityRating ==
                                      "A") {
                                    print("Maturity Rating check in show--");
                                    // Show the pop-up with details
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                                      text: 'Age ',
                                                      style: TextStyle(
                                                          fontSize: 19,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    TextSpan(
                                                      text: 'Verification',
                                                      style: TextStyle(
                                                          fontSize: 19,
                                                          color: colorPrimary,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(height: 14),
                                              Text(
                                                'You must be 18+ to access this content.',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w400),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Please verify your age.',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  TextButton(
                                                    onPressed: () {
                                                      // User confirmed they're over 18, open player screen
                                                      openPlayer(
                                                        "Show",
                                                        index,
                                                        episodeProvider
                                                            .episodeBySeasonModel
                                                            .result,
                                                      );
                                                      Navigator.of(context)
                                                          .pop(); // Close the dialog
                                                    },
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.black,
                                                      backgroundColor:
                                                          colorPrimary,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                              vertical: 10),
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
                                                      foregroundColor:
                                                          Colors.white,
                                                      side: BorderSide(
                                                          color: Colors.white),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                              vertical: 10),
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
                                              horizontal:
                                                  30), // Increase content height
                                        );
                                      },
                                    );

                                    return;
                                  }
                                  // Extract isBuy and isAdShow values from the episode data
                                  bool isPrimeUser = episodeProvider
                                          .episodeBySeasonModel
                                          .result?[index]
                                          .isBuy ==
                                      1;
                                  bool isPrimeUserCoin = episodeProvider
                                          .episodeBySeasonModel
                                          .result?[index]
                                          .iscoinbuy ==
                                      1; // Prime user
                                  bool isAdShow = episodeProvider
                                          .episodeBySeasonModel
                                          .result?[index]
                                          .isadshow ==
                                      1; // Ad should be shown

                                  // Check if reward ads are disabled for the platform
                                  if ((Platform.isAndroid && rewardad == "0") ||
                                      (Platform.isIOS && rewardadIos == "0")) {
                                    print(
                                        "Rewarded ad is disabled for this platform. Opening player directly.");
                                    openPlayer(
                                      "Show",
                                      index,
                                      episodeProvider
                                          .episodeBySeasonModel.result,
                                    );
                                    return; // Exit early since ads are skipped
                                  }

                                  if ((Platform.isAndroid &&
                                          generalProvider.rewardad == "1") ||
                                      (Platform.isIOS &&
                                          generalProvider.rewardadIos == "1")) {
                                    print(
                                        "Rewarded ad is disabled for this platform. Opening player directly.");
                                    if (isPrimeUser || isPrimeUserCoin) {
                                      // Prime users directly navigate to the player
                                      openPlayer(
                                        "Show",
                                        index,
                                        episodeProvider
                                            .episodeBySeasonModel.result,
                                      );
                                    } else {
                                      if (isAdShow) {
                                        AdHelper.showRewardedAd(
                                          onAdCompleted: () async {
                                            // Callback when the ad is completed successfully
                                            try {
                                              print("API call start...");
                                              await walletProvider
                                                  .addCoinsAfterWatchAd(
                                                Constant.userID!,
                                                0,
                                                episodeProvider
                                                    .episodeBySeasonModel
                                                    .result?[index]
                                                    .showId,
                                                generalProvider.isAdsCoin,
                                              );
                                              print(
                                                  "Coins added successfully!");
                                            } catch (e) {
                                              print("Error adding coins: $e");
                                            }
                                            // Navigate to the player after adding coins
                                            openPlayer(
                                              "Show",
                                              index,
                                              episodeProvider
                                                  .episodeBySeasonModel.result,
                                            );
                                          },
                                          onAdFailed: () {
                                            // Callback when the ad fails to show
                                            print(
                                                "Ad failed to show. Navigating to the player without rewarding.");
                                            // Navigate to the player without adding coins
                                            openPlayer(
                                              "Show",
                                              index,
                                              episodeProvider
                                                  .episodeBySeasonModel.result,
                                            );
                                          },
                                        );

                                        // AdHelper.showRewardedAd(() async {
                                        //   try {
                                        //     print("API call start...");
                                        //     await walletProvider
                                        //         .addCoinsAfterWatchAd(
                                        //       Constant.userID!,
                                        //       0,
                                        //       episodeProvider
                                        //           .episodeBySeasonModel
                                        //           .result?[index]
                                        //           .showId,
                                        //       generalProvider.isAdsCoin,
                                        //     );
                                        //     print("Coins added successfully!");
                                        //   } catch (e) {
                                        //     print("Error adding coins: $e");
                                        //   }
                                        //   // Navigate to the player after adding coins
                                        //   openPlayer(
                                        //     "Show",
                                        //     index,
                                        //     episodeProvider
                                        //         .episodeBySeasonModel.result,
                                        //   );
                                        // });
                                      } else {
                                        // If ads are not shown (isAdShow == 0), navigate directly to the player
                                        openPlayer(
                                          "Show",
                                          index,
                                          episodeProvider
                                              .episodeBySeasonModel.result,
                                        );
                                      }
                                    }
                                    return; // Exit early since ads are skipped
                                  }
                                } else {
                                  // User not logged in, navigate to the login screen
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginViaSocial(),
                                    ),
                                  );
                                }
                              },

                              // onTap: () async {
                              //   // Check if the user is logged in
                              //   if (Constant.userID != null) {
                              //     // Extract isBuy and isAdShow values from the episode data
                              //     bool isPrimeUser = episodeProvider
                              //             .episodeBySeasonModel
                              //             .result?[index]
                              //             .isBuy ==
                              //         1;
                              //     bool isPrimeUserCoin = episodeProvider
                              //             .episodeBySeasonModel
                              //             .result?[index]
                              //             .iscoinbuy ==
                              //         1; // Prime user
                              //     bool isAdShow = episodeProvider
                              //             .episodeBySeasonModel
                              //             .result?[index]
                              //             .isadshow ==
                              //         1; // Ad should be shown

                              //     if (isPrimeUser || isPrimeUserCoin) {
                              //       // Prime users directly navigate to the player
                              //       openPlayer(
                              //         "Show",
                              //         index,
                              //         episodeProvider
                              //             .episodeBySeasonModel.result,
                              //       );
                              //     } else {
                              //       if (isAdShow) {
                              //         AdHelper.showRewardedAd(() async {
                              //           try {
                              //             print("Api call start--");
                              //             await walletProvider
                              //                 .addCoinsAfterWatchAd(
                              //               Constant.userID!,
                              //               0,
                              //               episodeProvider.episodeBySeasonModel
                              //                   .result?[index].showId,
                              //               generalProvider.isAdsCoin,
                              //             );
                              //             print("Coins added successfully!");
                              //           } catch (e) {
                              //             print("Error adding coins: $e");
                              //           }
                              //           // After the ad is watched, call the API to add coins

                              //           // Navigate to the player after adding coins
                              //           openPlayer(
                              //             "Show",
                              //             index,
                              //             episodeProvider
                              //                 .episodeBySeasonModel.result,
                              //           );
                              //         });
                              //       } else {
                              //         // If ads are not shown (isAdShow == 0), navigate directly to the player
                              //         openPlayer(
                              //           "Show",
                              //           index,
                              //           episodeProvider
                              //               .episodeBySeasonModel.result,
                              //         );
                              //       }
                              //     }
                              //   } else {
                              //     // User not logged in, navigate to the login screen
                              //     Navigator.of(context).push(
                              //       MaterialPageRoute(
                              //         builder: (context) => const LoginViaSocial(),
                              //       ),
                              //     );
                              //   }
                              // },
                              child: Container(
                                width: 160,
                                height: 100,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    MyNetworkImage(
                                      fit: BoxFit.fill,
                                      imageUrl: (episodeProvider
                                              .episodeBySeasonModel
                                              .result?[index]
                                              .landscape ??
                                          ""),
                                    ),
                                    Center(
                                      child: MyImage(
                                        fit: BoxFit.cover,
                                        height: 32,
                                        width: 32,
                                        imagePath: "play.png",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            (episodeProvider.episodeBySeasonModel.result?[index]
                                            .videoDuration !=
                                        null &&
                                    (episodeProvider.episodeBySeasonModel
                                                .result?[index].stopTime ??
                                            0) >
                                        0)
                                ? Container(
                                    height: 2,
                                    width: 32,
                                    margin: const EdgeInsets.only(top: 8),
                                    child: LinearPercentIndicator(
                                      padding: const EdgeInsets.all(0),
                                      barRadius: const Radius.circular(2),
                                      lineHeight: 2,
                                      percent: Utils.getPercentage(
                                          episodeProvider
                                                  .episodeBySeasonModel
                                                  .result?[index]
                                                  .videoDuration ??
                                              0,
                                          episodeProvider.episodeBySeasonModel
                                                  .result?[index].stopTime ??
                                              0),
                                      backgroundColor: secProgressColor,
                                      progressColor: colorPrimary,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              MyText(
                                color: white,
                                text: episodeProvider.episodeBySeasonModel
                                        .result?[index].name ??
                                    "-",
                                textalign: TextAlign.start,
                                fontstyle: FontStyle.normal,
                                fontsizeNormal: 14,
                                fontsizeWeb: 14,
                                maxline: 2,
                                overflow: TextOverflow.ellipsis,
                                fontweight: FontWeight.w600,
                              ),
                              const SizedBox(height: 5),
                              MyText(
                                color: whiteLight,
                                text: episodeProvider.episodeBySeasonModel
                                        .result?[index].description ??
                                    "",
                                textalign: TextAlign.start,
                                fontsizeNormal: 12,
                                fontsizeWeb: 12,
                                multilanguage: false,
                                fontweight: FontWeight.w400,
                                maxline: 2,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(height: 5),
                              MyText(
                                color: colorPrimary,
                                text: ((episodeProvider.episodeBySeasonModel
                                                .result?[index].videoDuration ??
                                            0) >
                                        0)
                                    ? Utils.convertToColonText(episodeProvider
                                            .episodeBySeasonModel
                                            .result?[index]
                                            .videoDuration ??
                                        0)
                                    : "-",
                                textalign: TextAlign.start,
                                fontsizeNormal: 11,
                                fontsizeWeb: 12,
                                fontweight: FontWeight.w600,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(width: 5),
                              generalProvider.isCoinShow == "1"
                                  ? Row(
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
                                        const SizedBox(height: 5),
                                        MyText(
                                          color: colorPrimary,
                                          text: episodeProvider
                                                  .episodeBySeasonModel
                                                  .result?[index]
                                                  .coinvalue
                                                  .toString() ??
                                              "",
                                          textalign: TextAlign.start,
                                          fontsizeNormal: 12,
                                          fontsizeWeb: 12,
                                          multilanguage: false,
                                          fontweight: FontWeight.w400,
                                          maxline: 2,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        ),
                                      ],
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUITV() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLand,
      child: ListView.separated(
        itemCount: episodeProvider.episodeBySeasonModel.result?.length ?? 0,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            borderRadius: BorderRadius.circular(4),
            //focusColor:: white,
            onTap: () {
              debugPrint("===> index $index");
              openPlayer(
                "Show",
                index,
                episodeProvider.episodeBySeasonModel.result,
              );
            },
            child: Container(
              width: Dimens.widthLand,
              height: Dimens.heightLand,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(2.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: MyNetworkImage(
                  imageUrl: (episodeProvider
                          .episodeBySeasonModel.result?[index].landscape ??
                      ""),
                  fit: BoxFit.cover,
                  imgHeight: MediaQuery.of(context).size.height,
                  imgWidth: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /* ========= Open Player ========= */
  openPlayer(
      String playType, int epiPos, List<episode.Result>? episodeList) async {
   
   
    if ((episodeList?.length ?? 0) > 0) {
      /* CHECK SUBSCRIPTION */
      if (playType != "Trailer") {
        bool? isPrimiumUser = await _checkSubsRentLogin(epiPos, episodeList);
        debugPrint("isPrimiumUser =============> $isPrimiumUser");
        if (!isPrimiumUser) return;
      }
      /* CHECK SUBSCRIPTION */

      int? epiID = (episodeList?[epiPos].id ?? 0);
      int? showID = (episodeList?[epiPos].showId ?? 0);
      dynamic showVideoLibraryId, showVideoUrlId;
      int? vType =
          (showDetailsProvider.sectionDetailModel.result?.videoType ?? 0);
      int? vTypeID = widget.typeId;
      int? stopTime = (episodeList?[epiPos].stopTime ?? 0);
      String? vUploadType = (episodeList?[epiPos].videoUploadType ?? "");
      String? videoThumb = (episodeList?[epiPos].landscape ?? "");
      String? epiUrl = (episodeList?[epiPos].video320 ?? "");
      showVideoLibraryId = episodeList![epiPos].videoLibraryId ?? "";
      showVideoUrlId = episodeList[epiPos].urlVideoId ?? "";
      debugPrint("epiID ========> $epiID");
      debugPrint("showID =======> $showID");
      debugPrint("vType ========> $vType");
      debugPrint("vTypeID ======> $vTypeID");
      debugPrint("stopTime =====> $stopTime");
      debugPrint("vUploadType ==> $vUploadType");
      debugPrint("videoThumb ===> $videoThumb");
      debugPrint("epiUrl =======> $epiUrl");

      if (!mounted) return;
      if (epiUrl.isEmpty || epiUrl == "") {
        Utils.showSnackbar(context, "info", "episode_not_found", true);
        return;
      }

      /* Set-up Quality URLs */
      Utils.setQualityURLs(
        video320:
            (episodeProvider.episodeBySeasonModel.result?[epiPos].video320 ??
                ""),
        video480:
            (episodeProvider.episodeBySeasonModel.result?[epiPos].video480 ??
                ""),
        video720:
            (episodeProvider.episodeBySeasonModel.result?[epiPos].video720 ??
                ""),
        video1080:
            (episodeProvider.episodeBySeasonModel.result?[epiPos].video1080 ??
                ""),
      );

      if (!mounted) return;

      dynamic isContinue = await Utils.openPlayer(
        context: context,
        playType: "Show",
        videoId: epiID,
        videoType: vType,
        typeId: vTypeID,
        otherId: showID,
        videoUrl: epiUrl,
        trailerUrl: "",
        uploadType: vUploadType,
        videoThumb: videoThumb,
        vStopTime: stopTime,
        videoLibraryId: showVideoLibraryId,
        videoUrlVideoId: showVideoUrlId,
      );

      debugPrint("isContinue ===> $isContinue");
      if (isContinue != null && isContinue == true) {
        await getAllEpisode();
      }
    }
  }

  Future<bool> _checkSubsRentLogin(
      int epiPos, List<episode.Result>? episodeList) async {
    if (Constant.userID != null) {
      // Case 1: Premium + Rent Video with Coin Option
      if ((showDetailsProvider.sectionDetailModel.result?.isPremium ??
                  0) ==
              1 &&
          (episodeProvider.episodeBySeasonModel.result?[epiPos].isRent ?? 0) == 1 &&
          (episodeProvider.episodeBySeasonModel.result?[epiPos]
                      .isabaletocoinpurches ??
                  0) ==
              1) {
        debugPrint('Case 1: Premium + Rent Video with Coin Option');
        debugPrint(
            'isPremium: ${showDetailsProvider.sectionDetailModel.result?.isPremium}');
        debugPrint(
            'isRent: ${episodeProvider.episodeBySeasonModel.result?[epiPos].isRent}');
        debugPrint(
            'isabaletocoinpurches: ${showDetailsProvider.sectionDetailModel.result?.isabaletocoinpurches}');
        if ((showDetailsProvider.sectionDetailModel.result?.isBuy ?? 0) ==
                1 ||
            (episodeProvider.episodeBySeasonModel.result?[epiPos].rentBuy ?? 0) ==
                1 ||
            (episodeProvider.episodeBySeasonModel.result?[epiPos].iscoinbuy ??
                    0) ==
                1) {
          debugPrint('User can access the video');
          return true;
        } else {
          debugPrint('User needs to subscribe');
          dynamic isSubscribed = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Subscription(),
            ),
          );
          if (isSubscribed != null && isSubscribed == true) {
            getAllEpisode();
          }
          return false;
        }
      }

         // Case 2: Only Premium Video
      else if ((showDetailsProvider.sectionDetailModel.result?.isPremium ??
              0) ==
          1) {
        debugPrint('Case 2: Only Premium Video');
        debugPrint(
            'isPremium: ${showDetailsProvider.sectionDetailModel.result?.isPremium}');
        if ((showDetailsProvider.sectionDetailModel.result?.isBuy ?? 0) ==
            1) {
          debugPrint('User can access the video');
          return true;
        } else {
          debugPrint('User needs to subscribe');
          dynamic isSubscribed = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Subscription(),
            ),
          );
          if (isSubscribed != null && isSubscribed == true) {
            getAllEpisode();
          }
          return false;
        }
      }




      // Case 2: Only rent Video
      else if ((episodeProvider.episodeBySeasonModel.result?[epiPos].isRent ??
              0) ==
          1) {
        debugPrint('Case 2: Only rent Video');
        debugPrint(
            'is rent : ${episodeProvider.episodeBySeasonModel.result?[epiPos].isRent}');
        if ((episodeProvider.episodeBySeasonModel.result?[epiPos].rentBuy ?? 0) ==
            1) {
          debugPrint('User can access the video');
          return true;
        } else {
          debugPrint('User can not access the video');

           dynamic isRented = await Utils.paymentForRent(
            context: context,
            videoId:
                showDetailsProvider.sectionDetailModel.result?.id.toString() ??
                    '',
            rentPrice: showDetailsProvider.sectionDetailModel.result?.rentPrice
                    .toString() ??
                '',
            vTitle: showDetailsProvider.sectionDetailModel.result?.name
                    .toString() ??
                '',
            typeId: showDetailsProvider.sectionDetailModel.result?.typeId
                    .toString() ??
                '',
            vType: showDetailsProvider.sectionDetailModel.result?.videoType
                    .toString() ??
                '',
          );
        
        
          if (isRented != null && isRented == true) {
            getAllEpisode();
          }
          return false;
        }
      }



      //case - only rent video ---
      

      // Case 3: Rent Video with Coin Option but isRent == 0
      if ((episodeProvider.episodeBySeasonModel.result?[epiPos].isRent ?? 0) ==
              0 &&
          (episodeProvider.episodeBySeasonModel.result?[epiPos]
                      .isabaletocoinpurches ??
                  0) ==
              1) {
        debugPrint(
            'Both conditions met: isRent = 0 and isabaletocoinpurches = 1');

        // Check if the video is already purchased with coins
        if ((episodeProvider.episodeBySeasonModel.result?[epiPos].iscoinbuy ??
                0) ==
            1) {
          debugPrint('Video already purchased with coins.');
          return true; // Grant access
        }

        // Show bottom sheet to rent via coin
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.grey, thickness: 1),

                  // Single option: Rent via Coin
                  ListTile(
                    leading: AnimatedGifWidget(
                      height: 60,
                      width: 60,
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
                            homeProvider.userWalletBalanceModel?.balance ?? 0;
                        dynamic videoCoinValue = episodeProvider
                                .episodeBySeasonModel
                                .result?[epiPos]
                                .coinvalue ??
                            '0';

                        if (userBalance >= videoCoinValue) {
                          print("USER COME IN YTHE IF---");
                          // Sufficient balance, proceed with renting via coin
                          String userId = "${Constant.userID}";
                          String showId = episodeProvider
                                  .episodeBySeasonModel.result?[epiPos].showId
                                  .toString() ??
                              '';
                          String videoId = episodeProvider
                                  .episodeBySeasonModel.result?[epiPos].id
                                  .toString() ??
                              '';
                          String noOfToken = episodeProvider
                                  .episodeBySeasonModel
                                  .result?[epiPos]
                                  .coinvalue
                                  .toString() ??
                              '0';
                          debugPrint(
                              'Rent via Coin: userId=$userId, showId=$showId, noOfToken=$noOfToken');

                          // Navigate to SuccessScreen
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SuccessShowScreen(
                                  userId: userId,
                                  videoId: videoId,
                                  noOfToken: noOfToken,
                                  showId: showId,
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
                        debugPrint('Error: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Failed to navigate. Please try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );

        return false; // User needs to take an action
      }




      // Case 4: Only Rent Video with Coin Option
      else if ((episodeProvider.episodeBySeasonModel.result?[epiPos].isRent ??
              0) ==
          1) {
        debugPrint('Case 4: Only Rent Video with Coin Option');
        debugPrint(
            'isRent: ${showDetailsProvider.sectionDetailModel.result?.isRent}');
        // Sub-condition 1: Already rented or purchased with coins
        if ((episodeProvider.episodeBySeasonModel.result?[epiPos].rentBuy ??
                    0) ==
                1 ||
            (episodeProvider.episodeBySeasonModel.result?[epiPos].iscoinbuy ??
                    0) ==
                1) {
          debugPrint('Video already rented or purchased');
          return true;
        }

        // Sub-condition 2: Not rented/purchased, check payment options
        if ((episodeProvider.episodeBySeasonModel.result?[epiPos]
                    .isabaletocoinpurches ??
                0) ==
            1) {
          debugPrint('Rent via Coin is available');
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
                          videoId: showDetailsProvider
                                  .sectionDetailModel.result?.id
                                  .toString() ??
                              '',
                          rentPrice: showDetailsProvider
                                  .sectionDetailModel.result?.rentPrice
                                  .toString() ??
                              '',
                          vTitle: showDetailsProvider
                                  .sectionDetailModel.result?.name
                                  .toString() ??
                              '',
                          typeId: showDetailsProvider
                                  .sectionDetailModel.result?.typeId
                                  .toString() ??
                              '',
                          vType: showDetailsProvider
                                  .sectionDetailModel.result?.videoType
                                  .toString() ??
                              '',
                        );
                        if (isRented == true) {
                          getAllEpisode();
                        }
                      },
                    ),
                    const Divider(color: Colors.grey, thickness: 1),

                    // Single option: Rent via Coin
                    ListTile(
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
                              homeProvider.userWalletBalanceModel?.balance ?? 0;
                          dynamic videoCoinValue = episodeProvider
                                  .episodeBySeasonModel
                                  .result?[epiPos]
                                  .coinvalue ??
                              '0';

                          if (userBalance >= videoCoinValue) {
                            print("USER COME IN YTHE IF---");
                            // Sufficient balance, proceed with renting via coin
                            String userId = "${Constant.userID}";
                            String showId = episodeProvider
                                    .episodeBySeasonModel.result?[epiPos].showId
                                    .toString() ??
                                '';
                            String videoId = episodeProvider
                                    .episodeBySeasonModel.result?[epiPos].id
                                    .toString() ??
                                '';
                            String noOfToken = episodeProvider
                                    .episodeBySeasonModel
                                    .result?[epiPos]
                                    .coinvalue
                                    .toString() ??
                                '0';
                            debugPrint(
                                'Rent via Coin: userId=$userId, showId=$showId, noOfToken=$noOfToken');

                            // Navigate to SuccessScreen
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SuccessShowScreen(
                                    userId: userId,
                                    videoId: videoId,
                                    noOfToken: noOfToken,
                                    showId: showId,
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
                          debugPrint('Error: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Failed to navigate. Please try again.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
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
              showDetailsProvider.sectionDetailModel.result?.id.toString() ??
                  '',
          rentPrice: showDetailsProvider.sectionDetailModel.result?.rentPrice
                  .toString() ??
              '',
          vTitle:
              showDetailsProvider.sectionDetailModel.result?.name.toString() ??
                  '',
          typeId: showDetailsProvider.sectionDetailModel.result?.typeId
                  .toString() ??
              '',
          vType: showDetailsProvider.sectionDetailModel.result?.videoType
                  .toString() ??
              '',
        );
        if (isRented == true) {
          getAllEpisode();
        }
        return false;
      }

      // General Case: Access allowed by default
      debugPrint('General Case: Access allowed');
      return true;
    }

    // Case 5: Only Rent Video (No coin option available)
    else if ((episodeProvider.episodeBySeasonModel.result?[epiPos].isRent ??
            0) ==
        1) {
      debugPrint('Case 5: Rent Video with No Coin Option');

      if ((episodeProvider.episodeBySeasonModel.result?[epiPos].rentBuy ?? 0) ==
          1) {
        debugPrint('Video already rented');
        return true;
      } else {
        debugPrint('---RENT KRO SHOW KO');
        dynamic isRented = await Utils.paymentForRent(
          context: context,
          videoId:
              showDetailsProvider.sectionDetailModel.result?.id.toString() ??
                  '',
          rentPrice: showDetailsProvider.sectionDetailModel.result?.rentPrice
                  .toString() ??
              '',
          vTitle:
              showDetailsProvider.sectionDetailModel.result?.name.toString() ??
                  '',
          typeId: showDetailsProvider.sectionDetailModel.result?.typeId
                  .toString() ??
              '',
          vType: showDetailsProvider.sectionDetailModel.result?.videoType
                  .toString() ??
              '',
        );
        if (isRented != null && isRented == true) {
          getAllEpisode();
        }
        return false;
      }
    } else {
      if ((kIsWeb || Constant.isTV)) {
        Utils.buildWebAlertDialog(context, "login", "").then((value) {
          getAllEpisode();
        });
        return false;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const LoginViaSocial();
          },
        ),
      );
      return false;
    }
  }



}
