import 'dart:async';

import 'package:dtlive/shimmer/shimmerutils.dart';
import 'package:dtlive/utils/dimens.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/webwidget/footerweb.dart';
import 'package:dtlive/widget/nodata.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/widget/mynetworkimg.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../model/sectionlistmodel.dart';

class MoreScreen extends StatefulWidget {
   String appBarTitle;
   List<Datum>? sectionDataList;
   MoreScreen(
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
                                        ( widget.sectionDataList?.length?? 0),
                                        (position) {
                                          return InkWell(
                                            borderRadius: BorderRadius.circular(4),
                                            onTap: () {
                                              debugPrint("Clicked on position ==> $position");
                                              Utils.openDetails(
                                                context: context,
                                                videoId:widget.sectionDataList![position].id! ,
                                                  
                                                upcomingType: 0,
                                               videoType: widget.sectionDataList![position].videoType ?? 0,
                                          typeId: widget.sectionDataList![position].typeId ?? 0,
                                              );
                                            },
                                            child: Container(
                                              width: Dimens.widthLand,
                                              height: Dimens.heightLand,
                                              alignment: Alignment.center,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                                child: MyNetworkImage(
                                                  imageUrl:widget.sectionDataList![position].landscape ?? ""
                                                      ,
                                                  fit: BoxFit.cover,
                                                  imgHeight: MediaQuery.of(context).size.height,
                                                  imgWidth: MediaQuery.of(context).size.width,
                                                ),
                                              ),
                                            ),
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
  }}