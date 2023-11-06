// import 'dart:io';
// import 'dart:ui';

// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:dtlive/firebase_options.dart';
// import 'package:dtlive/pages/splash.dart';
// import 'package:dtlive/provider/avatarprovider.dart';
// import 'package:dtlive/provider/castdetailsprovider.dart';
// import 'package:dtlive/provider/channelsectionprovider.dart';
// import 'package:dtlive/provider/showdownloadprovider.dart';
// import 'package:dtlive/provider/subhistoryprovider.dart';
// import 'package:dtlive/provider/videodownloadprovider.dart';
// import 'package:dtlive/provider/episodeprovider.dart';
// import 'package:dtlive/provider/findprovider.dart';
// import 'package:dtlive/provider/generalprovider.dart';
// import 'package:dtlive/provider/homeprovider.dart';
// import 'package:dtlive/provider/paymentprovider.dart';
// import 'package:dtlive/provider/playerprovider.dart';
// import 'package:dtlive/provider/profileprovider.dart';
// import 'package:dtlive/provider/purchaselistprovider.dart';
// import 'package:dtlive/provider/rentstoreprovider.dart';
// import 'package:dtlive/provider/searchprovider.dart';
// import 'package:dtlive/provider/sectionbytypeprovider.dart';
// import 'package:dtlive/provider/sectiondataprovider.dart';
// import 'package:dtlive/provider/showdetailsprovider.dart';
// import 'package:dtlive/provider/subscriptionprovider.dart';
// import 'package:dtlive/provider/videobyidprovider.dart';
// import 'package:dtlive/provider/videodetailsprovider.dart';
// import 'package:dtlive/provider/watchlistprovider.dart';
// import 'package:dtlive/tvpages/tvhome.dart';
// import 'package:dtlive/utils/color.dart';
// import 'package:dtlive/utils/constant.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:flutter_locales/flutter_locales.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:responsive_framework/responsive_framework.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   if (!kIsWeb) {
//     await FlutterDownloader.initialize();
//     await MobileAds.instance.initialize();
//   }
//   await Firebase.initializeApp(
//       name: 'amuzi-5f9d4', options: DefaultFirebaseOptions.currentPlatform);
//   await Locales.init([
//     'en',
//     'af',
//     'ar',
//     'de',
//     'es',
//     'fr',
//     'gu',
//     'hi',
//     'id',
//     'nl',
//     'pt',
//     'sq',
//     'tr',
//     'vi'
//   ]);

//   if (!kIsWeb) {
//     OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
//     // Initialize OneSignal
//     OneSignal.initialize(Constant.oneSignalAppId);
//     OneSignal.Notifications.requestPermission(true);
//     OneSignal.Notifications.addPermissionObserver((state) {
//       debugPrint("Has permission ==> $state");
//     });
//     OneSignal.User.pushSubscription.addObserver((state) {
//       debugPrint(
//           "pushSubscription state ==> ${state.current.jsonRepresentation()}");
//     });
//     OneSignal.Notifications.addForegroundWillDisplayListener((event) {
//       /// preventDefault to not display the notification
//       event.preventDefault();
//       // Do async work
//       /// notification.display() to display after preventing default
//       event.notification.display();
//     });
//   }
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AvatarProvider()),
//         ChangeNotifierProvider(create: (_) => CastDetailsProvider()),
//         ChangeNotifierProvider(create: (_) => ChannelSectionProvider()),
//         ChangeNotifierProvider(create: (_) => EpisodeProvider()),
//         ChangeNotifierProvider(create: (_) => FindProvider()),
//         ChangeNotifierProvider(create: (_) => GeneralProvider()),
//         ChangeNotifierProvider(create: (_) => HomeProvider()),
//         ChangeNotifierProvider(create: (_) => PaymentProvider()),
//         ChangeNotifierProvider(create: (_) => PlayerProvider()),
//         ChangeNotifierProvider(create: (_) => ProfileProvider()),
//         ChangeNotifierProvider(create: (_) => PurchaselistProvider()),
//         ChangeNotifierProvider(create: (_) => RentStoreProvider()),
//         ChangeNotifierProvider(create: (_) => SearchProvider()),
//         ChangeNotifierProvider(create: (_) => SectionByTypeProvider()),
//         ChangeNotifierProvider(create: (_) => SectionDataProvider()),
//         ChangeNotifierProvider(create: (_) => ShowDownloadProvider()),
//         ChangeNotifierProvider(create: (_) => ShowDetailsProvider()),
//         ChangeNotifierProvider(create: (_) => SubHistoryProvider()),
//         ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
//         ChangeNotifierProvider(create: (_) => VideoByIDProvider()),
//         ChangeNotifierProvider(create: (_) => VideoDetailsProvider()),
//         ChangeNotifierProvider(create: (_) => VideoDownloadProvider()),
//         ChangeNotifierProvider(create: (_) => WatchlistProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
//   SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.landscapeLeft,
//     DeviceOrientation.landscapeRight,
//   ]);
// }

// final RouteObserver<ModalRoute<void>> routeObserver =
//     RouteObserver<ModalRoute<void>>();

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   @override
//   void initState() {
//     // if (!kIsWeb) Utils.enableScreenCapture();
//     if (!kIsWeb) _getDeviceInfo();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Shortcuts(
//       shortcuts: <LogicalKeySet, Intent>{
//         LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
//         LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
//       },
//       child: LocaleBuilder(
//         builder: (locale) => MaterialApp(
//           navigatorKey: navigatorKey,
//           debugShowCheckedModeBanner: false,
//           navigatorObservers: [routeObserver], //HERE
//           theme: ThemeData(
//             primaryColor: colorPrimary,
//             primaryColorDark: colorPrimaryDark,
//             primaryColorLight: primaryLight,
//             scaffoldBackgroundColor: appBgColor,
//           ).copyWith(
//             scrollbarTheme: const ScrollbarThemeData().copyWith(
//               thumbColor: MaterialStateProperty.all(white),
//               trackVisibility: MaterialStateProperty.all(true),
//               trackColor: MaterialStateProperty.all(whiteTransparent),
//             ),
//           ),
//           title: Constant.appName,
//           localizationsDelegates: Locales.delegates,
//           supportedLocales: Locales.supportedLocales,
//           locale: locale,
//           localeResolutionCallback:
//               (Locale? locale, Iterable<Locale> supportedLocales) {
//             return locale;
//           },
//           builder: (context, child) {
//             return ResponsiveBreakpoints.builder(
//               child: child!,
//               breakpoints: [
//                 const Breakpoint(start: 0, end: 360, name: MOBILE),
//                 const Breakpoint(start: 361, end: 800, name: TABLET),
//                 const Breakpoint(start: 801, end: 1000, name: DESKTOP),
//                 const Breakpoint(start: 1001, end: double.infinity, name: '4K'),
//               ],
//             );
//           },
//           home: (kIsWeb) ? const TVHome(pageName: "") : const Splash(),
//           scrollBehavior: const MaterialScrollBehavior().copyWith(
//             dragDevices: {
//               PointerDeviceKind.mouse,
//               PointerDeviceKind.touch,
//               PointerDeviceKind.stylus,
//               PointerDeviceKind.unknown,
//               PointerDeviceKind.trackpad
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   _getDeviceInfo() async {
//     if (Platform.isAndroid) {
//       DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//       AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//       Constant.isTV =
//           androidInfo.systemFeatures.contains('android.software.leanback');
//       debugPrint("isTV =======================> ${Constant.isTV}");
//     }
//   }
// }


// //TO BUILD APK
// //flutter build appbundle --target-platform android-arm,android-arm64,android-x64



import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dtlive/firebase_options.dart';
import 'package:dtlive/pages/splash.dart';
import 'package:dtlive/provider/avatarprovider.dart';
import 'package:dtlive/provider/castdetailsprovider.dart';
import 'package:dtlive/provider/channelsectionprovider.dart';
import 'package:dtlive/provider/showdownloadprovider.dart';
import 'package:dtlive/provider/subhistoryprovider.dart';
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
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await FlutterDownloader.initialize();
    await MobileAds.instance.initialize();
  }
  await Firebase.initializeApp(
      name: 'amuzi-5f9d4', options: DefaultFirebaseOptions.currentPlatform);
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

  if (!kIsWeb) {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    // Initialize OneSignal
    OneSignal.initialize(Constant.oneSignalAppId);
    OneSignal.Notifications.requestPermission(true);
    OneSignal.Notifications.addPermissionObserver((state) {
      debugPrint("Has permission ==> $state");
    });
    OneSignal.User.pushSubscription.addObserver((state) {
      debugPrint(
          "pushSubscription state ==> ${state.current.jsonRepresentation()}");
    });
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      /// preventDefault to not display the notification
      event.preventDefault();
      // Do async work
      /// notification.display() to display after preventing default
      event.notification.display();
    });
  }
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
      ],
      child: const MyApp(),
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    // if (!kIsWeb) Utils.enableScreenCapture();
    if (!kIsWeb) _getDeviceInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
            path: '/',
            builder: (_, __) => LocaleBuilder(
                  builder: (locale) => MaterialApp(
                    navigatorKey: navigatorKey,
                    debugShowCheckedModeBanner: false,
                    navigatorObservers: [routeObserver], //HERE
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
            path: '/videodetails/:typeId/:videoId/:upcomingType/:videoType',
            builder: (context, state) => LocaleBuilder(
                  builder: (locale) => MaterialApp(
                    navigatorKey: navigatorKey,
                    debugShowCheckedModeBanner: false,
                    navigatorObservers: [routeObserver], //HERE
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
                    home: Splash(
                      isDynamicLink: true,
                      videoType: int.parse(
                          state.pathParameters['videoType'].toString()),
                      upcomingType: int.parse(
                          state.pathParameters['upcomingType'].toString()),
                      videoId:
                          int.parse(state.pathParameters['videoId'].toString()),
                      typeId:
                          int.parse(state.pathParameters['typeId'].toString()),
                    ),

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
                    // home: (kIsWeb) ? const TVHome(pageName: "") : const Splash(),
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

  _getDeviceInfo() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      Constant.isTV =
          androidInfo.systemFeatures.contains('android.software.leanback');
      debugPrint("isTV =======================> ${Constant.isTV}");
    }
  }
}

//TO BUILD APK
//flutter build appbundle --target-platform android-arm,android-arm64,android-x64
