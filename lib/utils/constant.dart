import 'dart:io';

import 'package:dtlive/model/qualitymodel.dart';
import 'package:dtlive/model/subtitlemodel.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

class Constant {
  // static const String baseurl = '';
  static const String baseurl = 'https://admin.aaryaadigital.com/api/';
  static const String dynamicBaseUrl = 'https://play.aaryaadigital.com/';

  static String appName = "Aaryaa digital";
  static String appPackageName = "com.release.aryanews";
  static String appleAppId = "1584477559";
  static double curentAppVersion = 12;

  /* OneSignal App ID */
  static const String oneSignalAppId = "";

  /* Constant for TV check */
  static bool isTV = false;

  static String? userID;
  static String currencySymbol = "";
  static String currency = "";

  static String androidAppShareUrlDesc =
      "Let me recommend you this application\n\n$androidAppUrl";
  static String iosAppShareUrlDesc =
      "Let me recommend you this application\n\n$iosAppUrl";

  static String androidAppUrl =
      "https://play.google.com/store/apps/details?id=${Constant.appPackageName}";
  static String iosAppUrl =
      "https://apps.apple.com/in/app/id${Constant.appleAppId}";

  static String fbLink =
      "https://hi-in.facebook.com/people/Aaryaa-Digital-OTT/100071111258219";
  static String InstaLink = "https://www.instagram.com/aaryaadigital/";
  static String youtubeLink =
      "https://youtube.com/@AaryaaDigital?si=-0vOh88za82oB3Gz";
  static String twitterLink = "https://twitter.com/AaryaaDigital";

  static List<QualityModel> resolutionsUrls = [];
  static List<SubTitleModel> subtitleUrls = [];

  /* Download config */
  static String videoDownloadPort = 'video_downloader_send_port';
  static String showDownloadPort = 'show_downloader_send_port';
  static String hawkVIDEOList = "myVideoList_";
  static String hawkKIDSVIDEOList = "myKidsVideoList_";
  static String hawkSHOWList = "myShowList_";
  static String hawkSEASONList = "mySeasonList_";
  static String hawkEPISODEList = "myEpisodeList_";
  /* Download config */

  static int fixFourDigit = 1317;
  static int fixSixDigit = 161613;

  static int bannerDuration = 10000; // in milliseconds
  static int animationDuration = 800; // in milliseconds

  /* Show Ad By Type */
  static String rewardAdType = "rewardAd";
  static String interstialAdType = "interstialAd";
}

restrictScreenRecordingandScreenshot() async {
  if (Platform.isAndroid) {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }
}

allowScreenRecordingandScreenshot() async {
  if (Platform.isAndroid) {
    await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  }
}
