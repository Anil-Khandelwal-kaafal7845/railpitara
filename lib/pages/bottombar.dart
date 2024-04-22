// import 'package:dot_navigation_bar/dot_navigation_bar.dart';
// import 'package:dtlive/pages/channels.dart';
// import 'package:dtlive/pages/find.dart';
// import 'package:dtlive/pages/home.dart';
// import 'package:dtlive/pages/setting.dart';
// import 'package:dtlive/pages/rentstore.dart';
// import 'package:dtlive/provider/generalprovider.dart';
// import 'package:dtlive/provider/profileprovider.dart';
// import 'package:dtlive/utils/adhelper.dart';
// import 'package:dtlive/utils/color.dart';
// import 'package:dtlive/utils/constant.dart';
// import 'package:dtlive/utils/sharedpre.dart';
// import 'package:dtlive/utils/strings.dart';
// import 'package:dtlive/utils/utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';

// class Bottombar extends StatefulWidget {
//   const Bottombar({Key? key}) : super(key: key);

//   @override
//   State<Bottombar> createState() => BottombarState();
// }

// class BottombarState extends State<Bottombar> {
//   SharedPre sharedPre = SharedPre();
//   int selectedIndex = 0;
//   DateTime? currentBackPressTime;

//   static List<Widget> widgetOptions = <Widget>[
//     const Home(pageName: ""),
//     const Channels(),
//     const RentStore(),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _getData();
//     });
//   }

//   _getData() async {
//     final generalsetting = Provider.of<GeneralProvider>(context, listen: false);
//     final profileProvider =
//         Provider.of<ProfileProvider>(context, listen: false);
//     if (Constant.userID != null) {
//       await profileProvider.getProfile(context);
//     } else {
//       Utils.updatePremium("0");
//       Utils.loadAds(context);
//     }
//     if (!mounted) return;
//     await generalsetting.getGeneralsetting(context);
//     Future.delayed(Duration.zero).then((value) {
//       if (!mounted) return;
//       setState(() {});
//     });
//   }

//   void _onItemTapped(int index) {
//     AdHelper.showFullscreenAd(context, Constant.interstialAdType, () async {
//       setState(() {
//         selectedIndex = index;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: onBackPressed,
//       child: Scaffold(
//         resizeToAvoidBottomInset: false,
//         body: Stack(
//           children: [
//             Column(
//               children: [
//                 Expanded(
//                   child: Center(
//                     child: widgetOptions[selectedIndex],
//                   ),
//                 ),
//                 /* AdMob Banner */
//                 Utils.showBannerAd(context),
//               ],
//             ),
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: -4,
//               child: Padding(
//                 padding: EdgeInsets.only(bottom: 10),
//                 child: DotNavigationBar(
//                   backgroundColor: colorBottom8,
//                   margin: EdgeInsets.only(left: 10, right: 10),
//                   currentIndex: selectedIndex,
//                   dotIndicatorColor: colorPrimary,
//                   unselectedItemColor: Colors.grey[300],
//                   splashBorderRadius: 50,
//                   // enableFloatingNavBar: false,
//                   onTap: _onItemTapped,
//                   items: [
//                     /// Home
//                     DotNavigationBarItem(
//                       icon: Padding(
//                         padding: const EdgeInsets.only(left: 4),
//                         child: Image.asset(
//                           "assets/images/ic_home.png",
//                           width: 15,
//                           height: 15,
//                           color: appBgColor,
//                         ),
//                       ),
//                       selectedColor: white,
//                     ),

//                     /// Likes
//                     DotNavigationBarItem(
//                       icon: Padding(
//                         padding: const EdgeInsets.only(left: 4),
//                         child: Image.asset(
//                           "assets/images/ic_channels.png",
//                           width: 15,
//                           height: 15,
//                           color: appBgColor,
//                         ),
//                       ),
//                       selectedColor: white,
//                     ),

//                     /// Search
//                     DotNavigationBarItem(
//                       icon: Padding(
//                         padding: const EdgeInsets.only(left: 4),
//                         child: Image.asset(
//                           "assets/images/ic_store.png",
//                           width: 15,
//                           height: 15,
//                           color: appBgColor,
//                         ),
//                       ),
//                       selectedColor: white,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),

//         // bottomNavigationBar: Padding(
//         //   padding: EdgeInsets.only(bottom: 10),
//         //   child: DotNavigationBar(
//         //     backgroundColor: Colors.black,
//         //     margin: EdgeInsets.only(left: 10, right: 10),
//         //     currentIndex: selectedIndex,
//         //     dotIndicatorColor: colorPrimary,
//         //     unselectedItemColor: Colors.grey[300],
//         //     splashBorderRadius: 50,
//         //     // enableFloatingNavBar: false,
//         //     onTap: _onItemTapped,
//         //     items: [
//         //       /// Home
//         //       DotNavigationBarItem(
//         //         icon: Padding(
//         //           padding: const EdgeInsets.only(left: 4),
//         //           child: Image.asset(
//         //             "assets/images/ic_home.png",
//         //             width: 15,
//         //             height: 15,
//         //             color: white,
//         //           ),
//         //         ),
//         //         selectedColor: white,
//         //       ),

//         //       /// Likes
//         //       DotNavigationBarItem(
//         //         icon: Padding(
//         //            padding: const EdgeInsets.only(left: 4),
//         //           child: Image.asset(
//         //             "assets/images/ic_channels.png",
//         //             width: 15,
//         //             height: 15,
//         //             color: white,
//         //           ),
//         //         ),
//         //         selectedColor: white,
//         //       ),

//         //       /// Search
//         //       DotNavigationBarItem(
//         //         icon: Padding(
//         //            padding: const EdgeInsets.only(left: 4),
//         //           child: Image.asset(
//         //             "assets/images/ic_store.png",
//         //             width: 15,
//         //             height: 15,
//         //             color: white,
//         //           ),
//         //         ),
//         //         selectedColor: white,
//         //       ),

//         //     ],
//         //   ),
//         // ),
//       ),
//     );
//   }

//   Widget _buildBottomNavIcon(
//       {required String iconName, required Color? iconColor}) {
//     return Align(
//       alignment: Alignment.center,
//       child: Padding(
//         padding: const EdgeInsets.all(7),
//         child: Image.asset(
//           "assets/images/$iconName.png",
//           width: 22,
//           height: 22,
//           color: iconColor,
//         ),
//       ),
//     );
//   }

//   Future<bool> onBackPressed() async {
//     if (selectedIndex == 0) {
//       DateTime now = DateTime.now();
//       if (currentBackPressTime == null ||
//           now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
//         currentBackPressTime = now;
//         Utils.showSnackbar(context, "", "exit_warning", true);
//         return Future.value(false);
//       }
//       SystemNavigator.pop();
//       return Future.value(true);
//     } else {
//       _onItemTapped(0);
//       return Future.value(false);
//     }
//   }
// }



// import 'package:dtlive/pages/channels.dart';
// import 'package:dtlive/pages/find.dart';
// import 'package:dtlive/pages/home.dart';
// import 'package:dtlive/pages/setting.dart';
// import 'package:dtlive/pages/rentstore.dart';
// import 'package:dtlive/provider/generalprovider.dart';
// import 'package:dtlive/provider/profileprovider.dart';
// import 'package:dtlive/utils/adhelper.dart';
// import 'package:dtlive/utils/color.dart';
// import 'package:dtlive/utils/constant.dart';
// import 'package:dtlive/utils/sharedpre.dart';
// import 'package:dtlive/utils/strings.dart';
// import 'package:dtlive/utils/utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';

// class Bottombar extends StatefulWidget {
//   const Bottombar({Key? key}) : super(key: key);

//   @override
//   State<Bottombar> createState() => BottombarState();
// }

// class BottombarState extends State<Bottombar> {
//   SharedPre sharedPre = SharedPre();
//   int selectedIndex = 0;
//   DateTime? currentBackPressTime;

//   static List<Widget> widgetOptions = <Widget>[
//     const Home(pageName: ""),
//     const Find(),
//     const Channels(),
//     const RentStore(),
//     const Setting(),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _getData();
//     });
//   }

//   _getData() async {
//     final generalsetting = Provider.of<GeneralProvider>(context, listen: false);
//     final profileProvider =
//         Provider.of<ProfileProvider>(context, listen: false);
//     if (Constant.userID != null) {
//       await profileProvider.getProfile(context);
//     } else {
//       Utils.updatePremium("0");
//       Utils.loadAds(context);
//     }
//     if (!mounted) return;
//     await generalsetting.getGeneralsetting(context);
//     Future.delayed(Duration.zero).then((value) {
//       if (!mounted) return;
//       setState(() {});
//     });
//   }

//   void _onItemTapped(int index) {
//     AdHelper.showFullscreenAd(context, Constant.interstialAdType, () async {
//       setState(() {
//         selectedIndex = index;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: onBackPressed,
//       child: Scaffold(
//         resizeToAvoidBottomInset: false,
//         body: Column(
//           children: [
//             Expanded(
//               child: Center(
//                 child: widgetOptions[selectedIndex],
//               ),
//             ),
//             /* AdMob Banner */
//             Utils.showBannerAd(context),
//           ],
//         ),
//         bottomNavigationBar: BottomAppBar(
//           color: appBgColor,
//           padding: const EdgeInsets.fromLTRB(3, 5, 3, 5),
//           elevation: 5,
//           child: BottomNavigationBar(
//             backgroundColor: appBgColor,
//             selectedLabelStyle: GoogleFonts.montserrat(
//               fontSize: 10,
//               fontStyle: FontStyle.normal,
//               fontWeight: FontWeight.w500,
//               color: colorPrimary,
//             ),
//             unselectedLabelStyle: GoogleFonts.montserrat(
//               fontSize: 10,
//               fontStyle: FontStyle.normal,
//               fontWeight: FontWeight.w500,
//               color: colorPrimary,
//             ),
//             selectedFontSize: 12,
//             unselectedFontSize: 12,
//             elevation: 5,
//             currentIndex: selectedIndex,
//             unselectedItemColor: gray,
//             selectedItemColor: colorPrimary,
//             type: BottomNavigationBarType.fixed,
//             items: [
//               BottomNavigationBarItem(
//                 backgroundColor: black,
//                 label: bottomView1,
//                 activeIcon: _buildBottomNavIcon(
//                     iconName: 'ic_home', iconColor: colorPrimary),
//                 icon: _buildBottomNavIcon(iconName: 'ic_home', iconColor: gray),
//               ),
//               BottomNavigationBarItem(
//                 backgroundColor: black,
//                 label: bottomView2,
//                 activeIcon: _buildBottomNavIcon(
//                     iconName: 'ic_find', iconColor: colorPrimary),
//                 icon: _buildBottomNavIcon(iconName: 'ic_find', iconColor: gray),
//               ),
//               BottomNavigationBarItem(
//                 backgroundColor: black,
//                 label: bottomView3,
//                 activeIcon: _buildBottomNavIcon(
//                     iconName: 'ic_channels', iconColor: colorPrimary),
//                 icon: _buildBottomNavIcon(
//                     iconName: 'ic_channels', iconColor: gray),
//               ),
//               BottomNavigationBarItem(
//                 backgroundColor: black,
//                 label: bottomView4,
//                 activeIcon: _buildBottomNavIcon(
//                     iconName: 'ic_store', iconColor: colorPrimary),
//                 icon:
//                     _buildBottomNavIcon(iconName: 'ic_store', iconColor: gray),
//               ),
//               BottomNavigationBarItem(
//                 backgroundColor: black,
//                 label: bottomView5,
//                 activeIcon: _buildBottomNavIcon(
//                     iconName: 'ic_stuff', iconColor: colorPrimary),
//                 icon:
//                     _buildBottomNavIcon(iconName: 'ic_stuff', iconColor: gray),
//               ),
//             ],
//             onTap: _onItemTapped,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomNavIcon(
//       {required String iconName, required Color? iconColor}) {
//     return Align(
//       alignment: Alignment.center,
//       child: Padding(
//         padding: const EdgeInsets.all(7),
//         child: Image.asset(
//           "assets/images/$iconName.png",
//           width: 22,
//           height: 22,
//           color: iconColor,
//         ),
//       ),
//     );
//   }

//   Future<bool> onBackPressed() async {
//     if (selectedIndex == 0) {
//       DateTime now = DateTime.now();
//       if (currentBackPressTime == null ||
//           now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
//         currentBackPressTime = now;
//         Utils.showSnackbar(context, "", "exit_warning", true);
//         return Future.value(false);
//       }
//       SystemNavigator.pop();
//       return Future.value(true);
//     } else {
//       _onItemTapped(0);
//       return Future.value(false);
//     }
//   }
// }




import 'package:bottom_bar/bottom_bar.dart';
import 'package:dtlive/pages/channels.dart';

import 'package:dtlive/pages/home.dart';

import 'package:dtlive/pages/rentstore.dart';
import 'package:dtlive/pages/setting.dart';
import 'package:dtlive/provider/generalprovider.dart';
import 'package:dtlive/provider/profileprovider.dart';
import 'package:dtlive/utils/adhelper.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/sharedpre.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        body: Column(
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

        bottomNavigationBar: BottomBar(
          height: 60,
          textStyle: TextStyle(fontWeight: FontWeight.w500),
          selectedIndex: selectedIndex,
          onTap: _onItemTapped,
          items: <BottomBarItem>[
            BottomBarItem(
              icon: Image.asset(
                "assets/images/ic_home.png",
                width: 15,
                height: 15,
                color: white,
              ),
              title:Text('Home' ,style: TextStyle(color: colorPrimary),),
              activeColor: Colors.blue,
              activeTitleColor: Colors.blue.shade600,
            ),
            BottomBarItem(
              icon:Image.asset(
                "assets/images/ic_channels.png",
                width: 15,
                height: 15,
                color: white,
              ),
              title: Text('Channels' ,style: TextStyle(color: colorPrimary),),
             // backgroundColorOpacity: 0.1,
            activeColor: Colors.blue,
              activeTitleColor: Colors.blue.shade600,
            ),
            BottomBarItem(
              icon:Image.asset(
                "assets/images/ic_store.png",
                width: 15,
                height: 15,
                color: white,
              ),
              title: Text('Store' ,style: TextStyle(color: colorPrimary),),
               activeColor: Colors.blue,
              activeTitleColor: Colors.blue.shade600,
            ),
            BottomBarItem(
              icon:Image.asset(
                "assets/images/ic_stuff.png",
                width: 15,
                height: 15,
                color: white,
              ),
              title: Text('My Stuff' ,style: TextStyle(color: colorPrimary),),
               activeColor: Colors.blue,
              activeTitleColor: Colors.blue.shade600,
            ),
           
          ],
        ),

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
      // Show bottom sheet instead of snackbar
      return await _showExitBottomSheet();
    } else {
      SystemNavigator.pop();
      return true; // Allow the back operation
    }
  } else {
    _onItemTapped(0);
    return false; // Do not allow the back operation
  }
}
Future<bool> _showExitBottomSheet() async {
  bool? result = await showModalBottomSheet<bool>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black, // Set background color to black
          // borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
               SizedBox(height: 15),

            Text(
              'Are you sure you want to exit Aaryaa?',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white), // Set text color to white
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, false); // Close bottom sheet and indicate not to exit app
              },
              style: ElevatedButton.styleFrom(
                primary: colorPrimary, // Set button color to primaryDark
                onPrimary: Colors.white, // Set text color to white
                minimumSize: Size(double.infinity, 50), // Set button width to full width
              ),
              child: Text('No' ,style: TextStyle(fontSize: 18),),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true); // Close bottom sheet and indicate to exit app
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent, // Set button color to transparent
                onPrimary: Colors.white, // Set text color to white
                side: BorderSide(color: Colors.white), // Set border color to white
                minimumSize: Size(double.infinity, 50), // Set button width to full width
              ),
              child: Text('Yes' ,style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 20),
          ],
        ),
      );
    },
  );

  return result ?? false; // Return false if result is null
}



}





