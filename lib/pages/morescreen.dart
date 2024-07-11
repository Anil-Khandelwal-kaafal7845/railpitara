import 'dart:convert';

import 'package:dtlive/utils/dimens.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/widget/mynetworkimg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:http/http.dart' as http;
import '../model/sectionlistmodel.dart';


class MoreScreen extends StatefulWidget {
  final String appBarTitle;
  final String sectionId;

  const MoreScreen(this.appBarTitle, this.sectionId, {Key? key}) : super(key: key);

  @override
  State<MoreScreen> createState() => MoreScreenState();
}

class MoreScreenState extends State<MoreScreen> {
  late Future<List<VideoData>> futureSectionData;

Future<List<VideoData>> fetchSectionData(String sectionId) async {
  final response = await http.post(
    Uri.parse('https://admin.aaryaadigital.com/api/view-all'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'section_id': sectionId,
    }),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body)['result'][0]['data'];
    return data.map((json) => VideoData.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

  @override
  void initState() {
    super.initState();
    futureSectionData = fetchSectionData(widget.sectionId);
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
        child: FutureBuilder<List<VideoData>>(
          future: futureSectionData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No data found'));
            }

            final sectionDataList = snapshot.data!;

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


class VideoData {
  final int id;
  final String name;
  final String thumbnail;
  final String landscape;
  final String description;

  VideoData({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.landscape,
    required this.description,
  });

  factory VideoData.fromJson(Map<String, dynamic> json) {
    return VideoData(
      id: json['id'],
      name: json['name'],
      thumbnail: json['thumbnail'],
      landscape: json['landscape'],
      description: json['description'],
    );
  }
}

// class MoreScreen extends StatefulWidget {
//   final String appBarTitle;
//   final List<Datum>? sectionDataList;
//   const MoreScreen(
//     this.appBarTitle,
//     this.sectionDataList, {
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<MoreScreen> createState() => MoreScreenState();
// }

// class MoreScreenState extends State<MoreScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: appBgColor,
//       appBar: AppBar(
//         shadowColor: appBgColor,
//         backgroundColor: appBgColor,
        
//   title: Center(child: Text("${widget.appBarTitle}")),
//   leading: IconButton(
//     icon: Icon(CupertinoIcons.back),
//     onPressed: () {
//       Navigator.pop(context);
//     },
//   ),
// ),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//           //  Utils.myAppBar(context, widget.appBarTitle, false),
//             Expanded(
//               child: Container(
//                 width: MediaQuery.of(context).size.width,
//                 constraints: const BoxConstraints.expand(),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.fromLTRB(10, 6, 20, 10),
//                         child: ResponsiveGridList(
//                           minItemWidth: Dimens.widthLand,
//                           verticalGridSpacing: 8,
//                           horizontalGridSpacing: 8,
//                           minItemsPerRow: 2,
//                           maxItemsPerRow: 8,
//                           listViewBuilderOptions: ListViewBuilderOptions(
//                             shrinkWrap: true,
//                             physics: const NeverScrollableScrollPhysics(),
//                           ),
//                           children: List.generate(
//                             (widget.sectionDataList?.length ?? 0),
//                             (position) {
//                               return InkWell(
//                                 borderRadius: BorderRadius.circular(4),
//                                 onTap: () {
//                                   debugPrint(
//                                       "Clicked on position ==> $position");
//                                   Utils.openDetails(
//                                     context: context,
//                                     videoId:
//                                         widget.sectionDataList![position].id!,
//                                     upcomingType: 0,
//                                     videoType: widget.sectionDataList![position]
//                                             .videoType ??
//                                         0,
//                                     typeId: widget.sectionDataList![position]
//                                             .typeId ??
//                                         0,
//                                   );
//                                 },
//                                 child: Container(
//                                   width: Dimens.widthLand,
//                                   height: Dimens.heightLand,
//                                   alignment: Alignment.center,
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(4),
//                                     clipBehavior: Clip.antiAliasWithSaveLayer,
//                                     child: MyNetworkImage(
//                                       imageUrl: widget
//                                               .sectionDataList![position]
//                                               .landscape ??
//                                           "",
//                                       fit: BoxFit.cover,
//                                       imgHeight:
//                                           MediaQuery.of(context).size.height,
//                                       imgWidth:
//                                           MediaQuery.of(context).size.width,
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             /* AdMob Banner */
//             Container(
//               child: Utils.showBannerAd(context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
