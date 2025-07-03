import 'package:dtlive/pages/find.dart';
import 'package:dtlive/pages/home_screen.dart';
import 'package:dtlive/pages/my_watchlist.dart';
import 'package:dtlive/pages/sectionbytype.dart';
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

// int selectedIndex = 0;

class BottombarState extends State<Bottombar> {
  SharedPre sharedPre = SharedPre();
  DateTime? currentBackPressTime;

  int selectedIndex = 0;

  final List<Widget> _screens = [
    const Home(pageName: ""),
    const Find(),
  SectionByType(37, "Reels","2"),
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

  Future<void> _getData() async {
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
    setState(() {}); // Update once after loading
  }

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
        body: IndexedStack(
          index: selectedIndex,
          children: _screens,
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 15 ,right: 15),
          child: FloatingActionButton(
            backgroundColor: colorPrimary,
            child: Image.asset(
              "assets/images/reel.png", // replace with your Shorts/Reels icon
              width: 35,
              height: 35,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                selectedIndex = 2; // the center screen (Reels/Shorts)
              });
            },
          ),
        ),


        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          color: appBgColor,
          elevation: 10,
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// LEFT GROUP
                Row(
                  children: [
                    const SizedBox(width: 20), // more left padding
                    _buildTabItem(
                        index: 0, icon: 'ic_home', label: bottomView1),
                    const SizedBox(width: 25), // space between icons
                    _buildTabItem(
                        index: 1, icon: 'ic_find', label: bottomView2),
                  ],
                ),

                /// RIGHT GROUP
                Row(
                  children: [
                    _buildTabItem(
                        index: 3, icon: 'ic_plus', label: bottomView5),
                    const SizedBox(width: 25),
                    _buildTabItem(
                        index: 4, icon: 'ic_stuff', label: bottomView4),
                    const SizedBox(width: 20), // more right padding
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(
      {required int index, required String icon, required String label}) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/$icon.png',
              width: 22,
              height: 22,
              color: isSelected ? colorPrimary : gray,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected ? colorPrimary : gray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBarItem(String icon, String label) {
    return BottomNavigationBarItem(
      backgroundColor: black,
      label: label,
      activeIcon: _buildBottomNavIcon(iconName: icon, iconColor: colorPrimary),
      icon: _buildBottomNavIcon(iconName: icon, iconColor: gray),
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
        return await _showExitBottomSheet();
      } else {
        SystemNavigator.pop();
        return true;
      }
    } else {
      _onItemTapped(0);
      return false;
    }
  }

  Future<bool> _showExitBottomSheet() async {
    bool? result = await showModalBottomSheet<bool>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.black,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 15),
              const Text(
                'Are you sure you want to exit?',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('No', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Yes', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );

    return result ?? false;
  }
}
