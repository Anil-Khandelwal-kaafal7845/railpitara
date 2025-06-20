import 'dart:async';
import 'dart:io';
import 'dart:math';
// import 'package:dtlive/web_js/js_helper.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dtlive/main.dart';
import 'package:dtlive/pages/coinstorescreen.dart';
import 'package:dtlive/pages/login_mobile.dart';
import 'package:dtlive/pages/more_screen.dart';

import 'package:dtlive/pages/videosbyartist.dart';
import 'package:dtlive/pages/videosbyid.dart';
import 'package:dtlive/provider/findprovider.dart';
import 'package:dtlive/reel%20feature/reel_screen.dart';
import 'package:dtlive/shimmer/shimmerutils.dart';
import 'package:dtlive/subscription/subscription.dart';
import 'package:dtlive/utils/sharedpre.dart';
import 'package:dtlive/webwidget/commonappbar.dart';
import 'package:dtlive/webwidget/footerweb.dart';
import 'package:dtlive/model/sectionlistmodel.dart';
import 'package:dtlive/model/sectiontypemodel.dart' as type;
import 'package:dtlive/model/sectionlistmodel.dart' as list;
import 'package:dtlive/model/sectionbannermodel.dart' as banner;
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/dimens.dart';
import 'package:dtlive/widget/animatedgif.dart';
import 'package:dtlive/widget/nodata.dart';
import 'package:dtlive/provider/homeprovider.dart';
import 'package:dtlive/provider/sectiondataprovider.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/widget/myimage.dart';
import 'package:dtlive/widget/mytext.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/widget/mynetworkimg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moengage_flutter/moengage_flutter.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:singular_flutter_sdk/singular.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:url_launcher/url_launcher.dart';
import '../model/force_update_model.dart';
import '../utils/moenage_service.dart';
import '../webservice/apiservices.dart';
import '../provider/generalprovider.dart';
import '../provider/profileprovider.dart';
import 'aboutprivacyterms.dart';
import 'pip_web_player.dart';

class Home extends StatefulWidget {
  final String? pageName;
  const Home({Key? key, required this.pageName}) : super(key: key);

  @override
  State<Home> createState() => HomeState();
}

ForceUpdatemodel? forceUpdateData;

class HomeState extends State<Home> with RouteAware {
  // final JSHelper _jsHelper = JSHelper();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late SectionDataProvider sectionDataProvider;
  final FirebaseAuth auth = FirebaseAuth.instance;
  SharedPre sharedPref = SharedPre();
  CarouselController carouselController = CarouselController();
  final tabScrollController = ScrollController();
  late ListObserverController observerController;
  late HomeProvider homeProvider;
  int? videoId, videoType, typeId;
  late FindProvider findProvider = FindProvider();
  List<String> selectedLanguageIds = ["0"];

//drawer
  bool? isSwitched;
  String? userName, userType, userMobileNo;
  late GeneralProvider generalProvider;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool updateLoading = true;
  List<String> languages = []; // Example list of languages
  List<bool> selectedLanguages = [];

  String? currentPage,
      langCatName,
      aboutUsUrl,
      privacyUrl,
      termsConditionUrl,
      refundPolicyUrl,
      mSearchText;

  _onItemTapped(String page) async {
    debugPrint("_onItemTapped -----------------> $page");
    if (page != "") {
      await setSelectedTab(-1);
    }
    setState(() {
      currentPage = page;
    });
  }

  toggleSwitch(bool value) async {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
      });
    } else {
      setState(() {
        isSwitched = false;
      });
    }
    debugPrint('toggleSwitch isSwitched ==> $isSwitched');
    if (!kIsWeb) {
      if ((isSwitched ?? false)) {
        OneSignal.User.pushSubscription.optIn();
      } else {
        OneSignal.User.pushSubscription.optOut();
      }
      await sharedPref.saveBool("PUSH", isSwitched);
    }
  }

  getUserData() async {
    userName = await sharedPref.read("username");
    userType = await sharedPref.read("usertype");
    userMobileNo = await sharedPref.read("usermobile");
    debugPrint('getUserData userName ==> $userName');
    debugPrint('getUserData userType ==> $userType');
    debugPrint('getUserData userMobileNo ==> $userMobileNo');

    await generalProvider.getPages();
    await generalProvider.getGeneralsetting(context);
    await homeProvider.fetchUserWalletBalance(Constant.userID ?? "");

    debugPrint("isCoinShow ===========> ${generalProvider.isCoinShow}");

    isSwitched = await sharedPref.readBool("PUSH");
    debugPrint('getUserData isSwitched ==> $isSwitched');
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }
  bool hasFetchedData = false;
  @override
  void initState() {
    print("-----${Constant.userID}");
    
    Provider.of<GeneralProvider>(context, listen: false);
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);

    getUserData();

    fetchForceUpdateData();

    sectionDataProvider = Provider.of<SectionDataProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    findProvider = Provider.of<FindProvider>(context, listen: false);
    observerController =
        ListObserverController(controller: tabScrollController);
    currentPage = widget.pageName ?? "";
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasFetchedData) {
        _getData();
        hasFetchedData = true;
      }
    });
    if (!kIsWeb) {

      OneSignal.Notifications.addClickListener(_handleNotificationOpened);
    }
    trackMoEngageEventOnce();
  }
  bool _eventTracked = false;

  void trackMoEngageEventOnce() {
    if (_eventTracked) return;
    _eventTracked = true;

    final properties = MoEProperties()
      ..addAttribute('screen_name', 'HomePage')
      ..addAttribute('user_id', Constant.userID.toString())
      ..addAttribute('timestamp', DateTime.now().toIso8601String());

    print("MoEngage event tracked with Constant userID: ${userMobileNo}");

    // Optional delay
    Future.delayed(Duration(seconds: 2), () {
      MoEngageService.instance.trackEvent('screen_view', properties);
    });
  }

  fetchForceUpdateData() async {
    await HomeScreenRepo().forceUpdateApi(context).then((value) {
      setState(() {
        forceUpdateData = value;
        updateLoading = false;
      });
      checkForUpdate(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Register this route with the RouteObserver
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  Future<void> checkForUpdate(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    // Get current app version from API response
    final int apiAppVersion = forceUpdateData!.result!.appVersion!; // Android
    final int iosAppVersion = forceUpdateData!.result!.iosappVersion!; // iOS
    final bool isForceUpdate = forceUpdateData!.result!.forceUpdate == 1;

    // Get the current build number based on platform
    num currentVersion = Platform.isAndroid
        ? int.parse(packageInfo.buildNumber) // Android
        : Constant.curentiosAppVersion; // iOS

    // Determine if an update is needed based on platform
    bool needsUpdate = Platform.isAndroid
        ? apiAppVersion > currentVersion // Android
        : iosAppVersion > currentVersion; // iOS

    if (needsUpdate) {
      showDialog(
        barrierDismissible: !isForceUpdate, // Disable dismiss if force update
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false, // Prevent dialog dismissal on back
            child: AlertDialog(
              contentPadding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              surfaceTintColor: Theme.of(context).colorScheme.background,
              title: const Text("New Update Available!!"),
              content: const Text("A new app update is available"),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Visibility(
                      visible:
                          !isForceUpdate, // Show Cancel button if not forced
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (Platform.isAndroid || Platform.isIOS) {
                          final url = Uri.parse(
                            Platform.isAndroid
                            ?"${Constant.androidAppUrl}"
                                : "https://apps.apple.com/in/app/om-tv/id${Constant.appleAppId}",
                          );
                          launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: const Text("UPDATE"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
  }

  // checkForUpdate() async {
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();

  //   // Get current app version from API response
  //   final int apiAppVersion = forceUpdateData!.result!.appVersion!;
  //   final int iosAppVersion = forceUpdateData!.result!.iosappVersion!;
  //   final bool isForceUpdate = forceUpdateData!.result!.forceUpdate == 1;

  //   // Compare app versions
  //   if (apiAppVersion > num.parse(packageInfo.buildNumber)) {
  //     showDialog(
  //       barrierDismissible: !isForceUpdate, // Disable dismiss if force update
  //       context: context,
  //       builder: (context) {
  //         return WillPopScope(
  //           onWillPop: () async => false, // Prevent dialog dismissal on back
  //           child: AlertDialog(
  //             contentPadding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
  //             surfaceTintColor: Theme.of(context).colorScheme.background,
  //             title: const Text("New Update Available!!"),
  //             content: const Text("A new app update is available"),
  //             actions: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                 children: [
  //                   Visibility(
  //                     visible:
  //                         !isForceUpdate, // Show Cancel button if not forced
  //                     child: TextButton(
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                       },
  //                       child: const Text("Cancel"),
  //                     ),
  //                   ),
  //                   TextButton(
  //                     onPressed: () {
  //                       if (Platform.isAndroid || Platform.isIOS) {
  //                         final url = Uri.parse(
  //                           Platform.isAndroid
  //                               ? "https://play.google.com/store/apps/details?id=com.ott.Chull tvott&hl=en_IN"
  //                               : "https://apps.apple.com/in/app/om-tv/id1584477559",
  //                         );
  //                         launchUrl(
  //                           url,
  //                           mode: LaunchMode.externalApplication,
  //                         );
  //                       }
  //                     },
  //                     child: const Text("UPDATE"),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     );
  //   }
  // }

  // checkForUpdate() async {
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();

  //   if ((Platform.isAndroid
  //           ? forceUpdateData!.result!.appVersion!
  //           : forceUpdateData!.result!.appVersion!) >
  //       num.parse(packageInfo.buildNumber)) {
  //     showDialog(
  //       barrierDismissible:
  //           forceUpdateData!.result!.forceUpdateAndroid == 1 ? false : true,
  //       context: context,
  //       builder: (context) {
  //         return WillPopScope(
  //           onWillPop: () async =>
  //               false, // prevent dialog from dismissing on back button press
  //           child: AlertDialog(
  //             contentPadding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
  //             surfaceTintColor: Theme.of(context).colorScheme.background,
  //             title: const Text("New Update Available!!"),
  //             content: const Text("A new app update is available"),
  //             actions: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                 children: [
  //                   Visibility(
  //                     visible: forceUpdateData!.result!.forceUpdateAndroid == 0
  //                         ? true
  //                         : false,
  //                     child: TextButton(
  //                         onPressed: () {
  //                           Navigator.pop(context);
  //                         },
  //                         child: const Text("Cancel")),
  //                   ),
  //                   TextButton(
  //                       onPressed: () {
  //                         if (Platform.isAndroid || Platform.isIOS) {
  //                           final appId = Platform.isAndroid
  //                               ? Constant.appPackageName
  //                               : Constant.appleAppId;
  //                           final url = Uri.parse(
  //                             Platform.isAndroid
  //                                 ? "market://details?id=$appId"
  //                                 : "https://apps.apple.com/app/id$appId",
  //                           );
  //                           launchUrl(
  //                             url,
  //                             mode: LaunchMode.externalApplication,
  //                           );
  //                         }
  //                       },
  //                       child: const Text("UPDATE")),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     );
  //   }
  // }

  // What to do when the user opens/taps on a notification
  _handleNotificationOpened(OSNotificationClickEvent result) {
    /* id, video_type, type_id */

    debugPrint(
        "setNotificationOpenedHandler additionalData ===> ${result.notification.additionalData.toString()}");
    debugPrint(
        "setNotificationOpenedHandler video_id ===> ${result.notification.additionalData?['id']}");
    debugPrint(
        "setNotificationOpenedHandler upcoming_type ===> ${result.notification.additionalData?['upcoming_type']}");
    debugPrint(
        "setNotificationOpenedHandler video_type ===> ${result.notification.additionalData?['video_type']}");
    debugPrint(
        "setNotificationOpenedHandler type_id ===> ${result.notification.additionalData?['type_id']}");

    if (result.notification.additionalData?['id'] != null &&
        result.notification.additionalData?['upcoming_type'] != null &&
        result.notification.additionalData?['video_type'] != null &&
        result.notification.additionalData?['type_id'] != null) {
      String? videoID =
          result.notification.additionalData?['id'].toString() ?? "";
      String? upcomingType =
          result.notification.additionalData?['upcoming_type'].toString() ?? "";
      String? videoType =
          result.notification.additionalData?['video_type'].toString() ?? "";
      String? typeID =
          result.notification.additionalData?['type_id'].toString() ?? "";
      debugPrint("videoID =======> $videoID");
      debugPrint("upcomingType ==> $upcomingType");
      debugPrint("videoType =====> $videoType");
      debugPrint("typeID ========> $typeID");

      Utils.openDetails(
        context: context,
        videoId: int.parse(videoID),
        upcomingType: int.parse(upcomingType),
        videoType: int.parse(videoType),
        typeId: int.parse(typeID),
      );
    }
  }

  _getData() async {
    await generalProvider.getGeneralsetting(context);
    await homeProvider.setLoading(true);
    await homeProvider.getSectionType();
    await homeProvider.fetchUserWalletBalance(Constant.userID ?? "");
    if (!mounted) return;
    findProvider = Provider.of<FindProvider>(context, listen: false);
    if (!homeProvider.loading) {
      if (homeProvider.sectionTypeModel.status == 200 &&
          homeProvider.sectionTypeModel.result != null) {
        if ((homeProvider.sectionTypeModel.result?.length ?? 0) > 0) {
          if ((sectionDataProvider.sectionBannerModel.result?.length ?? 0) ==
                  0 ||
              (sectionDataProvider.sectionListModel.result?.length ?? 0) == 0) {
            getTabData(0, homeProvider.sectionTypeModel.result);
          }
        }
      }
    }
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
    Utils.getCurrencySymbol();
    if (!mounted) return;
    findProvider.getLanguage().then((_) {
      // Populate languages list
      languages = findProvider.langaugeModel.result!
          .map((language) => language.name!)
          .toList();

      // Initialize selectedIndex list with false values
      selectedLanguages = List.filled(languages.length, false);

      // Print data for verification
      debugPrint("Number of languages: ${languages.length}");
      debugPrint("Language name at index 1: ${languages[1]}");
      debugPrint(
          "Language id at index 1: ${findProvider.langaugeModel.result![1].id}");
    });
  }

  Future<void> setSelectedTab(int tabPos) async {
    debugPrint("setSelectedTab tabPos ====> $tabPos");
    if (!mounted) return;
    await homeProvider.setSelectedTab(tabPos);
    debugPrint(
        "setSelectedTab selectedIndex ====> ${homeProvider.selectedIndex}");
    debugPrint(
        "setSelectedTab lastTabPosition ====> ${sectionDataProvider.lastTabPosition}");
    if (sectionDataProvider.lastTabPosition == tabPos) {
      return;
    } else {
      sectionDataProvider.setTabPosition(tabPos);
    }
  }

  Future<void> getTabData(
      int position, List<type.Result>? sectionTypeList) async {
    debugPrint("getTabData position ====> $position");
    await setSelectedTab(position);
    await sectionDataProvider.setLoading(true);
    await sectionDataProvider.getSectionBanner(
        position == 0 ? "0" : (sectionTypeList?[position - 1].typeId),
        position == 0 ? "1" : "2");
    await sectionDataProvider.getSectionList(
        position == 0 ? "0" : (sectionTypeList?[position - 1].typeId),
        position == 0 ? "1" : "2",
        selectedLanguageIds.join(','));
  }

  // reel feature ---

  openDetailPage(String pageName, dynamic videoId, dynamic upcomingType,
      dynamic videoType, int typeId, dynamic reelName) async {
    debugPrint("reelName =======> $reelName");
    debugPrint("videoId ========> $videoId");
    debugPrint("upcomingType ===> $upcomingType");
    debugPrint("videoType ======> $videoType");
    debugPrint("typeId =========> $typeId");

    // Check if the videoType is 7
    if (videoType == 7) {
      if (Constant.userID == null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LoginViaSocial(),
          ),
        );
        return;
      }
      // Navigate to PreloadPage if videoType is 7
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReelScreen(
            videoId: videoId,
            videoType: videoType,
            typeId: typeId,
            nameReelVideo: reelName,
            // initialIndex: 0,
          ),
        ),
      );
      return; // Early return to prevent further code execution
    }
    // if (videoType == 7) {
    //   // Navigate to PreloadPage if videoType is 7
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => ReelScreen(),
    //     ),
    //   );
    //   return; // Early return to prevent further code execution
    // }

    // If videoType is not 7, proceed with the original behavior

    if (pageName != "" && (kIsWeb || Constant.isTV)) {
      await setSelectedTab(-1);
    }
    if (!mounted) return;
    Utils.openDetails(
      context: context,
      videoId: videoId,
      upcomingType: upcomingType,
      videoType: videoType,
      typeId: typeId,
    );
  }

  // openDetailPage(String pageName, int videoId, int upcomingType, int videoType,
  //     int typeId) async {
  //   debugPrint("pageName =======> $pageName");
  //   debugPrint("videoId ========> $videoId");
  //   debugPrint("upcomingType ===> $upcomingType");
  //   debugPrint("videoType ======> $videoType");
  //   debugPrint("typeId =========> $typeId");
  //   if (pageName != "" && (kIsWeb || Constant.isTV)) {
  //     await setSelectedTab(-1);
  //   }
  //   if (!mounted) return;
  //   Utils.openDetails(
  //     context: context,
  //     videoId: videoId,
  //     upcomingType: upcomingType,
  //     videoType: videoType,
  //     typeId: typeId,
  //   );
  // }

  Future<void> _redirectToUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);

    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when returning to this screen
    _fetchWalletBalance();
  }

  void _fetchWalletBalance() async {
    await homeProvider.fetchUserWalletBalance(Constant.userID ?? "");
    setState(() {});
  }

  _scrollToCurrent() {
    debugPrint(
        "selectedIndex ======> ${homeProvider.selectedIndex.toDouble()}");
    observerController.animateTo(
      index: homeProvider.selectedIndex,
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    analytics.logEvent(
      name: "screen_view",
      parameters: {
        "screen_name": "HomePage",
        "user_id": Constant.userID,
      },
    );
    Map<String, Object> screenViewEvent = {
      'screen_name': 'Home Screen',
      'user_id': Constant.userID.toString(),
    };
    Singular.eventWithArgs('screen_view', screenViewEvent);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: appBgColor,
      appBar: AppBar(
        surfaceTintColor: appBgColor,
        centerTitle: false,
        actions: [
          generalProvider.isCoinShow == "1"
              ? GestureDetector(
                  onTap: () {
                    if (Constant.userID != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CoinStoreScreen()),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginViaSocial(),
                        ),
                      );
                    }
                  },
                  child: Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Row(
                        children: [
                          AnimatedGifWidget(
                            height: 65,
                            width: 60,
                          ),
                          Constant.userID != null
                              ? Text(
                                  "${homeProvider.userWalletBalanceModel?.balance ?? ''}",
                                  style: TextStyle(
                                    fontSize: 23,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : SizedBox.shrink()
                        ],
                      )),
                )
              : SizedBox.shrink(),
        ],
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyImage(width: 110, height: 110, imagePath: "appicon.png"),
          ],
        ),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: (kIsWeb || Constant.isTV)
            ? _webAppBarWithDetails()
            : _mobileAppBarWithDetails(),
      ),
    );
  }

  Widget socialMediaIcon({required String imageUrl, required Function onTap}) {
    return InkWell(
      onTap: () async {
        await onTap();
      },
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 25,
        width: 25,
        child: Image.asset(imageUrl),
      ),
    );
  }

  Widget _buildLine() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 0.5,
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      color: otherColor,
    );
  }

  Widget _buildPages() {
    if (generalProvider.loading) {
      return const SizedBox.shrink();
    } else {
      if (generalProvider.pagesModel.status == 200 &&
          generalProvider.pagesModel.result != null) {
        return AlignedGridView.count(
          shrinkWrap: true,
          crossAxisCount: 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          itemCount: (generalProvider.pagesModel.result?.length ?? 0),
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int position) {
            return Column(
              children: [
                _buildSettingButton(
                  title:
                      generalProvider.pagesModel.result?[position].pageName ??
                          '',
                  //  subTitle: generalProvider
                  //         .pagesModel.result?[position].pageSubtitle ??
                  //      '',
                  titleMultilang: false,
                  subTitleMultilang: false,
                  onClick: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AboutPrivacyTerms(
                          appBarTitle: generalProvider
                                  .pagesModel.result?[position].pageName ??
                              '',
                          loadURL: generalProvider
                                  .pagesModel.result?[position].url ??
                              '',
                        ),
                      ),
                    );
                  },
                ),
                // _buildLine(),
              ],
            );
          },
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget _buildSettingButton({
    required String title,
    // required String subTitle,
    required bool titleMultilang,
    required bool subTitleMultilang,
    required Function() onClick,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(2),
      onTap: onClick,
      child: Container(
        width: MediaQuery.of(context).size.width,
        constraints: BoxConstraints(
          minHeight: Dimens.minHeightSettings,
        ),
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
              color: Colors.white,
              text: title,
              fontsizeNormal: 14,
              fontsizeWeb: 15,
              maxline: 1,
              multilanguage: titleMultilang,
              overflow: TextOverflow.ellipsis,
              fontweight: FontWeight.w500,
              textalign: TextAlign.start,
              fontstyle: FontStyle.normal,
            ),
            // SizedBox(height: subTitle.isEmpty ? 0 : 5),
            // subTitle.isEmpty
            //     ? const SizedBox.shrink()
            //     : MyText(
            //         color: otherColor,
            //         text: subTitle,
            //         fontsizeNormal: 12,
            //         fontsizeWeb: 14,
            //         multilanguage: subTitleMultilang,
            //         maxline: 2,
            //         overflow: TextOverflow.ellipsis,
            //         fontweight: FontWeight.w500,
            //         textalign: TextAlign.start,
            //         fontstyle: FontStyle.normal,
            //       ),
          ],
        ),
      ),
    );
  }

  _languageChangeDialog() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: transparentColor,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, state) {
            return DraggableScrollableSheet(
              initialChildSize: 0.35,
              minChildSize: 0.20,
              maxChildSize: 0.70,
              builder: (context, scrollController) {
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: lightBlack,
                    padding: const EdgeInsets.all(23),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                color: white,
                                text: "changelanguage",
                                multilanguage: true,
                                textalign: TextAlign.start,
                                fontsizeNormal: 16,
                                fontweight: FontWeight.bold,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(height: 3),
                              MyText(
                                color: white,
                                text: "selectyourlanguage",
                                multilanguage: true,
                                textalign: TextAlign.start,
                                fontsizeNormal: 12,
                                fontweight: FontWeight.w500,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              )
                            ],
                          ),
                        ),

                        /* English */
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "English",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('en');
                                    Navigator.pop(context);
                                  },
                                ),

                                // /* Afrikaans */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "Afrikaans",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('af');
                                //     Navigator.pop(context);
                                //   },
                                // ),

                                /* Arabic */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "Arabic",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('ar');
                                //     Navigator.pop(context);
                                //   },
                                // ),

                                /* German */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "German",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('de');
                                //     Navigator.pop(context);
                                //   },
                                // ),

                                /* Spanish */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "Spanish",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('es');
                                //     Navigator.pop(context);
                                //   },
                                // ),

                                /* French */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "French",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('fr');
                                //     Navigator.pop(context);
                                //   },
                                // ),

                                // /* Gujarati */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "Gujarati",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('gu');
                                //     Navigator.pop(context);
                                //   },
                                // ),

                                /* Hindi */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Hindi",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('hi');
                                    Navigator.pop(context);
                                  },
                                ),

                                // /* Indonesian */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "Indonesian",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('id');
                                //     Navigator.pop(context);
                                //   },
                                // ),

                                // /* Dutch */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "Dutch",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('nl');
                                //     Navigator.pop(context);
                                //   },
                                // ),

                                // /* Portuguese (Brazil) */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "Portuguese (Brazil)",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('pt');
                                //     Navigator.pop(context);
                                //   },
                                // ),

                                /* Albanian */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "Albanian",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('sq');
                                //     Navigator.pop(context);
                                //   },
                                // ),

                                // /* Turkish */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "Turkish",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('tr');
                                //     Navigator.pop(context);
                                //   },
                                // ),

                                // /* Vietnamese */
                                // const SizedBox(height: 20),
                                // _buildLanguage(
                                //   langName: "Vietnamese",
                                //   onClick: () {
                                //     state(() {});
                                //     LocaleNotifier.of(context)?.change('vi');
                                //     Navigator.pop(context);
                                //   },
                                // ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLanguage({
    required String langName,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        height: 48,
        padding: const EdgeInsets.only(left: 10, right: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: primaryLight,
            width: .5,
          ),
          color: colorPrimaryDark,
          borderRadius: BorderRadius.circular(5),
        ),
        child: MyText(
          color: white,
          text: langName,
          textalign: TextAlign.center,
          fontsizeNormal: 16,
          multilanguage: false,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          fontweight: FontWeight.w500,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }

  logoutConfirmDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: lightBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(23),
              color: lightBlack,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: white,
                          text: "confirmsognout",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: 16,
                          fontweight: FontWeight.bold,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 3),
                        MyText(
                          color: white,
                          text: "areyousurewanrtosignout",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsizeNormal: 12,
                          fontweight: FontWeight.w500,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildDialogBtn(
                          title: 'cancel',
                          isPositive: false,
                          isMultilang: true,
                          onClick: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildDialogBtn(
                          title: 'sign_out',
                          isPositive: true,
                          isMultilang: true,
                          onClick: () async {
                            final profileProvider =
                                Provider.of<ProfileProvider>(context,
                                    listen: false);
                            final homeProvider = Provider.of<HomeProvider>(
                                context,
                                listen: false);
                            final sectionDataProvider =
                                Provider.of<SectionDataProvider>(context,
                                    listen: false);
                            await homeProvider.setSelectedTab(0);
                            await sectionDataProvider.clearProvider();
                            await profileProvider.clearProvider();
                            // Firebase Signout
                            await _auth.signOut();
                            Map<String, Object> screenViewEvent = {
                              'screen_name': 'LogOut',
                              'user_id': Constant.userID.toString(),
                            };

                            Singular.eventWithArgs('LogOut', screenViewEvent);
                            await GoogleSignIn().signOut();
                            await Utils.setUserId(null);
                            sectionDataProvider.getSectionBanner("0", "1");
                            sectionDataProvider.getSectionList("0", "1", "0");
                            if (!mounted) return;
                            Utils.loadAds(context);
                            getUserData();
                            Navigator.pop(context);
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginViaSocial(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ).then((value) {
      if (!mounted) return;
      Utils.loadAds(context);
      setState(() {});
    });
  }

  deleteConfirmDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: lightBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(23),
              color: lightBlack,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: white,
                          text: "confirm_delete_account",
                          multilanguage: true,
                          textalign: TextAlign.center,
                          fontsizeNormal: 16,
                          fontweight: FontWeight.bold,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 3),
                        MyText(
                          color: white,
                          text: "delete_account_msg",
                          multilanguage: true,
                          textalign: TextAlign.center,
                          fontsizeNormal: 12,
                          fontweight: FontWeight.w500,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildDialogBtn(
                          title: 'cancel',
                          isPositive: false,
                          isMultilang: true,
                          onClick: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildDialogBtn(
                          title: 'delete',
                          isPositive: true,
                          isMultilang: true,
                          onClick: () async {
                            final homeProvider = Provider.of<HomeProvider>(
                                context,
                                listen: false);
                            final profileProvider =
                                Provider.of<ProfileProvider>(context,
                                    listen: false);
                            final sectionDataProvider =
                                Provider.of<SectionDataProvider>(context,
                                    listen: false);
                            await homeProvider.setSelectedTab(0);
                            await sectionDataProvider.clearProvider();
                            await profileProvider.clearProvider();
                            // Firebase Signout
                            await _auth.signOut();
                            Map<String, Object> screenViewEvent = {
                              'screen_name': 'LogOut',
                              'user_id': Constant.userID.toString(),
                            };
                            Singular.eventWithArgs('LogOut', screenViewEvent);
                            await GoogleSignIn().signOut();
                            await Utils.setUserId(null);
                            sectionDataProvider.getSectionBanner("0", "1");
                            sectionDataProvider.getSectionList("0", "1", "0");
                            if (!mounted) return;
                            Utils.loadAds(context);
                            getUserData();
                            Navigator.pop(context);
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginViaSocial(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ).then((value) {
      if (!mounted) return;
      Utils.loadAds(context);
      setState(() {});
    });
  }

  Widget _buildDialogBtn({
    required String title,
    required bool isPositive,
    required bool isMultilang,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      child: Container(
        constraints: const BoxConstraints(minWidth: 75),
        height: 50,
        padding: const EdgeInsets.only(left: 10, right: 10),
        alignment: Alignment.center,
        decoration: Utils.setBGWithBorder(
            isPositive ? primaryLight : transparentColor,
            isPositive ? transparentColor : otherColor,
            5,
            0.5),
        child: MyText(
          color: isPositive ? black : white,
          text: title,
          multilanguage: isMultilang,
          textalign: TextAlign.center,
          fontsizeNormal: 16,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          fontweight: FontWeight.w500,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }

  Widget _mobileAppBarWithDetails() {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: appBgColor,
              toolbarHeight: 0,
              title: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  splashColor: transparentColor,
                  highlightColor: transparentColor,
                  onTap: () async {
                    await getTabData(0, homeProvider.sectionTypeModel.result);
                  },
                  child: const Stack(
                    children: [],
                  ),
                ),
              ),
              pinned: false,
              expandedHeight: 0,
              forceElevated: innerBoxIsScrolled,
            ),
          ),
        ];
      },
      body: homeProvider.loading
          ? ShimmerUtils.buildHomeMobileShimmer(context)

          : (homeProvider.sectionTypeModel.status == 200)

              ? (homeProvider.sectionTypeModel.result != null ||
                      (homeProvider.sectionTypeModel.result?.length ?? 0) > 0)
                  ? Stack(
                      children: [
                        tabItem(homeProvider.sectionTypeModel.result),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.homeTabHeight,
                          padding: const EdgeInsets.only(top: 6, bottom: 6),
                          color: black.withOpacity(0.8),
                          child: tabTitle(homeProvider.sectionTypeModel.result),
                        ),
                      ],
                    )
                  : ShimmerUtils.buildHomeMobileShimmer(context)
              
              : ShimmerUtils.buildHomeMobileShimmer(context),
    );
  }

  Widget _webAppBarWithDetails() {
    if (homeProvider.loading) {
      return ShimmerUtils.buildHomeMobileShimmer(context);
    } else {
      if (homeProvider.sectionTypeModel.status == 200) {
        if (homeProvider.sectionTypeModel.result != null ||
            (homeProvider.sectionTypeModel.result?.length ?? 0) > 0) {
          return Stack(
            children: [
              // _clickToRedirect(pageName: currentPage ?? ""),
              tabItem(homeProvider.sectionTypeModel.result),
              const CommonAppBar(),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget tabTitle(List<type.Result>? sectionTypeList) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (tabScrollController.hasClients) {
        _scrollToCurrent();
      }
    });

    return ListViewObserver(
      controller: observerController,
      child: ListView.separated(
        itemCount: (sectionTypeList?.length ?? 0) + 1,
        shrinkWrap: true,
        controller: tabScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (BuildContext context, int index) {
          return Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              bool isSelected = homeProvider.selectedIndex == index;
              String title = index == 0
                  ? "HOME"
                  : (sectionTypeList?[index - 1].name.toString() ?? "");

              return InkWell(
                onTap: () async {
                  debugPrint("index ===========> $index");
                  await getTabData(index, homeProvider.sectionTypeModel.result);
                },
                child: Container(
                  height: 38, // Set exact height
                  width: 95, // Set exact width
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(12), // Reduced border radius
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 169, 11, 6), // Dark Red
                              Color.fromARGB(
                                  255, 237, 48, 41), // Light Red/Orange Mix
                              Color.fromARGB(
                                  226, 230, 62, 56), // White for smooth blend
                            ], // Dark Red → Light Red/Orange
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : const LinearGradient(
                            colors: [
                              Color(0xFF232526),
                              Color(0xFF414345)
                            ], // Dark Black → Light Gray
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Color(
                              0xFFB0B0B0), // White for selected, Gray for non-selected
                      fontSize: 14, // Adjusted font size
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal, // Bold for selected
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget tabItem(List<type.Result>? sectionTypeList) {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints.expand(),
      child: RefreshIndicator(
        backgroundColor: white,
        color: complimentryColor,
        displacement: 80,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 1500))
              .then((value) {
            debugPrint(
                "selectedIndex ===========> ${homeProvider.selectedIndex}");
            getTabData(
                homeProvider.selectedIndex > 0
                    ? (homeProvider.selectedIndex)
                    : 0,
                homeProvider.sectionTypeModel.result);
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: Dimens.homeTabHeight),

              /* Banner */
              Consumer<SectionDataProvider>(
                builder: (context, sectionDataProvider, child) {
                  if (sectionDataProvider.loadingBanner) {
                    return (kIsWeb || Constant.isTV) &&
                            MediaQuery.of(context).size.width > 720
                        ? ShimmerUtils.bannerWeb(context)
                        : ShimmerUtils.bannerMobile(context);
                  } else {
                    if (sectionDataProvider.sectionBannerModel.status == 200 &&
                        sectionDataProvider.sectionBannerModel.result != null) {
                      return (kIsWeb || Constant.isTV) &&
                              MediaQuery.of(context).size.width > 720
                          ? _webHomeBanner(
                              sectionDataProvider.sectionBannerModel.result)
                          : _mobileHomeBanner(
                              sectionDataProvider.sectionBannerModel.result);
                    } else {
                      return const SizedBox.shrink();
                    }
                  }
                },
              ),

              const SizedBox(height: 5.5),
              // /* AdMob Banner */
              Utils.showBannerAd(context),

              const SizedBox(height: 5.5),

              /* Continue Watching & Remaining Sections */
              Consumer<SectionDataProvider>(
                builder: (context, sectionDataProvider, child) {
                  if (sectionDataProvider.loadingSection) {
                    return sectionShimmer();
                  } else {
                    if (sectionDataProvider.sectionListModel.status == 200) {
                      bool allSectionsEmpty = sectionDataProvider
                          .sectionListModel.result!
                          .every((section) => section.data!.isEmpty);

                      if (allSectionsEmpty) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 100,
                            ),
                            MyImage(
                              height: 100,
                              fit: BoxFit.contain,
                              imagePath: "nodata.png",
                            ),
                            SizedBox(
                              height: 100,
                            )
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            /* Continue Watching */
                            // sectionDataProvider
                            //             .sectionListModel.continueWatching !=
                            //         null
                            //     ? continueWatchingLayout(sectionDataProvider
                            //         .sectionListModel.continueWatching)
                            //     : const SizedBox.shrink(),

                            /* Remaining Sections */
                            setSectionByType(
                                sectionDataProvider.sectionListModel.result),
                          ],
                        );
                      }
                    } else {
                      return const SizedBox.shrink();
                    }
                  }
                },
              ),

              const SizedBox(height: 20),

              /* Web Footer */
              kIsWeb ? const FooterWeb() : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget tabItem(List<type.Result>? sectionTypeList) {
  //   return Container(
  //     width: MediaQuery.of(context).size.width,
  //     constraints: const BoxConstraints.expand(),
  //     child: RefreshIndicator(
  //       backgroundColor: white,
  //       color.xml: complimentryColor,
  //       displacement: 80,
  //       onRefresh: () async {
  //         await Future.delayed(const Duration(milliseconds: 1500))
  //             .then((value) {
  //           debugPrint(
  //               "selectedIndex ===========> ${homeProvider.selectedIndex}");
  //           getTabData(
  //               homeProvider.selectedIndex > 0
  //                   ? (homeProvider.selectedIndex)
  //                   : 0,
  //               homeProvider.sectionTypeModel.result);
  //         });
  //       },
  //       child: SingleChildScrollView(
  //         physics: const AlwaysScrollableScrollPhysics(),
  //         child: Column(
  //           children: [
  //             SizedBox(height: Dimens.homeTabHeight),

  //             /* Banner */
  //             Consumer<SectionDataProvider>(
  //               builder: (context, sectionDataProvider, child) {
  //                 if (sectionDataProvider.loadingBanner) {
  //                   if ((kIsWeb || Constant.isTV) &&
  //                       MediaQuery.of(context).size.width > 720) {
  //                     return ShimmerUtils.bannerWeb(context);
  //                   } else {
  //                     return ShimmerUtils.bannerMobile(context);
  //                   }
  //                 } else {
  //                   if (sectionDataProvider.sectionBannerModel.status == 200 &&
  //                       sectionDataProvider.sectionBannerModel.result != null) {
  //                     if ((kIsWeb || Constant.isTV) &&
  //                         MediaQuery.of(context).size.width > 720) {
  //                       return _webHomeBanner(
  //                           sectionDataProvider.sectionBannerModel.result);
  //                     } else {
  //                       return _mobileHomeBanner(
  //                           sectionDataProvider.sectionBannerModel.result);
  //                     }
  //                   } else {
  //                     return const SizedBox.shrink();
  //                   }
  //                 }
  //               },
  //             ),

  //             /* AdMob Banner */

  //
  //             const SizedBox(height: 5.5),

  //             /* Continue Watching & Remaining Sections */
  //             Consumer<SectionDataProvider>(
  //               builder: (context, sectionDataProvider, child) {
  //                 if (sectionDataProvider.loadingSection) {

  //                   return sectionShimmer();
  //                 } else {

  //                   if (sectionDataProvider.sectionListModel.status == 200) {
  //                     return Column(
  //                       children: [
  //                         // // SizedBox(
  //                         // //   height: 5,
  //                         // // ),
  //                         // /* Continue Watching */
  //                         (sectionDataProvider
  //                                     .sectionListModel.continueWatching !=
  //                                 null)
  //                             ? continueWatchingLayout(sectionDataProvider
  //                                 .sectionListModel.continueWatching)

  //                             :const Text("ANIL" ,style: TextStyle(color.xml: white ,fontSize: 70),),

  //                         /* Remaining Sections */
  //                         (sectionDataProvider.sectionListModel.result != null)
  //                             ? setSectionByType(
  //                                 sectionDataProvider.sectionListModel.result)
  //                             : const Text("ANIL" ,style: TextStyle(color.xml: white),),
  //                       ],
  //                     );
  //                   } else {
  //                     return const SizedBox.shrink();
  //                   }
  //                 }
  //               },
  //             ),
  //             const SizedBox(height: 20),

  //             /* Web Footer */
  //             kIsWeb ? const FooterWeb() : const SizedBox.shrink(),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  /* Section Shimmer */
  Widget sectionShimmer() {
    return Column(
      children: [
        /* Continue Watching */
        if (Constant.userID != null && homeProvider.selectedIndex == 0)
          ShimmerUtils.continueWatching(context),

        /* Remaining Sections */
        ListView.builder(
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
        ),
      ],
    );
  }

// animated banner ----

// animated banner ----
  Widget _mobileHomeBanner(List<banner.Result>? sectionBannerList) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    if ((sectionBannerList?.length ?? 0) > 0) {
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          SizedBox(
            width: double.infinity,
            height: Dimens.homeBanner,
            child: CarouselSlider.builder(
              itemCount: sectionBannerList?.length ?? 0,
              carouselController: carouselController,
              options: CarouselOptions(
                initialPage: 0,
                height: Dimens.homeBanner,
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayCurve: Curves.easeInOut,
                enableInfiniteScroll: true,
                autoPlayInterval:
                    Duration(milliseconds: Constant.bannerDuration),
                autoPlayAnimationDuration:
                    Duration(milliseconds: Constant.animationDuration),
                viewportFraction: isTablet ? 1.0 : 0.70,
                onPageChanged: (val, _) async {
                  await sectionDataProvider.setCurrentBanner(val);
                },
              ),
              itemBuilder: (context, index, realIndex) {
                final bannerItem = sectionBannerList?[index];
                final imageUrl = isTablet
                    ? bannerItem?.fullWidth ?? ""
                    : bannerItem?.thumbnail ?? "";

                return GestureDetector(
                  onTap: () {
                    final timestamp = DateTime.now().toIso8601String();

                    final properties = MoEProperties()
                      ..addAttribute('banner_id', sectionBannerList?[index])
                      ..addAttribute('category_name',
                          sectionBannerList?[index].categoryName)
                      ..addAttribute(
                          'banner_name', sectionBannerList?[index].name)
                      ..addAttribute('user_id', Constant.userID.toString())
                      ..addAttribute('language', selectedLanguages)
                      ..addAttribute('timestamp', timestamp);

                    MoEngageService.instance
                        .trackEvent('dynamic_banner_clicked', properties);

                    print(
                        "MoEngage event tracked with and timestamp: $timestamp");

                    debugPrint("Clicked on banner: ${bannerItem?.video320}");

                    if (bannerItem?.isLiveUrl == 1) {
                      if (Constant.userID == null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginViaSocial()),
                        );
                      } else {
                        final timestamp = DateTime.now().toIso8601String();
                        final properties = MoEProperties()
                        // ..addAttribute('userName', Constant.userID.toString())
                          ..addAttribute('user_id', Constant.userID.toString())
                          ..addAttribute('stream_id', videoType)
                          ..addAttribute('stream_category', typeId)
                          ..addAttribute('timestamp', timestamp);

                        print(
                            "MoEngage event tracked with Constant userID: ${userMobileNo}");
                        MoEngageService.instance
                            .trackEvent('Live_Stream_Joined', properties);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestPlayerWeb(
                              loadURL: bannerItem?.videoUrl ?? "",
                            ),
                          ),
                        );
                      }
                    } else if (bannerItem?.bannerBacklink != null &&
                        bannerItem!.bannerBacklink!.isNotEmpty) {
                      launchUrl(Uri.parse(bannerItem.bannerBacklink!));
                    } else {
                      openDetailPage(
                        (bannerItem?.videoType ?? 0) == 2
                            ? "showdetail"
                            : "videodetail",
                        bannerItem?.id ?? 0,
                        bannerItem?.upcomingType ?? 0,
                        bannerItem?.videoType ?? 0,
                        bannerItem?.typeId ?? 0,
                        bannerItem?.name ?? 0,
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: MyNetworkImageTwo(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: _buildBannerBadge(bannerItem),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 10,
            child: Consumer<SectionDataProvider>(
              builder: (context, sectionDataProvider, child) {
                return AnimatedSmoothIndicator(
                  count: sectionBannerList?.length ?? 0,
                  activeIndex: sectionDataProvider.cBannerIndex ?? 0,
                  effect: const ExpandingDotsEffect(
                    spacing: 8,
                    radius: 6,
                    activeDotColor: colorPrimary,
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

  // Widget _mobileHomeBanner(List<banner.Result>? sectionBannerList) {
  //   if ((sectionBannerList?.length ?? 0) > 0) {
  //     return Stack(
  //       alignment: AlignmentDirectional.bottomCenter,
  //       children: [
  //         SizedBox(
  //           width: double.infinity,
  //           height: Dimens.homeBanner,
  //           child: CarouselSlider.builder(
  //             itemCount: sectionBannerList?.length ?? 0,
  //             carouselController: carouselController,
  //             options: CarouselOptions(
  //               initialPage: 0,
  //               height: Dimens.homeBanner,
  //               enlargeCenterPage: true,
  //               autoPlay: true,
  //               autoPlayCurve: Curves.easeInOut,
  //               enableInfiniteScroll: true,
  //               autoPlayInterval:
  //                   Duration(milliseconds: Constant.bannerDuration),
  //               autoPlayAnimationDuration:
  //                   Duration(milliseconds: Constant.animationDuration),
  //               viewportFraction:
  //                   0.70, // Adjusted for better portrait mode visibility
  //               onPageChanged: (val, _) async {
  //                 await sectionDataProvider.setCurrentBanner(val);
  //               },
  //             ),
  //             itemBuilder: (context, index, realIndex) {
  //               return GestureDetector(
  //                 onTap: () {
  //                   debugPrint(
  //                       "Clicked on banner: ${sectionBannerList?[index].video320}");
  //                   if (sectionBannerList?[index].isLiveUrl == 1) {
  //                     if (Constant.userID == null) {
  //                       Navigator.push(
  //                           context,
  //                           MaterialPageRoute(
  //                               builder: (context) => LoginViaSocial()));
  //                     } else {
  //                       Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                           builder: (context) => TestPlayerWeb(
  //                             loadURL: sectionBannerList?[index].videoUrl!,
  //                           ),
  //                         ),
  //                       );
  //                     }
  //                   } else if (sectionBannerList?[index].bannerBacklink !=
  //                           null &&
  //                       sectionBannerList![index].bannerBacklink!.isNotEmpty) {
  //                     launchUrl(
  //                         Uri.parse(sectionBannerList[index].bannerBacklink!));
  //                   } else {
  //                     openDetailPage(
  //                       (sectionBannerList?[index].videoType ?? 0) == 2
  //                           ? "showdetail"
  //                           : "videodetail",
  //                       sectionBannerList?[index].id ?? 0,
  //                       sectionBannerList?[index].upcomingType ?? 0,
  //                       sectionBannerList?[index].videoType ?? 0,
  //                       sectionBannerList?[index].typeId ?? 0,
  //                       sectionBannerList?[index].name ?? 0,

  //                     );
  //                   }
  //                 },
  //                 child: Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //                   child: ClipRRect(
  //                     borderRadius: BorderRadius.circular(12),
  //                     child: Stack(
  //                       alignment: Alignment.topRight,
  //                       children: [
  //                         Container(
  //                           decoration: BoxDecoration(
  //                             borderRadius: BorderRadius.circular(12),
  //                             boxShadow: [
  //                               BoxShadow(
  //                                 color.xml: Colors.black26,
  //                                 blurRadius: 5,
  //                                 spreadRadius: 2,
  //                               ),
  //                             ],
  //                           ),
  //                           child: MyNetworkImageTwo(
  //                             imageUrl:
  //                                 sectionBannerList?[index].thumbnail ?? "",
  //                             fit: BoxFit.cover,
  //                           ),
  //                         ),
  //                         Positioned(
  //                           top: 10,
  //                           right: 10,
  //                           child: _buildBannerBadge(sectionBannerList?[index]),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //         Positioned(
  //           bottom: 10,
  //           child: Consumer<SectionDataProvider>(
  //             builder: (context, sectionDataProvider, child) {
  //               return AnimatedSmoothIndicator(
  //                 count: sectionBannerList?.length ?? 0,
  //                 activeIndex: sectionDataProvider.cBannerIndex ?? 0,
  //                 effect: const ExpandingDotsEffect(
  //                   spacing: 8,
  //                   radius: 6,
  //                   activeDotColor: colorPrimary,
  //                   dotColor: dotsDefaultColor,
  //                   dotHeight: 8,
  //                   dotWidth: 8,
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //       ],
  //     );
  //   } else {
  //     return const SizedBox.shrink();
  //   }
  // }

//  Widget _mobileHomeBanner(List<banner.Result>? sectionBannerList) {
//     if ((sectionBannerList?.length ?? 0) > 0) {
//       return Stack(
//         alignment: AlignmentDirectional.bottomCenter,
//         clipBehavior: Clip.antiAliasWithSaveLayer,
//         children: [
//           SizedBox(
//             width: MediaQuery.of(context).size.width,
//             height: Dimens.homeBanner,
//             child: CarouselSlider.builder(
//               itemCount: (sectionBannerList?.length ?? 0),
//               carouselController: carouselController,
//               options: CarouselOptions(
//                 initialPage: 0,
//                 height: Dimens.homeBanner,
//                 enlargeCenterPage: false,
//                 autoPlay: true,
//                 autoPlayCurve: Curves.linear,
//                 enableInfiniteScroll: true,
//                 autoPlayInterval:
//                     Duration(milliseconds: Constant.bannerDuration),
//                 autoPlayAnimationDuration:
//                     Duration(milliseconds: Constant.animationDuration),
//                 viewportFraction: 1.0,
//                 onPageChanged: (val, _) async {
//                   await sectionDataProvider.setCurrentBanner(val);
//                 },
//               ),
//               itemBuilder:
//                   (BuildContext context, int index, int pageViewIndex) {
//                 return GestureDetector(
//                   behavior: HitTestBehavior.translucent,
//                   // focusColor: white,
//                   // borderRadius: BorderRadius.circular(0),
//                   onTap: () {
//                     debugPrint("Clicked userid ==> ${Constant.userID}");
//                     debugPrint(
//                         "Clicked on link is  ==> ${sectionBannerList?[index].video320.toString()}");
//                     if (sectionBannerList?[index].isLiveUrl == 1) {
//                       if (Constant.userID == null) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => LoginViaSocial()),
//                         );
//                       } else {

//                         Navigator.of(context).push(MaterialPageRoute(
//                             builder: (context) => TestPlayerWeb(
//                                 loadURL: sectionBannerList?[index].videoUrl!)));
//                       }
//                     } else if (sectionBannerList?[index].bannerBacklink !=
//                             null &&
//                         sectionBannerList![index]
//                             .bannerBacklink
//                             .toString()
//                             .isNotEmpty) {
//                       launchUrl(Uri.parse(
//                           sectionBannerList[index].bannerBacklink.toString()));
//                     } else {
//                       openDetailPage(
//                         (sectionBannerList?[index].videoType ?? 0) == 2
//                             ? "showdetail"
//                             : "videodetail",
//                         sectionBannerList?[index].id ?? 0,
//                         sectionBannerList?[index].upcomingType ?? 0,
//                         sectionBannerList?[index].videoType ?? 0,
//                         sectionBannerList?[index].typeId ?? 0,
//                       );
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.only(
//                         top: 0, bottom: 0, left: 10, right: 10),
//                     child: Stack(
//                       alignment: Alignment.topRight,
//                       // alignment: AlignmentDirectional.bottomCenter,
//                       children: [
//                         SizedBox(
//                           height: Dimens.homeBanner,
//                           child: MyNetworkImageTwo(
//                             imageUrl: sectionBannerList?[index].fullWidth?? "",
//                             fit: BoxFit.fill,
//                           ),
//                         ),
//                        Positioned(
//                         top: 10,
//                         right: 10,
//                         child: _buildBannerBadge(sectionBannerList?[index]),
//                       ),

//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//         ],
//       );
//     } else {
//       return const SizedBox.shrink();
//     }
//   }

  // Widget _mobileHomeBanner(List<banner.Result>? sectionBannerList) {
  //   if ((sectionBannerList?.length ?? 0) > 0) {
  //     return Stack(
  //       alignment: AlignmentDirectional.bottomCenter,
  //       clipBehavior: Clip.antiAliasWithSaveLayer,
  //       children: [
  //         SizedBox(
  //           width: MediaQuery.of(context).size.width,
  //           height: Dimens.homeBanner,
  //           child: CarouselSlider.builder(
  //             itemCount: (sectionBannerList?.length ?? 0),
  //             carouselController: carouselController,
  //             options: CarouselOptions(
  //               initialPage: 0,
  //               height: Dimens.homeBanner,
  //               enlargeCenterPage: false,
  //               autoPlay: true,
  //               autoPlayCurve: Curves.linear,
  //               enableInfiniteScroll: true,
  //               autoPlayInterval:
  //                   Duration(milliseconds: Constant.bannerDuration),
  //               autoPlayAnimationDuration:
  //                   Duration(milliseconds: Constant.animationDuration),
  //               viewportFraction: 1.0,
  //               onPageChanged: (val, _) async {
  //                 await sectionDataProvider.setCurrentBanner(val);
  //               },
  //             ),
  //             itemBuilder:
  //                 (BuildContext context, int index, int pageViewIndex) {
  //               return GestureDetector(
  //                 behavior: HitTestBehavior.translucent,
  //                 // focusColor: white,
  //                 // borderRadius: BorderRadius.circular(0),
  //                 onTap: () {
  //                   debugPrint("Clicked userid ==> ${Constant.userID}");
  //                   debugPrint(
  //                       "Clicked on link is  ==> ${sectionBannerList?[index].video320.toString()}");
  //                   if (sectionBannerList?[index].isLiveUrl == 1) {
  //                     if (Constant.userID == null) {
  //                       Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                             builder: (context) => LoginViaSocial()),
  //                       );
  //                     } else {

  //                       Navigator.of(context).push(MaterialPageRoute(
  //                           builder: (context) => TestPlayerWeb(
  //                               loadURL: sectionBannerList?[index].videoUrl!)));
  //                     }
  //                   } else if (sectionBannerList?[index].bannerBacklink !=
  //                           null &&
  //                       sectionBannerList![index]
  //                           .bannerBacklink
  //                           .toString()
  //                           .isNotEmpty) {
  //                     launchUrl(Uri.parse(
  //                         sectionBannerList[index].bannerBacklink.toString()));
  //                   } else {
  //                     openDetailPage(
  //                       (sectionBannerList?[index].videoType ?? 0) == 2
  //                           ? "showdetail"
  //                           : "videodetail",
  //                       sectionBannerList?[index].id ?? 0,
  //                       sectionBannerList?[index].upcomingType ?? 0,
  //                       sectionBannerList?[index].videoType ?? 0,
  //                       sectionBannerList?[index].typeId ?? 0,
  //                     );
  //                   }
  //                 },
  //                 child: Padding(
  //                   padding: const EdgeInsets.only(
  //                       top: 0, bottom: 0, left: 10, right: 10),
  //                   child: Stack(
  //                     alignment: Alignment.topRight,
  //                     // alignment: AlignmentDirectional.bottomCenter,
  //                     children: [
  //                       SizedBox(
  //                         height: Dimens.homeBanner,
  //                         child: MyNetworkImageTwo(
  //                           imageUrl: sectionBannerList?[index].fullWidth ?? "",
  //                           fit: BoxFit.fill,
  //                         ),
  //                       ),
  //                       Positioned(
  //                         top: 10,
  //                         right: 10,
  //                         child: _buildBannerBadge(sectionBannerList?[index]),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //         const SizedBox(height: 5.5),
  //         Positioned(
  //           bottom: 10,
  //           child: Consumer<SectionDataProvider>(
  //             builder: (context, sectionDataProvider, child) {
  //               return AnimatedSmoothIndicator(
  //                 count: (sectionBannerList?.length ?? 0),
  //                 activeIndex: sectionDataProvider.cBannerIndex ?? 0,
  //                 effect: const ScrollingDotsEffect(
  //                   spacing: 8,
  //                   radius: 4,
  //                   activeDotColor: colorPrimary,
  //                   dotColor: dotsDefaultColor,
  //                   dotHeight: 8,
  //                   dotWidth: 8,
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //       ],
  //     );
  //   } else {
  //     return const SizedBox.shrink();
  //   }
  // }

//   Widget _mobileHomeBanner(List<banner.Result>? sectionBannerList, BuildContext context) {
//   if ((sectionBannerList?.length ?? 0) > 0) {
//     return Stack(
//       alignment: Alignment.bottomCenter,
//       children: [
//         SizedBox(
//           width: MediaQuery.of(context).size.width,
//           height: Dimens.homeBanner,
//           child: CarouselSlider.builder(
//             itemCount: sectionBannerList?.length ?? 0,
//             carouselController: carouselController,
//             options: CarouselOptions(
//               initialPage: 0,
//               height: Dimens.homeBanner,
//               autoPlay: true,
//               autoPlayCurve: Curves.easeInOut,
//               enableInfiniteScroll: true,
//               autoPlayInterval: Duration(seconds: 3),
//               autoPlayAnimationDuration: Duration(milliseconds: 800),
//               viewportFraction: 1.0, // Adjust for spacing
//               onPageChanged: (val, _) async {
//                 await sectionDataProvider.setCurrentBanner(val);
//               },
//             ),
//             itemBuilder: (context, index, _) {
//               final bannerItem = sectionBannerList?[index];
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 5), // Adds margin
//                 child: GestureDetector(
//                   onTap: () => _handleBannerTap(bannerItem, context),
//                   child: Stack(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Stack(
//                           fit: StackFit.expand,
//                           children: [
//                             MyNetworkImageTwo(
//                               imageUrl: bannerItem?.landscape ?? "",
//                               fit: BoxFit.cover,
//                             ),
//                             // Container(
//                             //   decoration: BoxDecoration(
//                             //     gradient: LinearGradient(
//                             //       begin: Alignment.topCenter,
//                             //       end: Alignment.bottomCenter,
//                             //       colors: [
//                             //         Colors.black.withOpacity(0.2),
//                             //         Colors.black.withOpacity(0.6),
//                             //       ],
//                             //     ),
//                             //   ),
//                             // ),
//                           ],
//                         ),
//                       ),
//                       Positioned(
//                         top: 10,
//                         right: 10,
//                         child: _buildBannerBadge(bannerItem),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         Positioned(
//           bottom: 12,
//           child: AnimatedSmoothIndicator(
//             count: sectionBannerList?.length ?? 0,
//             activeIndex: sectionDataProvider.cBannerIndex ?? 0,
//             effect: ScrollingDotsEffect(
//               spacing: 8,
//               activeDotColor: Colors.white,
//               dotColor: Colors.grey.shade400,
//               dotHeight: 8,
//               dotWidth: 8,
//             ),
//           ),
//         ),
//       ],
//     );
//   } else {
//     return SizedBox.shrink();
//   }
// }

// Widget _mobileHomeBanner(List<banner.Result>? sectionBannerList, BuildContext context) {
//   if ((sectionBannerList?.length ?? 0) > 0) {
//     return Stack(
//       alignment: Alignment.bottomCenter,
//       children: [
//         SizedBox(
//           width: MediaQuery.of(context).size.width,
//           height: Dimens.homeBanner,
//           child: CarouselSlider.builder(
//             itemCount: sectionBannerList?.length ?? 0,
//             carouselController: carouselController,
//             options: CarouselOptions(
//               initialPage: 0,
//               height: Dimens.homeBanner,
//               autoPlay: true,
//               autoPlayCurve: Curves.easeInOut,
//               enableInfiniteScroll: true,
//               autoPlayInterval: Duration(seconds: 3),
//               autoPlayAnimationDuration: Duration(milliseconds: 800),
//               viewportFraction: 0.98,
//               onPageChanged: (val, _) async {
//                 await sectionDataProvider.setCurrentBanner(val);
//               },
//             ),
//             itemBuilder: (context, index, _) {
//               final bannerItem = sectionBannerList?[index];
//               return GestureDetector(
//                 onTap: () => _handleBannerTap(bannerItem, context),
//                 child: Stack(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Stack(
//                         fit: StackFit.expand,
//                         children: [
//                           MyNetworkImageTwo(
//                             imageUrl: bannerItem?.fullWidth ?? "",
//                             fit: BoxFit.cover,
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                                 colors: [
//                                   Colors.black.withOpacity(0.2),
//                                   Colors.black.withOpacity(0.6),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Positioned(
//                       top: 10,
//                       right: 10,
//                       child: _buildBannerBadge(bannerItem),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//         Positioned(
//           bottom: 12,
//           child: AnimatedSmoothIndicator(
//             count: sectionBannerList?.length ?? 0,
//             activeIndex: sectionDataProvider.cBannerIndex ?? 0,
//             effect: ScrollingDotsEffect(
//               spacing: 8,
//               activeDotColor: Colors.white,
//               dotColor: Colors.grey.shade400,
//               dotHeight: 8,
//               dotWidth: 8,
//             ),
//           ),
//         ),
//       ],
//     );
//   } else {
//     return SizedBox.shrink();
//   }
// }

  void _handleBannerTap(banner.Result? bannerItem, BuildContext context) {
    if (bannerItem == null) return;
    if (bannerItem.isLiveUrl == 1) {
      if (Constant.userID == null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginViaSocial()));
      } else {
        final timestamp = DateTime.now().toIso8601String();
        final properties = MoEProperties()
        // ..addAttribute('userName', Constant.userID.toString())
          ..addAttribute('user_id', Constant.userID.toString())
          ..addAttribute('stream_id', videoType)
          ..addAttribute('stream_category', typeId)
          ..addAttribute('timestamp', timestamp);

        print("MoEngage event tracked with Constant userID: ${userMobileNo}");
        MoEngageService.instance.trackEvent('Live_Stream_Joined', properties);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  TestPlayerWeb(loadURL: bannerItem.videoUrl!)),
        );
      }
    } else if (bannerItem.bannerBacklink?.isNotEmpty == true) {
      launchUrl(Uri.parse(bannerItem.bannerBacklink!));
    } else {
      openDetailPage(
          (bannerItem.videoType ?? 0) == 2 ? "showdetail" : "videodetail",
          bannerItem.id ?? 0,
          bannerItem.upcomingType ?? 0,
          bannerItem.videoType ?? 0,
          bannerItem.typeId ?? 0,
          bannerItem.name ?? "");
    }
  }

  Widget _buildBannerBadge(banner.Result? bannerItem) {
    if (bannerItem == null) return SizedBox.shrink();
    if (bannerItem.isLiveUrl == 1) {
      return _badge("LIVE", Colors.red);
    } else if (bannerItem.isRent == 1 && bannerItem.isPremium == 0) {
      return _iconBadge('assets/images/rupee.png');
    } else if (bannerItem.isPremium == 1) {
      return _iconBadge('assets/images/crown.png');
    }
    return SizedBox.shrink();
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _iconBadge(String assetPath) {
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(
        assetPath,
        height: 15,
        width: 15,
      ),
    );
  }

  // Widget _mobileHomeBanner(List<banner.Result>? sectionBannerList) {
  //   if ((sectionBannerList?.length ?? 0) > 0) {
  //     return Stack(
  //       alignment: AlignmentDirectional.bottomCenter,
  //       clipBehavior: Clip.antiAliasWithSaveLayer,
  //       children: [
  //         SizedBox(
  //           width: MediaQuery.of(context).size.width,
  //           height: Dimens.homeBanner,
  //           child: CarouselSlider.builder(
  //             itemCount: (sectionBannerList?.length ?? 0),
  //             carouselController: carouselController,
  //             options: CarouselOptions(
  //               initialPage: 0,
  //               height: Dimens.homeBanner,
  //               enlargeCenterPage: false,
  //               autoPlay: true,
  //               autoPlayCurve: Curves.linear,
  //               enableInfiniteScroll: true,
  //               autoPlayInterval:
  //                   Duration(milliseconds: Constant.bannerDuration),
  //               autoPlayAnimationDuration:
  //                   Duration(milliseconds: Constant.animationDuration),
  //               viewportFraction: 1.0,
  //               onPageChanged: (val, _) async {
  //                 await sectionDataProvider.setCurrentBanner(val);
  //               },
  //             ),
  //             itemBuilder:
  //                 (BuildContext context, int index, int pageViewIndex) {
  //               return GestureDetector(
  //                 behavior: HitTestBehavior.translucent,
  //                 // //focusColor:: white,
  //                 // borderRadius: BorderRadius.circular(0),
  //                 onTap: () {
  //                   debugPrint("Clicked userid ==> ${Constant.userID}");
  //                   debugPrint(
  //                       "Clicked on link is  ==> ${sectionBannerList?[index].video320.toString()}");
  //                   if (sectionBannerList?[index].isLiveUrl == 1) {
  //                     if (Constant.userID == null) {
  //                       Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                             builder: (context) => LoginViaSocial()),
  //                       );
  //                     } else {
  //                       Navigator.of(context).push(MaterialPageRoute(
  //                           builder: (context) => TestPlayerWeb(
  //                               loadURL: sectionBannerList?[index].videoUrl!)));
  //                     }
  //                   } else if (sectionBannerList?[index].bannerBacklink !=
  //                           null &&
  //                       sectionBannerList![index]
  //                           .bannerBacklink
  //                           .toString()
  //                           .isNotEmpty) {
  //                     launchUrl(Uri.parse(
  //                         sectionBannerList[index].bannerBacklink.toString()));
  //                   } else {
  //                     openDetailPage(
  //                       (sectionBannerList?[index].videoType ?? 0) == 2
  //                           ? "showdetail"
  //                           : "videodetail",
  //                       sectionBannerList?[index].id ?? 0,
  //                       sectionBannerList?[index].upcomingType ?? 0,
  //                       sectionBannerList?[index].videoType ?? 0,
  //                       sectionBannerList?[index].typeId ?? 0,
  //                     );
  //                   }
  //                 },
  //                 child: Padding(
  //                   padding: const EdgeInsets.only(
  //                       top: 0, bottom: 0, left: 10, right: 10),
  //                   child: Stack(
  //                     alignment: Alignment.topRight,
  //                     // alignment: AlignmentDirectional.bottomCenter,
  //                     children: [
  //                       SizedBox(
  //                         height: Dimens.homeBanner,
  //                         child: MyNetworkImageTwo(
  //                           imageUrl: sectionBannerList?[index].fullWidth ?? "",
  //                           fit: BoxFit.fill,
  //                         ),
  //                       ),
  //                       Visibility(
  //                         visible: sectionBannerList?[index].isRent == 1 &&
  //                             sectionBannerList?[index].isPremium == 0,
  //                         child: FittedBox(
  //                           child: Container(
  //                               constraints: const BoxConstraints(
  //                                 minHeight: 15,
  //                                 minWidth: 30,
  //                               ),
  //                               alignment: Alignment.center,
  //                               padding: const EdgeInsets.all(5),
  //                               decoration: const BoxDecoration(
  //                                 color.xml: otherIcons,
  //                                 borderRadius: BorderRadius.only(
  //                                     topLeft: Radius.circular(3),
  //                                     topRight: Radius.circular(4),
  //                                     bottomLeft: Radius.circular(8),
  //                                     bottomRight: Radius.circular(3)),
  //                               ),
  //                               child: Row(
  //                                 children: [
  //                                   Image.asset(
  //                                     'assets/images/rupee.png',
  //                                     height: 13,
  //                                     width: 13,
  //                                   ),
  //                                 ],
  //                               )),
  //                         ),
  //                       ),
  //                       Visibility(
  //                         visible: sectionBannerList?[index].isPremium == 1,
  //                         child: FittedBox(
  //                           child: Container(
  //                               constraints: const BoxConstraints(
  //                                 minHeight: 15,
  //                                 minWidth: 30,
  //                               ),
  //                               alignment: Alignment.center,
  //                               padding: const EdgeInsets.all(5),
  //                               decoration: const BoxDecoration(
  //                                 color.xml: otherIcons,
  //                                 borderRadius: BorderRadius.only(
  //                                     topLeft: Radius.circular(3),
  //                                     topRight: Radius.circular(4),
  //                                     bottomLeft: Radius.circular(8),
  //                                     bottomRight: Radius.circular(3)),
  //                               ),
  //                               child: Row(
  //                                 children: [
  //                                   Image.asset(
  //                                     'assets/images/crown.png',
  //                                     height: 15,
  //                                     width: 15,
  //                                   ),
  //                                 ],
  //                               )),
  //                         ),
  //                       ),
  //                       Visibility(
  //                         visible: sectionBannerList?[index].isRent == 1 &&
  //                             sectionBannerList?[index].isPremium == 1,
  //                         child: FittedBox(
  //                           child: Container(
  //                               constraints: const BoxConstraints(
  //                                 minHeight: 15,
  //                                 minWidth: 30,
  //                               ),
  //                               alignment: Alignment.center,
  //                               padding: const EdgeInsets.all(5),
  //                               decoration: const BoxDecoration(
  //                                 color.xml: otherIcons,
  //                                 borderRadius: BorderRadius.only(
  //                                     topLeft: Radius.circular(3),
  //                                     topRight: Radius.circular(4),
  //                                     bottomLeft: Radius.circular(8),
  //                                     bottomRight: Radius.circular(3)),
  //                               ),
  //                               child: Row(
  //                                 children: [
  //                                   Image.asset(
  //                                     'assets/images/crown.png',
  //                                     height: 15,
  //                                     width: 15,
  //                                   ),
  //                                 ],
  //                               )),
  //                         ),
  //                       ),
  //                       Visibility(
  //                         visible: sectionBannerList?[index].isLiveUrl == 1,
  //                         child: FittedBox(
  //                           child: Container(
  //                               margin: EdgeInsets.only(right: 8),
  //                               constraints: const BoxConstraints(
  //                                 minHeight: 15,
  //                                 minWidth: 30,
  //                               ),
  //                               alignment: Alignment.center,
  //                               padding: const EdgeInsets.all(5),
  //                               // decoration: const BoxDecoration(
  //                               //   color.xml: colorPrimary,
  //                               //   borderRadius: BorderRadius.only(
  //                               //       topLeft: Radius.circular(3),
  //                               //       topRight: Radius.circular(4),
  //                               //       bottomLeft: Radius.circular(8),
  //                               //       bottomRight: Radius.circular(3)),
  //                               // ),
  //                               child: Row(
  //                                 children: [
  //                                   Container(
  //                                     height: 7,
  //                                     width: 7,
  //                                     margin: EdgeInsets.only(right: 3),
  //                                     decoration: BoxDecoration(
  //                                       color.xml: redColor,
  //                                       borderRadius: BorderRadius.circular(30),
  //                                     ),
  //                                   ),
  //                                   Text(
  //                                     "LIVE",
  //                                     style: TextStyle(
  //                                         color.xml: redColor,
  //                                         fontSize: 12,
  //                                         fontWeight: FontWeight.w700),
  //                                   )
  //                                 ],
  //                               )),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //         // const SizedBox(height: 5.5),
  //         // Positioned(
  //         //   bottom: 10,
  //         //   child: Consumer<SectionDataProvider>(
  //         //     builder: (context, sectionDataProvider, child) {
  //         //       return AnimatedSmoothIndicator(
  //         //         count: (sectionBannerList?.length ?? 0),
  //         //         activeIndex: sectionDataProvider.cBannerIndex ?? 0,
  //         //         effect: const ScrollingDotsEffect(
  //         //           spacing: 8,
  //         //           radius: 4,
  //         //           activeDotColor: colorPrimary,
  //         //           dotColor: dotsDefaultColor,
  //         //           dotHeight: 8,
  //         //           dotWidth: 8,
  //         //         ),
  //         //       );
  //         //     },
  //         //   ),
  //         // ),
  //       ],
  //     );
  //   } else {
  //     return const SizedBox.shrink();
  //   }
  // }

  Widget _webHomeBanner(List<banner.Result>? sectionBannerList) {
    if ((sectionBannerList?.length ?? 0) > 0) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: Dimens.homeWebBanner,
        child: CarouselSlider.builder(
          itemCount: (sectionBannerList?.length ?? 0),
          carouselController: carouselController,
          options: CarouselOptions(
            initialPage: 0,
            height: Dimens.homeWebBanner,
            enlargeCenterPage: false,
            autoPlay: true,
            autoPlayCurve: Curves.easeInOutQuart,
            enableInfiniteScroll: true,
            autoPlayInterval: Duration(milliseconds: Constant.bannerDuration),
            autoPlayAnimationDuration:
                Duration(milliseconds: Constant.animationDuration),
            viewportFraction: 0.95,
            onPageChanged: (val, _) async {
              await sectionDataProvider.setCurrentBanner(val);
            },
          ),
          itemBuilder: (BuildContext context, int index, int pageViewIndex) {
            return InkWell(
              // //focusColor:: white,
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                debugPrint("Clicked on index ==> $index");
                openDetailPage(
                  (sectionBannerList?[index].videoType ?? 0) == 2
                      ? "showdetail"
                      : "videodetail",
                  sectionBannerList?[index].id ?? 0,
                  sectionBannerList?[index].upcomingType ?? 0,
                  sectionBannerList?[index].videoType ?? 0,
                  sectionBannerList?[index].typeId ?? 0,
                  sectionBannerList?[index].name ?? "",
                );
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Stack(
                    alignment: AlignmentDirectional.centerEnd,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            (Dimens.webBannerImgPr),
                        height: Dimens.homeWebBanner,
                        child: MyNetworkImage(
                          imageUrl: sectionBannerList?[index].landscape ?? "",
                          fit: BoxFit.fill,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.homeWebBanner,
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              lightBlack,
                              lightBlack,
                              lightBlack,
                              lightBlack,
                              transparentColor,
                              transparentColor,
                              transparentColor,
                              transparentColor,
                              transparentColor,
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.homeWebBanner,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  (1.0 - Dimens.webBannerImgPr),
                              constraints: const BoxConstraints(minHeight: 0),
                              padding:
                                  const EdgeInsets.fromLTRB(35, 50, 55, 35),
                              alignment: Alignment.centerLeft,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    color: white,
                                    text: sectionBannerList?[index].name ?? "",
                                    textalign: TextAlign.start,
                                    fontsizeNormal: 14,
                                    fontsizeWeb: 25,
                                    fontweight: FontWeight.w700,
                                    multilanguage: false,
                                    maxline: 2,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                  const SizedBox(height: 12),
                                  MyText(
                                    color: whiteLight,
                                    text: sectionBannerList?[index]
                                            .categoryName ??
                                        "",
                                    textalign: TextAlign.start,
                                    fontsizeNormal: 14,
                                    fontweight: FontWeight.w600,
                                    fontsizeWeb: 15,
                                    multilanguage: false,
                                    maxline: 2,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: MyText(
                                      color: whiteLight,
                                      text: sectionBannerList?[index]
                                              .description ??
                                          "",
                                      textalign: TextAlign.start,
                                      fontsizeNormal: 14,
                                      fontweight: FontWeight.w600,
                                      fontsizeWeb: 15,
                                      multilanguage: false,
                                      maxline:
                                          (MediaQuery.of(context).size.width <
                                                  1000)
                                              ? 2
                                              : 5,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget continueWatchingLayout(List<ContinueWatching>? continueWatchingList) {
    if ((continueWatchingList?.length ?? 0) > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: MyText(
              color: white,
              text: "continuewatching",
              multilanguage: true,
              textalign: TextAlign.center,
              fontsizeNormal: 14,
              fontsizeWeb: 16,
              fontweight: FontWeight.w600,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: Dimens.heightContiLand,
            child: ListView.separated(
              itemCount: (continueWatchingList?.length ?? 0),
              shrinkWrap: true,
              padding: const EdgeInsets.only(left: 20, right: 20),
              scrollDirection: Axis.horizontal,
              physics: const PageScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              separatorBuilder: (context, index) => const SizedBox(
                width: 5,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    InkWell(
                      //focusColor:: white,
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        debugPrint("Clicked on index ==> $index");
                        openDetailPage(
                            (continueWatchingList?[index].videoType ?? 0) == 2
                                ? "showdetail"
                                : "videodetail",
                            (continueWatchingList?[index].videoType ?? 0) == 2
                                ? (continueWatchingList?[index].showId ?? 0)
                                : (continueWatchingList?[index].id ?? 0),
                            0,
                            continueWatchingList?[index].videoType ?? 0,
                            continueWatchingList?[index].typeId ?? 0,
                            continueWatchingList?[index].name ?? "");
                      },
                      child: Container(
                        width: Dimens.widthContiLand,
                        height: Dimens.heightContiLand,
                        alignment: Alignment.center,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: MyNetworkImage(
                            imageUrl:
                                continueWatchingList?[index].landscape ?? "",
                            fit: BoxFit.cover,
                            imgHeight: MediaQuery.of(context).size.height,
                            imgWidth: MediaQuery.of(context).size.width,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () async {
                              openPlayer(
                                  "ContinueWatch", index, continueWatchingList);
                            },
                            child: MyImage(
                              width: 30,
                              height: 30,
                              imagePath: "play.png",
                            ),
                          ),
                        ),
                        Container(
                          width: Dimens.widthContiLand,
                          constraints: const BoxConstraints(minWidth: 0),
                          padding: const EdgeInsets.all(3),
                          child: LinearPercentIndicator(
                            padding: const EdgeInsets.all(0),
                            barRadius: const Radius.circular(2),
                            lineHeight: 4,
                            percent: Utils.getPercentage(
                                continueWatchingList?[index].videoDuration ?? 0,
                                continueWatchingList?[index].stopTime ?? 0),
                            backgroundColor: secProgressColor,
                            progressColor: colorPrimary,
                          ),
                        ),
                        (continueWatchingList?[index].releaseTag != null &&
                                (continueWatchingList?[index].releaseTag ?? "")
                                    .isNotEmpty)
                            ? Container(
                                decoration: const BoxDecoration(
                                  color: black,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                  ),
                                  shape: BoxShape.rectangle,
                                ),
                                alignment: Alignment.center,
                                width: Dimens.widthContiLand,
                                height: 15,
                                child: MyText(
                                  color: white,
                                  multilanguage: false,
                                  text:
                                      continueWatchingList?[index].releaseTag ??
                                          "",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: 6,
                                  fontweight: FontWeight.w700,
                                  fontsizeWeb: 10,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ],
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
          bool isReelShow = sectionList[index].videoType == 7;

          bool isFMSection = sectionList[index].title == "FM";

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 9, 18, 4),
                    child: MyTextTWO(
                      maxline: 2,
                      color: white,
                      text: sectionList[index].title.toString(),
                      textalign: TextAlign.left,
                      fontsizeNormal: 11,
                      fontweight: FontWeight.w500,
                      fontsizeWeb: 11,
                      multilanguage: false,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                  if (!isFMSection && !isGenreOrLanguage && !isReelShow)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return MoreScreen(
                              sectionList[index].title.toString(),
                              sectionList[index]
                                  .id
                                  .toString(), // Pass the section ID
                            );
                          },
                        )
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: 6), // Adjust padding to avoid overflow
                        child: Row(
                          mainAxisSize: MainAxisSize
                              .min, // Prevents the row from stretching
                          children: [
                            MyText(
                              color: primaryLight,
                              text: "More",
                              textalign: TextAlign.center,
                              fontsizeNormal: 8,
                              fontweight: FontWeight.w500,
                              fontsizeWeb: 14,
                              multilanguage: false,
                              maxline: 1,
                              overflow: TextOverflow
                                  .ellipsis, // Prevents text overflow
                              fontstyle: FontStyle.normal,
                            ),
                            const SizedBox(
                                width: 4), // Space between text and icon
                            Icon(
                              CupertinoIcons.right_chevron,
                              color: primaryLight, // White color arrow
                              size: 14, // Adjust size as needed
                            ),
                          ],
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 5, 0),
                      child: SizedBox(
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
                                      builder: (context) => LoginViaSocial()),
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
        padding: const EdgeInsets.only(left: 20, right: 5),
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              debugPrint("Clicked userid ==> ${Constant.userID}");
              debugPrint(
                  "Clicked on link ==> ${sectionDataList?[index].video320.toString()}");

              if (sectionDataList?[index].isLiveUrl == 1) {
                if (Constant.userID == null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginViaSocial()));
                } else {
                  final timestamp = DateTime.now().toIso8601String();
                  final properties = MoEProperties()
                  // ..addAttribute('userName', Constant.userID.toString())
                    ..addAttribute('user_id', Constant.userID.toString())
                    ..addAttribute('stream_id', videoType)
                    ..addAttribute('stream_category', typeId)
                    ..addAttribute('timestamp', timestamp);

                  print(
                      "MoEngage event tracked with Constant userID: ${userMobileNo}");
                  MoEngageService.instance
                      .trackEvent('Live_Stream_Joined', properties);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TestPlayerWeb(
                        loadURL: sectionDataList![index].video320!),
                  ));
                }
              } else {
                openDetailPage(
                  (sectionDataList?[index].videoType ?? 0) == 2
                      ? "showdetail"
                      : "videodetail",
                  sectionDataList?[index].id ?? 0,
                  upcomingType ?? 0,
                  sectionDataList?[index].videoType ?? 0,
                  sectionDataList?[index].typeId ?? 0,
                  sectionDataList?[index].name ?? "",
                );
              }
            },
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                // Background image with gradient overlay for better visibility
                Container(
                  width: Dimens.widthLand,
                  height: Dimens.heightLand,
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
                          imageUrl:
                              sectionDataList?[index].landscape.toString() ??
                                  "",
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

                // Rent Tag
                Visibility(
                  visible: sectionDataList?[index].isRent == 1 &&
                      sectionDataList?[index].isPremium == 0,
                  child: _buildTag('assets/images/rupee.png'),
                ),

                // Premium Tag
                Visibility(
                  visible: sectionDataList?[index].isPremium == 1,
                  child: _buildTag('assets/images/crown.png'),
                ),

                // Both Rent & Premium Tag
                Visibility(
                  visible: sectionDataList?[index].isRent == 1 &&
                      sectionDataList?[index].isPremium == 1,
                  child: _buildTag('assets/images/crown.png'),
                ),

                // Live Indicator
                Visibility(
                  visible: sectionDataList?[index].isLiveUrl == 1,
                  child: Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4)
                        ],
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
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
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
    );
  }

  Widget landscapeTwo(int? upcomingType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLandTwo,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 20, right: 5),
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              debugPrint("Clicked userid ==> ${Constant.userID}");
              debugPrint(
                  "Clicked on link ==> ${sectionDataList?[index].video320.toString()}");

              if (sectionDataList?[index].isLiveUrl == 1) {
                if (Constant.userID == null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginViaSocial()));
                } else {
                  final timestamp = DateTime.now().toIso8601String();
                  final properties = MoEProperties()
                  // ..addAttribute('userName', Constant.userID.toString())
                    ..addAttribute('user_id', Constant.userID.toString())
                    ..addAttribute('stream_id', videoType)
                    ..addAttribute('stream_category', typeId)
                    ..addAttribute('timestamp', timestamp);

                  print(
                      "MoEngage event tracked with Constant userID: ${userMobileNo}");
                  MoEngageService.instance
                      .trackEvent('Live_Stream_Joined', properties);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TestPlayerWeb(
                        loadURL: sectionDataList![index].video320!),
                  ));
                }
              } else {
                openDetailPage(
                  (sectionDataList?[index].videoType ?? 0) == 2
                      ? "showdetail"
                      : "videodetail",
                  sectionDataList?[index].id ?? 0,
                  upcomingType ?? 0,
                  sectionDataList?[index].videoType ?? 0,
                  sectionDataList?[index].typeId ?? 0,
                  sectionDataList?[index].name ?? "",
                );
              }
            },
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                // Background image with gradient overlay for better visibility
                Container(
                  width: Dimens.widthLandTwo,
                  height: Dimens.heightLandTwo,
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
                          imageUrl:
                              sectionDataList?[index].landscape1.toString() ??
                                  "",
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

                // Rent Tag
                Visibility(
                  visible: sectionDataList?[index].isRent == 1 &&
                      sectionDataList?[index].isPremium == 0,
                  child: _buildTag('assets/images/rupee.png'),
                ),

                // Premium Tag
                Visibility(
                  visible: sectionDataList?[index].isPremium == 1,
                  child: _buildTag('assets/images/crown.png'),
                ),

                // Both Rent & Premium Tag
                Visibility(
                  visible: sectionDataList?[index].isRent == 1 &&
                      sectionDataList?[index].isPremium == 1,
                  child: _buildTag('assets/images/crown.png'),
                ),

                // Live Indicator
                Visibility(
                  visible: sectionDataList?[index].isLiveUrl == 1,
                  child: Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4)
                        ],
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
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
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
    );
  }

  Widget portrait(int? upcomingType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightPort,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 20, right: 5),
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              debugPrint("Clicked userid ==> ${Constant.userID}");
              debugPrint(
                  "Clicked on link ==> ${sectionDataList?[index].video320.toString()}");

              if (sectionDataList?[index].isLiveUrl == 1) {
                if (Constant.userID == null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginViaSocial()));
                } else {
                  final timestamp = DateTime.now().toIso8601String();
                  final properties = MoEProperties()
                  // ..addAttribute('userName', Constant.userID.toString())
                    ..addAttribute('user_id', userMobileNo)
                    ..addAttribute('stream_id', videoType)
                    ..addAttribute('stream_category', typeId)
                    ..addAttribute('timestamp', timestamp);

                  print(
                      "MoEngage event tracked with Constant userID: ${userMobileNo}");
                  MoEngageService.instance
                      .trackEvent('Live_Stream_Joined', properties);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TestPlayerWeb(
                        loadURL: sectionDataList![index].video320!),
                  ));
                }
              } else {
                openDetailPage(
                  (sectionDataList?[index].videoType ?? 0) == 2
                      ? "showdetail"
                      : "videodetail",
                  sectionDataList?[index].id ?? 0,
                  upcomingType ?? 0,
                  sectionDataList?[index].videoType ?? 0,
                  sectionDataList?[index].typeId ?? 0,
                  sectionDataList?[index].name ?? "",
                );
              }
            },
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                // Background image with gradient overlay for better visibility
                Container(
                  width: Dimens.widthPort,
                  height: Dimens.heightPort,
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
                          imageUrl:
                              sectionDataList?[index].thumbnail.toString() ??
                                  "",
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

                // Rent Tag
                Visibility(
                  visible: sectionDataList?[index].isRent == 1 &&
                      sectionDataList?[index].isPremium == 0,
                  child: _buildTag('assets/images/rupee.png'),
                ),

                // Premium Tag
                Visibility(
                  visible: sectionDataList?[index].isPremium == 1,
                  child: _buildTag('assets/images/crown.png'),
                ),

                // Both Rent & Premium Tag
                Visibility(
                  visible: sectionDataList?[index].isRent == 1 &&
                      sectionDataList?[index].isPremium == 1,
                  child: _buildTag('assets/images/crown.png'),
                ),

                // Live Indicator
                Visibility(
                  visible: sectionDataList?[index].isLiveUrl == 1,
                  child: Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4)
                        ],
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
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
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
    );
  }

// Tag Widget for Rent & Premium badges
  Widget _buildTag(String iconPath) {
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
          iconPath,
          height: 16,
          width: 16,
        ),
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
        padding: const EdgeInsets.only(left: 20, right: 5),
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              debugPrint("Clicked userid ==> ${Constant.userID}");
              debugPrint(
                  "Clicked on link ==> ${sectionDataList?[index].video320.toString()}");

              if (sectionDataList?[index].isLiveUrl == 1) {
                if (Constant.userID == null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginViaSocial()));
                } else {
                  final timestamp = DateTime.now().toIso8601String();
                  final properties = MoEProperties()
                  // ..addAttribute('userName', Constant.userID.toString())
                    ..addAttribute('user_id', userMobileNo)
                    ..addAttribute('stream_id', videoType)
                    ..addAttribute('stream_category', typeId)
                    ..addAttribute('timestamp', timestamp);

                  print(
                      "MoEngage event tracked with Constant userID: ${userMobileNo}");
                  MoEngageService.instance
                      .trackEvent('Live_Stream_Joined', properties);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TestPlayerWeb(
                        loadURL: sectionDataList![index].video320!),
                  ));
                }
              } else {
                openDetailPage(
                  (sectionDataList?[index].videoType ?? 0) == 2
                      ? "showdetail"
                      : "videodetail",
                  sectionDataList?[index].id ?? 0,
                  upcomingType ?? 0,
                  sectionDataList?[index].videoType ?? 0,
                  sectionDataList?[index].typeId ?? 0,
                  sectionDataList?[index].name ?? "",
                );
              }
            },
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                // Background image with gradient overlay for better visibility
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
                          imageUrl:
                              sectionDataList?[index].thumbnail1.toString() ??
                                  "",
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

                // Rent Tag
                Visibility(
                  visible: sectionDataList?[index].isRent == 1 &&
                      sectionDataList?[index].isPremium == 0,
                  child: _buildTag('assets/images/rupee.png'),
                ),

                // Premium Tag
                Visibility(
                  visible: sectionDataList?[index].isPremium == 1,
                  child: _buildTag('assets/images/crown.png'),
                ),

                // Both Rent & Premium Tag
                Visibility(
                  visible: sectionDataList?[index].isRent == 1 &&
                      sectionDataList?[index].isPremium == 1,
                  child: _buildTag('assets/images/crown.png'),
                ),

                // Live Indicator
                Visibility(
                  visible: sectionDataList?[index].isLiveUrl == 1,
                  child: Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4)
                        ],
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
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
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
        padding: const EdgeInsets.only(left: 20, right: 5),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
              //focusColor:: white,
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                debugPrint("Clicked userid ==> ${Constant.userID}");
                debugPrint(
                    "Clicked on link is  ==> ${sectionDataList?[index].video320.toString()}");
                if (sectionDataList?[index].isLiveUrl == 1) {
                  if (Constant.userID == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginViaSocial()),
                    );
                  } else {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => PlayerVideo('', 0, 0, typeId, 0,
                    //           sectionDataList?[index].video320, 0, "", "")),
                    // );

                    final timestamp = DateTime.now().toIso8601String();
                    final properties = MoEProperties()
                    // ..addAttribute('userName', Constant.userID.toString())
                      ..addAttribute('user_id', Constant.userID.toString())
                      ..addAttribute('stream_id', videoType)
                      ..addAttribute('stream_category', typeId)
                      ..addAttribute('timestamp', timestamp);

                    print(
                        "MoEngage event tracked with Constant userID: ${userMobileNo}");
                    MoEngageService.instance
                        .trackEvent('Live_Stream_Joined', properties);                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TestPlayerWeb(
                            loadURL: sectionDataList![index].video320!)));
                  }
                } else {
                  openDetailPage(
                    (sectionDataList?[index].videoType ?? 0) == 2
                        ? "showdetail"
                        : "videodetail",
                    sectionDataList?[index].id ?? 0,
                    upcomingType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
                    sectionDataList?[index].name ?? 0,
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
              //       MaterialPageRoute(builder: (context) => LoginViaSocial()),
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
                    visible: sectionDataList?[index].isLiveUrl == 1,
                    child: FittedBox(
                      child: Container(
                          constraints: const BoxConstraints(
                            minHeight: 15,
                            minWidth: 30,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(5),
                          // decoration: const BoxDecoration(
                          //   color: colorPrimary,
                          //   borderRadius: BorderRadius.only(
                          //       topLeft: Radius.circular(3),
                          //       topRight: Radius.circular(4),
                          //       bottomLeft: Radius.circular(8),
                          //       bottomRight: Radius.circular(3)),
                          // ),
                          child: Row(
                            children: [
                              Container(
                                height: 5,
                                width: 5,
                                margin: EdgeInsets.only(right: 3),
                                decoration: BoxDecoration(
                                  color: redColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              Text(
                                "LIVE",
                                style: TextStyle(
                                    color: redColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700),
                              )
                            ],
                          )),
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
                            color: otherIcons,
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
                            color: otherIcons,
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
                            color: otherIcons,
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
        padding: const EdgeInsets.only(left: 20, right: 5),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              InkWell(
                //focusColor:: white,
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
        padding: const EdgeInsets.only(left: 20, right: 5),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              InkWell(
                //focusColor:: white,
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
        padding: const EdgeInsets.only(left: 20, right: 5),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              InkWell(
                //focusColor:: white,
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
    getAdaptiveTextSize(BuildContext context, double value) {
      if (kIsWeb || Constant.isTV) {
        return (value / 650) *
            min(MediaQuery.of(context).size.height,
                MediaQuery.of(context).size.width);
      } else {
        return (value / 720 * MediaQuery.of(context).size.height);
      }
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightTopTen, // Adjusted for better visibility
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, right: 5),
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              debugPrint("Clicked on: ${sectionDataList?[index].video320}");

              if (sectionDataList?[index].isLiveUrl == 1) {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginViaSocial()),
                  );
                } else {
                  final timestamp = DateTime.now().toIso8601String();
                  final properties = MoEProperties()
                  // ..addAttribute('userName', Constant.userID.toString())
                    ..addAttribute('user_id', Constant.userID.toString())
                    ..addAttribute('stream_id', videoType)
                    ..addAttribute('stream_category', typeId)
                    ..addAttribute('timestamp', timestamp);

                  print(
                      "MoEngage event tracked with Constant userID: ${userMobileNo}");
                  MoEngageService.instance
                      .trackEvent('Live_Stream_Joined', properties);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TestPlayerWeb(
                        loadURL: sectionDataList![index].video320!,
                      ),
                    ),
                  );
                }
              } else {
                openDetailPage(
                  (sectionDataList?[index].videoType ?? 0) == 2
                      ? "showdetail"
                      : "videodetail",
                  sectionDataList?[index].id ?? 0,
                  upcomingType ?? 0,
                  sectionDataList?[index].videoType ?? 0,
                  sectionDataList?[index].typeId ?? 0,
                  sectionDataList?[index].name ?? "",
                );
              }
            },
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  width: Dimens.widthTopTen,
                  height: Dimens.heightTopTen,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 5,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: MyNetworkImage(
                      imageUrl: sectionDataList?[index].thumbnail1 ?? "",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Rent Tag
                Visibility(
                  visible: sectionDataList?[index].isRent == 1 &&
                      sectionDataList?[index].isPremium == 0,
                  child: _buildTag('assets/images/rupee.png'),
                ),
                // Premium Tag
                Visibility(
                  visible: sectionDataList?[index].isPremium == 1,
                  child: _buildTag('assets/images/crown.png'),
                ),

                // Both Rent & Premium Tag
                Visibility(
                  visible: sectionDataList?[index].isRent == 1 &&
                      sectionDataList?[index].isPremium == 1,
                  child: _buildTag('assets/images/crown.png'),
                ),

                // Live Indicator
                Visibility(
                  visible: sectionDataList?[index].isLiveUrl == 1,
                  child: Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4)
                        ],
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
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                              75,
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
            ),
          );
        },
      ),
    );
  }

  // Widget topTenLayout(int? upcomingType, List<Datum>? sectionDataList) {
  //   getAdaptiveTextSize(BuildContext context, dynamic value) {
  //     if (kIsWeb || Constant.isTV) {
  //       return (value / 650) *
  //           min(MediaQuery.of(context).size.height,
  //               MediaQuery.of(context).size.width);
  //     } else {
  //       return (value / 720 * MediaQuery.of(context).size.height);
  //     }
  //   }

  //   return Container(
  //     width: MediaQuery.of(context).size.width,
  //     height: Dimens.heightTopTen,
  //     child: ListView.separated(
  //       itemCount: sectionDataList?.length ?? 0,
  //       shrinkWrap: true,
  //       physics: const AlwaysScrollableScrollPhysics(),
  //       padding: const EdgeInsets.only(left: 20, right: 5),
  //       scrollDirection: Axis.horizontal,
  //       separatorBuilder: (context, index) => const SizedBox(width: 1),
  //       itemBuilder: (BuildContext context, int index) {
  //         return Stack(
  //           children: [
  //             InkWell(
  //                 //focusColor:: white,
  //                 borderRadius: BorderRadius.circular(4),
  //                 onTap: () {
  //                   debugPrint("Clicked userid ==> ${Constant.userID}");
  //                   debugPrint(
  //                       "Clicked on link is  ==> ${sectionDataList?[index].video320.toString()}");
  //                   if (sectionDataList?[index].isLiveUrl == 1) {
  //                     if (Constant.userID == null) {
  //                       Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                             builder: (context) => LoginViaSocial()),
  //                       );
  //                     } else {
  //                       // Navigator.push(
  //                       //   context,
  //                       //   MaterialPageRoute(
  //                       //       builder: (context) => PlayerVideo(
  //                       //           '',
  //                       //           0,
  //                       //           0,
  //                       //           typeId,
  //                       //           0,
  //                       //           sectionDataList?[index].video320,
  //                       //           0,
  //                       //           "",
  //                       //           "")),
  //                       // );
  //                       Navigator.of(context).push(MaterialPageRoute(
  //                           builder: (context) => TestPlayerWeb(
  //                               loadURL: sectionDataList![index].video320!)));
  //                     }
  //                   } else {
  //                     openDetailPage(
  //                       (sectionDataList?[index].videoType ?? 0) == 2
  //                           ? "showdetail"
  //                           : "videodetail",
  //                       sectionDataList?[index].id ?? 0,
  //                       upcomingType ?? 0,
  //                       sectionDataList?[index].videoType ?? 0,
  //                       sectionDataList?[index].typeId ?? 0,
  //                     );
  //                   }
  //                 },
  //                 child: Padding(
  //                   padding: const EdgeInsets.only(left: 18),
  //                   child: Container(
  //                     width: Dimens.widthTopTen,
  //                     height: Dimens.heightTopTen,
  //                     alignment: Alignment.center,
  //                     padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
  //                     child: Stack(
  //                       alignment: Alignment.topRight,
  //                       children: [
  //                         Container(
  //                           width: 100,
  //                           child: ClipRRect(
  //                             borderRadius: BorderRadius.circular(4),
  //                             clipBehavior: Clip.antiAliasWithSaveLayer,
  //                             child: MyNetworkImage(
  //                               imageUrl: sectionDataList?[index]
  //                                       .thumbnail1
  //                                       .toString() ??
  //                                   "",
  //                               fit: BoxFit.fill,
  //                               imgHeight: MediaQuery.of(context).size.height,
  //                               imgWidth: MediaQuery.of(context).size.width,
  //                             ),
  //                           ),
  //                         ),
  //                         // Rent Tag
  //                         // Visibility(
  //                         //   visible: sectionDataList?[index].isRent == 1 &&
  //                         //       sectionDataList?[index].isPremium == 0,
  //                         //   child: _buildTag('assets/images/rupee.png'),
  //                         // ),

  //                         // // Premium Tag
  //                         // Visibility(
  //                         //   visible: sectionDataList?[index].isPremium == 1,
  //                         //   child: _buildTag('assets/images/crown.png'),
  //                         // ),

  //                         // // Both Rent & Premium Tag
  //                         // Visibility(
  //                         //   visible: sectionDataList?[index].isRent == 1 &&
  //                         //       sectionDataList?[index].isPremium == 1,
  //                         //   child: _buildTag('assets/images/crown.png'),
  //                         // ),

  //                         // // Live Indicator
  //                         // Visibility(
  //                         //   visible: sectionDataList?[index].isLiveUrl == 1,
  //                         //   child: Positioned(
  //                         //     top: 8,
  //                         //     right: 8,
  //                         //     child: Container(
  //                         //       padding: const EdgeInsets.symmetric(
  //                         //           horizontal: 8, vertical: 4),
  //                         //       decoration: BoxDecoration(
  //                         //         color.xml: Colors.red,
  //                         //         borderRadius: BorderRadius.circular(12),
  //                         //         boxShadow: [
  //                         //           BoxShadow(color.xml: Colors.black26, blurRadius: 4)
  //                         //         ],
  //                         //       ),
  //                         //       child: Row(
  //                         //         children: [
  //                         //           Container(
  //                         //             height: 6,
  //                         //             width: 6,
  //                         //             margin: const EdgeInsets.only(right: 5),
  //                         //             decoration: BoxDecoration(
  //                         //               color.xml: Colors.white,
  //                         //               borderRadius: BorderRadius.circular(10),
  //                         //             ),
  //                         //           ),
  //                         //           const Text(
  //                         //             "LIVE",
  //                         //             style: TextStyle(
  //                         //                 color.xml: Colors.white,
  //                         //                 fontSize: 12,
  //                         //                 fontWeight: FontWeight.bold),
  //                         //           ),
  //                         //         ],
  //                         //       ),
  //                         //     ),
  //                         //   ),
  //                         // ),
  //                       ],
  //                     ),
  //                   ),
  //                 )),
  //             Positioned(
  //               left: 0,
  //               bottom: -18,
  //               child: Container(
  //                 child: RichText(
  //                   text: TextSpan(children: <TextSpan>[
  //                     TextSpan(
  //                       text: '${index + 1} ',
  //                       style: GoogleFonts.outfit(
  //                         fontSize: getAdaptiveTextSize(
  //                           context,
  //                           60,
  //                         ),
  //                         fontStyle: FontStyle.normal,
  //                         color.xml: topTen,
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                   ]),
  //                 ),
  //               ),
  //             )
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget browseByArtistLayout(int? typeId, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightArtist,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 5),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Column(
            // alignment: AlignmentDirectional.bottomStart,
            children: [
              InkWell(
                //focusColor:: white,
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

  /* ========= Open Player ========= */
  openPlayer(String playType, int index,
      List<ContinueWatching>? continueWatchingList) async {
    debugPrint("index ==========> $index");

    /* CHECK SUBSCRIPTION */
    if (playType != "Trailer") {
      bool? isPrimiumUser =
          await _checkSubsRentLogin(index, continueWatchingList);
      debugPrint("isPrimiumUser =============> $isPrimiumUser");
      if (!isPrimiumUser) return;
    }
    /* CHECK SUBSCRIPTION */

    /* Set-up Quality URLs */
    Utils.setQualityURLs(
      video320: (continueWatchingList?[index].video320 ?? ""),
      video480: (continueWatchingList?[index].video480 ?? ""),
      video720: (continueWatchingList?[index].video720 ?? ""),
      video1080: (continueWatchingList?[index].video1080 ?? ""),
    );

    if (!mounted) return;

    dynamic isContinue = await Utils.openPlayer(
      context: context,
      playType:
          (continueWatchingList?[index].videoType ?? 0) == 2 ? "Show" : "Video",
      videoId: (continueWatchingList?[index].videoType ?? 0) == 2
          ? (continueWatchingList?[index].showId ?? 0)
          : (continueWatchingList?[index].id ?? 0),
      videoType: continueWatchingList?[index].videoType ?? 0,
      typeId: continueWatchingList?[index].typeId ?? 0,
      otherId: continueWatchingList?[index].typeId ?? 0,
      videoUrl: continueWatchingList?[index].video320 ?? "",
      trailerUrl: continueWatchingList?[index].trailerUrl ?? "",
      uploadType: continueWatchingList?[index].videoUploadType ?? "",
      videoThumb: continueWatchingList?[index].landscape ?? "",
      vStopTime: continueWatchingList?[index].stopTime ?? 0,
    );
    debugPrint("isContinue ===> $isContinue");
    if (isContinue != null && isContinue == true) {
      getTabData(0, homeProvider.sectionTypeModel.result);
      Future.delayed(Duration.zero).then((value) {
        if (!mounted) return;
        setState(() {});
      });
    }
  }

  Future<bool> _checkSubsRentLogin(
      int index, List<ContinueWatching>? continueWatchingList) async {
    if (Constant.userID != null) {
      if ((continueWatchingList?[index].isPremium ?? 0) == 1 &&
          (continueWatchingList?[index].isRent ?? 0) == 1) {
        if ((continueWatchingList?[index].isBuy ?? 0) == 1 ||
            (continueWatchingList?[index].rentBuy ?? 0) == 1) {
          return true;
        } else {
          dynamic isSubscribed = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const Subscription();
              },
            ),
          );
          if (isSubscribed != null && isSubscribed == true) {
            _getData();
          }
          return false;
        }
      } else if ((continueWatchingList?[index].isPremium ?? 0) == 1) {
        if ((continueWatchingList?[index].isBuy ?? 0) == 1) {
          return true;
        } else {
          dynamic isSubscribed = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const Subscription();
              },
            ),
          );
          if (isSubscribed != null && isSubscribed == true) {
            _getData();
          }
          return false;
        }
      } else if ((continueWatchingList?[index].isRent ?? 0) == 1) {
        if ((continueWatchingList?[index].rentBuy ?? 0) == 1) {
          return true;
        } else {
          dynamic isRented = await Utils.paymentForRent(
            context: context,
            videoId: continueWatchingList?[index].id.toString() ?? '',
            rentPrice: continueWatchingList?[index].rentPrice.toString() ?? '',
            vTitle: continueWatchingList?[index].name.toString() ?? '',
            typeId: continueWatchingList?[index].typeId.toString() ?? '',
            vType: continueWatchingList?[index].videoType.toString() ?? '',
          );
          if (isRented != null && isRented == true) {
            _getData();
          }
          return false;
        }
      } else {
        return true;
      }
    } else {
      if ((kIsWeb || Constant.isTV)) {
        Utils.buildWebAlertDialog(context, "login", "")
            .then((value) => _getData());
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
  /* ========= Open Player ========= */
}
