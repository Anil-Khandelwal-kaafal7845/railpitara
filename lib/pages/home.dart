import 'dart:async';
import 'dart:io';
import 'dart:math';
// import 'package:dtlive/web_js/js_helper.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dtlive/pages/find.dart';
import 'package:dtlive/pages/loginsocial.dart';
import 'package:dtlive/pages/morescreen.dart';
import 'package:dtlive/pages/mypurchaselist.dart';
import 'package:dtlive/players/player_video.dart';
import 'package:dtlive/pages/profileedit.dart';
import 'package:dtlive/pages/videosbyartist.dart';
import 'package:dtlive/pages/videosbyid.dart';
import 'package:dtlive/provider/findprovider.dart';
import 'package:dtlive/shimmer/shimmerutils.dart';
import 'package:dtlive/subscription/subscription.dart';
import 'package:dtlive/utils/adhelper.dart';
import 'package:dtlive/utils/sharedpre.dart';
import 'package:dtlive/webwidget/commonappbar.dart';
import 'package:dtlive/webwidget/footerweb.dart';
import 'package:dtlive/model/sectionlistmodel.dart';
import 'package:dtlive/model/sectiontypemodel.dart' as type;
import 'package:dtlive/model/sectionlistmodel.dart' as list;
import 'package:dtlive/model/sectionbannermodel.dart' as banner;
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/dimens.dart';
import 'package:dtlive/widget/nodata.dart';
import 'package:dtlive/provider/homeprovider.dart';
import 'package:dtlive/provider/sectiondataprovider.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/widget/myimage.dart';
import 'package:dtlive/widget/mytext.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/widget/mynetworkimg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/force_update_model.dart';
import '../webservice/apiservices.dart';
import '../provider/generalprovider.dart';
import '../provider/profileprovider.dart';
import '../utils/strings.dart';
import 'aboutprivacyterms.dart';
import 'mydownloads.dart';
import 'mywatchlist.dart';
import 'pip_web_player.dart';

class Home extends StatefulWidget {
  final String? pageName;
  const Home({Key? key, required this.pageName}) : super(key: key);

  @override
  State<Home> createState() => HomeState();
}

ForceUpdatemodel? forceUpdateData;

class HomeState extends State<Home> {
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

    isSwitched = await sharedPref.readBool("PUSH");
    debugPrint('getUserData isSwitched ==> $isSwitched');
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void initState() {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    getUserData();

    fetchForceUpdateData();

    sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    findProvider = Provider.of<FindProvider>(context, listen: false);
    observerController =
        ListObserverController(controller: tabScrollController);
    currentPage = widget.pageName ?? "";
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
    if (!kIsWeb) {
      OneSignal.Notifications.addClickListener(_handleNotificationOpened);
    }
  }

  fetchForceUpdateData() async {
    await HomeScreenRepo().forceUpdateApi(context).then((value) {
      setState(() {
        forceUpdateData = value;
        updateLoading = false;
      });
      checkForUpdate();
    });
  }

  checkForUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    if ((Platform.isAndroid
            ? forceUpdateData!.result!.appVersion!
            : forceUpdateData!.result!.appVersionIos!) >
        num.parse(packageInfo.buildNumber)) {
      showDialog(
        barrierDismissible:
            forceUpdateData!.result!.forceUpdateAndroid == 1 ? false : true,
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async =>
                false, // prevent dialog from dismissing on back button press
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
                      visible: forceUpdateData!.result!.forceUpdateAndroid == 0
                          ? true
                          : false,
                      child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel")),
                    ),
                    TextButton(
                        onPressed: () {
                          if (Platform.isAndroid || Platform.isIOS) {
                            final appId = Platform.isAndroid
                                ? Constant.appPackageName
                                : Constant.appleAppId;
                            final url = Uri.parse(
                              Platform.isAndroid
                                  ? "market://details?id=$appId"
                                  : "https://apps.apple.com/app/id$appId",
                            );
                            launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        child: const Text("UPDATE")),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
  }

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
    await homeProvider.setLoading(true);
    await homeProvider.getSectionType();
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

  openDetailPage(String pageName, int videoId, int upcomingType, int videoType,
      int typeId) async {
    debugPrint("pageName =======> $pageName");
    debugPrint("videoId ========> $videoId");
    debugPrint("upcomingType ===> $upcomingType");
    debugPrint("videoType ======> $videoType");
    debugPrint("typeId =========> $typeId");
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

  // _redirectToUrl(loadingUrl) async {
  //   debugPrint("loadingUrl -----------> $loadingUrl");
  //   /*
  //     _blank => open new Tab
  //     _self => open in current Tab
  //   */
  //   String dataFromJS = await _jsHelper.callOpenTab(loadingUrl, '_blank');
  //   debugPrint("dataFromJS -----------> $dataFromJS");
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
    super.dispose();
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
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Navigator.of(context)
      //     //     .push(MaterialPageRoute(builder: (context) => PIPExampleApp()));
      //     Navigator.of(context).push(MaterialPageRoute(
      //         builder: (context) => TestPlayerWeb(
      //             loadURL:
      //                 "https://iframe.mediadelivery.net/embed/135513/fe5da825-ffd0-4ba4-85b5-893c4001d059?autoplay=true&loop=false&muted=false&preload=true&responsive=true")));
      //   },
      // ),
      key: _scaffoldKey,
      backgroundColor: appBgColor,
      appBar: AppBar(
        surfaceTintColor: appBgColor,
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset(
            "assets/images/ic_channels.png",
            width: 17,
            height: 17,
            color: white,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Find()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Image.asset(
                "assets/images/ic_find.png",
                width: 17,
                height: 17,
                color: white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: PopupMenuButton<type.Result>(
              offset: const Offset(0, 70),
              color: Colors.black54,
              itemBuilder: (context) {
                List<bool> tempSelectedLanguages = List.generate(
                  findProvider.langaugeModel.result!.length,
                  (index) => selectedLanguages[index],
                );
                return [
                  PopupMenuItem(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.55, // Adjust width here
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              for (int i = 0;
                                  i < findProvider.langaugeModel.result!.length;
                                  i++)
                                Theme(
                                  data: ThemeData(
                                    unselectedWidgetColor: Colors.white,
                                  ),
                                  child: CheckboxListTile(
                                    title: Text(
                                      findProvider
                                          .langaugeModel.result![i].name!,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                    value: tempSelectedLanguages[i],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        tempSelectedLanguages[i] = value!;
                                      });
                                    },
                                    autofocus: true,
                                    activeColor: primaryDark,
                                  ),
                                ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: primaryDark,
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedLanguages =
                                        List.from(tempSelectedLanguages);
                                  });
                                  selectedLanguageIds.clear();
                                  for (int i = 0;
                                      i < tempSelectedLanguages.length;
                                      i++) {
                                    if (tempSelectedLanguages[i]) {
                                      selectedLanguageIds.add(
                                        findProvider.langaugeModel.result![i].id
                                            .toString(),
                                      );
                                    }
                                  }
                                  getTabData(
                                    homeProvider.selectedIndex,
                                    homeProvider.sectionTypeModel.result,
                                  );
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ];
              },
              child: Image.asset(
                "assets/images/ic_language.png",
                width: 20,
                height: 20,
                color: white,
              ),
            ),
          )
        ],
        title: MyImage(width: 90, height: 90, imagePath: "appicon.png"),
        backgroundColor: Colors.black,
      ),
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor:
              appBgColor, //This will change the drawer background to blue.
          //other styles
        ),
        child: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 180,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: appBgColor,
                  ),
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: MyImage(
                        width: 50, height: 50, imagePath: "appicon.png"),
                  ),
                ),
              ),
              ListTile(
                title: Column(
                  children: [
                    _buildLine(),

                    /* Account Details */
                    _buildSettingButton(
                      title: 'accountdetails',
                      // subTitle: 'manageprofile',
                      titleMultilang: true,
                      subTitleMultilang: true,
                      onClick: () {
                        AdHelper.showFullscreenAd(
                            context, Constant.rewardAdType, () async {
                          if (Constant.userID != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ProfileEdit(),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginSocial(),
                              ),
                            );
                          }
                        });
                      },
                    ),
                    // _buildLine(),
                    // _buildLine(16.0, 16.0),

                    // /* Active TV */
                    // _buildSettingButton(
                    //   title: 'activetv',
                    //   // subTitle: 'activetv_desc',
                    //   titleMultilang: true,
                    //   subTitleMultilang: true,
                    //   onClick: () {
                    //     AdHelper.showFullscreenAd(
                    //         context, Constant.rewardAdType, () async {
                    //       if (Constant.userID != null) {
                    //         Navigator.of(context).push(
                    //           MaterialPageRoute(
                    //             builder: (context) => const ActiveTV(),
                    //           ),
                    //         );
                    //       } else {
                    //         Navigator.of(context).push(
                    //           MaterialPageRoute(
                    //             builder: (context) => const LoginSocial(),
                    //           ),
                    //         );
                    //       }
                    //     });
                    //   },
                    // ),
                    // // _buildLine(),

                    /* Watchlist */
                    _buildSettingButton(
                      title: 'watchlist',
                      // subTitle: 'view_your_watchlist',
                      titleMultilang: true,
                      subTitleMultilang: true,
                      onClick: () {
                        AdHelper.showFullscreenAd(
                            context, Constant.rewardAdType, () async {
                          if (Constant.userID != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MyWatchlist(),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginSocial(),
                              ),
                            );
                          }
                        });
                      },
                    ),
                    // _buildLine(),

                    /* Purchases */
                    _buildSettingButton(
                      title: 'purchases',
                      // subTitle: 'view_your_purchases',
                      titleMultilang: true,
                      subTitleMultilang: true,
                      onClick: () {
                        AdHelper.showFullscreenAd(
                            context, Constant.rewardAdType, () async {
                          if (Constant.userID != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MyPurchaselist(),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginSocial(),
                              ),
                            );
                          }
                        });
                      },
                    ),
                    // _buildLine(),

                    /* Downloads */
                    _buildSettingButton(
                      title: 'downloads',
                      // subTitle: 'view_your_downloads',
                      titleMultilang: true,
                      subTitleMultilang: true,
                      onClick: () {
                        AdHelper.showFullscreenAd(
                            context, Constant.rewardAdType, () async {
                          if (Constant.userID != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const MyDownloads(),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginSocial(),
                              ),
                            );
                          }
                        });
                      },
                    ),
                    // _buildLine(),

                    /* Subscription */
                    _buildSettingButton(
                      title: 'subsciption',
                      // subTitle: 'subsciptionnotes',
                      titleMultilang: true,
                      subTitleMultilang: true,
                      onClick: () {
                        AdHelper.showFullscreenAd(
                            context, Constant.rewardAdType, () async {
                          if (Constant.userID != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const Subscription(),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginSocial(),
                              ),
                            );
                          }
                        });
                      },
                    ),
                    // _buildLine(),

                    // /* Transactions */
                    // _buildSettingButton(
                    //   title: 'transactions',
                    //   // subTitle: 'transactions_notes',
                    //   titleMultilang: true,
                    //   subTitleMultilang: true,
                    //   onClick: () {
                    //     AdHelper.showFullscreenAd(
                    //         context, Constant.rewardAdType, () async {
                    //       if (Constant.userID != null) {
                    //         Navigator.of(context).push(
                    //           MaterialPageRoute(
                    //             builder: (context) =>
                    //                 const SubscriptionHistory(),
                    //           ),
                    //         );
                    //       } else {
                    //         Navigator.of(context).push(
                    //           MaterialPageRoute(
                    //             builder: (context) => const LoginSocial(),
                    //           ),
                    //         );
                    //       }
                    //     });
                    //   },
                    // ),
                    // // _buildLine(),

                    /* MaltiLanguage */
                    _buildSettingButton(
                      title: 'change_language',
                      // subTitle: 'change_language_desc',
                      titleMultilang: true,
                      subTitleMultilang: true,
                      onClick: () {
                        _languageChangeDialog();
                      },
                    ),
                    // _buildLine(),

                    // /* Push Notification enable/disable */
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.center,
                    //   children: [
                    //     Expanded(
                    //       child: _buildSettingButton(
                    //         title: 'notification',
                    //         // subTitle: 'recivepushnotification',
                    //         titleMultilang: true,
                    //         subTitleMultilang: true,
                    //         onClick: () {
                    //           toggleSwitch(!(isSwitched ?? false));
                    //         },
                    //       ),
                    //     ),
                    //     Switch(
                    //       activeColor: primaryDark,
                    //       activeTrackColor: primaryLight,
                    //       inactiveTrackColor: gray,
                    //       value: isSwitched ?? true,
                    //       onChanged: toggleSwitch,
                    //     ),
                    //   ],
                    // ),
                    // // _buildLine(),

                    // /* Clear Cache */
                    // if (!Platform.isIOS)
                    //   Row(
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: [
                    //       Expanded(
                    //         child: _buildSettingButton(
                    //           title: 'clearcatch',
                    //           // subTitle: 'clearlocallycatch',
                    //           titleMultilang: true,
                    //           subTitleMultilang: true,
                    //           onClick: () async {
                    //             if (!(kIsWeb) || !(Constant.isTV)) {
                    //               Utils.deleteCacheDir();
                    //             }
                    //             if (!mounted) return;
                    //             Utils.showSnackbar(
                    //                 context, "success", "cacheclearmsg", true);
                    //           },
                    //         ),
                    //       ),
                    //       MyImage(
                    //         width: 28,
                    //         height: 28,
                    //         imagePath: "ic_clear.png",
                    //         color: colorPrimary,
                    //       ),
                    //     ],
                    //   ),
                    // if (!Platform.isIOS)
                    //   //  _buildLine(),

                    /* SignIn / SignOut */
                    _buildSettingButton(
                      title: Constant.userID == null
                          ? youAreNotSignIn
                          : (userType == "3" && (userName ?? "").isEmpty)
                              ? ("$signedInAs ${userMobileNo ?? ""}")
                              : ("$signedInAs ${userName ?? ""}"),
                      // subTitle: Constant.userID == null ? "sign_in" : "sign_out",
                      titleMultilang: false,
                      subTitleMultilang: true,
                      onClick: () async {
                        if (Constant.userID != null) {
                          logoutConfirmDialog();
                        } else {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LoginSocial(),
                            ),
                          );
                          setState(() {});
                        }
                      },
                    ),
                    // _buildLine(),

                    // /* Rate App */
                    // _buildSettingButton(
                    //   title: 'rateus',
                    //   // subTitle: 'rateourapp',
                    //   titleMultilang: true,
                    //   subTitleMultilang: true,
                    //   onClick: () async {
                    //     debugPrint("Clicked on rateApp");
                    //     await Utils.redirectToStore();
                    //   },
                    // ),
                    // // _buildLine(),

                    // /* Share App */
                    // _buildSettingButton(
                    //   title: 'shareapp',
                    //   // subTitle: 'sharewithfriends',
                    //   titleMultilang: true,
                    //   subTitleMultilang: true,
                    //   onClick: () async {
                    //     await Utils.shareApp(Platform.isIOS
                    //         ? Constant.iosAppShareUrlDesc
                    //         : Constant.androidAppShareUrlDesc);
                    //   },
                    // ),
                    // // _buildLine(),

                    // /* Delete Account */
                    // if (Constant.userID != null)
                    //   _buildSettingButton(
                    //     title: 'delete_account',
                    //     // subTitle: 'delete_account_desc',
                    //     titleMultilang: true,
                    //     subTitleMultilang: true,
                    //     onClick: () async {
                    //       if (Constant.userID != null) {
                    //         deleteConfirmDialog();
                    //       } else {
                    //         await Navigator.of(context).push(
                    //           MaterialPageRoute(
                    //             builder: (context) => const LoginSocial(),
                    //           ),
                    //         );
                    //         setState(() {});
                    //       }
                    //     },
                    //   ),
                    // if (Constant.userID != null) _buildLine(),

                    // /* Pages */
                    // _buildPages(),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildLine(),
                    const SizedBox(
                      height: 10,
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          socialMediaIcon(
                            imageUrl: 'assets/images/fb.png',
                            onTap: () {
                              _redirectToUrl(Constant.fbLink);
                            },
                          ),
                          const SizedBox(width: 15),
                          socialMediaIcon(
                            imageUrl: 'assets/images/insta.png',
                            onTap: () {
                              _redirectToUrl(Constant.InstaLink);
                            },
                          ),
                          const SizedBox(width: 15),
                          socialMediaIcon(
                            imageUrl: 'assets/images/twt.png',
                            onTap: () {
                              _redirectToUrl(Constant.twitterLink);
                            },
                          ),
                          const SizedBox(width: 15),
                          socialMediaIcon(
                            imageUrl: 'assets/images/yt.png',
                            onTap: () {
                              _redirectToUrl(Constant.youtubeLink);
                            },
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
        alignment: Alignment.bottomLeft,
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
              initialChildSize: 0.55,
              minChildSize: 0.4,
              maxChildSize: 0.9,
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

                                /* Afrikaans */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Afrikaans",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('af');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Arabic */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Arabic",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('ar');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* German */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "German",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('de');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Spanish */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Spanish",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('es');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* French */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "French",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('fr');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Gujarati */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Gujarati",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('gu');
                                    Navigator.pop(context);
                                  },
                                ),

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

                                /* Indonesian */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Indonesian",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('id');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Dutch */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Dutch",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('nl');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Portuguese (Brazil) */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Portuguese (Brazil)",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('pt');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Albanian */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Albanian",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('sq');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Turkish */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Turkish",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('tr');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Vietnamese */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Vietnamese",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('vi');
                                    Navigator.pop(context);
                                  },
                                ),
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
                                builder: (context) => const LoginSocial(),
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
                                builder: (context) => const LoginSocial(),
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
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          color: black.withOpacity(0.8),
                          child: tabTitle(homeProvider.sectionTypeModel.result),
                        ),
                      ],
                    )
                  : const NoData(title: '', subTitle: '')
              : const NoData(title: '', subTitle: ''),
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
        padding: const EdgeInsets.fromLTRB(13, 2, 13, 2),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              return InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () async {
                    debugPrint("index ===========> $index");
                    AdHelper.showFullscreenAd(
                        context, Constant.interstialAdType, () async {
                      if (kIsWeb) _onItemTapped("");
                      await getTabData(
                          index, homeProvider.sectionTypeModel.result);
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxHeight: 35),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                        child: MyText(
                          color: homeProvider.selectedIndex == index
                              ? colorPrimary
                              : white,
                          multilanguage: false,
                          text: index == 0
                              ? "Home"
                              : index > 0
                                  ? (sectionTypeList?[index - 1]
                                          .name
                                          .toString() ??
                                      "")
                                  : "",
                          fontsizeNormal: 12,
                          fontweight: FontWeight.w700,
                          fontsizeWeb: 14,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ));
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
                    if ((kIsWeb || Constant.isTV) &&
                        MediaQuery.of(context).size.width > 720) {
                      return ShimmerUtils.bannerWeb(context);
                    } else {
                      return ShimmerUtils.bannerMobile(context);
                    }
                  } else {
                    if (sectionDataProvider.sectionBannerModel.status == 200 &&
                        sectionDataProvider.sectionBannerModel.result != null) {
                      if ((kIsWeb || Constant.isTV) &&
                          MediaQuery.of(context).size.width > 720) {
                        return _webHomeBanner(
                            sectionDataProvider.sectionBannerModel.result);
                      } else {
                        return _mobileHomeBanner(
                            sectionDataProvider.sectionBannerModel.result);
                      }
                    } else {
                      return const SizedBox.shrink();
                    }
                  }
                },
              ),

              /* AdMob Banner */

              Utils.showBannerAd(context),
              const SizedBox(height: 5.5),

              /* Continue Watching & Remaining Sections */
              Consumer<SectionDataProvider>(
                builder: (context, sectionDataProvider, child) {
                  if (sectionDataProvider.loadingSection) {
                    return sectionShimmer();
                  } else {
                    if (sectionDataProvider.sectionListModel.status == 200) {
                      return Column(
                        children: [
                          // // SizedBox(
                          // //   height: 5,
                          // // ),
                          // /* Continue Watching */
                          (sectionDataProvider
                                      .sectionListModel.continueWatching !=
                                  null)
                              ? continueWatchingLayout(sectionDataProvider
                                  .sectionListModel.continueWatching)
                              : const SizedBox.shrink(),

                          /* Remaining Sections */
                          (sectionDataProvider.sectionListModel.result != null)
                              ? setSectionByType(
                                  sectionDataProvider.sectionListModel.result)
                              : const SizedBox.shrink(),
                        ],
                      );
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

  Widget _mobileHomeBanner(List<banner.Result>? sectionBannerList) {
    if ((sectionBannerList?.length ?? 0) > 0) {
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        clipBehavior: Clip.antiAliasWithSaveLayer,
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
                  await sectionDataProvider.setCurrentBanner(val);
                },
              ),
              itemBuilder:
                  (BuildContext context, int index, int pageViewIndex) {
                return InkWell(
                  focusColor: white,
                  borderRadius: BorderRadius.circular(0),
                  onTap: () {
                    debugPrint("Clicked userid ==> ${Constant.userID}");
                    debugPrint(
                        "Clicked on link is  ==> ${sectionBannerList?[index].video320.toString()}");
                    if (sectionBannerList?[index].isLiveUrl == 1) {
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
                        //           sectionBannerList?[index].videoUrl,
                        //           0,
                        //           "",
                        //           "")),
                        // );
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => TestPlayerWeb(
                                loadURL: sectionBannerList?[index].videoUrl!)));
                      }
                    } else if (sectionBannerList?[index].bannerBacklink !=
                            null &&
                        sectionBannerList![index]
                            .bannerBacklink
                            .toString()
                            .isNotEmpty) {
                      launchUrl(Uri.parse(
                          sectionBannerList[index].bannerBacklink.toString()));
                    } else {
                      openDetailPage(
                        (sectionBannerList?[index].videoType ?? 0) == 2
                            ? "showdetail"
                            : "videodetail",
                        sectionBannerList?[index].id ?? 0,
                        sectionBannerList?[index].upcomingType ?? 0,
                        sectionBannerList?[index].videoType ?? 0,
                        sectionBannerList?[index].typeId ?? 0,
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 2, bottom: 2, left: 10, right: 10),
                    child: Stack(
                      alignment: Alignment.topRight,
                      // alignment: AlignmentDirectional.bottomCenter,
                      children: [
                        SizedBox(
                          height: Dimens.homeBanner,
                          child: MyNetworkImageTwo(
                            imageUrl: sectionBannerList?[index].landscape ?? "",
                            fit: BoxFit.fill,
                          ),
                        ),
                        Visibility(
                          visible: sectionBannerList?[index].isRent == 1 &&
                              sectionBannerList?[index].isPremium == 0,
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
                          visible: sectionBannerList?[index].isPremium == 1,
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
                          visible: sectionBannerList?[index].isRent == 1 &&
                              sectionBannerList?[index].isPremium == 1,
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
                );
              },
            ),
          ),
          const SizedBox(height: 5.5),
          Positioned(
            bottom: 10,
            child: Consumer<SectionDataProvider>(
              builder: (context, sectionDataProvider, child) {
                return AnimatedSmoothIndicator(
                  count: (sectionBannerList?.length ?? 0),
                  activeIndex: sectionDataProvider.cBannerIndex ?? 0,
                  effect: const ScrollingDotsEffect(
                    spacing: 8,
                    radius: 4,
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
              focusColor: white,
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
                      focusColor: white,
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
                        );
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
                                sectionList[index].data);
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
                openDetailPage(
                  (sectionDataList?[index].videoType ?? 0) == 2
                      ? "showdetail"
                      : "videodetail",
                  sectionDataList?[index].id ?? 0,
                  upcomingType ?? 0,
                  sectionDataList?[index].videoType ?? 0,
                  sectionDataList?[index].typeId ?? 0,
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
                openDetailPage(
                  (sectionDataList?[index].videoType ?? 0) == 2
                      ? "showdetail"
                      : "videodetail",
                  sectionDataList?[index].id ?? 0,
                  upcomingType ?? 0,
                  sectionDataList?[index].videoType ?? 0,
                  sectionDataList?[index].typeId ?? 0,
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
                  openDetailPage(
                    (sectionDataList?[index].videoType ?? 0) == 2
                        ? "showdetail"
                        : "videodetail",
                    sectionDataList?[index].id ?? 0,
                    upcomingType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
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
                  openDetailPage(
                    (sectionDataList?[index].videoType ?? 0) == 2
                        ? "showdetail"
                        : "videodetail",
                    sectionDataList?[index].id ?? 0,
                    upcomingType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
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
                  openDetailPage(
                    (sectionDataList?[index].videoType ?? 0) == 2
                        ? "showdetail"
                        : "videodetail",
                    sectionDataList?[index].id ?? 0,
                    upcomingType ?? 0,
                    sectionDataList?[index].videoType ?? 0,
                    sectionDataList?[index].typeId ?? 0,
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
                      openDetailPage(
                        (sectionDataList?[index].videoType ?? 0) == 2
                            ? "showdetail"
                            : "videodetail",
                        sectionDataList?[index].id ?? 0,
                        upcomingType ?? 0,
                        sectionDataList?[index].videoType ?? 0,
                        sectionDataList?[index].typeId ?? 0,
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
    AdHelper.showFullscreenAd(
      context,
      Constant.interstialAdType,
      () async {
        dynamic isContinue = await Utils.openPlayer(
          context: context,
          playType: (continueWatchingList?[index].videoType ?? 0) == 2
              ? "Show"
              : "Video",
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
      },
    );
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
            return const LoginSocial();
          },
        ),
      );
      return false;
    }
  }
  /* ========= Open Player ========= */
}
