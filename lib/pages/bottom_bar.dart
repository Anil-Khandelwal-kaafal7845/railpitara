import 'package:dtlive/pages/find.dart';
import 'package:dtlive/pages/home_screen.dart';
import 'package:dtlive/pages/my_watchlist.dart';
import 'package:dtlive/pages/setting.dart';
import 'package:dtlive/provider/generalprovider.dart';
import 'package:dtlive/provider/profileprovider.dart';
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

int selectedIndex = 0;

class BottombarState extends State<Bottombar> {
  SharedPre sharedPre = SharedPre();
  // int selectedIndex = 0;
  DateTime? currentBackPressTime;

  static List<Widget> widgetOptions = <Widget>[
    const Home(pageName: ""),
    const Find(),
    const MyWatchlist(),
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

  // void _onItemTapped(int index) {
  //   setState(() {
  //       selectedIndex = index;
  //     });
  // }
  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
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
              // /* AdMob Banner */
              // Utils.showBannerAd(context),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            color: appBgColor,
            padding: const EdgeInsets.fromLTRB(3, 5, 3, 5),
            elevation: 5,
            child: BottomNavigationBar(
              backgroundColor: appBgColor,
              selectedLabelStyle: GoogleFonts.montserrat(
                fontSize: 10,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w500,
                color: colorPrimary,
              ),
              unselectedLabelStyle: GoogleFonts.montserrat(
                fontSize: 10,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w400,
                color: colorPrimary,
              ),
              selectedFontSize: 12,
              unselectedFontSize: 12,
              elevation: 5,
              currentIndex: selectedIndex,
              unselectedItemColor: gray,
              selectedItemColor: colorPrimary,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  label: bottomView1,
                  activeIcon: _buildBottomNavIcon(
                      iconName: 'ic_home', iconColor: colorPrimary),
                  icon:
                      _buildBottomNavIcon(iconName: 'ic_home', iconColor: gray),
                ),
                BottomNavigationBarItem(
                  label: bottomView2,
                  activeIcon: _buildBottomNavIcon(
                      iconName: 'ic_find', iconColor: colorPrimary),
                  icon:
                      _buildBottomNavIcon(iconName: 'ic_find', iconColor: gray),
                ),

                // 📌 New Reel Tab with custom image
                BottomNavigationBarItem(
                  label: 'Reel',
                  activeIcon: _buildCustomImageIcon('ic_reel', colorPrimary),
                  icon: _buildCustomImageIcon('ic_reel', gray),
                ),

                BottomNavigationBarItem(
                  label: bottomView6,
                  activeIcon: _buildBottomNavIcon(
                      iconName: 'ic_plus', iconColor: colorPrimary),
                  icon:
                      _buildBottomNavIcon(iconName: 'ic_plus', iconColor: gray),
                ),
                BottomNavigationBarItem(
                  label: bottomView5,
                  activeIcon: _buildBottomNavIcon(
                      iconName: 'ic_stuff', iconColor: colorPrimary),
                  icon: _buildBottomNavIcon(
                      iconName: 'ic_stuff', iconColor: gray),
                ),
              ],
              onTap: _onItemTapped,
            ),

            // BottomNavigationBar(
            //   backgroundColor: appBgColor,
            //   selectedLabelStyle: GoogleFonts.montserrat(
            //     fontSize: 10,
            //     fontStyle: FontStyle.normal,
            //     fontWeight: FontWeight.w500,
            //     color: colorPrimary,
            //   ),
            //   unselectedLabelStyle: GoogleFonts.montserrat(
            //     fontSize: 10,
            //     fontStyle: FontStyle.normal,
            //     fontWeight: FontWeight.w400,
            //     color: colorPrimary,
            //   ),
            //   selectedFontSize: 12,
            //   unselectedFontSize: 12,
            //   elevation: 5,
            //   currentIndex: selectedIndex,
            //   unselectedItemColor: gray,
            //   selectedItemColor: colorPrimary,
            //   type: BottomNavigationBarType.fixed,
            //   items: [
            //     BottomNavigationBarItem(
            //       backgroundColor: black,
            //       label: bottomView1,
            //       activeIcon: _buildBottomNavIcon(
            //           iconName: 'ic_home', iconColor: colorPrimary),
            //       icon:
            //           _buildBottomNavIcon(iconName: 'ic_home', iconColor: gray),
            //     ),
            //     BottomNavigationBarItem(
            //       backgroundColor: black,
            //       label: bottomView2,
            //       activeIcon: _buildBottomNavIcon(
            //           iconName: 'ic_find', iconColor: colorPrimary),
            //       icon:
            //           _buildBottomNavIcon(iconName: 'ic_find', iconColor: gray),
            //     ),
            //     BottomNavigationBarItem(
            //       backgroundColor: black,
            //       label: bottomView6,
            //       activeIcon: _buildBottomNavIcon(
            //           iconName: 'ic_plus', iconColor: colorPrimary),
            //       icon:
            //           _buildBottomNavIcon(iconName: 'ic_plus', iconColor: gray),
            //     ),
            //     BottomNavigationBarItem(
            //       backgroundColor: black,
            //       label: bottomView5,
            //       activeIcon: _buildBottomNavIcon(
            //           iconName: 'ic_stuff', iconColor: colorPrimary),
            //       icon: _buildBottomNavIcon(
            //           iconName: 'ic_stuff', iconColor: gray),
            //     ),
            //   ],
            //   onTap: _onItemTapped,
            // ),
          )),
    );
  }

  Widget _buildCustomImageIcon(String iconName, Color? iconColor) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Image.asset(
          "assets/images/$iconName.png",
          width: 28, // slightly bigger for emphasis
          height: 28,
          color: iconColor, // remove this if you want original colors
        ),
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
                'Are you sure you want to exit ?',
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white), // Set text color to white
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context,
                      false); // Close bottom sheet and indicate not to exit app
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: colorPrimary, // Set text color to white
                  minimumSize: Size(
                      double.infinity, 50), // Set button width to full width
                ),
                child: Text(
                  'No',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context,
                      true); // Close bottom sheet and indicate to exit app
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Colors.transparent, // Set text color to white
                  side: BorderSide(
                      color: Colors.white), // Set border color to white
                  minimumSize: Size(
                      double.infinity, 50), // Set button width to full width
                ),
                child: Text('Yes', style: TextStyle(fontSize: 18)),
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
