import 'package:dtlive/pages/loginsocial.dart';
import 'package:dtlive/pages/pip_web_player.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/dimens.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/widget/mynetworkimg.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../model/sectionlistmodel.dart';

class MoreScreen extends StatefulWidget {
  final String appBarTitle;
  final List<Datum>? sectionDataList;
  const MoreScreen(
    this.appBarTitle,
    this.sectionDataList, {
    Key? key,
  }) : super(key: key);

  @override
  State<MoreScreen> createState() => MoreScreenState();
}

class MoreScreenState extends State<MoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Utils.myAppBarWithBack(context, widget.appBarTitle, false),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                constraints: const BoxConstraints.expand(),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                      width: Dimens.widthLand,
                                  height: Dimens.heightLand,
                        padding: const EdgeInsets.fromLTRB(20, 6, 0, 20),
                        child: ResponsiveGridList(
                          minItemWidth: Dimens.widthLand,
                          verticalGridSpacing: 8,
                          horizontalGridSpacing: 8,
                          minItemsPerRow: 2,
                          maxItemsPerRow: 8,
                          listViewBuilderOptions: ListViewBuilderOptions(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                          ),
                          children: List.generate(
                            (widget.sectionDataList?.length ?? 0),
                            (position) {
                              return 
                              InkWell(
                                borderRadius: BorderRadius.circular(4),
                                onTap: () {
                                  debugPrint(
                                      "Clicked userid ==> ${Constant.userID}");
                                  debugPrint(
                                      "Clicked on link is  ==> ${widget.sectionDataList?[position].video320.toString()}");
                                  if (widget.sectionDataList?[position]
                                          .isLiveUrl ==
                                      1) {
                                    if (Constant.userID == null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginSocial()),
                                      );
                                    } else {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //       builder: (context) => PlayerVideo(
                                      //           '',
                                      //           0,
                                      //           0,
                                      //           0,
                                      //           0,
                                      //           widget
                                      //               .sectionDataList?[position]
                                      //               .video320,
                                      //           0,
                                      //           "",
                                      //           "")),
                                      // );
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TestPlayerWeb(
                                                      loadURL: widget
                                                          .sectionDataList![
                                                              position]
                                                          .video320!)));
                                    }
                                  } else {
                                    Utils.openDetails(
                                      context: context,
                                      videoId:
                                          widget.sectionDataList![position].id!,
                                      upcomingType: 0,
                                      videoType: widget
                                              .sectionDataList![position]
                                              .videoType ??
                                          0,
                                      typeId: widget.sectionDataList![position]
                                              .typeId ??
                                          0,
                                    );
                                  }
                                },
                                // onTap: () {
                                //   debugPrint(
                                //       "Clicked on position ==> $position");

                                //   // Utils.openDetails(
                                //   //   context: context,
                                //   //   videoId:
                                //   //       widget.sectionDataList![position].id!,
                                //   //   upcomingType: 0,
                                //   //   videoType: widget.sectionDataList![position]
                                //   //           .videoType ??
                                //   //       0,
                                //   //   typeId: widget.sectionDataList![position]
                                //   //           .typeId ??
                                //   //       0,
                                //   // );
                                // },
                                child:Stack(
                                  
                                   alignment: Alignment.topRight,

                                  children: [

                                 Container(
                                  width: Dimens.widthLand,
                                  height: Dimens.heightLand,
                                  alignment: Alignment.center,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: MyNetworkImage(
                                      imageUrl: widget
                                              .sectionDataList![position]
                                              .landscape ??
                                          "",
                                      fit: BoxFit.cover,
                                      imgHeight:
                                          MediaQuery.of(context).size.height,
                                      imgWidth:
                                          MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                ),
                             

                                     Visibility(
                  visible:(widget.sectionDataList![position].isRent == 1 &&
                                        widget.sectionDataList![position].isPremium == 0) ,
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
                  visible:  widget.sectionDataList![position].isPremium == 1,
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
                  visible:  widget.sectionDataList![position].isRent == 1 &&
                       widget.sectionDataList![position].isPremium == 1,
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
                                )
                                ,
                             
                              );
                         
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            /* AdMob Banner */
            Container(
              child: Utils.showBannerAd(context),
            ),
          ],
        ),
      ),
    );
  }
}
