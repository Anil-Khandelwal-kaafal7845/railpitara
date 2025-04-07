import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ContentScreen extends StatefulWidget {
  final VideoPlayerController controller;
  final String title;

  const ContentScreen({Key? key, required this.controller, required this.title})
      : super(key: key);

  @override
  _ContentScreenState createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  bool _isPlaying = true;
  bool _showControls = true; // Show controls initially
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handlePlayPause);
    widget.controller.play();
    _startHideTimer(); // Start auto-hide timer immediately
  }

  void _handlePlayPause() {
    if (!mounted) return;
    setState(() {
      _isPlaying = widget.controller.value.isPlaying;
      if (!_isPlaying) {
        _showControls = true;
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) setState(() => _showControls = false);
    });
  }

  void _togglePlayPause() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
      _startHideTimer();
    }
  }

  void _seekToPosition(Duration position) {
    widget.controller.seekTo(position);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handlePlayPause);
    widget.controller.pause(); // Pause the video before disposing
    _hideTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleControls,
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width, // Full screen width
          height:
              MediaQuery.of(context).size.width * (16 / 9), // 9:16 aspect ratio
          child: AspectRatio(
            aspectRatio: 9 / 16, // Maintain 9:16 aspect ratio
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(widget.controller),

                // Play/Pause Button
                if (_showControls)
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        _isPlaying
                            ? CupertinoIcons.pause_fill
                            : CupertinoIcons.play_fill,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),

                // Back Button & Title
                if (_showControls)
                  Positioned(
                    top: 5,
                    left: 3,
                    child: Row(
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: const Icon(CupertinoIcons.back,
                              color: Colors.white, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Progress Bar
                if (_showControls)
                  Positioned(
                    bottom: 2,
                    left: 5,
                    right: 5,
                    child: VideoProgressIndicator(
                      widget.controller,
                      allowScrubbing: true,
                      padding: EdgeInsets.all(0),
                      colors: VideoProgressColors(
                        playedColor: Colors.white,
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.grey.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
