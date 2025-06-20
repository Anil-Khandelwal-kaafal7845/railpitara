
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

// int selectedIndex = 0;

class BottombarState extends State<Bottombar> {
  SharedPre sharedPre = SharedPre();
  DateTime? currentBackPressTime;

  int selectedIndex = 0;

  final List<Widget> _screens = [
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

  Future<void> _getData() async {
    final generalsetting = Provider.of<GeneralProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

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
        bottomNavigationBar: BottomAppBar(
          color: appBgColor,
          padding: const EdgeInsets.fromLTRB(3, 5, 3, 5),
          elevation: 5,
          child: BottomNavigationBar(
            backgroundColor: appBgColor,
            selectedLabelStyle: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: colorPrimary,
            ),
            unselectedLabelStyle: GoogleFonts.montserrat(
              fontSize: 10,
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
              _buildBarItem('ic_home', bottomView1),
              _buildBarItem('ic_find', bottomView2),
              _buildBarItem('ic_plus', bottomView6),
              _buildBarItem('ic_stuff', bottomView5),
            ],
            onTap: _onItemTapped,
          ),
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

  Widget _buildBottomNavIcon({required String iconName, required Color? iconColor}) {
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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

