import 'package:dtlive/main.dart';
import 'package:flutter/material.dart';
import 'package:moengage_flutter/moengage_flutter.dart';
import 'package:provider/provider.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/widget/mynetworkimg.dart';
import 'package:dtlive/provider/sectiondataprovider.dart';
import 'package:singular_flutter_sdk/singular.dart';
import '../model/viewallmodel.dart';
import '../utils/constant.dart';
import '../utils/moenage_service.dart';

class MoreScreen extends StatefulWidget {
  final String appBarTitle;
  final String sectionId;

  const MoreScreen(this.appBarTitle, this.sectionId, {Key? key}) : super(key: key);

  @override
  State<MoreScreen> createState() => MoreScreenState();
}

class MoreScreenState extends State<MoreScreen> {
  late ScrollController _scrollController;
  bool _eventTracked = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    Provider.of<SectionDataProvider>(context, listen: false)
        .getViewallpagination(widget.sectionId);

    trackMoEngageEventOnce();
  }

  void _onScroll() {
    final provider = Provider.of<SectionDataProvider>(context, listen: false);
    if (!provider.isFetchingviewall &&
        provider.hasMoreDataviewall &&
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      provider.getViewallpagination(widget.sectionId, loadMore: true);
    }
  }

  void trackMoEngageEventOnce() {
    if (_eventTracked) return;
    _eventTracked = true;

       analytics.logEvent(
      name: "More_screen_view",
      parameters: {
        "screen_name": "More Section Screen",
        "user_id": Constant.userID,
      },
    );
    Singular.eventWithArgs('More_screen_view', {
      'screen_name': 'More Section Screen',
      'user_id': Constant.userID.toString(),
    });

    final properties = MoEProperties()
      ..addAttribute('screen_name', 'More Section Screen')
      ..addAttribute('timestamp', DateTime.now().toIso8601String());

    Future.delayed(const Duration(seconds: 2), () {
      MoEngageService.instance.trackEvent('More_screen_view', properties);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: Utils.myAppBarWithBack(context, widget.appBarTitle, false),
      body: SafeArea(
        child: Consumer<SectionDataProvider>(
          builder: (context, provider, child) {
            if (provider.loadingViewAll) {
              return const Center(
                child: CircularProgressIndicator(color: primaryLight),
              );
            }

            final List<VideoData> videoList = provider.sectionDataListviewall
                .expand<VideoData>((result) => result.data ?? [])
                .toList();

            return Stack(
              children: [
                GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: videoList.length,
                  itemBuilder: (context, index) {
                    final videoData = videoList[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        openDetailPage(
                          (videoData.videoType ?? 0) == 2 ? "showdetail" : "videodetail",
                          videoData.id ?? 0,
                          0,
                          videoData.videoType ?? 0,
                          videoData.typeId ?? 0,
                        );
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: MyNetworkImage(
                              imageUrl: videoData.thumbnail1.toString(),
                              fit: BoxFit.cover,
                              imgHeight: double.infinity,
                              imgWidth: double.infinity,
                            ),
                          ),
                          _buildGradientOverlay(),
                          if (videoData.isPremium == 1) _buildTag('assets/images/crown.png'),
                          // if (videoData.isLiveUrl == 1) _buildLiveIndicator(),
                        ],
                      ),
                    );
                  },
                ),

                /// Bottom loader as overlay
                if (provider.isFetchingviewall)
                  const Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircularProgressIndicator(color: primaryLight),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildTag(String assetPath) {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Image.asset(
          assetPath,
          height: 16,
          width: 16,
        ),
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Row(
          children: [
            Container(
              height: 6,
              width: 6,
              margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Text(
              "LIVE",
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void openDetailPage(String pageName, int videoId, int upcomingType, int videoType, int typeId) {
    Utils.openDetails(
      context: context,
      videoId: videoId,
      upcomingType: upcomingType,
      videoType: videoType,
      typeId: typeId,
    );
  }
}
