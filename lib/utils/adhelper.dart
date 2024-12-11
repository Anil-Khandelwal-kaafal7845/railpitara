import 'dart:io';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/sharedpre.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static SharedPre sharePref = SharedPre();
  static bool? isPremiumBuy;
  static String? banneradid;
  static String? interstitaladid;
  static String? rewardadid;
  static String? rewardadidios;

    static var rewardad = "";
  static var rewardadIos = "";

  static var bannerad = "";
  static var interstitalad = "";


  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;

  static AdRequest request = AdRequest(
    keywords: <String>[Constant.appName, 'OM TV'],
    contentUrl: 'https://flutter.io',
    nonPersonalizedAds: true,
  );


  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return rewardadid.toString();
    } else if (Platform.isIOS) {
      return rewardadidios.toString();
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }




  // Initialize Google Mobile Ads SDK
  Future<InitializationStatus> initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }

//---
  static Future<void> getAds(BuildContext context) async {
    isPremiumBuy = await Utils.checkPremiumUser();
    bannerad = await sharePref.read("banner_ad") ?? "";

    interstitalad = await sharePref.read("interstital_ad") ?? "";

//rewarded add -----
      rewardad = await sharePref.read("reward_ad") ?? "";
    rewardadIos = await sharePref.read("ios_reward_ad") ?? "";
    rewardadid = await sharePref.read("reward_adid") ?? "";
    rewardadidios = await sharePref.read("ios_reward_adid") ?? "";

       debugPrint("reward         : $rewardad");
    debugPrint("rewardadIos    : $rewardadIos");

    // rewardad = 'ca-app-pub-3940256099942544/5224354917'; // Test Ad Unit ID

    if (!kIsWeb && !(isPremiumBuy ?? false)) {
      // Ensure the rewarded ad is created as soon as possible
      AdHelper.createRewardedAd();
    }
  }


 //--old---
    static Future<void> createRewardedAd() async {
    debugPrint(
        '================ createRewardedAd : $rewardedAdUnitId ================');
    if ((rewardad == "1" && Platform.isAndroid) ||
        (rewardadIos == "1" && Platform.isIOS)) {
      if (rewardedAdUnitId != "null" || rewardedAdUnitId.isNotEmpty) {
       
  try {
        await RewardedAd.load(
          adUnitId: rewardedAdUnitId,
          request: const AdRequest(),
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (RewardedAd ad) {
              _rewardedAd = ad;
              print("Rewarded Ad loaded successfully!");
            },
            onAdFailedToLoad: (LoadAdError error) {
              print("Failed to load rewarded ad: $error");
            },
          ),
        );
      } catch (e) {
        print("Error loading rewarded ad: $e");
      }

      }
    }
  }

//--new--
  // static Future<void> createRewardedAd() async {
  //   debugPrint(
  //       '================ createRewardedAd : $rewardedAdUnitId ================');
  //   if (Platform.isAndroid) {
  //     try {
  //       await RewardedAd.load(
  //         adUnitId: rewardedAdUnitId,
  //         request: const AdRequest(),
  //         rewardedAdLoadCallback: RewardedAdLoadCallback(
  //           onAdLoaded: (RewardedAd ad) {
  //             _rewardedAd = ad;
  //             print("Rewarded Ad loaded successfully!");
  //           },
  //           onAdFailedToLoad: (LoadAdError error) {
  //             print("Failed to load rewarded ad: $error");
  //           },
  //         ),
  //       );
  //     } catch (e) {
  //       print("Error loading rewarded ad: $e");
  //     }
  //   }
  // }


 static rewardedAd(BuildContext context, VoidCallback callAction) {
    if ((rewardad == "1" && Platform.isAndroid) ||
        (rewardadIos == "1" && Platform.isIOS)) {
      debugPrint("rewardedAd add");
      showRewardedAd(callAction);
    } else {
      debugPrint("rewardedAd action Device");
      callAction();
    }
  }
//new-----
  // static void rewardedAd(BuildContext context, VoidCallback callAction) {
  //   if (Platform.isAndroid) {
  //     showRewardedAd(callAction);
  //   } else {
  //     callAction();
  //   }
  // }

 
//new ----

  static void showRewardedAd(VoidCallback callAction) {
    if (_rewardedAd == null) {
      print("Rewarded ad is not ready yet.");
      callAction(); // Proceed with default action if ad is not ready
      return;
    }

    print("Showing rewarded ad...");
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('ad onAdShowedFullScreenContent.');
        print("Ad dismissed.");
        callAction();
        ad.dispose();
        createRewardedAd(); // Reload the ad after it is dismissed
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print("Failed to show ad: $error");
        callAction();
        ad.dispose();
        createRewardedAd(); // Reload the ad after failure
      },
    );

    _rewardedAd?.setImmersiveMode(true);
    _rewardedAd?.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print("User earned reward: $reward");
    });

    _rewardedAd =
        null; // Set the ad to null once shown to ensure it's only shown once
  }



}

