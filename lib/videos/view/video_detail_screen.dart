import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoDetailScreen extends StatefulWidget {
  VideoDetailScreen(
      {Key? key,
      required this.videoUrl,
      required this.title,
      required this.description})
      : super(key: key);
  final String videoUrl, title, description;

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.videoUrl)!,
      flags: YoutubePlayerFlags(
        autoPlay: true,
      ),
    )..addListener(listener);
    // TODO: implement initState
    super.initState();
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller!.value.isFullScreen) {
      // setState(() {
      //   _playerState = _controller!.value.playerState;
      //   _videoMetaData = _controller!.metadata;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("video details"),
      ),
      body: Column(children: [
        YoutubePlayer(
          controller: _controller!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.blueAccent,
          topActions: <Widget>[
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                _controller!.metadata.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 25.0,
              ),
              onPressed: () {
                log('Settings Tapped!');
              },
            ),
          ],
          onReady: () {
            _isPlayerReady = false;
            // _controller!.addListener(() { });
          },
          onEnded: (data) {
              // _controller
              //     !.load(_ids[(_ids.indexOf(data.videoId) + 1) % _ids.length]);
              // _showSnackBar('Next Video Started!');
          },
        ),
        Text(widget.title),
        Text(widget.description)
      ]),
    );
  }
}
