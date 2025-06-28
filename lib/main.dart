import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:advertising_id/advertising_id.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dtlive/firebase_options.dart';
import 'package:dtlive/pages/splash.dart';
import 'package:dtlive/provider/avatarprovider.dart';
import 'package:dtlive/provider/castdetailsprovider.dart';
import 'package:dtlive/provider/channelsectionprovider.dart';
import 'package:dtlive/provider/showdownloadprovider.dart';
import 'package:dtlive/provider/subhistoryprovider.dart';
import 'package:dtlive/provider/userwallectProvider.dart';
import 'package:dtlive/provider/videodownloadprovider.dart';
import 'package:dtlive/provider/episodeprovider.dart';
import 'package:dtlive/provider/findprovider.dart';
import 'package:dtlive/provider/generalprovider.dart';
import 'package:dtlive/provider/homeprovider.dart';
import 'package:dtlive/provider/paymentprovider.dart';
import 'package:dtlive/provider/playerprovider.dart';
import 'package:dtlive/provider/profileprovider.dart';
import 'package:dtlive/provider/purchaselistprovider.dart';
import 'package:dtlive/provider/rentstoreprovider.dart';
import 'package:dtlive/provider/searchprovider.dart';
import 'package:dtlive/provider/sectionbytypeprovider.dart';
import 'package:dtlive/provider/sectiondataprovider.dart';
import 'package:dtlive/provider/showdetailsprovider.dart';
import 'package:dtlive/provider/subscriptionprovider.dart';
import 'package:dtlive/provider/videobyidprovider.dart';
import 'package:dtlive/provider/videodetailsprovider.dart';
import 'package:dtlive/provider/watchlistprovider.dart';
import 'package:dtlive/tvpages/tvhome.dart';
import 'package:dtlive/utils/adhelper.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/utils/moenage_service.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:moengage_flutter/moengage_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:singular_flutter_sdk/singular.dart';
import 'package:singular_flutter_sdk/singular_config.dart';
import 'package:wakelock/wakelock.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await FlutterDownloader.initialize();
    await MobileAds.instance.initialize();
    await AdHelper.createRewardedAd();
    print("Google Mobile Ads initialized");
    //     MobileAds.instance.updateRequestConfiguration(
    //   RequestConfiguration(
    //     testDeviceIds: ['F707BCE73FCDC4F761ED40ADF21EB962'], // Replace with your device ID
    //   ),
    // );
  }

  await Firebase.initializeApp(
      name: 'chulltv', options: DefaultFirebaseOptions.currentPlatform);
  await Locales.init([
    'en',
    'af',
    'ar',
    'de',
    'es',
    'fr',
    'gu',
    'hi',
    'id',
    'nl',
    'pt',
    'sq',
    'tr',
    'vi'
  ]);

  // Initialize Singular SDK

  // Request App Tracking Transparency Permission
  final trackingStatus =
  await AppTrackingTransparency.requestTrackingAuthorization();
  debugPrint("Tracking Authorization Status: $trackingStatus");

  SingularConfig config = SingularConfig('ott_snap_37c31355',
      '127028793bbb28d66296b90aef4eddec'); // Replace with your SDK Key and Secret
  config.customUserId = "${Constant.userID}"; // Optionally set user ID

// For iOS (Remove this if you are not displaying an ATT prompt)
  config.waitForTrackingAuthorizationWithTimeoutInterval = 300;

  // Enable SkAdNetwork Support (optional for iOS)
  config.skAdNetworkEnabled = true;

  // Start Singular SDK with the configuration
  Singular.start(config);

  debugPrint("Singular SDK Initialized successfully");

  // FlutterError.onError = (FlutterErrorDetails details) {
  //   FlutterError.presentError(details);
  //   // Optionally forward to Crashlytics or other service

  //   MoEProperties properties = MoEProperties();
  //   properties.addAttribute("App_Crash", details);
  //   MoEngageService.instance.trackEvent('App_Crash', properties);
  // };
// Initialize Singular done ---

  // if (!kIsWeb) {
  //   OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  //   // Initialize OneSignal
  //   OneSignal.initialize(Constant.oneSignalAppId);
  //   // OneSignal.Notifications.requestPermission(true);
  //   OneSignal.Notifications.addPermissionObserver((state) {
  //     debugPrint("Has permission ==> $state");
  //   });
  //   OneSignal.User.pushSubscription.addObserver((state) {
  //     debugPrint(
  //         "pushSubscription state ==> ${state.current.jsonRepresentation()}");
  //   });
  //   OneSignal.Notifications.addForegroundWillDisplayListener((event) {
  //     /// preventDefault to not display the notification
  //     event.preventDefault();
  //     // Do async work
  //     /// notification.display() to display after preventing default
  //     event.notification.display();
  //   });
  // }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AvatarProvider()),
        ChangeNotifierProvider(create: (_) => CastDetailsProvider()),
        ChangeNotifierProvider(create: (_) => ChannelSectionProvider()),
        ChangeNotifierProvider(create: (_) => EpisodeProvider()),
        ChangeNotifierProvider(create: (_) => FindProvider()),
        ChangeNotifierProvider(create: (_) => GeneralProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => PurchaselistProvider()),
        ChangeNotifierProvider(create: (_) => RentStoreProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => SectionByTypeProvider()),
        ChangeNotifierProvider(create: (_) => SectionDataProvider()),
        ChangeNotifierProvider(create: (_) => ShowDownloadProvider()),
        ChangeNotifierProvider(create: (_) => ShowDetailsProvider()),
        ChangeNotifierProvider(create: (_) => SubHistoryProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => VideoByIDProvider()),
        ChangeNotifierProvider(create: (_) => VideoDetailsProvider()),
        ChangeNotifierProvider(create: (_) => VideoDownloadProvider()),
        ChangeNotifierProvider(create: (_) => WatchlistProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: const MyApp(),
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

final RouteObserver<ModalRoute<void>> routeObserver =
RouteObserver<ModalRoute<void>>();

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

// Replace with your actual Workspace ID from MoEngage dashboard
// final MoEngageFlutter _moengagePlugin = MoEngageFlutter("F2Z5P8P67ZG4GWG42469CTWX");

class _MyAppState extends State<MyApp> {
  final FirebaseAnalyticsObserver analyticsObserver =
  FirebaseAnalyticsObserver(analytics: analytics);

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  // final _noScreenshot = NoScreenshot.instance;
  @override
  void initState() {
    // _noScreenshot.screenshotOff();
    // if (!kIsWeb) Utils.enableScreenCapture();
    if (!kIsWeb) _getDeviceInfo();
    MoEngageService.initialise();
    MoEngageService.instance.requestPushPermissionAndroid();
    MoEngageService.instance.pushPermissionResponseAndroid(true);
    getAdvertisingId();
    super.initState();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      // Optional: Show a dialog before navigating to settings
      // MoEngageService.instance.navigateToSettingsAndroid();
    }
  }

  @override
  Widget build(BuildContext context) {
    Wakelock.enable();
    final router = GoRouter(
      routes: [
        GoRoute(
            path: '/',
            builder: (_, __) => LocaleBuilder(
              builder: (locale) => MaterialApp(
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                navigatorObservers: [
                  routeObserver,
                  analyticsObserver
                ], //HERE
                theme: ThemeData(
                  primaryColor: colorPrimary,
                  primaryColorDark: colorPrimaryDark,
                  primaryColorLight: primaryLight,
                  scaffoldBackgroundColor: appBgColor,
                ).copyWith(
                  scrollbarTheme: const ScrollbarThemeData().copyWith(
                    thumbColor: MaterialStateProperty.all(white),
                    trackVisibility: MaterialStateProperty.all(true),
                    trackColor: MaterialStateProperty.all(whiteTransparent),
                  ),
                ),
                title: Constant.appName,
                localizationsDelegates: Locales.delegates,
                supportedLocales: Locales.supportedLocales,
                locale: locale,
                localeResolutionCallback:
                    (Locale? locale, Iterable<Locale> supportedLocales) {
                  return locale;
                },
                builder: (context, child) {
                  return ResponsiveBreakpoints.builder(
                    child: child!,
                    breakpoints: [
                      const Breakpoint(start: 0, end: 360, name: MOBILE),
                      const Breakpoint(start: 361, end: 800, name: TABLET),
                      const Breakpoint(
                          start: 801, end: 1000, name: DESKTOP),
                      const Breakpoint(
                          start: 1001, end: double.infinity, name: '4K'),
                    ],
                  );
                },
                home: (kIsWeb)
                    ? const TVHome(pageName: "")
                    : Splash(
                  isDynamicLink: false,
                ),
                scrollBehavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.touch,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.unknown,
                    PointerDeviceKind.trackpad
                  },
                ),
              ),
            )),
        GoRoute(
          path: '/home/:title/:encodedParams',
          builder: (context, state) {
            String encodedParams = state.pathParameters['encodedParams'] ?? '';
            String title = state.pathParameters['title'] ?? '';

            print('Received Encoded Params: $encodedParams');
            print('Received Title: $title');

            List<String> decodedParams = [];
            try {
              decodedParams =
                  utf8.decode(base64Url.decode(encodedParams)).split('-');
              print('Decoded Params: $decodedParams');
            } catch (e) {
              print('Error decoding params: $e');
            }

            if (decodedParams.length != 4) {
              print("Invalid encoded parameters: $decodedParams");
              throw Exception("Invalid encoded parameters");
            }

            return LocaleBuilder(
              builder: (locale) {
                print('Locale: $locale');
                return MaterialApp(
                  navigatorKey: GlobalKey<NavigatorState>(),
                  debugShowCheckedModeBanner: false,
                  navigatorObservers: [routeObserver, analyticsObserver],
                  theme: ThemeData(
                    primaryColor: colorPrimary,
                    primaryColorDark: colorPrimaryDark,
                    primaryColorLight: primaryLight,
                    scaffoldBackgroundColor: appBgColor,
                  ).copyWith(
                    scrollbarTheme: const ScrollbarThemeData().copyWith(
                      thumbColor: MaterialStateProperty.all(white),
                      trackVisibility: MaterialStateProperty.all(true),
                      trackColor: MaterialStateProperty.all(whiteTransparent),
                    ),
                  ),
                  title: Constant.appName,
                  localizationsDelegates: Locales.delegates,
                  supportedLocales: Locales.supportedLocales,
                  locale: locale,
                  localeResolutionCallback:
                      (Locale? locale, Iterable<Locale> supportedLocales) {
                    return locale;
                  },
                  home: Builder(
                    builder: (context) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Utils.openDetailsUsingDynamicLink(
                          context: context,
                          videoId: int.parse(decodedParams[0]),
                          upcomingType: int.parse(decodedParams[3]),
                          videoType: int.parse(decodedParams[2]),
                          typeId: int.parse(decodedParams[1]),
                        );
                      });
                      return const SizedBox(); // Prevents an unnecessary blank screen
                    },
                  ),
                  builder: (context, child) {
                    return ResponsiveBreakpoints.builder(
                      child: child!,
                      breakpoints: [
                        const Breakpoint(start: 0, end: 360, name: MOBILE),
                        const Breakpoint(start: 361, end: 800, name: TABLET),
                        const Breakpoint(start: 801, end: 1000, name: DESKTOP),
                        const Breakpoint(
                            start: 1001, end: double.infinity, name: '4K'),
                      ],
                    );
                  },
                  scrollBehavior: const MaterialScrollBehavior().copyWith(
                    dragDevices: {
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.touch,
                      PointerDeviceKind.stylus,
                      PointerDeviceKind.unknown,
                      PointerDeviceKind.trackpad
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );

    return Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
          LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
        },
        child: LocaleBuilder(
          builder: (localeMain) => MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primaryColor: colorPrimary,
                primaryColorDark: colorPrimaryDark,
                primaryColorLight: primaryLight,
                scaffoldBackgroundColor: appBgColor,
              ).copyWith(
                scrollbarTheme: const ScrollbarThemeData().copyWith(
                  thumbColor: MaterialStateProperty.all(white),
                  trackVisibility: MaterialStateProperty.all(true),
                  trackColor: MaterialStateProperty.all(whiteTransparent),
                ),
              ),
              title: Constant.appName,
              localizationsDelegates: Locales.delegates,
              supportedLocales: Locales.supportedLocales,
              locale: localeMain,
              localeResolutionCallback:
                  (Locale? localeMain, Iterable<Locale> supportedLocales) {
                return localeMain;
              },
              builder: (context, child) {
                return ResponsiveBreakpoints.builder(
                  child: child!,
                  breakpoints: [
                    const Breakpoint(start: 0, end: 360, name: MOBILE),
                    const Breakpoint(start: 361, end: 800, name: TABLET),
                    const Breakpoint(start: 801, end: 1000, name: DESKTOP),
                    const Breakpoint(
                        start: 1001, end: double.infinity, name: '4K'),
                  ],
                );
              },
              routerConfig: router),
        ));
  }

  Future<void> getAdvertisingId() async {
    try {
      // Check the platform (Android or iOS)
      if (kIsWeb) {
        debugPrint("Web platform does not support advertising ID");
        return;
      }

      // For Android
      if (defaultTargetPlatform == TargetPlatform.android) {
        final advertisingId =
        await AdvertisingId.id(false); // Pass false to not limit tracking
        if (advertisingId != null) {
          debugPrint("Google Advertising ID (GAID): $advertisingId");
      
          // Pass GAID to Singular SDK
          Singular.setCustomUserId(advertisingId);
        } else {
          debugPrint("Failed to retrieve Google Advertising ID (GAID)");
        }
      }

      // For iOS
      else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final deviceInfo = DeviceInfoPlugin();
        final iosInfo = await deviceInfo.iosInfo;
        final idfv = iosInfo.identifierForVendor;
        debugPrint("iOS Identifier for Vendor (IDFV): $idfv");

        // If you need to get the IDFA (Advertising Identifier)
        // Note: IDFA requires user permission starting iOS 14.
        // You may use the package 'idfa' to get it, or check the permission status.
      } else {
        debugPrint("Platform not supported for advertising ID retrieval");
      }
    } catch (e) {
      debugPrint("Error fetching Advertising ID: $e");
    }
  }

  _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      Constant.isTV =
          androidInfo.systemFeatures.contains('android.software.leanback');
      Constant.deviceType = "android_app"; // Set device type to Android
      debugPrint("isTV =======================> ${Constant.isTV}");
    } else if (Platform.isIOS) {
      Constant.deviceType = "ios_app"; // Set device type to iOS
    }

    debugPrint("Device Type =======================> ${Constant.deviceType}");
  }
}

//TO BUILD APK
//flutter build appbundle --target-platform android-arm,android-arm64,android-x64
