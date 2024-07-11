import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:dtlive/utils/dimens.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/widget/mynetworkimg.dart';

import 'package:dtlive/provider/sectiondataprovider.dart';


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
      appBar: AppBar(
        shadowColor: appBgColor,
        backgroundColor: appBgColor,
        title: Center(child: Text("${widget.appBarTitle}")),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Consumer<SectionDataProvider>(
          builder: (context, sectionDataProvider, child) {
            if (sectionDataProvider.loadingViewAll) {
              return Center(child: CircularProgressIndicator(color: primaryLight,));
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
                            padding: const EdgeInsets.fromLTRB(10, 6, 20, 10),
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
                                sectionDataList.length,
                                (position) {
                                  final videoData = sectionDataList[position];
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(4),
                                    onTap: () {
                                      debugPrint(
                                          "Clicked on position ==> $position");
                                      Utils.openDetails(
                                        context: context,
                                        videoId: videoData.id,
                                        upcomingType: 0,
                                        videoType: 2,
                                        typeId: 4,
                                      );
                                    },
                                    child: Container(
                                      width: Dimens.widthLand,
                                      height: Dimens.heightLand,
                                      alignment: Alignment.center,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        child: MyNetworkImage(
                                          imageUrl: videoData.landscape,
                                          fit: BoxFit.cover,
                                          imgHeight: MediaQuery.of(context)
                                              .size
                                              .height,
                                          imgWidth:
                                              MediaQuery.of(context).size.width,
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
            );
          },
        ),
      ),
    );
  }
}
