
import 'package:bottom_bar/bottom_bar.dart';
import 'package:dtlive/pages/channels.dart';
import 'package:dtlive/pages/find.dart';
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
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

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
    const NewLivePlayer(),
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
            /* AdMob Banner */
            // Utils.showBannerAd(context),
          ],
        ),

bottomNavigationBar: SalomonBottomBar(

          currentIndex: selectedIndex,
          onTap: _onItemTapped,
          items:[
            SalomonBottomBarItem(
              icon: Image.asset(
                "assets/images/ic_home.png",
                width: 15,
                height: 15,
                color: white,
              ),
              title:Text('Home' ,style: TextStyle(color: colorPrimary,fontWeight: FontWeight.w500),),
              selectedColor: Color.fromRGBO(33, 150, 243, 1),
              //activeTitleColor: Colors.blue.shade600,
            ),
             SalomonBottomBarItem(
              icon: Image.asset(
                "assets/images/ic_find.png",
                width: 15,
                height: 15,
                color: white,
              ),
              title:Text('Search' ,style: TextStyle(color: colorPrimary,fontWeight: FontWeight.w500),),
              selectedColor: Color.fromRGBO(33, 150, 243, 1),
              //activeTitleColor: Colors.blue.shade600,
            ),
           
            SalomonBottomBarItem(
              icon:Image.asset(
                "assets/images/ic_channels.png",
                width: 15,
                height: 15,
                color: white,
              ),
              title: Text('Channels' ,style: TextStyle(color: colorPrimary, fontWeight: FontWeight.w500),),
             // backgroundColorOpacity: 0.1,
            selectedColor: Colors.blue,
              //activeTitleColor: Colors.blue.shade600,
            ),
           SalomonBottomBarItem(
              icon: Image.asset(
                "assets/images/ic_store.png",
                width: 15,
                height: 15,
                color: white,
              ),
              title:Text('Store' ,style: TextStyle(color: colorPrimary,fontWeight: FontWeight.w500),),
              selectedColor: Colors.blue,
              //activeTitleColor: Colors.blue.shade600,
            ),
            SalomonBottomBarItem(
              icon:Image.asset(
                "assets/images/ic_stuff.png",
                width: 15,
                height: 15,
                color: white,
              ),
              title: Text('My Stuff' ,style: TextStyle(color: colorPrimary,fontWeight: FontWeight.w500),),
               selectedColor: Colors.blue,
              //activeTitleColor: Colors.blue.shade600,
            ),

          ],
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





