import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:dtlive/utils/dimens.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/widget/mynetworkimg.dart';
import 'package:dtlive/provider/sectiondataprovider.dart';

import '../utils/constant.dart';

class MoreScreen extends StatefulWidget {
  final String appBarTitle;
  final String sectionId;

  const MoreScreen(this.appBarTitle, this.sectionId, {Key? key}) : super(key: key);

  @override
  State<MoreScreen> createState() => MoreScreenState();
}

class MoreScreenState extends State<MoreScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<SectionDataProvider>(context, listen: false).getViewAll(widget.sectionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
     appBar: (kIsWeb || Constant.isTV)
          ? Utils.myAppBar(context, widget.appBarTitle, false)
          : Utils.myAppBarWithBack(context, widget.appBarTitle, false),
     
      body: SafeArea(
        child: Consumer<SectionDataProvider>(
          builder: (context, sectionDataProvider, child) {
            if (sectionDataProvider.loadingViewAll) {
              return Center(
                child: CircularProgressIndicator(
                  color: primaryLight,
                ),
              );
            }

            final sectionDataList = sectionDataProvider.sectionDataList;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    constraints: const BoxConstraints.expand(),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 6, 10, 5),
                            child: ResponsiveGridList(
                              minItemWidth: Dimens.widthLandmore,
                              verticalGridSpacing: 8,
                              horizontalGridSpacing: 8,
                              minItemsPerRow: 2,
                              maxItemsPerRow: 8,
                              listViewBuilderOptions: ListViewBuilderOptions(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                              ),
                              children: List.generate(
                                sectionDataList.length,
                                (position) {
                                  final videoData = sectionDataList[position];
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(4),
                                    onTap: () {
                                      debugPrint("Clicked on position ==> $position");
                                      Utils.openDetails(
                                        context: context,
                                        videoId: videoData.id,
                                        upcomingType: 0,
                                        videoType: 2,
                                        typeId: 4,
                                      );
                                    },
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Container(
                                          width: Dimens.widthLandmore,
                                          height: Dimens.heightLand,
                                          alignment: Alignment.center,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            clipBehavior: Clip.antiAliasWithSaveLayer,
                                            child: MyNetworkImage(
                                              imageUrl: videoData.landscape.toString(),
                                              fit: BoxFit.cover,
                                              imgHeight: double.infinity,
                                              imgWidth: Dimens.widthLandmore,
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: videoData.isRent == 1 && videoData.isPremium == 0,
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
                                                  bottomRight: Radius.circular(3),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    'assets/images/rupee.png',
                                                    height: 13,
                                                    width: 13,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: videoData.isPremium == 1,
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
                                                  bottomRight: Radius.circular(3),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    'assets/images/crown.png',
                                                    height: 15,
                                                    width: 15,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: videoData.isRent == 1 && videoData.isPremium == 1,
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
                                                  bottomRight: Radius.circular(3),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    'assets/images/crown.png',
                                                    height: 15,
                                                    width: 15,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      
                                      ],
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
            );
          },
        ),
      ),
    );
  }
}
