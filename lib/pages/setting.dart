
import 'package:dtlive/main.dart';
import 'package:dtlive/pages/aboutprivacyterms.dart';
import 'package:dtlive/pages/coinstorescreen.dart';
import 'package:dtlive/pages/home_screen.dart';
import 'package:dtlive/pages/login_mobile.dart';
import 'package:dtlive/pages/profile_edit.dart';
import 'package:dtlive/pages/mypurchaselist.dart';
import 'package:dtlive/pages/my_watchlist.dart';
import 'package:dtlive/pages/rentstore.dart';
import 'package:dtlive/provider/generalprovider.dart';
import 'package:dtlive/provider/homeprovider.dart';
import 'package:dtlive/provider/profileprovider.dart';
import 'package:dtlive/provider/sectiondataprovider.dart';
import 'package:dtlive/provider/userwallectProvider.dart';
import 'package:dtlive/subscription/subscription.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/dimens.dart';
import 'package:dtlive/utils/sharedpre.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:dtlive/widget/mytext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moengage_flutter/moengage_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:singular_flutter_sdk/singular.dart';

import '../utils/moenage_service.dart';
import '../widget/myusernetworkimg.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => SettingState();
}

class SettingState extends State<Setting> {
  bool? isSwitched;
  String? userName, userType, userMobileNo;
  late GeneralProvider generalProvider;
  SharedPre sharedPref = SharedPre();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late WalletProvider walletProvider;

  @override
  void initState() {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    generalProvider.getGeneralsetting(context);
    getUserData();
    getUserDataProfile();

    super.initState();
    trackMoEngageEventOnce();
  }
  bool _eventTracked = false;

  void trackMoEngageEventOnce() {
    if (_eventTracked) return;
    _eventTracked = true;

    final properties = MoEProperties()
      ..addAttribute('screen_name', 'Setting Screen')
      ..addAttribute('user_id', Constant.userID.toString())
      ..addAttribute('timestamp', DateTime.now().toIso8601String());
    // Optional delay
    Future.delayed(Duration(seconds: 2), () {
      MoEngageService.instance.trackEvent('screen_view', properties);
      // moEngagePlugin();
    });
  }

  void getUserDataProfile() async {
    final profileProvider =
    Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.getProfile(context);
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
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
    debugPrint("isCoinShow ===========> ${generalProvider.isCoinShow}");

    await generalProvider.getPages();

    isSwitched = await sharedPref.readBool("PUSH");
    debugPrint('getUserData isSwitched ==> $isSwitched');
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;

      setState(() {});
      // moEngagePlugin();
    });
  }
  Future<void> moEngagePlugin() async {
    final timestamp = DateTime.now().toIso8601String();
    MoEngageService.instance.setUserName(userName.toString() ?? " ");
    final properties = MoEProperties()
      ..addAttribute('user_id', Constant.userID.toString())
      ..addAttribute('timestamp', timestamp);

    MoEngageService.instance.trackEvent('Profile_Updated', properties);
  }
  @override
  Widget build(BuildContext context) {
    analytics.logEvent(
      name: "screen_view",
      parameters: {
        "screen_name": "Setting screen",
        "user_id": Constant.userID,
      },
    );
    Map<String, Object> screenViewEvent = {
      'screen_name': 'Setting Screen',
      'user_id': Constant.userID.toString(),
    };
    Singular.eventWithArgs('screen_view', screenViewEvent);

    return Scaffold(
      backgroundColor: appBgColor,
      // appBar: Utils.myAppBar(context, "setting", true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.all(22),
            child: Column(
              children: [

                profileCardWidget(
                  userID: Constant.userID,
                  userName: userName,
                  profile: 'H',
                  userMobileNo: userMobileNo,
                  userType: userType,
                  onDeleteAccountPressed: () {
                    if (Constant.userID != null) {
                      deleteConfirmDialog();
                    }
                  },
                  onLoginPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginViaSocial(),
                      ),
                    );
                    setState(() {});
                  },
                  onLogoutPressed: () {
                    MoEngageService.instance.logout();
                    // // Get device ID
                    //
                    // final timestamp = DateTime.now().toIso8601String();
                    //
                    // final properties = MoEProperties()
                    //   ..addAttribute('user_id', Constant.userID.toString())
                    //
                    //   ..addAttribute('timestamp', timestamp);
                    //
                    // MoEngageService.instance.trackEvent('Logout', properties);
                    //
                    // print("userName check ${userName.toString()}");
                    // print(
                    //     "MoEngage event tracked with device ID: and timestamp: $timestamp");
                    if (Constant.userID != null) {
                      logoutConfirmDialog();
                    }
                  },
                  onEditProfilePressed: () {
                    if (Constant.userID != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProfileEdit(),
                        ),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginViaSocial(),
                        ),
                      );
                    }
                  },
                ),
                /* Account Details */
                // Account Details Button On Click

                // _buildSettingButton(
                //   title: 'accountdetails',
                //   subTitle: 'manageprofile',
                //   titleMultilang: true,
                //   subTitleMultilang: true,
                //   onClick: () {
                //     // AdHelper.showFullscreenAd(context, Constant.rewardAdType,
                //     //     () async {
                //     if (Constant.userID != null) {
                //       Navigator.of(context).push(
                //         MaterialPageRoute(
                //           builder: (context) => const ProfileEdit(),
                //         ),
                //       );
                //     } else {
                //       Navigator.of(context).push(
                //         MaterialPageRoute(
                //           builder: (context) => const LoginViaSocial(),
                //         ),
                //       );
                //     }
                //   },
                // ),

                // Visibility(
                //   visible: forceUpdateData!.result!.showPackage == 1,
                //   child: _buildLine(7.0, 7.0),
                // ),

                Visibility(
                  visible: forceUpdateData?.result?.showPackage == 1,
                  child: _buildSettingButton(
                    title: 'rent_store',
                    subTitle: 'view_your_rentvideo',
                    // title: 'watchlist',
                    // subTitle: 'view_your_watchlist',
                    titleMultilang: true,
                    subTitleMultilang: true,
                    onClick: () {
                      if (Constant.userID != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RentStore(),
                            // builder: (context) => const MyWatchlist(),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginViaSocial(),
                          ),
                        );
                      }
                    },
                  ),
                ),

                Visibility(
                    visible: forceUpdateData?.result?.showPackage == 1,

                    child: _buildLine(7.0, 7.0),
                ),

                /* Watchlist */
                _buildSettingButton(
                  title: 'watchlist',
                  subTitle: 'view_your_watchlist',
                  titleMultilang: true,
                  subTitleMultilang: true,
                  onClick: () {
                    if (Constant.userID != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MyWatchlist(),
                        ),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginViaSocial(),
                        ),
                      );
                    }
                  },
                ),
                _buildLine(7.0, 7.0),

                /* Purchases */
                Visibility(
                  visible: forceUpdateData?.result?.showPackage == 1,

                  child: _buildSettingButton(
                    title: 'purchases',
                    subTitle: 'view_your_purchases',
                    titleMultilang: true,
                    subTitleMultilang: true,
                    onClick: () {
                      if (Constant.userID != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MyPurchaselist(),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginViaSocial(),
                          ),
                        );
                      }
                    },
                  ),
                ),

                Visibility(
                    visible: forceUpdateData?.result?.showPackage == 1,

                    child: _buildLine(7.0, 7.0)),

                /* Coin--- */

                generalProvider.isCoinShow == "1"
                    ? _buildSettingButton(
                        title: 'coin',
                        subTitle: 'view_your_coin',
                        titleMultilang: true,
                        subTitleMultilang: true,
                        onClick: () {
                          if (Constant.userID != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CoinStoreScreen(),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginViaSocial(),
                              ),
                            );
                          }
                        },
                      )
                    : SizedBox.shrink(),

                generalProvider.isCoinShow == "1"
                    ? _buildLine(7.0, 7.0)
                    : SizedBox.shrink(),

                /* Subscription */
                Visibility(
                  visible: forceUpdateData?.result?.showPackage == 1,

                  child: _buildSettingButton(
                    title: 'subsciption',
                    subTitle: 'subsciptionnotes',
                    titleMultilang: true,
                    subTitleMultilang: true,
                    onClick: () {
                      if (Constant.userID != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Subscription(),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginViaSocial(),
                          ),
                        );
                      }
                    },
                  ),
                ),

                Visibility(
                    visible: forceUpdateData?.result?.showPackage == 1,

                    child: _buildLine(7.0, 7.0)),

                /* MaltiLanguage */
                _buildSettingButton(
                  title: 'change_language',
                  subTitle: 'change_language_desc',
                  titleMultilang: true,
                  subTitleMultilang: true,
                  onClick: () {
                    _languageChangeDialog();
                  },
                ),

                _buildLine(7.0, 7.0),

                // /* Push Notification enable/disable */
                // Row(
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                //     Expanded(
                //       child: _buildSettingButton(
                //         title: 'notification',
                //         subTitle: 'recivepushnotification',
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
                // _buildLine(16.0, 16.0),

                // /* Clear Cache */
                // if (!Platform.isIOS)
                //   Row(
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       Expanded(
                //         child: _buildSettingButton(
                //           title: 'clearcatch',
                //           subTitle: 'clearlocallycatch',
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
                // if (!Platform.isIOS) _buildLine(16.0, 16.0),

                // /* SignIn / SignOut */
                // _buildSettingButton(
                //   title: Constant.userID == null
                //       ? youAreNotSignIn
                //       : (userType == "3" && (userName ?? "").isEmpty)
                //           ? ("$signedInAs ${userMobileNo ?? ""}")
                //           : ("$signedInAs ${userName ?? ""}"),
                //   subTitle: Constant.userID == null ? "sign_in" : "sign_out",
                //   titleMultilang: false,
                //   subTitleMultilang: true,
                //   onClick: () async {
                //     if (Constant.userID != null) {
                //       logoutConfirmDialog();
                //     } else {
                //       await Navigator.of(context).push(
                //         MaterialPageRoute(
                //           builder: (context) => const LoginViaSocial(),
                //         ),
                //       );
                //       setState(() {});
                //     }
                //   },
                // ),

                // _buildLine(7.0, 7.0),

                // if (Constant.userID != null)
                //   _buildSettingButton(
                //     title: 'delete_account',
                //     subTitle: 'delete_account_desc',
                //     titleMultilang: true,
                //     subTitleMultilang: true,
                //     onClick: () async {
                //       if (Constant.userID != null) {
                //         deleteConfirmDialog();
                //       } else {
                //         await Navigator.of(context).push(
                //           MaterialPageRoute(
                //             builder: (context) => const LoginViaSocial(),
                //           ),
                //         );
                //         setState(() {});
                //       }
                //     },
                //   ),

                // if (Constant.userID != null) _buildLine(7.0, 7.0),

                // /* Rate App */
                // _buildSettingButton(
                //   title: 'rateus',
                //   subTitle: 'rateourapp',
                //   titleMultilang: true,
                //   subTitleMultilang: true,
                //   onClick: () async {
                //     debugPrint("Clicked on rateApp");
                //     await Utils.redirectToStore();
                //   },
                // ),
                // _buildLine(16.0, 16.0),

                // /* Share App */
                // _buildSettingButton(
                //   title: 'shareapp',
                //   subTitle: 'sharewithfriends',
                //   titleMultilang: true,
                //   subTitleMultilang: true,
                //   onClick: () async {
                //     await Utils.shareApp(Platform.isIOS
                //         ? Constant.iosAppUrl
                //         : Constant.androidAppUrl);
                //   },
                // ),
                // _buildLine(7.0, 7.0),

                // /* Delete Account */
                // if (Constant.userID != null)
                //   _buildSettingButton(
                //     title: 'delete_account',
                //     subTitle: 'delete_account_desc',
                //     titleMultilang: true,
                //     subTitleMultilang: true,
                // onClick: () async {
                // if (Constant.userID != null) {
                //   deleteConfirmDialog();
                // } else {
                //   await Navigator.of(context).push(
                //     MaterialPageRoute(
                //       builder: (context) => const LoginViaSocial(),
                //     ),
                //   );
                //   setState(() {});
                // }
                //   },
                // ),

                //  if (Constant.userID != null) _buildLine(16.0, 16.0),

                /* Pages */
                _buildPages(),

                SizedBox(
                  height: 20,
                ),

                GestureDetector(
                    onTap: () {
                      if (Constant.userID != null) {
                  logoutConfirmDialog();
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginViaSocial(),
                          ),
                        );
                        setState(() {});
                      }
                    },
                    child: Constant.userID == null
                        ? Text(
                            "Log in ",
                            style: TextStyle(
                              fontSize: 15,
                              color: primaryDark,
                            ),
                          )
                        : Text(
                            "Log out",
                            style: TextStyle(
                              fontSize: 15,
                              color: primaryDark,
                            ),
                          )),
              ],
            ),
          ),
        ),
      ),
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
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
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
                  subTitle: generalProvider
                          .pagesModel.result?[position].pageSubtitle ??
                      '',
                  titleMultilang: false,
                  subTitleMultilang: false,
                  onClick: () {
                    Map<String, Object> screenViewEvent = {
                      'screen_name': 'Open policy Pages',
                      'user_id': Constant.userID.toString(),
                    };
                    Singular.eventWithArgs(
                        'Open policy Pages', screenViewEvent);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AboutPrivacyTerms(
                          appBarTitle: generalProvider
                                  .pagesModel.result?[position].pageName ??
                              '',
                          loadURL:
                              "${Constant.baseurlwithoutapi}${generalProvider.pagesModel.result?[position].url}",
                        ),
                      ),
                    );
                  },
                ),
                _buildLine(7.0, 0.0),
              ],
            );
          },
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  // Widget _buildPages() {
  //   if (generalProvider.loading) {
  //     return const SizedBox.shrink();
  //   } else {
  //     if (generalProvider.pagesModel.status == 200 &&
  //         generalProvider.pagesModel.result != null) {
  //       return AlignedGridView.count(
  //         shrinkWrap: true,
  //         crossAxisCount: 1,
  //         crossAxisSpacing: 16,
  //         mainAxisSpacing: 16,
  //         itemCount: (generalProvider.pagesModel.result?.length ?? 0),
  //         padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
  //         physics: const NeverScrollableScrollPhysics(),
  //         itemBuilder: (BuildContext context, int position) {
  //           return Column(
  //             children: [
  //               _buildSettingButton(
  //                 title:
  //                     generalProvider.pagesModel.result?[position].pageName ??
  //                         '',
  //                 subTitle: generalProvider
  //                         .pagesModel.result?[position].pageSubtitle ??
  //                     '',
  //                 titleMultilang: false,
  //                 subTitleMultilang: false,
  //                 onClick: () {
  //                   Navigator.of(context).push(
  //                     MaterialPageRoute(
  //                       builder: (context) => AboutPrivacyTerms(
  //                         appBarTitle: generalProvider
  //                                 .pagesModel.result?[position].pageName ??
  //                             '',
  //                         loadURL: generalProvider
  //                                 .pagesModel.result?[position].url ??
  //                             '',
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               ),
  //               _buildLine(16.0, 0.0),
  //             ],
  //           );
  //         },
  //       );
  //     } else {
  //       return const SizedBox.shrink();
  //     }
  //   }
  // }

  Widget _buildSettingButton({
    required String title,
    required String subTitle,
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
              color: white,
              text: title,
              fontsizeNormal: 12,
              fontsizeWeb: 12,
              maxline: 1,
              multilanguage: titleMultilang,
              overflow: TextOverflow.ellipsis,
              fontweight: FontWeight.w500,
              textalign: TextAlign.start,
              fontstyle: FontStyle.normal,
            ),
            //     SizedBox(height: subTitle.isEmpty ? 0 : 5),
            //     subTitle.isEmpty
            //         ? const SizedBox.shrink()
            //         : MyText(
            //             color: otherColor,
            //             text: subTitle,
            //             fontsizeNormal: 12,
            //             fontsizeWeb: 14,
            //             multilanguage: subTitleMultilang,
            //             maxline: 2,
            //             overflow: TextOverflow.ellipsis,
            //             fontweight: FontWeight.w500,
            //             textalign: TextAlign.start,
            //             fontstyle: FontStyle.normal,
            //           ),
            // //
          ],
        ),
      ),
    );
  }

Widget profileCardWidget({
  required String? userID,
  required String? userName,
  required String? userMobileNo,
  required String? userType,
  required String? profile,
  required VoidCallback onLoginPressed,
  required VoidCallback onLogoutPressed,
  required VoidCallback onDeleteAccountPressed,
  required VoidCallback onEditProfilePressed,
}) {
  const colorPrimary = Color(0xFFB80E07);
  bool isLoggedIn = userID != null && userID.isNotEmpty;

  /// Get Safe Initials
  // String getInitials(String? name) {
  //   if (name == null || name.trim().isEmpty) return "NA";
  //   List<String> nameParts = name.trim().split(" ");
  //   return nameParts.length > 1
  //       ? "${nameParts[0][0]}${nameParts[1][0]}"
  //       : nameParts[0][0];
  // }


  String getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return "NA";
    List<String> nameParts = name.trim().split(" ").where((part) => part.isNotEmpty).toList();
    if (nameParts.isEmpty) return "NA";
    String firstInitial = nameParts[0].isNotEmpty ? nameParts[0][0] : '';
    String secondInitial = nameParts.length > 1 && nameParts[1].isNotEmpty
        ? nameParts[1][0]
        : '';
    return (firstInitial + secondInitial).toUpperCase();
  }


  /// Dynamic Gradient Colors for Profile Circle
  final List<Color> gradientColors = [
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.deepOrangeAccent,
    Colors.greenAccent,
    Colors.tealAccent,
  ];

  Color gradientStartColor =
      gradientColors[(userName?.hashCode ?? 0).abs() % gradientColors.length];
  Color gradientEndColor =
      gradientColors[((userName?.hashCode ?? 0).abs() + 1) % gradientColors.length];

  /// Login Text
  String loginText = !isLoggedIn
      ? "You are not signed in"
      : (userType == "3" && (userName ?? "").isEmpty)
          ? "${userMobileNo ?? ""}"
          : "${userName ?? ""}";

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Colors.black, Color(0xFF1C1C1C), Colors.grey],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: colorPrimary, width: 2),
    ),
    child: Stack(
      children: [
        Column(
          children: [
            /// Profile Info Row
            Row(
              children: [
                /// Profile Icon with Gradient
                ClipOval(
                  child: MyUserNetworkImage(
                    imageUrl: Provider.of<ProfileProvider>(context, listen: false).profileModel.status == 200
                        ? Provider.of<ProfileProvider>(context, listen: false).profileModel.result != null
                        ? (Provider.of<ProfileProvider>(context, listen: false).profileModel.result?[0].image ?? "")
                        : ""
                        : "",
                    fit: BoxFit.cover,
                    imgHeight: 90,
                    imgWidth: 90,
                  ),
                ),
                // Container(
                //   width: 65,
                //   height: 65,
                //   decoration: BoxDecoration(
                //     shape: BoxShape.circle,
                //     gradient: LinearGradient(
                //       colors: [gradientStartColor, gradientEndColor],
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //     ),
                //   ),
                //   alignment: Alignment.center,
                //   child: Text(
                //     isLoggedIn ? getInitials(profile).toUpperCase() : "NA",
                //     style: const TextStyle(
                //       fontSize: 22,
                //       fontWeight: FontWeight.bold,
                //       color: Colors.white,
                //     ),
                //   ),
                // ),
                const SizedBox(width: 16),

                /// User Info
                Expanded(
                  child: Text(
                    loginText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            /// Delete & Logout Button Row or Login Button
            isLoggedIn
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Delete Account Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onDeleteAccountPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Delete Account",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      /// Logout Button (Circular)
                      GestureDetector(
                        onTap: onLogoutPressed,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.black, Colors.grey],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            CupertinoIcons.square_arrow_right,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: onLoginPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: colorPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Login", style: TextStyle(fontSize: 13)),
                  ),
          ],
        ),

        if (isLoggedIn)
          Positioned(
            top: 5,
            right: -10,
            child: IconButton(
              icon: const Icon(CupertinoIcons.pencil, color: Colors.white),
              onPressed: onEditProfilePressed,
            ),
          ),
      ],
    ),
  );
}
  // Widget profileCardWidget({
  //   required String? userID,
  //   required String? userName,
  //   required String? userMobileNo,
  //   required String? userType,
  //   required VoidCallback onLoginPressed,
  //   required VoidCallback onLogoutPressed,
  //   required VoidCallback onDeleteAccountPressed,
  //   required VoidCallback onEditProfilePressed,
  // }) {
  //   const colorPrimary = Color(0xFFB80E07);

  //   bool isLoggedIn = userID != null && userID.isNotEmpty;

  //   /// **Get Safe Initials**
  //   String getInitials(String? name) {
  //     if (name == null || name.isEmpty) return "NA";
  //     List<String> nameParts = name.split(" ");
  //     return nameParts.length > 1
  //         ? "${nameParts[0][0]}${nameParts[1][0]}"
  //         : nameParts[0][0];
  //   }

  //   /// **Dynamic Gradient Colors for Profile Circle**
  //   final List<Color> gradientColors = [
  //     Colors.blueAccent,
  //     Colors.purpleAccent,
  //     Colors.deepOrangeAccent,
  //     Colors.greenAccent,
  //     Colors.tealAccent
  //   ];
  //   Color gradientStartColor =
  //       gradientColors[(userName?.hashCode ?? 0) % gradientColors.length];
  //   Color gradientEndColor =
  //       gradientColors[((userName?.hashCode ?? 0) + 1) % gradientColors.length];

  //   /// **Login Text**
  //   String loginText = !isLoggedIn
  //       ? "You are not signed in"
  //       : (userType == "3" && (userName ?? "").isEmpty)
  //           ? "Signed in as ${userMobileNo ?? ""}"
  //           : "Signed in as ${userName ?? ""}";

  //   return Container(
  //     width: double.infinity,
  //     margin: const EdgeInsets.symmetric(vertical: 10),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       gradient: const LinearGradient(
  //         colors: [
  //           Colors.black,
  //           Color(0xFF1C1C1C),
  //           Colors.grey
  //         ], // Dark to Light Gradient
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       borderRadius: BorderRadius.circular(15),
  //       border: Border.all(
  //           color.xml: colorPrimary, width: 2), // Border with Primary Color
  //     ),
  //     child: Stack(
  //       children: [
  //         Column(
  //           children: [
  //             /// **Profile Info Row**
  //             Row(
  //               children: [
  //                 /// **Profile Icon with Gradient**
  //                 Container(
  //                   width: 65,
  //                   height: 65,
  //                   decoration: BoxDecoration(
  //                     shape: BoxShape.circle,
  //                     gradient: LinearGradient(
  //                       colors: [gradientStartColor, gradientEndColor],
  //                       begin: Alignment.topLeft,
  //                       end: Alignment.bottomRight,
  //                     ),
  //                   ),
  //                   alignment: Alignment.center,
  //                   child: Text(
  //                     isLoggedIn ? getInitials(userName).toUpperCase() : "NA",
  //                     style: const TextStyle(
  //                       fontSize: 22,
  //                       fontWeight: FontWeight.bold,
  //                       color.xml: Colors.white,
  //                     ),
  //                   ),
  //                 ),

  //                 const SizedBox(width: 16),

  //                 /// **User Info**
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         loginText,
  //                         style: TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.w600,
  //                           color.xml: Colors.white.withOpacity(0.7),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),

  //             const SizedBox(height: 10),

  //             /// **Delete & Logout Button Row**
  //             if (isLoggedIn)
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   /// **Delete Account Button**
  //                   Expanded(
  //                     child: ElevatedButton(
  //                       onPressed: onDeleteAccountPressed,
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: Colors.white,
  //                         foregroundColor: Colors.red,
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                       ),
  //                       child: const Text(
  //                         "Delete Account",
  //                         style: TextStyle(fontSize: 13),
  //                       ),
  //                     ),
  //                   ),

  //                   const SizedBox(width: 10),

  //                   /// **Logout Button (Circular)**
  //                   GestureDetector(
  //                     onTap: onLogoutPressed,
  //                     child: Container(
  //                       width: 38,
  //                       height: 38,
  //                       decoration: BoxDecoration(
  //                         shape: BoxShape.circle,
  //                         gradient: const LinearGradient(
  //                           colors: [
  //                             Colors.black,
  //                             Colors.grey
  //                           ], // Black to Gray Gradient
  //                           begin: Alignment.centerLeft,
  //                           end: Alignment.centerRight,
  //                         ),
  //                       ),
  //                       alignment: Alignment.center,
  //                       child: const Icon(
  //                         CupertinoIcons.square_arrow_right, // Logout Icon
  //                         color.xml: Colors.white,
  //                         size: 22,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               )
  //             else

  //               /// **Login Button**
  //               ElevatedButton(
  //                 onPressed: onLoginPressed,
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.white,
  //                   foregroundColor: colorPrimary,
  //                   shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(10)),
  //                 ),
  //                 child: const Text("Login", style: TextStyle(fontSize: 13)),
  //               ),
  //           ],
  //         ),

  //         /// **Edit Button at Top Right**
  //         ///
  //         if (isLoggedIn)
  //           Positioned(
  //             top: 5,
  //             right: -10,
  //             child: IconButton(
  //               icon: const Icon(CupertinoIcons.pencil, color.xml: Colors.white),
  //               onPressed: onEditProfilePressed,
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  // Widget profileCardWidget({
  //   required String? userID,
  //   required String? userName,
  //   required String? userMobileNo,
  //   required String? userType,
  //   required VoidCallback onLoginPressed,
  //   required VoidCallback onLogoutPressed,
  //   required VoidCallback onDeleteAccountPressed,
  //   required VoidCallback onEditProfilePressed,
  // }) {
  //   const colorPrimary = Color(0xFFB80E07);

  //   bool isLoggedIn = userID != null && userID.isNotEmpty;

  //   /// **Get Safe Initials**
  //   String getInitials(String? name) {
  //     if (name == null || name.isEmpty) return "NA";
  //     List<String> nameParts = name.split(" ");
  //     return nameParts.length > 1
  //         ? "${nameParts[0][0]}${nameParts[1][0]}"
  //         : nameParts[0][0];
  //   }

  //   /// **Dynamic Gradient Colors for Profile Circle**
  //   final List<Color> gradientColors = [
  //     Colors.blueAccent,
  //     Colors.purpleAccent,
  //     Colors.deepOrangeAccent,
  //     Colors.greenAccent,
  //     Colors.tealAccent
  //   ];
  //   Color gradientStartColor =
  //       gradientColors[(userName?.hashCode ?? 0) % gradientColors.length];
  //   Color gradientEndColor =
  //       gradientColors[((userName?.hashCode ?? 0) + 1) % gradientColors.length];

  //   /// **Login Text**
  //   String loginText = !isLoggedIn
  //       ? "You are not signed in"
  //       : (userType == "3" && (userName ?? "").isEmpty)
  //           ? "Signed in as ${userMobileNo ?? ""}"
  //           : "Signed in as ${userName ?? ""}";

  //   return Container(
  //     width: double.infinity,
  //     margin: const EdgeInsets.symmetric(vertical: 10),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       gradient: const LinearGradient(
  //         colors: [
  //           Colors.black,
  //           Color(0xFF1C1C1C),
  //           Colors.grey
  //         ], // Dark to Light Gradient
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       borderRadius: BorderRadius.circular(15),
  //       border: Border.all(
  //           color.xml: colorPrimary, width: 2), // Border with Primary Color
  //     ),
  //     child: Stack(
  //       children: [
  //         Row(
  //           children: [
  //             /// **Profile Icon with Gradient**
  //             Container(
  //               width: 65,
  //               height: 65,
  //               decoration: BoxDecoration(
  //                 shape: BoxShape.circle,
  //                 gradient: LinearGradient(
  //                   colors: [gradientStartColor, gradientEndColor],
  //                   begin: Alignment.topLeft,
  //                   end: Alignment.bottomRight,
  //                 ),
  //               ),
  //               alignment: Alignment.center,
  //               child: Text(
  //                 isLoggedIn ? getInitials(userName).toUpperCase() : "NA",
  //                 style: const TextStyle(
  //                     fontSize: 22,
  //                     fontWeight: FontWeight.bold,
  //                     color.xml: Colors.white),
  //               ),
  //             ),

  //             const SizedBox(width: 16),

  //             /// **User Info & Buttons**
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     loginText,
  //                     style: TextStyle(
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.w600,
  //                         color.xml: white.withOpacity(0.7)),
  //                   ),
  //                   const SizedBox(height: 8),
  //                   if (isLoggedIn) ...[
  //                     /// **Delete Account Button**
  //                     ElevatedButton(
  //                       onPressed: onDeleteAccountPressed,
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: Colors.white,
  //                         foregroundColor: Colors.red,
  //                         shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(10)),
  //                       ),
  //                       child: const Text(
  //                         "Delete Account",
  //                         style: TextStyle(fontSize: 13),
  //                       ),
  //                     ),
  //                   ] else ...[
  //                     /// **Login Button**
  //                     ElevatedButton(
  //                       onPressed: onLoginPressed,
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: Colors.white,
  //                         foregroundColor: colorPrimary,
  //                         shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(10)),
  //                       ),
  //                       child:
  //                           const Text("Login", style: TextStyle(fontSize: 13)),
  //                     ),
  //                   ]
  //                 ],
  //               ),
  //             ),

  //             /// **Logout Button as Circular Icon (Using Cupertino Icon)**
  //             if (isLoggedIn)
  //               GestureDetector(
  //                 onTap: onLogoutPressed,
  //                 child: Container(
  //                   width: 38,
  //                   height: 38,
  //                   decoration: BoxDecoration(
  //                     shape: BoxShape.circle,
  //                     gradient: const LinearGradient(
  //                       colors: [
  //                         Colors.black,
  //                         Colors.grey
  //                       ], // Gradient from Black to Gray
  //                       begin: Alignment.centerLeft,
  //                       end: Alignment.centerRight,
  //                     ),
  //                   ),
  //                   alignment: Alignment.center,
  //                   child: const Icon(
  //                     CupertinoIcons.square_arrow_right, // Logout Icon
  //                     color.xml: Colors.white,
  //                     size: 22,
  //                   ),
  //                 ),
  //               ),
  //           ],
  //         ),

  //         /// **Edit Button at Top Right**
  //         Positioned(
  //           top: 0,
  //           right: 0,
  //           child: IconButton(
  //             icon: const Icon(CupertinoIcons.pencil, color.xml: Colors.white),
  //             onPressed: onEditProfilePressed,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

// Widget profileCardWidget({
//   required String? userID,
//   required String? userName,
//   required String? userMobileNo,
//   required String? userType,
//   required VoidCallback onLoginPressed,
//   required VoidCallback onLogoutPressed,
//   required VoidCallback onDeleteAccountPressed,
// }) {
//   const colorPrimary = Color(0xFFB80E07);
//   bool isLoggedIn = userID != null && userID.isNotEmpty;

//   /// **Safe function to get initials**
//   String getInitials(String? name) {
//     if (name == null || name.isEmpty) return "NA"; // Handle null or empty names safely

//     List<String> nameParts = name.split(" ");
//     if (nameParts.length > 1) {
//       return "${nameParts[0][0]}${nameParts[1][0]}".toUpperCase();
//     } else {
//       return nameParts[0][0].toUpperCase();
//     }
//   }

//   /// **Login text logic**
//   String loginText = !isLoggedIn
//       ? "You are not signed in"
//       : (userType == "3" && (userName ?? "").isEmpty)
//           ? "Signed in as ${userMobileNo ?? ""}"
//           : "Signed in as ${userName ?? ""}";

//   return Container(
//     width: double.infinity,
//     margin: const EdgeInsets.symmetric(vertical: 10),
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       gradient: const LinearGradient(
//         colors: [colorPrimary, Colors.redAccent],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//       borderRadius: BorderRadius.circular(15),
//     ),
//     child: Row(
//       children: [
//         /// **Profile Icon (Initials)**
//         ClipRRect(
//           borderRadius: BorderRadius.circular(50),
//           child: Container(
//             width: 60,
//             height: 60,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color.xml: Colors.primaries[
//                   (userName?.hashCode ?? 0) % Colors.primaries.length],
//               shape: BoxShape.circle,
//             ),
//             child: Text(
//               isLoggedIn ? getInitials(userName) : "NA",
//               style: const TextStyle(
//                   fontSize: 22, fontWeight: FontWeight.bold, color.xml: Colors.white),
//             ),
//           ),
//         ),
//         const SizedBox(width: 16),

//         /// **User Info and Buttons**
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 loginText,
//                 style: const TextStyle(
//                     fontSize: 16, fontWeight: FontWeight.w600, color.xml: Colors.white),
//               ),
//               const SizedBox(height: 8),

//               isLoggedIn
//                   ? Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: onDeleteAccountPressed,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white,
//                               foregroundColor: Colors.red,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10)),
//                             ),
//                             child: const Text("Delete Account"),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: onLogoutPressed,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white,
//                               foregroundColor: Colors.black,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10)),
//                             ),
//                             child: const Text("Logout"),
//                           ),
//                         ),
//                       ],
//                     )
//                   : ElevatedButton(
//                       onPressed: onLoginPressed,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: colorPrimary,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10)),
//                       ),
//                       child: const Text("Login"),
//                     ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }

  Widget _buildLine(double topMargin, double bottomMargin) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 0.5,
      margin: EdgeInsets.only(top: topMargin, bottom: bottomMargin),
      color: otherColor,
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
                            MoEngageService.instance.logout();
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
                          text: "confirmsognout",
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
                          text: "areyousurewanrtosignout",
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
                          title: 'sign_out',
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
                            MoEngageService.instance.logout();
                            // MoEngageService.instance.logout();
                            final timestamp = DateTime.now().toIso8601String();

                            final properties = MoEProperties()
                              ..addAttribute('user_id', Constant.userID.toString())

                              ..addAttribute('timestamp', timestamp);

                            MoEngageService.instance.trackEvent('Logout', properties);

                            print("userName check ${userName.toString()}");
                            print(
                                "MoEngage event tracked with device ID: and timestamp: $timestamp");

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
}
