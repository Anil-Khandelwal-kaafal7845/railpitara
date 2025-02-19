import 'dart:io';

import 'package:dtlive/model/qualitymodel.dart';
import 'package:dtlive/model/subtitlemodel.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

class Constant {
  static const String baseurl = 'https://chull.ottsnap.in/api/';
  static const String dynamicBaseUrl = 'https://chull.tv/';
  static const String baseurlwithoutapi = 'https://chull.ottsnap.in';
  static String appName = "CHULL TV";
  static String appPackageName = "com.ott.chulltvott";
  static String appleAppId = "";
  static double curentAppVersion = 4;
  static dynamic curentiosAppVersion = 1;

  /* OneSignal App ID */
  static const String oneSignalAppId = "";

  /* Constant for TV check */
  static bool isTV = false;

  static String deviceType = "";

  static String? userID;
  static String currencySymbol = "";
  static String currency = "";

  static String androidAppUrl =
      "https://play.google.com/store/apps/details?id=${Constant.appPackageName}";
  static String iosAppUrl =
      "https://apps.apple.com/in/app/id${Constant.appleAppId}";

  static String fbLink = "";
  static String InstaLink = "";
  static String youtubeLink = "";
  static String twitterLink = "";

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
