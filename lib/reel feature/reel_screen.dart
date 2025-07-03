import 'package:dtlive/reel%20feature/content_screen.dart';
import 'package:dtlive/subscription/subscription.dart';
import 'package:dtlive/utils/color.dart';
import 'package:dtlive/utils/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReelScreen extends StatefulWidget {
  final int videoId;
  final int videoType;
  final int typeId;
  final dynamic nameReelVideo;

  const ReelScreen(
      {Key? key,
      required this.videoId,
      required this.videoType,
      required this.typeId,
      required this.nameReelVideo})
      : super(key: key);

  @override
  _ReelScreenState createState() => _ReelScreenState();
}

class _ReelScreenState extends State<ReelScreen> {
  List<Map<String, String>> videos = [];
  int currentPage = 1;
  int lastPage = 1;
  int totalReels = 0;
  dynamic reelName = 'Reel';
  bool isLoading = false;
  final Map<int, VideoPlayerController> _controllers = {};
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    print("----${Constant.userID}");
    super.initState();
    fetchReels().then((_) {
      if (videos.isNotEmpty) {
        _initializeController(0);
        _playController(0);
      }
    });
  }

  @override
  void dispose() {
    debugPrint("[DEBUG] Disposing all video controllers...");

    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();

    _pageController.dispose();
    super.dispose();
  }

bool _showSubscriptionBox = false;
void _playController(int index) {
  debugPrint("[DEBUG] Request to play video at index: $index");

  // Pause the currently playing video
  if (_controllers.containsKey(_currentIndex)) {
    debugPrint("[DEBUG] Pausing current video at index: $_currentIndex");
    _controllers[_currentIndex]?.pause();
  }

  String isPremium = videos[index]['is_premium'] ?? '0';
  String isBuy = videos[index]['is_premium_buy'] ?? '0';

  debugPrint("[DEBUG] Video Index: $index | is_premium: $isPremium | is_buy: $isBuy");

  // ✅ Check access before updating _currentIndex or playing video
  if (isPremium == '1' && isBuy != '1') {
    debugPrint("[DEBUG] ❌ Premium video – show subscription popup.");

    // ✅ Force pause the target video
    if (_controllers.containsKey(index)) {
      _controllers[index]?.pause();
      debugPrint("[DEBUG] ⏸️ Paused premium video at index: $index");
    }

    setState(() {
      _showSubscriptionBox = true;
    });

    return;
  }

  // ✅ Only update currentIndex and play if allowed
  _currentIndex = index;

  if (_controllers.containsKey(index)) {
    debugPrint("[DEBUG] ✅ Playing video at index: $index");
    _controllers[index]?.play();
  } else {
    debugPrint("[ERROR] ⚠️ Video at index: $index not found in controllers");
  }
}


  Widget _buildSubscriptionBox() {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 30),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           Image(image: AssetImage("assets/images/appicon.png"),height: 70,),
            SizedBox(height: 10),
            Text(
              "Premium Content",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "To watch this reel, you need an active subscription.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _showSubscriptionBox = false;
                      });

                      // ✅ Exit the Reel screen
                      Navigator.pop(context);
                    },
                    child: Text("Maybe Later"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _showSubscriptionBox = false;
                      });
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Subscription(),
                        ),
                      );
                    },
                    child: Text("Subscribe Now"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _initializeController(int startIndex) {
    for (int i = startIndex; i < videos.length; i++) {
      if (!_controllers.containsKey(i)) {
        debugPrint("[DEBUG] Initializing video at index: $i");

        // Declare the controller first
        final VideoPlayerController controller =
            VideoPlayerController.network(videos[i]['video']!);

        // Initialize the controller
        controller.initialize().then((_) {
          setState(() {});

          // Add listener for video completion
          controller.addListener(() {
            if (controller.value.position >= controller.value.duration &&
                !controller.value.isPlaying) {
              _onVideoComplete(i);
            }
          });
        });

        _controllers[i] = controller;
      }
    }
  }

  void _onVideoComplete(int index) {
    debugPrint("[DEBUG] Video at index $index completed.");

    if (index + 1 < videos.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _playController(index + 1);
    } else {
      debugPrint("[DEBUG] No more reels available to play.");
    }
  }

  Future<void> fetchReels({int? page}) async {
    if (isLoading || (page != null && page > lastPage)) return;

    setState(() => isLoading = true);

    final url = Uri.parse('${Constant.baseurl}reels-video');
    final requestBody = {
      "type_id": widget.typeId,
      "video_type": widget.videoType,
      "video_id": widget.videoId,
      "page": page ?? currentPage,
      "user_id": Constant.userID,
    };

    debugPrint("[DEBUG] Sending Request to API: $url");
    debugPrint("[DEBUG] Request Body: ${jsonEncode(requestBody)}");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      debugPrint(
          "[DEBUG] API Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> reels = data['result']['data'] ?? [];
        lastPage = data['result']['last_page'] ?? lastPage;
        totalReels = data['result']['total'] ?? totalReels;

        if (reels.isNotEmpty) {
          setState(() {
            int previousLength = videos.length;

            videos.addAll(reels
                .map((reel) {
                  debugPrint(
                      "[DEBUG] Reel ID: ${reel['id']} -> is_buy: ${reel['is_buy']}");

                  return {
                    'video': reel['video_320'] as String? ?? '',
                    'thumbnail': reel['thumbnail'] as String? ?? '',
                    'name': reel['name'] as String? ?? 'Reel',
                    'is_premium': reel['is_premium'].toString(),
                    'is_premium_buy': reel['is_buy'].toString(),
                  };
                })
                .where((map) => map['video']!.isNotEmpty)
                .toList());

            currentPage++; // Move to next page **only if we got new data**

            debugPrint(
                "[DEBUG] Added ${videos.length - previousLength} new videos. Total videos: ${videos.length}");
          });

          _initializeController(videos.length - reels.length);
        } else {
          debugPrint("[WARNING] No more reels found for page $page.");
        }
      } else {
        debugPrint(
            "[ERROR] API Request Failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("[ERROR] Network Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _jumpToReel(int targetIndex) async {
    debugPrint("[DEBUG] User requested to jump to reel at index: $targetIndex");

    // If the target index is already available, navigate immediately
    if (targetIndex < videos.length) {
      _navigateToReel(targetIndex);
      return;
    }

    // Determine which page should contain the target index
    int targetPage = (targetIndex ~/ 6) + 1;
    debugPrint(
        "[DEBUG] Fetching additional reels for target index: $targetIndex (page $targetPage)");

    while (videos.length <= targetIndex && currentPage <= lastPage) {
      debugPrint("[DEBUG] Fetching reels for page: $currentPage");

      await fetchReels(page: currentPage);

      // If after fetching, we have enough videos, navigate to the target index
      if (videos.length > targetIndex) {
        _navigateToReel(targetIndex);
        return;
      }

      // If no more pages exist, break the loop
      if (currentPage > lastPage) {
        break;
      }
    }

    debugPrint(
        "[ERROR] Reel data still missing after loading, please try again!");
  }

  void _navigateToReel(int index) {
    debugPrint("[DEBUG] Navigating to reel at index: $index");

    // **Step 1: Pause all active controllers before jumping**
    for (var controller in _controllers.values) {
      if (controller.value.isPlaying) {
        controller.pause();
      }
    }

    // **Step 2: Jump to the selected reel and update the current index**
    if (index >= 0 && index < videos.length) {
      _currentIndex = index;
      _pageController.jumpToPage(index);

      // **Step 3: Ensure the selected reel starts playing**
      _playController(index);

      setState(() {}); // Refresh UI
    }
  }

  void _showReelSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows dynamic height based on content
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context)
                .viewInsets
                .bottom, // Dynamic bottom padding
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height *
                  0.9, // Allows more space if needed
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Makes height dynamic
              children: [
                const SizedBox(height: 10),

                // Title Row with Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.nameReelVideo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        CupertinoIcons.xmark, // Cupertino close button
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Transparent Container with Episode Count
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1), // Transparent effect
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "All $totalReels Episodes", // Dynamic count
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12, // Small text size
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Grid View of Episodes (6 per row, Square Boxes)
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6, // 6 items per row
                      crossAxisSpacing: 10, // More spacing for better look
                      mainAxisSpacing: 10, // More spacing for better look
                      childAspectRatio: 1, // Ensuring square shape
                    ),
                    itemCount: totalReels,
                    itemBuilder: (context, index) {
                      bool isPlaying = _currentIndex == index;
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _jumpToReel(index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isPlaying
                                ? colorPrimary
                                : Colors.grey[800], // Darker background
                            borderRadius:
                                BorderRadius.circular(8), // Rounded corners
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15, // Bigger font size
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Spacing for Dynamic Height
                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }

@override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      if (_showSubscriptionBox) {
        // ✅ If popup is visible, treat back press as "Maybe Later"
        Navigator.pop(context); // Exit the reel screen completely
        return false;
      }

      return true; // default back behavior
    },
      child: Scaffold(
        body: Stack(
          children: [
            videos.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: videos.length,
                    onPageChanged: (index) {
                      debugPrint(
                          "[DEBUG] User scrolled to video index: $index");
                      _playController(index);
                      if (index >= videos.length - 3) {
                        debugPrint(
                            "[DEBUG] Fetching more videos as user reached end");
                        fetchReels();
                      }
                    },
                    itemBuilder: (context, index) {
                      return ContentScreen(
                        controller: _controllers[index]!,
                        title: videos[index]['name']!,
                      );
                    },
                  ),
            Positioned(
              bottom: 40,
              right: 15,
              child: GestureDetector(
                onTap: _showReelSelectionSheet,
                child: Icon(CupertinoIcons.list_dash,
                    color: Colors.white, size: 30),
              ),
            ),

            // ⬇️ Subscription UI Overlay
            if (_showSubscriptionBox) _buildSubscriptionBox(),
          ],
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   print("REEL NAME ___${widget.nameReelVideo}");
  //   return Scaffold(
  //     body: Stack(
  //       children: [
  //         videos.isEmpty
  //             ? const Center(child: CircularProgressIndicator())
  //             : PageView.builder(
  //                 controller: _pageController,
  //                 scrollDirection: Axis.vertical,
  //                 itemCount: videos.length,
  //                 onPageChanged: (index) {
  //                   debugPrint("[DEBUG] User scrolled to video index: $index");
  //                   _playController(index);
  //                   if (index >= videos.length - 3) {
  //                     debugPrint(
  //                         "[DEBUG] Fetching more videos as user reached end");
  //                     fetchReels();
  //                   }
  //                 },
  //                 itemBuilder: (context, index) {
  //                   return ContentScreen(
  //                     controller: _controllers[index]!,
  //                     title: videos[index]['name']!,
  //                   );
  //                 },
  //               ),
  //         Positioned(
  //           bottom: 40,
  //           right: 15,
  //           child: GestureDetector(
  //             onTap: _showReelSelectionSheet,
  //             child:
  //                 Icon(CupertinoIcons.list_dash, color: Colors.white, size: 30),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
