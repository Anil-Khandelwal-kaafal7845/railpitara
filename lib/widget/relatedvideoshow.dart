

import 'package:dtlive/model/sectiondetailmodel.dart';
import 'package:dtlive/pages/home_screen.dart';
import 'package:dtlive/pages/movie_details.dart';
import 'package:dtlive/pages/showdetails.dart';
import 'package:dtlive/tvpages/tvmoviedetails.dart';
import 'package:dtlive/tvpages/tvshowdetails.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/dimens.dart';
import 'package:dtlive/widget/mynetworkimg.dart';
import 'package:dtlive/widget/mytext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RelatedVideoShow extends StatefulWidget {
  final List<GetRelatedVideo>? relatedDataList;
  const RelatedVideoShow({required this.relatedDataList, Key? key})
      : super(key: key);

  @override
  State<RelatedVideoShow> createState() => _RelatedVideoShowState();
}

class _RelatedVideoShowState extends State<RelatedVideoShow> {
  HomeState? homeStateObject;

  @override
  void initState() {
    homeStateObject = context.findAncestorStateOfType<HomeState>();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.relatedDataList != null &&
        (widget.relatedDataList?.length ?? 0) > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 7),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 20, 0),
            child: MyText(
              color: white,
              text: "customer_also_watch",
              multilanguage: true,
              textalign: TextAlign.start,
              fontsizeNormal: 12,
              fontweight: FontWeight.w400,
              fontsizeWeb: 13,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal,
            ),
          ),
          const SizedBox(height: 12),
          /* video_type =>  1-video,  2-show,  3-language,  4-category */
          /* screen_layout =>  landscape, potrait, square */
          // SizedBox(
          //   width: MediaQuery.of(context).size.width,
          //   height: Dimens.heightLand,
          //   child: landscape(widget.relatedDataList),
          // ),
          SizedBox(
  width: MediaQuery.of(context).size.width,
    height: Dimens.heightPortTwo,
  child: portrait(widget.relatedDataList),
),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
Widget portrait(List<GetRelatedVideo>? relatedDataList) {
  return SizedBox(
    width: MediaQuery.of(context).size.width,
    height: Dimens.heightPortTwo,
    child: ListView.separated(
      itemCount: relatedDataList?.length ?? 0,
      shrinkWrap: true,
      padding: const EdgeInsets.only(left: 20, right: 5),
      scrollDirection: Axis.horizontal,
      physics: const AlwaysScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            debugPrint("Clicked on index ==> $index");
            if ((relatedDataList?[index].videoType ?? 0) == 5) {
              if ((relatedDataList?[index].upcomingType ?? 0) == 1) {
                if (!(context.mounted)) return;
                await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      if (kIsWeb || Constant.isTV) {
                        return TVMovieDetails(
                          relatedDataList?[index].id ?? 0,
                          relatedDataList?[index].upcomingType ?? 0,
                          relatedDataList?[index].videoType ?? 0,
                          relatedDataList?[index].typeId ?? 0,
                        );
                      } else {
                        return MovieDetails(
                          relatedDataList?[index].id ?? 0,
                          relatedDataList?[index].upcomingType ?? 0,
                          relatedDataList?[index].videoType ?? 0,
                          relatedDataList?[index].typeId ?? 0,
                          isDynamicLink: false,
                        );
                      }
                    },
                  ),
                );
              } else if ((relatedDataList?[index].upcomingType ?? 0) == 2) {
                if (!(context.mounted)) return;
                await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      if (kIsWeb || Constant.isTV) {
                        return TVShowDetails(
                          relatedDataList?[index].id ?? 0,
                          relatedDataList?[index].upcomingType ?? 0,
                          relatedDataList?[index].videoType ?? 0,
                          relatedDataList?[index].typeId ?? 0,
                        );
                      } else {
                        return ShowDetails(
                          relatedDataList?[index].id ?? 0,
                          relatedDataList?[index].upcomingType ?? 0,
                          relatedDataList?[index].videoType ?? 0,
                          relatedDataList?[index].typeId ?? 0,
                          isDynamicLink: false,
                        );
                      }
                    },
                  ),
                );
              }
            } else {
              if ((relatedDataList?[index].videoType ?? 0) == 1) {
                if (!(context.mounted)) return;
                await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      if (kIsWeb || Constant.isTV) {
                        return TVMovieDetails(
                          relatedDataList?[index].id ?? 0,
                          relatedDataList?[index].upcomingType ?? 0,
                          relatedDataList?[index].videoType ?? 0,
                          relatedDataList?[index].typeId ?? 0,
                        );
                      } else {
                        return MovieDetails(
                          relatedDataList?[index].id ?? 0,
                          relatedDataList?[index].upcomingType ?? 0,
                          relatedDataList?[index].videoType ?? 0,
                          relatedDataList?[index].typeId ?? 0,
                          isDynamicLink: false,
                        );
                      }
                    },
                  ),
                );
              } else if ((relatedDataList?[index].videoType ?? 0) == 2) {
                if (!(context.mounted)) return;
                await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      if (kIsWeb || Constant.isTV) {
                        return TVShowDetails(
                          relatedDataList?[index].id ?? 0,
                          relatedDataList?[index].upcomingType ?? 0,
                          relatedDataList?[index].videoType ?? 0,
                          relatedDataList?[index].typeId ?? 0,
                        );
                      } else {
                        return ShowDetails(
                          relatedDataList?[index].id ?? 0,
                          relatedDataList?[index].upcomingType ?? 0,
                          relatedDataList?[index].videoType ?? 0,
                          relatedDataList?[index].typeId ?? 0,
                          isDynamicLink: false,
                        );
                      }
                    },
                  ),
                );
              }
            }
          },
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: Dimens.widthPortTwo,
                height: Dimens.heightPortTwo,
                padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 5)
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      MyNetworkImage(
                        imageUrl: relatedDataList?[index].thumbnail.toString() ?? "",
                        fit: BoxFit.cover,
                        imgHeight: MediaQuery.of(context).size.height,
                        imgWidth: MediaQuery.of(context).size.width,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent
                            ],
                          ),
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



  // Widget landscape(List<GetRelatedVideo>? relatedDataList) {
  //   return ListView.separated(
  //     itemCount: relatedDataList?.length ?? 0,
  //     shrinkWrap: true,
  //     padding: const EdgeInsets.only(left: 20, right: 20),
  //     scrollDirection: Axis.horizontal,
  //     physics: const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
  //     separatorBuilder: (context, index) => const SizedBox(width: 5),
  //     itemBuilder: (BuildContext context, int index) {
  //       return InkWell(
  //         borderRadius: BorderRadius.circular(4),
  //         //focusColor:: white,
  //         onTap: () async {
  //           debugPrint("Clicked on index ==> $index");
  //           if ((relatedDataList?[index].videoType ?? 0) == 5) {
  //             if ((relatedDataList?[index].upcomingType ?? 0) == 1) {
  //               if (!(context.mounted)) return;
  //               await Navigator.pushReplacement(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) {
  //                     if (kIsWeb || Constant.isTV) {
  //                       return TVMovieDetails(
  //                         relatedDataList?[index].id ?? 0,
  //                         relatedDataList?[index].upcomingType ?? 0,
  //                         relatedDataList?[index].videoType ?? 0,
  //                         relatedDataList?[index].typeId ?? 0,
  //                       );
  //                     } else {
  //                       return MovieDetails(
  //                         relatedDataList?[index].id ?? 0,
  //                         relatedDataList?[index].upcomingType ?? 0,
  //                         relatedDataList?[index].videoType ?? 0,
  //                         relatedDataList?[index].typeId ?? 0,
  //                         isDynamicLink: false
  //                       );
  //                     }
  //                   },
  //                 ),
  //               );
  //             } else if ((relatedDataList?[index].upcomingType ?? 0) == 2) {
  //               if (!(context.mounted)) return;
  //               await Navigator.pushReplacement(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) {
  //                     if (kIsWeb || Constant.isTV) {
  //                       return TVShowDetails(
  //                         relatedDataList?[index].id ?? 0,
  //                         relatedDataList?[index].upcomingType ?? 0,
  //                         relatedDataList?[index].videoType ?? 0,
  //                         relatedDataList?[index].typeId ?? 0,
  //                       );
  //                     } else {
  //                       return ShowDetails(
  //                         relatedDataList?[index].id ?? 0,
  //                         relatedDataList?[index].upcomingType ?? 0,
  //                         relatedDataList?[index].videoType ?? 0,
  //                         relatedDataList?[index].typeId ?? 0,
  //                         isDynamicLink: false,
                          
  //                       );
  //                     }
  //                   },
  //                 ),
  //               );
  //             }
  //           } else {
  //             if ((relatedDataList?[index].videoType ?? 0) == 1) {
  //               if (!(context.mounted)) return;
  //               await Navigator.pushReplacement(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) {
  //                     if (kIsWeb || Constant.isTV) {
  //                       return TVMovieDetails(
  //                         relatedDataList?[index].id ?? 0,
  //                         relatedDataList?[index].upcomingType ?? 0,
  //                         relatedDataList?[index].videoType ?? 0,
  //                         relatedDataList?[index].typeId ?? 0,
  //                       );
  //                     } else {
  //                       return MovieDetails(
  //                         relatedDataList?[index].id ?? 0,
  //                         relatedDataList?[index].upcomingType ?? 0,
  //                         relatedDataList?[index].videoType ?? 0,
  //                         relatedDataList?[index].typeId ?? 0,
  //                         isDynamicLink: false
  //                       );
  //                     }
  //                   },
  //                 ),
  //               );
  //             } else if ((relatedDataList?[index].videoType ?? 0) == 2) {
  //               if (!(context.mounted)) return;
  //               await Navigator.pushReplacement(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) {
  //                     if (kIsWeb || Constant.isTV) {
  //                       return TVShowDetails(
  //                         relatedDataList?[index].id ?? 0,
  //                         relatedDataList?[index].upcomingType ?? 0,
  //                         relatedDataList?[index].videoType ?? 0,
  //                         relatedDataList?[index].typeId ?? 0,
  //                       );
  //                     } else {
  //                       return ShowDetails(
  //                         relatedDataList?[index].id ?? 0,
  //                         relatedDataList?[index].upcomingType ?? 0,
  //                         relatedDataList?[index].videoType ?? 0,
  //                         relatedDataList?[index].typeId ?? 0,
  //                         isDynamicLink: false,
  //                       );
  //                     }
  //                   },
  //                 ),
  //               );
  //             }
  //           }
  //         },
  //         child: Container(
  //           width: Dimens.widthLand,
  //           height: Dimens.heightLand,
  //           alignment: Alignment.center,
  //           padding: const EdgeInsets.all(2.0),
  //           child: ClipRRect(
  //             borderRadius: BorderRadius.circular(4),
  //             clipBehavior: Clip.antiAliasWithSaveLayer,
  //             child: MyNetworkImage(
  //               imageUrl: relatedDataList?[index].landscape.toString() ?? "",
  //               fit: BoxFit.cover,
  //               imgHeight: MediaQuery.of(context).size.height,
  //               imgWidth: MediaQuery.of(context).size.width,
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }


}
