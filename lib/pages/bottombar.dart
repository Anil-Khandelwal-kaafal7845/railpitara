import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:dtlive/pages/channels.dart';
import 'package:dtlive/pages/find.dart';
import 'package:dtlive/pages/home.dart';
import 'package:dtlive/pages/setting.dart';
import 'package:dtlive/pages/rentstore.dart';
import 'package:dtlive/provider/generalprovider.dart';
import 'package:dtlive/provider/profileprovider.dart';
import 'package:dtlive/utils/adhelper.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/sharedpre.dart';
import 'package:dtlive/utils/strings.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Bottombar extends StatefulWidget {
  const Bottombar({Key? key}) : super(key: key);

  @override
  State<Bottombar> createState() => BottombarState();
}

class BottombarState extends State<Bottombar> {
  SharedPre sharedPre = SharedPre();
  int selectedIndex = 0;
  DateTime? currentBackPressTime;

  static List<Widget> widgetOptions = <Widget>[
    const Home(pageName: ""),
    const Channels(),
    const RentStore(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
  }

  _getData() async {
    final generalsetting = Provider.of<GeneralProvider>(context, listen: false);
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    if (Constant.userID != null) {
      await profileProvider.getProfile(context);
    } else {
      Utils.updatePremium("0");
      Utils.loadAds(context);
    }
    if (!mounted) return;
    await generalsetting.getGeneralsetting(context);
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _onItemTapped(int index) {
    AdHelper.showFullscreenAd(context, Constant.interstialAdType, () async {
      setState(() {
        selectedIndex = index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Center(
                    child: widgetOptions[selectedIndex],
                  ),
                ),
                /* AdMob Banner */
                Utils.showBannerAd(context),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: -4,
              child: Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: DotNavigationBar(
                  backgroundColor: colorBottom8,
                  margin: EdgeInsets.only(left: 10, right: 10),
                  currentIndex: selectedIndex,
                  dotIndicatorColor: colorPrimary,
                  unselectedItemColor: Colors.grey[300],
                  splashBorderRadius: 50,
                  // enableFloatingNavBar: false,
                  onTap: _onItemTapped,
                  items: [
                    /// Home
                    DotNavigationBarItem(
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Image.asset(
                          "assets/images/ic_home.png",
                          width: 15,
                          height: 15,
                          color: appBgColor,
                        ),
                      ),
                      selectedColor: white,
                    ),

                    /// Likes
                    DotNavigationBarItem(
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Image.asset(
                          "assets/images/ic_channels.png",
                          width: 15,
                          height: 15,
                          color: appBgColor,
                        ),
                      ),
                      selectedColor: white,
                    ),

                    /// Search
                    DotNavigationBarItem(
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Image.asset(
                          "assets/images/ic_store.png",
                          width: 15,
                          height: 15,
                          color: appBgColor,
                        ),
                      ),
                      selectedColor: white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // bottomNavigationBar: Padding(
        //   padding: EdgeInsets.only(bottom: 10),
        //   child: DotNavigationBar(
        //     backgroundColor: Colors.black,
        //     margin: EdgeInsets.only(left: 10, right: 10),
        //     currentIndex: selectedIndex,
        //     dotIndicatorColor: colorPrimary,
        //     unselectedItemColor: Colors.grey[300],
        //     splashBorderRadius: 50,
        //     // enableFloatingNavBar: false,
        //     onTap: _onItemTapped,
        //     items: [
        //       /// Home
        //       DotNavigationBarItem(
        //         icon: Padding(
        //           padding: const EdgeInsets.only(left: 4),
        //           child: Image.asset(
        //             "assets/images/ic_home.png",
        //             width: 15,
        //             height: 15,
        //             color: white,
        //           ),
        //         ),
        //         selectedColor: white,
        //       ),

        //       /// Likes
        //       DotNavigationBarItem(
        //         icon: Padding(
        //            padding: const EdgeInsets.only(left: 4),
        //           child: Image.asset(
        //             "assets/images/ic_channels.png",
        //             width: 15,
        //             height: 15,
        //             color: white,
        //           ),
        //         ),
        //         selectedColor: white,
        //       ),

        //       /// Search
        //       DotNavigationBarItem(
        //         icon: Padding(
        //            padding: const EdgeInsets.only(left: 4),
        //           child: Image.asset(
        //             "assets/images/ic_store.png",
        //             width: 15,
        //             height: 15,
        //             color: white,
        //           ),
        //         ),
        //         selectedColor: white,
        //       ),

        //     ],
        //   ),
        // ),
      ),
    );
  }

  Widget _buildBottomNavIcon(
      {required String iconName, required Color? iconColor}) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Image.asset(
          "assets/images/$iconName.png",
          width: 22,
          height: 22,
          color: iconColor,
        ),
      ),
    );
  }

  Future<bool> onBackPressed() async {
    if (selectedIndex == 0) {
      DateTime now = DateTime.now();
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
        currentBackPressTime = now;
        Utils.showSnackbar(context, "", "exit_warning", true);
        return Future.value(false);
      }
      SystemNavigator.pop();
      return Future.value(true);
    } else {
      _onItemTapped(0);
      return Future.value(false);
    }
  }
}
