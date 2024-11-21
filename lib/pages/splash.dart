import 'package:dtlive/main.dart';
import 'package:dtlive/pages/bottombar.dart';
import 'package:dtlive/provider/homeprovider.dart';
import 'package:dtlive/tvpages/tvhome.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/widget/myimage.dart';
import 'package:dtlive/utils/sharedpre.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dtlive/utils/utils.dart';
import 'package:video_player/video_player.dart';

class Splash extends StatefulWidget {
  final bool isDynamicLink;
  final int? videoId;
  final int? upcomingType;
  final int? videoType;
  final int? typeId;

  Splash(
      {Key? key,
      required this.isDynamicLink,
      this.videoId,
      this.upcomingType,
      this.videoType,
      this.typeId})
      : super(key: key);

  @override
  State<Splash> createState() => SplashState();
}

class SplashState extends State<Splash> {
  String? seen;
  SharedPre sharedPre = SharedPre();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    // Simulating a delay of 5 seconds before proceeding to the next screen
    Future.delayed(const Duration(seconds: 3)).then((value) {
      if (!mounted) return;
      isFirstCheck();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    analytics.logEvent(
  name: "screen_view",
  parameters: {
    "screen_name": "Splash Screen",
     "user_id": Constant.userID, 

  },
);
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        color: Colors.transparent, // Set to transparent if needed
        child: MyImage(
          imagePath: (kIsWeb || Constant.isTV) ? "appicon.png" : "splash.png",
          fit: (kIsWeb || Constant.isTV) ? BoxFit.contain : BoxFit.cover,
        ),
      ),
    );
  }

  Future<void> isFirstCheck() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    await homeProvider.setLoading(true);

    seen = await sharedPre.read('seen') ?? "0";
    Constant.userID = await sharedPre.read('userid');
    debugPrint('seen ==> $seen');
    debugPrint('Constant userID ==> ${Constant.userID}');
    if (!mounted) return;
    if (kIsWeb || Constant.isTV) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const TVHome(pageName: "");
          },
        ),
      );
    } else {
      if (widget.isDynamicLink) {
        // log("DYNAMIC LINK");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Bottombar();
            },
          ),
        );

        Future.delayed(Duration.zero).then((value) {
          if (!mounted) return;
          Utils.openDetails(
              context: context,
              videoId: widget.videoId!,
              upcomingType: widget.upcomingType!,
              videoType: widget.videoType!,
              typeId: widget.videoId!);
        });
      } else {
        if (seen == "1") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const Bottombar();
              },
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Bottombar();
              },
            ),
          );
        }
      }
    }
  }
}
