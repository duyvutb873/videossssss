import 'package:flutter/material.dart';
import '../../models/media.dart';
import '../organisms/media_player.dart';

class MediaShowTemplate extends StatelessWidget {
  final Media media;
  final VoidCallback onMediaFinished;

  const MediaShowTemplate({super.key, required this.media, required this.onMediaFinished});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SizedBox.expand(
          child: MediaPlayer(
            media: media,
            onFinished: onMediaFinished,
          ),
        ),
      ),
    );
  }
}
