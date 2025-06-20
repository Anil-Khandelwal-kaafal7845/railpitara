import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pages/bottom_bar.dart';
import '../pages/splash.dart';

class StartUpPage extends StatefulWidget {
  const StartUpPage({super.key});

  @override
  State<StartUpPage> createState() => _StartUpPageState();
}

class _StartUpPageState extends State<StartUpPage> {
  bool? showSplash;

  @override
  void initState() {
    super.initState();
    _checkWhereToGo();
  }

  Future<void> _checkWhereToGo() async {
    // Simulate logic: you can use SharedPreferences here
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      showSplash = true; // or false, based on your app state
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showSplash == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return showSplash!
        ? Splash(isDynamicLink: false)
        : const Bottombar(); // your main screen
  }
}
