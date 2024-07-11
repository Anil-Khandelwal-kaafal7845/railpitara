import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dtlive/model/sectionlistmodel.dart';
import 'package:dtlive/model/sectionlistmodel.dart' as list;
import 'package:dtlive/model/sectionbannermodel.dart' as banner;
import 'package:dtlive/pages/loginsocial.dart';
import 'package:dtlive/pages/morescreen.dart';
import 'package:dtlive/pages/pip_web_player.dart';
import 'package:dtlive/pages/videosbyartist.dart';
import 'package:dtlive/pages/videosbyid.dart';
import 'package:dtlive/provider/sectionbytypeprovider.dart';
import 'package:dtlive/shimmer/shimmerutils.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/dimens.dart';
import 'package:dtlive/widget/mytext.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/widget/mynetworkimg.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class SectionByType extends StatefulWidget {
  final String appBarTitle, isHomePage;
  final int typeId;
  const SectionByType(
    this.typeId,
    this.appBarTitle,
    this.isHomePage, {
    Key? key,
  }) : super(key: key);

  @override
  State<SectionByType> createState() => SectionByTypeState();
}

class SectionByTypeState extends State<SectionByType> {
  late SectionByTypeProvider sectionByTypeProvider;
  CarouselController carouselController = CarouselController();

  @override
  void initState() {
    sectionByTypeProvider =
        Provider.of<SectionByTypeProvider>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
  }

  _getData() async {
    Utils.getCurrencySymbol();
    await sectionByTypeProvider.setLoading(true);
    await sectionByTypeProvider.getSectionBanner(
        widget.typeId.toString(), widget.isHomePage.toString());
    await sectionByTypeProvider.getSectionList(
        widget.typeId.toString(), widget.isHomePage.toString(),"0");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: (kIsWeb || Constant.isTV)
          ? Utils.myAppBar(context, widget.appBarTitle, false)
          : Utils.myAppBarWithBack(context, widget.appBarTitle, false),
      body: RefreshIndicator(
        backgroundColor: white,
        color: complimentryColor,
        displacement: 80,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 1500))
              .then((value) {
            _getData();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              /* Banner */
              Consumer<SectionByTypeProvider>(
                builder: (context, sectionByTypeProvider, child) {
                  if (sectionByTypeProvider.loadingBanner) {
                    if (kIsWeb && MediaQuery.of(context).size.width > 720) {
                      return ShimmerUtils.bannerWeb(context);
                    } else {
                      return ShimmerUtils.bannerMobile(context);
                    }
                  } else {
                    if (sectionByTypeProvider.sectionBannerModel.status ==
                            200 &&
                        sectionByTypeProvider.sectionBannerModel.result !=
                            null) {
                      return homebanner(
                          sectionByTypeProvider.sectionBannerModel.result);
                    } else {
                      return const SizedBox.shrink();
                    }
                  }
                },
              ),

              /* AdMob Banner */
              const SizedBox(height: 10),
              Utils.showBannerAd(context),

              /* Remaining Sections */
              Consumer<SectionByTypeProvider>(
                builder: (context, sectionByTypeProvider, child) {
                  if (sectionByTypeProvider.loadingSection) {
                    return sectionShimmer();
                  } else {
                    if (sectionByTypeProvider.sectionListModel.status == 200) {
                      if (sectionByTypeProvider.sectionListModel.result !=
                          null) {
                        return setSectionByType(
                            sectionByTypeProvider.sectionListModel.result);
                      } else {
                        return const SizedBox.shrink();
                      }
                    } else {
                      return const SizedBox.shrink();
                    }
                  }
                },
              ),
              const SizedBox(height: 20),

              /* AdMob Banner */
              Utils.showBannerAd(context),
            ],
          ),
        ),
      ),
    );
  }

  /* Section Shimmer */
  Widget sectionShimmer() {
    return ListView.builder(
      itemCount: 10, // itemCount must be greater than 5
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        if (index == 1) {
          return ShimmerUtils.setHomeSections(context, "potrait");
        } else if (index == 2) {
          return ShimmerUtils.setHomeSections(context, "square");
        } else if (index == 3) {
          return ShimmerUtils.setHomeSections(context, "langGen");
        } else {
          return ShimmerUtils.setHomeSections(context, "landscape");
        }
      },
    );
  }

  Widget homebanner(List<banner.Result>? sectionBannerList) {
    if ((sectionBannerList?.length ?? 0) > 0) {
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: Dimens.homeBanner,
            child: CarouselSlider.builder(
              itemCount: (sectionBannerList?.length ?? 0),
              carouselController: carouselController,
              options: CarouselOptions(
                initialPage: 0,
                height: Dimens.homeBanner,
                enlargeCenterPage: false,
                autoPlay: true,
                autoPlayCurve: Curves.linear,
                enableInfiniteScroll: true,
                autoPlayInterval:
                    Duration(milliseconds: Constant.bannerDuration),
                autoPlayAnimationDuration:
                    Duration(milliseconds: Constant.animationDuration),
                viewportFraction: 1.0,
                onPageChanged: (val, _) async {
                  await sectionByTypeProvider.setCurrentBanner(val);
                },
              ),
              itemBuilder:
                  (BuildContext context, int index, int pageViewIndex) {
                return InkWell(
                  onTap: () {
                    debugPrint("Clicked on index ==> $index");
                    Utils.openDetails(
                      context: context,
                      videoId: sectionBannerList?[index].id ?? 0,
                      upcomingType: sectionBannerList?[index].upcomingType ?? 0,
                      videoType: sectionBannerList?[index].videoType ?? 0,
                      typeId: sectionBannerList?[index].typeId ?? 0,
                    );
                  },
                  child: Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.homeBanner,
                        child: MyNetworkImage(
                          imageUrl: sectionBannerList?[index].landscape ?? "",
                          fit: BoxFit.fill,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.homeBanner,
                        alignment: Alignment.center,
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
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            child: Consumer<SectionByTypeProvider>(
              builder: (context, sectionByTypeProvider, child) {
                return AnimatedSmoothIndicator(
                  count: (sectionBannerList?.length ?? 0),
                  activeIndex: sectionByTypeProvider.cBannerIndex ?? 0,
                  effect: const ScrollingDotsEffect(
                    spacing: 8,
                    radius: 4,
                    activeDotColor: dotsActiveColor,
                    dotColor: dotsDefaultColor,
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
  Widget setSectionByType(List<list.Result>? sectionList) {
    // Check if sectionList is not null
    if (sectionList == null || sectionList.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort the sectionList based on sectionOrder
    sectionList
        .sort((a, b) => (a.sectionOrder ?? 0).compareTo(b.sectionOrder ?? 0));

    return ListView.builder(
      itemCount: sectionList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        if (sectionList[index].data != null &&
            sectionList[index].data!.isNotEmpty) {
          bool isBannerVisible =
              (sectionList[index].bannerVisible ?? "0") == "1";
          bool isGenreOrLanguage = sectionList[index].videoType == 3 ||
              sectionList[index].videoType == 4 ||
              sectionList[index].videoType == 6;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                    child: MyText(
                      color: white,
                      text: sectionList[index].title.toString(),
                      textalign: TextAlign.center,
                      fontsizeNormal: 14,
                      fontweight: FontWeight.w600,
                      fontsizeWeb: 16,
                      multilanguage: false,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                  if (!isGenreOrLanguage)
                    GestureDetector(
                        onTap: () {
  Navigator.push(context, MaterialPageRoute(
    builder: (context) {
      return MoreScreen(
        sectionList[index].title.toString(),
        sectionList[index].id.toString(), // Pass the section ID
      );
    },
  ));
},
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 15, 3, 0),
                        child: MyText(
                          color: Colors.red,
                          text: "More",
                          textalign: TextAlign.center,
                          fontsizeNormal: 10,
                          fontweight: FontWeight.w600,
                          fontsizeWeb: 16,
                          multilanguage: false,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: getRemainingDataHeight(
                  sectionList[index].videoType.toString(),
                  sectionList[index].screenLayout ?? "",
                ),
                child: setSectionData(sectionList: sectionList, index: index),
              ),
              if (isBannerVisible)
                Column(
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: Dimens.upcomingHeight,
                      width: MediaQuery.of(context).size.width,
                      child: GestureDetector(
                        onTap: () {
                          if (sectionList[index].bannerLinkType == 0) {
                            // Handle onTap for bannerLinkType = 0
                            if (sectionList[index].bannerBacklink != null &&
                                sectionList[index]
                                    .bannerBacklink
                                    .toString()
                                    .isNotEmpty) {
                              launchUrl(Uri.parse(sectionList[index]
                                  .bannerBacklink
                                  .toString()));
                            }
                          } else {
                            // Handle onTap for bannerLinkType = 1
                            if (Constant.userID == null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginSocial()),
                              );
                              // Utils.buildWebAlertDialog(context, "login", "");
                            } else {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => PlayerVideo(
                              //           '',
                              //           0,
                              //           0,
                              //           typeId,
                              //           0,
                              //           sectionList[index]
                              //               .bannerBacklink
                              //               .toString(),
                              //           0,
                              //           "",
                              //           "")),
                              // );

                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => TestPlayerWeb(
                                      loadURL: sectionList[index]
                                          .bannerBacklink
                                          .toString())));
                            }
                          }
                        },
                        child: Image.network(
                            sectionList[index].bannerImage.toString(),
                            fit: BoxFit.fill),
                      ),
                    ),
                  ],
                ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }


  Widget setSectionData(
      {required List<list.Result>? sectionList, required int index}) {
    /* video_type =>  1-video,  2-show,  3-language,  4-category */
    /* screen_layout =>  landscape, potrait, square */
    if ((sectionList?[index].isTop10 == 1)) {
      return topTenLayout(
          sectionList?[index].upcomingType, sectionList?[index].data);
    }
    if ((sectionList?[index].videoType ?? 0) == 1) {
      if ((sectionList?[index].screenLayout ?? "") == "landscape") {
        return landscape(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "landscape_1") {
        return landscapeTwo(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "potrait_1") {
        return portraitTwo(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "potrait") {
        return portrait(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "square") {
        return square(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else {
        return landscape(
            sectionList?[index].upcomingType, sectionList?[index].data);
      }
    } else if ((sectionList?[index].videoType ?? 0) == 2) {
      if ((sectionList?[index].screenLayout ?? "") == "landscape") {
        return landscape(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "potrait") {
        return portrait(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "square") {
        return square(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else {
        return landscape(
            sectionList?[index].upcomingType, sectionList?[index].data);
      }
    } else if ((sectionList?[index].videoType ?? 0) == 3) {
      if ((sectionList?[index].screenLayout ?? "") == "landscape") {
        return languageLayoutLand(
            sectionList?[index].typeId ?? 0, sectionList?[index].data);
      } else {
        return languageLayout(
            sectionList?[index].typeId ?? 0, sectionList?[index].data);
      }
    } else if ((sectionList?[index].videoType ?? 0) == 4) {
      return genresLayout(
          sectionList?[index].typeId ?? 0, sectionList?[index].data);
    } else if ((sectionList?[index].videoType ?? 0) == 6) {
      return browseByArtistLayout(
          sectionList?[index].typeId ?? 0, sectionList?[index].data);
    } else {
      if ((sectionList?[index].screenLayout ?? "") == "landscape") {
        return landscape(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "potrait") {
        return portrait(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else if ((sectionList?[index].screenLayout ?? "") == "square") {
        return square(
            sectionList?[index].upcomingType, sectionList?[index].data);
      } else {
        return landscape(
            sectionList?[index].upcomingType, sectionList?[index].data);
      }
    }
  }

  double getRemainingDataHeight(
    String? videoType,
    String? layoutType,
  ) {
    if (videoType == "1" || videoType == "2") {
      if (layoutType == "landscape") {
        return Dimens.heightLand;
      } else if (layoutType == "landscape_1") {
        return Dimens.heightLandTwo;
      } else if (layoutType == "potrait_1") {
        return Dimens.heightPortTwo;
      } else if (layoutType == "potrait") {
        return Dimens.heightPort;
      } else if (layoutType == "square") {
        return Dimens.heightSquare;
      } else {
        return Dimens.heightLand;
      }
    } else if (videoType == "3" || videoType == "4") {
      if (layoutType == "landscape") {
        return Dimens.heightLangGenLand;
      } else {
        return Dimens.heightLangGen;
      }
    } else if (videoType == "6") {
      if (layoutType == "landscape") {
        return Dimens.heightArtist;
      } else {
        return Dimens.heightArtist;
      }
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

  Widget landscape(int? upcomingType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLand,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(6),

            onTap: () {
              debugPrint("Clicked userid ==> ${Constant.userID}");
              debugPrint(
                  "Clicked on link is  ==> ${sectionDataList?[index].video320.toString()}");
              if (sectionDataList?[index].isLiveUrl == 1) {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginSocial()),
                  );
                } else {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => PlayerVideo('', 0, 0, typeId, 0,
                  //           sectionDataList?[index].video320, 0, "", "")),
                  // );
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => TestPlayerWeb(
                          loadURL: sectionDataList![index].video320!)));
                }
              } else {
                 Utils.openDetails(
                context: context,
                videoId: sectionDataList?[index].id ?? 0,
                upcomingType: upcomingType ?? 0,
                videoType: sectionDataList?[index].videoType ?? 0,
                typeId: sectionDataList?[index].typeId ?? 0,
              );
              }
            },

            // onTap: () {
            //   debugPrint("Clicked userid ==> ${Constant.userID}");
            //   debugPrint(
            //       "Clicked on link is  ==> ${sectionDataList?[index].video320.toString()}");
            //   if (Constant.userID == null) {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => LoginSocial()),
            //     );

            //     // Utils.buildWebAlertDialog(context, "login", "");
            //   } else {
            //     sectionDataList?[index].isLiveUrl == 1
            //         ? Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //                 builder: (context) => PlayerVideo(
            //                     '',
            //                     0,
            //                     0,
            //                     typeId,
            //                     0,
            //                     sectionDataList?[index].video320,
            //                     0,
            //                     "",
            //                     "")),
            //           )
            //         : openDetailPage(
            //             (sectionDataList?[index].videoType ?? 0) == 2
            //                 ? "showdetail"
            //                 : "videodetail",
            //             sectionDataList?[index].id ?? 0,
            //             upcomingType ?? 0,
            //             sectionDataList?[index].videoType ?? 0,
            //             sectionDataList?[index].typeId ?? 0,
            //           );
            //   }
            // },

            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: Dimens.widthLand,
                  height: Dimens.heightLand,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: MyNetworkImage(
                      imageUrl:
                          sectionDataList?[index].landscape.toString() ?? "",
                      fit: BoxFit.cover,
                      imgHeight: MediaQuery.of(context).size.height,
                      imgWidth: MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
                Visibility(
                  visible: sectionDataList?[index].isRent == 1 &&
                      sectionDataList?[index].isPremium == 0,
                  child: FittedBox(
                    child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 15,
                          minWidth: 30,
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: colorPrimary,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(3),
                              topRight: Radius.circular(4),
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(3)),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/rupee.png',
                              height: 13,
                              width: 13,
                            ),
                          ],
                        )),
                  ),
                ),
                Visibility(
                  visible: sectionDataList?[index].isPremium == 1,
                  child: FittedBox(
                    child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 15,
                          minWidth: 30,
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: colorPrimary,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(3),
                              topRight: Radius.circular(4),
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(3)),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/crown.png',
                              height: 15,
                              width: 15,
                            ),
                          ],
                        )),
                  ),
                ),
                Visibility(
                  visible: sectionDataList?[index].isRent == 1 &&
                      sectionDataList?[index].isPremium == 1,
                  child: FittedBox(
                    child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 15,
                          minWidth: 30,
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: colorPrimary,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(3),
                              topRight: Radius.circular(4),
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(3)),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/crown.png',
                              height: 15,
                              width: 15,
                            ),
                          ],
                        )),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget landscapeTwo(int? upcomingType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLand,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(6),
            onTap: () {
              debugPrint("Clicked userid ==> ${Constant.userID}");
              debugPrint(
                  "Clicked on link is  ==> ${sectionDataList?[index].video320.toString()}");
              if (sectionDataList?[index].isLiveUrl == 1) {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginSocial()),
                  );
                } else {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => PlayerVideo('', 0, 0, typeId, 0,
                  //           sectionDataList?[index].video320, 0, "", "")),
                  // );
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => TestPlayerWeb(
                          loadURL: sectionDataList![index].video320!)));
                }
              } else {
                Utils.openDetails(
                context: context,
                videoId: sectionDataList?[index].id ?? 0,
                upcomingType: upcomingType ?? 0,
                videoType: sectionDataList?[index].videoType ?? 0,
                typeId: sectionDataList?[index].typeId ?? 0,
              );
              }
            },
            // onTap: () {
            //   debugPrint("Clicked userid ==> ${Constant.userID}");
            //   debugPrint(
            //       "Clicked on link is  ==> ${sectionDataList?[index].video320.toString()}");
            //   if (Constant.userID == null) {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => LoginSocial()),
            //     );

            //     // Utils.buildWebAlertDialog(context, "login", "");
            //   } else {
            //     sectionDataList?[index].isLiveUrl == 1
            //         ? Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //                 builder: (context) => PlayerVideo(
            //                     '',
            //                     0,
            //                     0,
            //                     typeId,
            //                     0,
            //                     sectionDataList?[index].video320,
            //                     0,
            //                     "",
            //                     "")),
            //           )
            //         : openDetailPage(
            //             (sectionDataList?[index].videoType ?? 0) == 2
            //                 ? "showdetail"
            //                 : "videodetail",
            //             sectionDataList?[index].id ?? 0,
            //             upcomingType ?? 0,
            //             sectionDataList?[index].videoType ?? 0,
            //             sectionDataList?[index].typeId ?? 0,
            //           );
            //   }
            // },
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: Dimens.widthLandTwo,
                  height: Dimens.heightLandTwo,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: MyNetworkImage(
                      imageUrl:
                          sectionDataList?[index].landscape1.toString() ?? "",
                      fit: BoxFit.fill,
                      imgHeight: MediaQuery.of(context).size.height,
                      imgWidth: MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
                Visibility(
                  visible: sectionDataList?[index].isRent == 1 &&
                      sectionDataList?[index].isPremium == 0,
                  child: FittedBox(
                    child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 15,
                          minWidth: 30,
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: colorPrimary,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(3),
                              topRight: Radius.circular(4),
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(3)),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/rupee.png',
                              height: 13,
                              width: 13,
                            ),
                          ],
                        )),
                  ),
                ),
                Visibility(
                  visible: sectionDataList?[index].isPremium == 1,
                  child: FittedBox(
                    child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 15,
                          minWidth: 30,
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: colorPrimary,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(3),
                              topRight: Radius.circular(4),
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(3)),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/crown.png',
                              height: 15,
                              width: 15,
                            ),
                          ],
                        )),
                  ),
                ),
                Visibility(
                  visible: sectionDataList?[index].isRent == 1 &&
                      sectionDataList?[index].isPremium == 1,
                  child: FittedBox(
                    child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 15,
                          minWidth: 30,
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: colorPrimary,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(3),
                              topRight: Radius.circular(4),
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(3)),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/crown.png',
                              height: 15,
                              width: 15,
                            ),
                          ],
                        )),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget portrait(int? upcomingType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightPort,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
              focusColor: white,
              borderRadius: BorderRadius.circular(4),
              // onTap: () {
              //   debugPrint("Clicked userid ==> ${Constant.userID}");
              //   debugPrint(
              //       "Clicked on link is  ==> ${sectionDataList?[index].video320.toString()}");
              //   if (Constant.userID == null) {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => LoginSocial()),
              //     );

              //     // Utils.buildWebAlertDialog(context, "login", "");
              //   } else {
              //     sectionDataList?[index].isLiveUrl == 1
              //         ? Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) => PlayerVideo(
              //                     '',
              //                     0,
              //                     0,
              //                     typeId,
              //                     0,
              //                     sectionDataList?[index].video320,
              //                     0,
              //                     "",
              //                     "")),
              //           )
              //         : openDetailPage(
              //             (sectionDataList?[index].videoType ?? 0) == 2
              //                 ? "showdetail"
              //                 : "videodetail",
              //             sectionDataList?[index].id ?? 0,
              //             upcomingType ?? 0,
              //             sectionDataList?[index].videoType ?? 0,
              //             sectionDataList?[index].typeId ?? 0,
              //           );
              //   }
              // },
              onTap: () {
                debugPrint("Clicked userid ==> ${Constant.userID}");
                debugPrint(
                    "Clicked on link is  ==> ${sectionDataList?[index].video320.toString()}");
                if (sectionDataList?[index].isLiveUrl == 1) {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginSocial()),
                    );
                  } else {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => PlayerVideo('', 0, 0, typeId, 0,
                    //           sectionDataList?[index].video320, 0, "", "")),
                    // );
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TestPlayerWeb(
                            loadURL: sectionDataList![index].video320!)));
                  }
                } else {
                  Utils.openDetails(
                context: context,
                videoId: sectionDataList?[index].id ?? 0,
                upcomingType: upcomingType ?? 0,
                videoType: sectionDataList?[index].videoType ?? 0,
                typeId: sectionDataList?[index].typeId ?? 0,
              );
                }
              },
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: Dimens.widthPort,
                    height: Dimens.heightPort,
                    padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyNetworkImage(
                        imageUrl:
                            sectionDataList?[index].thumbnail.toString() ?? "",
                        fit: BoxFit.cover,
                        imgHeight: MediaQuery.of(context).size.height,
                        imgWidth: MediaQuery.of(context).size.width,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: sectionDataList?[index].isRent == 1 &&
                        sectionDataList?[index].isPremium == 0,
                    child: FittedBox(
                      child: Container(
                          constraints: const BoxConstraints(
                            minHeight: 15,
                            minWidth: 30,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(3),
                                topRight: Radius.circular(4),
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(3)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/rupee.png',
                                height: 13,
                                width: 13,
                              ),
                            ],
                          )),
                    ),
                  ),
                  Visibility(
                    visible: sectionDataList?[index].isPremium == 1,
                    child: FittedBox(
                      child: Container(
                          constraints: const BoxConstraints(
                            minHeight: 15,
                            minWidth: 30,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(3),
                                topRight: Radius.circular(4),
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(3)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/crown.png',
                                height: 15,
                                width: 15,
                              ),
                            ],
                          )),
                    ),
                  ),
                  Visibility(
                    visible: sectionDataList?[index].isRent == 1 &&
                        sectionDataList?[index].isPremium == 1,
                    child: FittedBox(
                      child: Container(
                          constraints: const BoxConstraints(
                            minHeight: 15,
                            minWidth: 30,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(3),
                                topRight: Radius.circular(4),
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(3)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/crown.png',
                                height: 15,
                                width: 15,
                              ),
                            ],
                          )),
                    ),
                  ),
                ],
              ));
        },
      ),
    );
  }

  Widget portraitTwo(int? upcomingType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightPortTwo,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
              focusColor: white,
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                debugPrint("Clicked userid ==> ${Constant.userID}");
                debugPrint(
                    "Clicked on link is  ==> ${sectionDataList?[index].video320.toString()}");
                if (sectionDataList?[index].isLiveUrl == 1) {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginSocial()),
                    );
                  } else {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => PlayerVideo('', 0, 0, typeId, 0,
                    //           sectionDataList?[index].video320, 0, "", "")),
                    // );
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TestPlayerWeb(
                            loadURL: sectionDataList![index].video320!)));
                  }
                } else {
                  Utils.openDetails(
                context: context,
                videoId: sectionDataList?[index].id ?? 0,
                upcomingType: upcomingType ?? 0,
                videoType: sectionDataList?[index].videoType ?? 0,
                typeId: sectionDataList?[index].typeId ?? 0,
              );
                }
              },
              // onTap: () {
              //   debugPrint("Clicked userid ==> ${Constant.userID}");
              //   debugPrint(
              //       "Clicked on link is  ==> ${sectionDataList?[index].video320.toString()}");
              //   if (Constant.userID == null) {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => LoginSocial()),
              //     );

              //     // Utils.buildWebAlertDialog(context, "login", "");
              //   } else {
              //     sectionDataList?[index].isLiveUrl == 1
              //         ? Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) => PlayerVideo(
              //                     '',
              //                     0,
              //                     0,
              //                     typeId,
              //                     0,
              //                     sectionDataList?[index].video320,
              //                     0,
              //                     "",
              //                     "")),
              //           )
              //         : openDetailPage(
              //             (sectionDataList?[index].videoType ?? 0) == 2
              //                 ? "showdetail"
              //                 : "videodetail",
              //             sectionDataList?[index].id ?? 0,
              //             upcomingType ?? 0,
              //             sectionDataList?[index].videoType ?? 0,
              //             sectionDataList?[index].typeId ?? 0,
              //           );
              //   }
              // },
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: Dimens.widthPortTwo,
                    height: Dimens.heightPortTwo,
                    padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyNetworkImage(
                        imageUrl:
                            sectionDataList?[index].thumbnail1.toString() ?? "",
                        fit: BoxFit.cover,
                        imgHeight: MediaQuery.of(context).size.height,
                        imgWidth: MediaQuery.of(context).size.width,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: sectionDataList?[index].isRent == 1 &&
                        sectionDataList?[index].isPremium == 0,
                    child: FittedBox(
                      child: Container(
                          constraints: const BoxConstraints(
                            minHeight: 15,
                            minWidth: 30,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(3),
                                topRight: Radius.circular(4),
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(3)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/rupee.png',
                                height: 13,
                                width: 13,
                              ),
                            ],
                          )),
                    ),
                  ),
                  Visibility(
                    visible: sectionDataList?[index].isPremium == 1,
                    child: FittedBox(
                      child: Container(
                          constraints: const BoxConstraints(
                            minHeight: 15,
                            minWidth: 30,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(3),
                                topRight: Radius.circular(4),
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(3)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/crown.png',
                                height: 15,
                                width: 15,
                              ),
                            ],
                          )),
                    ),
                  ),
                  Visibility(
                    visible: sectionDataList?[index].isRent == 1 &&
                        sectionDataList?[index].isPremium == 1,
                    child: FittedBox(
                      child: Container(
                          constraints: const BoxConstraints(
                            minHeight: 15,
                            minWidth: 30,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(3),
                                topRight: Radius.circular(4),
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(3)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/crown.png',
                                height: 15,
                                width: 15,
                              ),
                            ],
                          )),
                    ),
                  ),
                ],
              ));
        },
      ),
    );
  }

  Widget square(int? upcomingType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightSquare,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
              focusColor: white,
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                debugPrint("Clicked userid ==> ${Constant.userID}");
                debugPrint(
                    "Clicked on link is  ==> ${sectionDataList?[index].video320.toString()}");
                if (sectionDataList?[index].isLiveUrl == 1) {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginSocial()),
                    );
                  } else {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => PlayerVideo('', 0, 0, typeId, 0,
                    //           sectionDataList?[index].video320, 0, "", "")),
                    // );
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TestPlayerWeb(
                            loadURL: sectionDataList![index].video320!)));
                  }
                } else {
                  Utils.openDetails(
                context: context,
                videoId: sectionDataList?[index].id ?? 0,
                upcomingType: upcomingType ?? 0,
                videoType: sectionDataList?[index].videoType ?? 0,
                typeId: sectionDataList?[index].typeId ?? 0,
              );
                }
              },
              // onTap: () {
              //   debugPrint("Clicked userid ==> ${Constant.userID}");
              //   debugPrint(
              //       "Clicked on link is  ==> ${sectionDataList?[index].video320.toString()}");
              //   if (Constant.userID == null) {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => LoginSocial()),
              //     );

              //     // Utils.buildWebAlertDialog(context, "login", "");
              //   } else {
              //     sectionDataList?[index].isLiveUrl == 1
              //         ? Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) => PlayerVideo(
              //                     '',
              //                     0,
              //                     0,
              //                     typeId,
              //                     0,
              //                     sectionDataList?[index].video320,
              //                     0,
              //                     "",
              //                     "")),
              //           )
              //         : openDetailPage(
              //             (sectionDataList?[index].videoType ?? 0) == 2
              //                 ? "showdetail"
              //                 : "videodetail",
              //             sectionDataList?[index].id ?? 0,
              //             upcomingType ?? 0,
              //             sectionDataList?[index].videoType ?? 0,
              //             sectionDataList?[index].typeId ?? 0,
              //           );
              //   }
              // },
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: Dimens.widthSquare,
                    height: Dimens.heightSquare,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyNetworkImage(
                        imageUrl:
                            sectionDataList?[index].thumbnail.toString() ?? "",
                        fit: BoxFit.cover,
                        imgHeight: MediaQuery.of(context).size.height,
                        imgWidth: MediaQuery.of(context).size.width,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: sectionDataList?[index].isRent == 1 &&
                        sectionDataList?[index].isPremium == 0,
                    child: FittedBox(
                      child: Container(
                          constraints: const BoxConstraints(
                            minHeight: 15,
                            minWidth: 30,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(3),
                                topRight: Radius.circular(4),
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(3)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/rupee.png',
                                height: 13,
                                width: 13,
                              ),
                            ],
                          )),
                    ),
                  ),
                  Visibility(
                    visible: sectionDataList?[index].isPremium == 1,
                    child: FittedBox(
                      child: Container(
                          constraints: const BoxConstraints(
                            minHeight: 15,
                            minWidth: 30,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(3),
                                topRight: Radius.circular(4),
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(3)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/crown.png',
                                height: 15,
                                width: 15,
                              ),
                            ],
                          )),
                    ),
                  ),
                  Visibility(
                    visible: sectionDataList?[index].isRent == 1 &&
                        sectionDataList?[index].isPremium == 1,
                    child: FittedBox(
                      child: Container(
                          constraints: const BoxConstraints(
                            minHeight: 15,
                            minWidth: 30,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(3),
                                topRight: Radius.circular(4),
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(3)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/crown.png',
                                height: 15,
                                width: 15,
                              ),
                            ],
                          )),
                    ),
                  ),
                ],
              ));
        },
      ),
    );
  }

  Widget languageLayoutLand(int? typeId, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLangGenLand,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  debugPrint("Clicked on index ==> $index");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return VideosByID(
                          sectionDataList?[index].id ?? 0,
                          typeId ?? 0,
                          sectionDataList?[index].name ?? "",
                          "ByLanguage",
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  width: Dimens.widthLangGenLand,
                  height: Dimens.heightLangGenLand,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                  child: Stack(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: MyNetworkImage(
                          imageUrl:
                              sectionDataList?[index].image.toString() ?? "",
                          fit: BoxFit.fill,
                          imgHeight: MediaQuery.of(context).size.height,
                          imgWidth: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.heightLangGenLand,
                        alignment: Alignment.center,
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
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget languageLayout(int? typeId, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLangGen,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  debugPrint("Clicked on index ==> $index");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return VideosByID(
                          sectionDataList?[index].id ?? 0,
                          typeId ?? 0,
                          sectionDataList?[index].name ?? "",
                          "ByLanguage",
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  width: Dimens.widthLangGen,
                  height: Dimens.heightLangGen,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                  child: Stack(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: MyNetworkImage(
                          imageUrl:
                              sectionDataList?[index].image.toString() ?? "",
                          fit: BoxFit.fill,
                          imgHeight: MediaQuery.of(context).size.height,
                          imgWidth: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.heightLangGen,
                        alignment: Alignment.center,
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
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget genresLayout(int? typeId, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLangGen,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  debugPrint("Clicked on index ==> $index");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return VideosByID(
                          sectionDataList?[index].id ?? 0,
                          typeId ?? 0,
                          sectionDataList?[index].name ?? "",
                          "ByCategory",
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  width: Dimens.widthLangGen,
                  height: Dimens.heightLangGen,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                  child: Stack(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: MyNetworkImage(
                          imageUrl:
                              sectionDataList?[index].image.toString() ?? "",
                          fit: BoxFit.fill,
                          imgHeight: MediaQuery.of(context).size.height,
                          imgWidth: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.heightLangGen,
                        alignment: Alignment.center,
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
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3),
                child: MyText(
                  color: white,
                  text: sectionDataList?[index].name.toString() ?? "",
                  textalign: TextAlign.center,
                  fontsizeNormal: 14,
                  fontweight: FontWeight.w600,
                  fontsizeWeb: 15,
                  multilanguage: false,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget topTenLayout(int? upcomingType, List<Datum>? sectionDataList) {
    getAdaptiveTextSize(BuildContext context, dynamic value) {
      if (kIsWeb || Constant.isTV) {
        return (value / 650) *
            min(MediaQuery.of(context).size.height,
                MediaQuery.of(context).size.width);
      } else {
        return (value / 720 * MediaQuery.of(context).size.height);
      }
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightTopTen,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 1),
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            children: [
              InkWell(
                  focusColor: white,
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    debugPrint("Clicked userid ==> ${Constant.userID}");
                    debugPrint(
                        "Clicked on link is  ==> ${sectionDataList?[index].video320.toString()}");
                    if (sectionDataList?[index].isLiveUrl == 1) {
                      if (Constant.userID == null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginSocial()),
                        );
                      } else {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => PlayerVideo(
                        //           '',
                        //           0,
                        //           0,
                        //           typeId,
                        //           0,
                        //           sectionDataList?[index].video320,
                        //           0,
                        //           "",
                        //           "")),
                        // );
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => TestPlayerWeb(
                                loadURL: sectionDataList![index].video320!)));
                      }
                    } else {
                      Utils.openDetails(
                context: context,
                videoId: sectionDataList?[index].id ?? 0,
                upcomingType: upcomingType ?? 0,
                videoType: sectionDataList?[index].videoType ?? 0,
                typeId: sectionDataList?[index].typeId ?? 0,
              );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: Container(
                      width: Dimens.widthTopTen,
                      height: Dimens.heightTopTen,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            width: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: MyNetworkImage(
                                imageUrl: sectionDataList?[index]
                                        .thumbnail1
                                        .toString() ??
                                    "",
                                fit: BoxFit.fill,
                                imgHeight: MediaQuery.of(context).size.height,
                                imgWidth: MediaQuery.of(context).size.width,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: sectionDataList?[index].isRent == 1 &&
                                sectionDataList?[index].isPremium == 0,
                            child: FittedBox(
                              child: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 15,
                                    minWidth: 30,
                                  ),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: colorPrimary,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(3),
                                        topRight: Radius.circular(4),
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/rupee.png',
                                        height: 13,
                                        width: 13,
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                          Visibility(
                            visible: sectionDataList?[index].isPremium == 1,
                            child: FittedBox(
                              child: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 15,
                                    minWidth: 30,
                                  ),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: colorPrimary,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(3),
                                        topRight: Radius.circular(4),
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/crown.png',
                                        height: 15,
                                        width: 15,
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                          Visibility(
                            visible: sectionDataList?[index].isRent == 1 &&
                                sectionDataList?[index].isPremium == 1,
                            child: FittedBox(
                              child: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 15,
                                    minWidth: 30,
                                  ),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: colorPrimary,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(3),
                                        topRight: Radius.circular(4),
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/crown.png',
                                        height: 15,
                                        width: 15,
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              Positioned(
                left: 0,
                bottom: -18,
                child: Container(
                  child: RichText(
                    text: TextSpan(children: <TextSpan>[
                      TextSpan(
                        text: '${index + 1} ',
                        style: GoogleFonts.outfit(
                          fontSize: getAdaptiveTextSize(
                            context,
                            60,
                          ),
                          fontStyle: FontStyle.normal,
                          color: topTen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget browseByArtistLayout(int? typeId, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightArtist,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Column(
            // alignment: AlignmentDirectional.bottomStart,
            children: [
              InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  debugPrint("Clicked on index ==> $index");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return VideosByArtist(
                          sectionDataList?[index].id ?? 0,
                          typeId ?? 0,
                          sectionDataList?[index].name ?? "",
                          "ByArtist",
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  width: Dimens.widthArtist,
                  height: 100,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                  child: Stack(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: MyNetworkImage(
                          imageUrl:
                              sectionDataList?[index].image.toString() ?? "",
                          fit: BoxFit.fill,
                          imgHeight: MediaQuery.of(context).size.height,
                          imgWidth: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width,
                        height: 100,
                        alignment: Alignment.center,
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
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3),
                child: MyText(
                  color: white,
                  text: sectionDataList?[index].name.toString() ?? "",
                  textalign: TextAlign.center,
                  fontsizeNormal: 10,
                  fontweight: FontWeight.w600,
                  fontsizeWeb: 15,
                  multilanguage: false,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  // Widget setSectionData(
  //     {required List<list.Result>? sectionList, required int index}) {
  //   /* video_type =>  1-video,  2-show,  3-language,  4-category */
  //   /* screen_layout =>  landscape, potrait, square */
  //   if ((sectionList?[index].videoType ?? 0) == 1) {
  //     if ((sectionList?[index].screenLayout ?? "") == "landscape") {
  //       return landscape(
  //           sectionList?[index].upcomingType, sectionList?[index].data);
  //     } else if ((sectionList?[index].screenLayout ?? "") == "potrait") {
  //       return portrait(
  //           sectionList?[index].upcomingType, sectionList?[index].data);
  //     } else if ((sectionList?[index].screenLayout ?? "") == "square") {
  //       return square(
  //           sectionList?[index].upcomingType, sectionList?[index].data);
  //     } else {
  //       return landscape(
  //           sectionList?[index].upcomingType, sectionList?[index].data);
  //     }
  //   } else if ((sectionList?[index].videoType ?? 0) == 2) {
  //     if ((sectionList?[index].screenLayout ?? "") == "landscape") {
  //       return landscape(
  //           sectionList?[index].upcomingType, sectionList?[index].data);
  //     } else if ((sectionList?[index].screenLayout ?? "") == "potrait") {
  //       return portrait(
  //           sectionList?[index].upcomingType, sectionList?[index].data);
  //     } else if ((sectionList?[index].screenLayout ?? "") == "square") {
  //       return square(
  //           sectionList?[index].upcomingType, sectionList?[index].data);
  //     } else {
  //       return landscape(
  //           sectionList?[index].upcomingType, sectionList?[index].data);
  //     }
  //   } else if ((sectionList?[index].videoType ?? 0) == 3) {
  //     return languageLayout(
  //         sectionList?[index].typeId ?? 0, sectionList?[index].data);
  //   } else if ((sectionList?[index].videoType ?? 0) == 4) {
  //     return genresLayout(
  //         sectionList?[index].typeId ?? 0, sectionList?[index].data);
  //   } else {
  //     if ((sectionList?[index].screenLayout ?? "") == "landscape") {
  //       return landscape(
  //           sectionList?[index].upcomingType, sectionList?[index].data);
  //     } else if ((sectionList?[index].screenLayout ?? "") == "potrait") {
  //       return portrait(
  //           sectionList?[index].upcomingType, sectionList?[index].data);
  //     } else if ((sectionList?[index].screenLayout ?? "") == "square") {
  //       return square(
  //           sectionList?[index].upcomingType, sectionList?[index].data);
  //     } else {
  //       return landscape(
  //           sectionList?[index].upcomingType, sectionList?[index].data);
  //     }
  //   }
  // }


  // double getRemainingDataHeight(String? videoType, String? layoutType) {
  //   if (videoType == "1" || videoType == "2") {
  //     if (layoutType == "landscape") {
  //       return Dimens.heightLand;
  //     } else if (layoutType == "potrait") {
  //       return Dimens.heightPort;
  //     } else if (layoutType == "square") {
  //       return Dimens.heightSquare;
  //     } else {
  //       return Dimens.heightLand;
  //     }
  //   } else if (videoType == "3" || videoType == "4") {
  //     return Dimens.heightLangGen;
  //   } else {
  //     if (layoutType == "landscape") {
  //       return Dimens.heightLand;
  //     } else if (layoutType == "potrait") {
  //       return Dimens.heightPort;
  //     } else if (layoutType == "square") {
  //       return Dimens.heightSquare;
  //     } else {
  //       return Dimens.heightLand;
  //     }
  //   }
  // }

  // Widget landscape(int? upcomingType, List<Datum>? sectionDataList) {
  //   return SizedBox(
  //     width: MediaQuery.of(context).size.width,
  //     height: Dimens.heightLand,
  //     child: ListView.separated(
  //       itemCount: sectionDataList?.length ?? 0,
  //       shrinkWrap: true,
  //       padding: const EdgeInsets.only(left: 20, right: 20),
  //       scrollDirection: Axis.horizontal,
  //       physics:
  //           const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
  //       separatorBuilder: (context, index) => const SizedBox(width: 5),
  //       itemBuilder: (BuildContext context, int index) {
  //         return InkWell(
  //           borderRadius: BorderRadius.circular(4),
  //           onTap: () {
  //             debugPrint("Clicked on index ==> $index");
  //             Utils.openDetails(
  //               context: context,
  //               videoId: sectionDataList?[index].id ?? 0,
  //               upcomingType: upcomingType ?? 0,
  //               videoType: sectionDataList?[index].videoType ?? 0,
  //               typeId: sectionDataList?[index].typeId ?? 0,
  //             );
  //           },
  //           child: Container(
  //             width: Dimens.widthLand,
  //             height: Dimens.heightLand,
  //             alignment: Alignment.center,
  //             child: ClipRRect(
  //               borderRadius: BorderRadius.circular(4),
  //               clipBehavior: Clip.antiAliasWithSaveLayer,
  //               child: MyNetworkImage(
  //                 imageUrl: sectionDataList?[index].landscape.toString() ?? "",
  //                 fit: BoxFit.cover,
  //                 imgHeight: MediaQuery.of(context).size.height,
  //                 imgWidth: MediaQuery.of(context).size.width,
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  // Widget portrait(int? upcomingType, List<Datum>? sectionDataList) {
  //   return SizedBox(
  //     width: MediaQuery.of(context).size.width,
  //     height: Dimens.heightPort,
  //     child: ListView.separated(
  //       itemCount: sectionDataList?.length ?? 0,
  //       shrinkWrap: true,
  //       padding: const EdgeInsets.only(left: 20, right: 20),
  //       scrollDirection: Axis.horizontal,
  //       physics:
  //           const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
  //       separatorBuilder: (context, index) => const SizedBox(
  //         width: 5,
  //       ),
  //       itemBuilder: (BuildContext context, int index) {
  //         return InkWell(
  //           borderRadius: BorderRadius.circular(4),
  //           onTap: () {
  //             debugPrint("Clicked on index ==> $index");
  //             Utils.openDetails(
  //               context: context,
  //               videoId: sectionDataList?[index].id ?? 0,
  //               upcomingType: upcomingType ?? 0,
  //               videoType: sectionDataList?[index].videoType ?? 0,
  //               typeId: sectionDataList?[index].typeId ?? 0,
  //             );
  //           },
  //           child: Container(
  //             width: Dimens.widthPort,
  //             height: Dimens.heightPort,
  //             alignment: Alignment.center,
  //             child: ClipRRect(
  //               borderRadius: BorderRadius.circular(4),
  //               clipBehavior: Clip.antiAliasWithSaveLayer,
  //               child: MyNetworkImage(
  //                 imageUrl: sectionDataList?[index].thumbnail.toString() ?? "",
  //                 fit: BoxFit.cover,
  //                 imgHeight: MediaQuery.of(context).size.height,
  //                 imgWidth: MediaQuery.of(context).size.width,
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  // Widget square(int? upcomingType, List<Datum>? sectionDataList) {
  //   return SizedBox(
  //     width: MediaQuery.of(context).size.width,
  //     height: Dimens.heightSquare,
  //     child: ListView.separated(
  //       itemCount: sectionDataList?.length ?? 0,
  //       shrinkWrap: true,
  //       scrollDirection: Axis.horizontal,
  //       physics:
  //           const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
  //       padding: const EdgeInsets.only(left: 20, right: 20),
  //       separatorBuilder: (context, index) => const SizedBox(
  //         width: 5,
  //       ),
  //       itemBuilder: (BuildContext context, int index) {
  //         return InkWell(
  //           borderRadius: BorderRadius.circular(4),
  //           onTap: () {
  //             debugPrint("Clicked on index ==> $index");
  //             Utils.openDetails(
  //               context: context,
  //               videoId: sectionDataList?[index].id ?? 0,
  //               upcomingType: upcomingType ?? 0,
  //               videoType: sectionDataList?[index].videoType ?? 0,
  //               typeId: sectionDataList?[index].typeId ?? 0,
  //             );
  //           },
  //           child: Container(
  //             width: Dimens.widthSquare,
  //             height: Dimens.heightSquare,
  //             alignment: Alignment.center,
  //             child: ClipRRect(
  //               borderRadius: BorderRadius.circular(4),
  //               clipBehavior: Clip.antiAliasWithSaveLayer,
  //               child: MyNetworkImage(
  //                 imageUrl: sectionDataList?[index].thumbnail.toString() ?? "",
  //                 fit: BoxFit.cover,
  //                 imgHeight: MediaQuery.of(context).size.height,
  //                 imgWidth: MediaQuery.of(context).size.width,
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }


}
