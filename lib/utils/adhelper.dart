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
  static String? banneradidios;

  static var rewardad = "";
  static var rewardadIos = "";

  static var bannerad = "";
  static var interstitalad = "";

  static var banneradIos = "";

  static RewardedAd? _rewardedAd;

  static AdRequest request = AdRequest(
    keywords: <String>[Constant.appName, 'Railpitara'],
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

    //bannner ads ---
    bannerad = await sharePref.read("banner_ad") ?? "";
    banneradIos = await sharePref.read("ios_banner_ad") ?? "";
    banneradid = await sharePref.read("banner_adid") ?? "";
    banneradidios = await sharePref.read("ios_banner_adid") ?? "";

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

  // Banner Ad
  static Widget bannerAd(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        if (bannerad == "1") {
          if (bannerAdUnitId != "null" || bannerAdUnitId.isNotEmpty) {
            if (!(isPremiumBuy ?? false)) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: AdSize.banner.height.toDouble(),
                  child: AdWidget(
                    ad: createBannerAd()..load(),
                    key: UniqueKey(),
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          } else {
            return const SizedBox.shrink();
          }
        } else {
          return const SizedBox.shrink();
        }
      } else if (Platform.isIOS) {
        if (banneradIos == "1") {
          if (bannerAdUnitId != "null" || bannerAdUnitId.isNotEmpty) {
            if (!(isPremiumBuy ?? false)) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: AdSize.banner.height.toDouble(),
                  child: AdWidget(
                    ad: createBannerAd()..load(),
                    key: UniqueKey(),
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          } else {
            return const SizedBox.shrink();
          }
        } else {
          return const SizedBox.shrink();
        }
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  static BannerAd createBannerAd() {
    BannerAd? bannerAd;
    debugPrint(
        '================ bannerAdUnitId : $bannerAdUnitId ================');
    bannerAd = BannerAd(
      size: AdSize.fullBanner,
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => debugPrint('BannerAd Loaded'),
        onAdClosed: (Ad ad) => debugPrint('BannerAd Closed'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
        onAdOpened: (Ad ad) => debugPrint('BannerAd Open'),
      ),
    );
    return bannerAd;
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return banneradid.toString();
    } else if (Platform.isIOS) {
      return banneradidios.toString();
    } else {
      throw UnsupportedError('Unsupported platform');
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

  static void rewardedAd(BuildContext context, VoidCallback callAction) {
    if ((rewardad == "1" && Platform.isAndroid) ||
        (rewardadIos == "1" && Platform.isIOS)) {
      debugPrint("rewardedAd add");

      // Provide both the onAdCompleted and onAdFailed callbacks using named parameters
      showRewardedAd(
        onAdCompleted: () {
          // Ad completed successfully, perform the desired action
          debugPrint("Ad completed successfully");
          callAction();
        },
        onAdFailed: () {
          // Ad failed to show, fallback to the action
          debugPrint("Ad failed to show");
          callAction();
        },
      );
    } else {
      debugPrint("rewardedAd action Device");
      callAction();
    }
  }

//new ----

// static void showRewardedAd(VoidCallback onAdCompleted, VoidCallback onAdFailed) {
//   if (_rewardedAd == null) {
//     print("Rewarded ad is not ready yet.");
//     onAdFailed(); // Call the failure callback if the ad is not ready
//     return;
//   }

//   print("Showing rewarded ad...");
//   _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
//     onAdDismissedFullScreenContent: (RewardedAd ad) {
//       print("Ad dismissed.");
//       onAdCompleted(); // Proceed with the API call after the ad is dismissed
//       ad.dispose();
//       createRewardedAd(); // Reload the ad after it is dismissed
//     },
//     onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
//       print("Failed to show ad: $error");
//       onAdFailed(); // Call the failure callback if the ad fails to display
//       ad.dispose();
//       createRewardedAd(); // Reload the ad after failure
//     },
//   );

//   _rewardedAd?.setImmersiveMode(true);
//   _rewardedAd?.show(
//       onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
//     print("User earned reward: $reward");
//   });

//   _rewardedAd = null; // Set the ad to null once shown to ensure it's only shown once
// }
  static void showRewardedAd(
      {required VoidCallback onAdCompleted, required VoidCallback onAdFailed}) {
    if (_rewardedAd == null) {
      print("Rewarded ad is not ready yet.");
      onAdFailed(); // Ad is not ready, invoke failure callback
      return;
    }

    print("Showing rewarded ad...");

    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        print("Ad is now showing...");
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print("Ad dismissed by the user.");
        ad.dispose();
        createRewardedAd(); // Reload the ad for future use
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print("Failed to show ad: $error");
        onAdFailed();
        ad.dispose();
        createRewardedAd(); // Reload the ad for future use
      },
    );

    _rewardedAd?.setImmersiveMode(true);

    // Reward the user only if they complete the ad
    _rewardedAd?.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print("User earned reward: ${reward.amount} ${reward.type}");
      onAdCompleted(); // Trigger logic only when reward is earned
    });

    _rewardedAd = null; // Reset the ad reference
  }

  // static void showRewardedAd(VoidCallback callAction) {
  //   if (_rewardedAd == null) {
  //     print("Rewarded ad is not ready yet.");
  //     callAction(); // Proceed with default action if ad is not ready
  //     return;
  //   }

  //   print("Showing rewarded ad...");
  //   _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
  //     onAdDismissedFullScreenContent: (RewardedAd ad) {
  //       debugPrint('ad onAdShowedFullScreenContent.');
  //       print("Ad dismissed.");
  //       callAction();
  //       ad.dispose();
  //       createRewardedAd(); // Reload the ad after it is dismissed
  //     },
  //     onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
  //       print("Failed to show ad: $error");
  //       callAction();
  //       ad.dispose();
  //       createRewardedAd(); // Reload the ad after failure
  //     },
  //   );

  //   _rewardedAd?.setImmersiveMode(true);
  //   _rewardedAd?.show(
  //       onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
  //     print("User earned reward: $reward");
  //   });

  //   _rewardedAd =
  //       null; // Set the ad to null once shown to ensure it's only shown once
  // }
}
