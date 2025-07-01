import 'package:avatar_glow/avatar_glow.dart';
import 'package:dtlive/main.dart';
import 'package:dtlive/pages/search.dart';
import 'package:dtlive/pages/sectionbytype.dart';
import 'package:dtlive/provider/findprovider.dart';
import 'package:dtlive/shimmer/shimmerutils.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:dtlive/widget/myimage.dart';
import 'package:dtlive/widget/mytext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:moengage_flutter/moengage_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:singular_flutter_sdk/singular.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../utils/moenage_service.dart';
import '../utils/sharedpre.dart';

class Find extends StatefulWidget {
  const Find({Key? key}) : super(key: key);

  @override
  State<Find> createState() => FindState();
}

class FindState extends State<Find> {
  final searchController = TextEditingController();
  late FindProvider findProvider;
  final SpeechToText _speechToText = SpeechToText();
  bool speechEnabled = false, _isListening = false;
  String _lastWords = '';
  late BuildContext dialogContext;
  String?   userMobileNo;
  SharedPre sharedPref = SharedPre();
  @override
  void initState() {
    super.initState();
    _getData();
    findProvider = Provider.of<FindProvider>(context, listen: false);
    getUserData();
    trackMoEngageEventOnce();
  }
  bool _eventTracked = false;

  void trackMoEngageEventOnce() {
    if (_eventTracked) return;
    _eventTracked = true;

                analytics.logEvent(
  name: "Search_screen_view",
  parameters: {
    "screen_name": "Find Screen",
    "user_id": Constant.userID,
  },
);

    Map<String, Object> screenViewEvent = {
      'screen_name': 'Search Screen',
      'user_id': Constant.userID.toString(),
    };

    Singular.eventWithArgs('Search_screen_view', screenViewEvent);


    final properties = MoEProperties()
      ..addAttribute('screen_name', 'Search Screen')
      ..addAttribute('user_id', Constant.userID.toString())

      ..addAttribute('timestamp', DateTime.now().toIso8601String());


    Future.delayed(Duration(seconds: 2), () {
      MoEngageService.instance.trackEvent('Search_screen_view', properties);
    });


  }
  getUserData() async {
    userMobileNo = await sharedPref.read("usermobile");
    debugPrint('getUserData userMobileNo1 ==> $userMobileNo');
  }
  /// Start listening to speech
  void _startListening() async {
    debugPrint("<============== _startListening ==============>");
    // ✅ Request ONLY microphone permission
    var micStatus = await Permission.microphone.request();

    if (micStatus.isPermanentlyDenied) {
      _showPermissionDialog();
      return;
    }

    if (!micStatus.isGranted) {
      // Optional: show message if permission not granted
      // Utils.showSnackbar(context, "info", "Microphone permission not granted", true);
      return;
    }

    // Always re-initialize before listening
    speechEnabled = await _speechToText.initialize(
      onStatus: (status) => debugPrint("Speech status: $status"),
      onError: (error) => debugPrint("Speech error: $error"),
    );

// Initialize speech recognition here
    if (!_speechToText.isAvailable) {
      speechEnabled = await _speechToText.initialize();
    }

    if (!speechEnabled) {
      // Utils.showSnackbar(context, "info", "Microphone permission denied", true);
      return;
    }

    // Show a listening animation dialog
    showDialog(
      context: context,
      barrierDismissible:
          true, // Prevents dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        dialogContext = context; // Save the dialog context to close it later
        return AlertDialog(
          backgroundColor: colorPrimaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AvatarGlow(
                glowColor: Colors.blue,
                endRadius: 50,
                duration: const Duration(milliseconds: 2000),
                repeat: true,
                child: Icon(CupertinoIcons.mic, color: white, size: 40),
              ),
              const SizedBox(height: 10),
              Text(
                "Listening...",
                style: TextStyle(color: white),
              ),
            ],
          ),
        );
      },
    );

    // Start listening to speech input
    await _speechToText.listen(
        onResult: _onSpeechResult, listenMode: ListenMode.dictation);

    setState(() {
      _isListening = true;
    });

    // Delay logic to check if speech input is available
    Future.delayed(const Duration(seconds: 5), () {
      if (_isListening && searchController.text.toString().isEmpty) {
        // Utils.showSnackbar(context, "info", "speechnotavailable", true);
        _stopListening();
      }
    });
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
            'Microphone permission is permanently denied. Please enable it from app settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings(); // Opens system app settings
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Stop listening to speech
  void _stopListening() async {
    debugPrint("<============== _stopListening ==============>");
    await _speechToText.stop();

    if (!mounted) return;
    setState(() {
      _lastWords = '';
      _isListening = false;
    });

    // Close the listening popup
    if (Navigator.canPop(dialogContext)) {
      Navigator.of(dialogContext).pop();
    }

    // Perform search after stopping the listening
    if (_lastWords.isNotEmpty) {
      searchController.text = _lastWords.toString();
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return Search(searchText: searchController.text.toString());
          },
        ),
      );
      setState(() {
        _lastWords = '';
        searchController.clear();
      });
    }
  }

  /// Callback when speech is recognized
  void _onSpeechResult(SpeechRecognitionResult result) async {
    _lastWords = result.recognizedWords;

    if (result.finalResult && _lastWords.isNotEmpty) {
      // Close the dialog immediately when result is available
      if (Navigator.canPop(dialogContext)) {
        Navigator.pop(dialogContext); // Close the dialog first
      }

      // Stop listening immediately after getting the result
      await _speechToText.stop();
      setState(() {
        _isListening = false;
      });

      // Perform the search
      searchController.text = _lastWords;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Search(searchText: _lastWords),
        ),
      );

      setState(() {
        _lastWords = '';
        searchController.clear();
      });
    }
  }

  void _getData() async {
    findProvider = Provider.of<FindProvider>(context, listen: false);
    findProvider.getSectionType();
    findProvider.getGenres();
    findProvider.getLanguage();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (_isListening) {
      _stopListening();
    }
    // _stopListening();
    searchController.dispose();
    findProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: appBgColor,
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: white,
          color: complimentryColor,
          displacement: 80,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 1500))
                .then((value) {
              _getData();
            });
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 15),
                /* Search Box */
                searchBox(),
                const SizedBox(height: 22),

                /* Genres */
                Consumer<FindProvider>(
                  builder: (context, findProvider, child) {
                    debugPrint(
                        "setGenresSize  ===>  ${findProvider.setGenresSize}");
                    debugPrint(
                        "genresModel Size  ===>  ${(findProvider.genresModel.result?.length ?? 0)}");
                    if (findProvider.loading) {
                      return ShimmerUtils.buildFindShimmer(context);
                    } else {
                      if (findProvider.genresModel.status == 200) {
                        if (findProvider.genresModel.result != null &&
                            (findProvider.genresModel.result?.length ?? 0) >
                                0) {
                          return Column(
                            children: [
                              /* Browse by START */
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                alignment: Alignment.centerLeft,
                                child: MyText(
                                  color: white,
                                  text: "browsby",
                                  multilanguage: true,
                                  textalign: TextAlign.center,
                                  fontsizeNormal: 15,
                                  fontsizeWeb: 16,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontweight: FontWeight.w600,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                              const SizedBox(height: 10),
                              AlignedGridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                itemCount: (findProvider
                                        .sectionTypeModel.result?.length ??
                                    0),
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder:
                                    (BuildContext context, int position) {
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(4),
                                    onTap: () {
                                      debugPrint("Item Clicked! => $position");
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => SectionByType(
                                              findProvider.sectionTypeModel
                                                      .result?[position].id ??
                                                  0,
                                              findProvider.sectionTypeModel
                                                      .result?[position].name ??
                                                  "",
                                              "2"),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 65,
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 10, 0),
                                      decoration: BoxDecoration(
                                        color: colorPrimaryDark,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      alignment: Alignment.center,
                                      child: MyText(
                                        color: white,
                                        text: findProvider.sectionTypeModel
                                                .result?[position].name ??
                                            "",
                                        textalign: TextAlign.center,
                                        fontstyle: FontStyle.normal,
                                        multilanguage: false,
                                        fontsizeNormal: 14,
                                        fontsizeWeb: 14,
                                        fontweight: FontWeight.w600,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              /* Browse by END */
                            ],
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      } else {
                        return const SizedBox.shrink();
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget searchBox() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 55,
      margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      decoration: BoxDecoration(
        color: colorPrimaryDark,
        border: Border.all(
          color: primaryLight,
          width: 0.5,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: MyImage(
              width: 20,
              height: 20,
              imagePath: "ic_find.png",
              color: white,
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: TextField(
                onSubmitted: (value) async {
                  if (value.isNotEmpty) {
                    Map<String, Object> screenViewEvent = {
                      'screen_name': 'Content_Searched',
                      "search_item": value,
                      'user_id': Constant.userID.toString(),
                    };
                    Singular.eventWithArgs('Content_Searched', screenViewEvent);
                    final timestamp = DateTime.now().toIso8601String();
                    MoEngageService.instance
                        .setUserName(userMobileNo.toString());
                    final properties = MoEProperties()
                      ..addAttribute('user_id', Constant.userID.toString())
                      ..addAttribute('search_query', value)
                      ..addAttribute('timestamp', timestamp);

                    MoEngageService.instance
                        .trackEvent('Content_Searched', properties);

                    print(
                        "MoEngage event tracked with and timestamp: $timestamp");
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Search(searchText: value.toString());
                        },
                      ),
                    );
                    setState(() {
                      searchController.clear();
                    });
                  }
                },
                controller: searchController,
                style: const TextStyle(
                  color: white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search here...',
                  hintStyle: TextStyle(
                    color: otherColor,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          Consumer<FindProvider>(
            builder: (context, findProvider, child) {
              return InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () {
                  if (_isListening) {
                    _stopListening();
                  } else {
                    _startListening();
                  }
                },
                child: _isListening
                    ? AvatarGlow(
                        glowColor: colorPrimary,
                        endRadius: 25,
                        duration: const Duration(milliseconds: 2000),
                        repeat: true,
                        child: Container(
                          height: 25,
                          child: MyImage(
                            imagePath: "ic_voice.png",
                            color: white,
                            fit: BoxFit.fill,
                            height: 20,
                            width: 20,
                          ),
                        ),
                      )
                    : Container(
                        height: 25,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: MyImage(
                            imagePath: "ic_voice.png",
                            color: white,
                            fit: BoxFit.fill,
                            height: 20,
                            width: 20,
                          ),
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}
