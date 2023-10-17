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
    const Find(),
    const Channels(),
    const RentStore(),
    const Setting(),
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
        body: 

         Stack(
                children: [
                  Center(
                    child: widgetOptions[selectedIndex],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: Colors.transparent,
                      child: DotNavigationBar(
                        unselectedItemColor: Colors.white.withOpacity(0.7),
                        backgroundColor: bottombackcolor,
                        currentIndex: selectedIndex,
                        onTap: _onItemTapped,
                        dotIndicatorColor: colorPrimary,
                        selectedItemColor: colorPrimary,
                        items: [
                          DotNavigationBarItem(
                             icon: _buildBottomNavIcon(iconName: 'ic_home', isSelected: selectedIndex == 0),
                            selectedColor: colorPrimary,
                          ),
                          DotNavigationBarItem(
                             icon: _buildBottomNavIcon(iconName: 'ic_find', isSelected: selectedIndex == 1),
                            selectedColor: colorPrimary,
                          ),
                          DotNavigationBarItem(
                           icon: _buildBottomNavIcon(iconName: 'ic_channels', isSelected: selectedIndex == 2),
                            selectedColor: colorPrimary,
                          
                          ),
                          DotNavigationBarItem(
                              icon: _buildBottomNavIcon(iconName: 'ic_store', isSelected: selectedIndex == 3),
                          
                            selectedColor: colorPrimary,
                          ),
                          DotNavigationBarItem(
                           icon: _buildBottomNavIcon(iconName: 'ic_stuff', isSelected: selectedIndex == 4),
                            selectedColor: colorPrimary,
                         
                          ),
                        ],
                      ),
                    ),
                  ),
               
                ],
              ))
          
          
        
        // Column(
        //   children: [
        //     Expanded(
        //       child: Center(
        //         child: widgetOptions[selectedIndex],
        //       ),
        //     ),
        //     /* AdMob Banner */
        //     Utils.showBannerAd(context),
        //   ],
        // ),

        // bottomNavigationBar: BottomAppBar(
        //   color: appBgColor,
        //   padding: const EdgeInsets.fromLTRB(3, 5, 3, 5),
        //   elevation: 5,
        //   child: BottomNavigationBar(
        //     backgroundColor: appBgColor,
        //     selectedLabelStyle: GoogleFonts.montserrat(
        //       fontSize: 10,
        //       fontStyle: FontStyle.normal,
        //       fontWeight: FontWeight.w500,
        //       color: colorPrimary,
        //     ),
        //     unselectedLabelStyle: GoogleFonts.montserrat(
        //       fontSize: 10,
        //       fontStyle: FontStyle.normal,
        //       fontWeight: FontWeight.w500,
        //       color: colorPrimary,
        //     ),
        //     selectedFontSize: 12,
        //     unselectedFontSize: 12,
        //     elevation: 5,
        //     currentIndex: selectedIndex,
        //     unselectedItemColor: gray,
        //     selectedItemColor: colorPrimary,
        //     type: BottomNavigationBarType.fixed,
        //     items: [
        //       BottomNavigationBarItem(
        //         backgroundColor: black,
        //         label: bottomView1,
        //         activeIcon: _buildBottomNavIcon(
        //             iconName: 'ic_home', iconColor: colorPrimary),
        //         icon: _buildBottomNavIcon(iconName: 'ic_home', iconColor: gray),
        //       ),
        //       BottomNavigationBarItem(
        //         backgroundColor: black,
        //         label: bottomView2,
        //         activeIcon: _buildBottomNavIcon(
        //             iconName: 'ic_find', iconColor: colorPrimary),
        //         icon: _buildBottomNavIcon(iconName: 'ic_find', iconColor: gray),
        //       ),
        //       BottomNavigationBarItem(
        //         backgroundColor: black,
        //         label: bottomView3,
        //         activeIcon: _buildBottomNavIcon(
        //             iconName: 'ic_channels', iconColor: colorPrimary),
        //         icon: _buildBottomNavIcon(
        //             iconName: 'ic_channels', iconColor: gray),
        //       ),
        //       BottomNavigationBarItem(
        //         backgroundColor: black,
        //         label: bottomView4,
        //         activeIcon: _buildBottomNavIcon(
        //             iconName: 'ic_store', iconColor: colorPrimary),
        //         icon:
        //             _buildBottomNavIcon(iconName: 'ic_store', iconColor: gray),
        //       ),
        //       BottomNavigationBarItem(
        //         backgroundColor: black,
        //         label: bottomView5,
        //         activeIcon: _buildBottomNavIcon(
        //             iconName: 'ic_stuff', iconColor: colorPrimary),
        //         icon:
        //             _buildBottomNavIcon(iconName: 'ic_stuff', iconColor: gray),
        //       ),
        //     ],
        //     onTap: _onItemTapped,
        //   ),
        // ),
     
     
    
    );
  }




Widget _buildBottomNavIcon({
  required String iconName,
  required bool isSelected, // Add isSelected parameter
}) {
  final iconColor = isSelected ? colorPrimary : Colors.white; // Set color based on isSelected

  return Align(
    alignment: Alignment.center,
    child: Padding(
      padding: const EdgeInsets.all(4),
      child: Image.asset(
        "assets/images/$iconName.png",
        width: 15,
        height: 15,
        color: iconColor, // Use the calculated iconColor
      ),
    ),
  );
}


  // Widget _buildBottomNavIcon(
  //     {required String iconName, required Color? iconColor}) {
  //   return Align(
  //     alignment: Alignment.center,
  //     child: Padding(
  //       padding: const EdgeInsets.all(4),
  //       child: Image.asset(
  //         "assets/images/$iconName.png",
  //         width: 15,
  //         height: 15,
  //         color: iconColor,
  //       ),
  //     ),
  //   );
  // }

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
