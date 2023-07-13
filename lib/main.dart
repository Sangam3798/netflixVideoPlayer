import 'dart:developer';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stage_video_player/player_controller_ui.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Video Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Netflix Player'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key, required this.title});

  final String title;
  final ValueNotifier<bool> playVideoNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<bool>(
                valueListenable: playVideoNotifier,
                builder: (context, isPlay, child) {
                  return isPlay ? VideoPlayerScreen() : const SizedBox.shrink();
                }),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    playVideoNotifier.value = true;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.play_arrow),
                        SizedBox(width: 5),
                        Text('Play', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    playVideoNotifier.value = false;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.stop),
                        SizedBox(width: 5),
                        Text('Stop', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  ChewieController? _chewieController;
  VideoPlayerController? _videoPlayerController;
  TapDownDetails? doubleTapDetails;
  ValueNotifier<bool> playVideoNotifier = ValueNotifier(false);
  final List<Subtitles> subtitlesList = [
    Subtitles([]),
    Subtitles([
      Subtitle(
          index: 0, start: const Duration(seconds: 10), end: const Duration(seconds: 30), text: "Hey i am English subtitle"),
    ]),
    Subtitles([
      Subtitle(
          index: 0, start: const Duration(seconds: 10), end: const Duration(seconds: 30), text: "Hey i am Hindi subtitle"),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse('https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8'),
    );
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        allowedScreenSleep: false,
        customControls: CustomMediaControls(
          backgroundColor: Colors.black12,
          iconColor: Colors.white,
          videoTitle: 'Akamaihd',
          supportedSubTitle: const ['Off', 'English', 'Hindi'],
          onTabSubtitleBtn: (int? i) {
            _chewieController?.subtitle = subtitlesList[i ?? 1];
          },
        ),
        subtitle: subtitlesList[1],
        additionalOptions: (context) {
          return <OptionItem>[
            OptionItem(
              onTap: () {},
              iconData: Icons.live_tv_sharp,
              title: 'Toggle Video Src',
            ),
          ];
        },
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp]);
      _videoPlayerController?.initialize().then((value) {
        playVideoNotifier.value = true;
      _videoPlayerController?.play();
    });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    log('dispose called');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: ValueListenableBuilder(
          valueListenable: playVideoNotifier,
          builder: (context, isPlay, child) {
            return _chewieController != null && isPlay
                ? GestureDetector(
                    onDoubleTapDown: (TapDownDetails details) {
                      log('details of double tab down ${details.localPosition}');
                      log('details of double tab down ${details.globalPosition}');
                      doubleTapDetails = details;
                      showDialog(
                          context: context,
                          builder: (ctx) {
                            return Dialog(
                              child: Text('new data ${details.localPosition}'),
                            );
                          });
                    },
                    onDoubleTap: () {
                      log('double tab called');
                      showDialog(
                          context: context,
                          builder: (ctx) {
                            return Dialog(
                              child: Text('new data on Double tap ${doubleTapDetails?.localPosition}'),
                            );
                          });
                      // Duration? currentPosition = _chewieController?.videoPlayerController.value.position;
                      // Duration targetPosition =
                      //     currentPosition != null ? currentPosition + const Duration(seconds: 10) : const Duration(seconds: 10);
                      // _chewieController?.seekTo(targetPosition);
                    },
                    child: Chewie(
                      controller: _chewieController!,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 20),
                      Text(
                        'Loading...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  );
          },
        ));
  }
}
