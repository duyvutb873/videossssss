import 'package:flutter/material.dart';
import '../../models/media.dart';
import '../organisms/media_player.dart';

class MediaShowTemplate extends StatelessWidget {
  final Media media;
  final VoidCallback onMediaFinished;
  final int sequence;

  const MediaShowTemplate({super.key, required this.media, required this.onMediaFinished, required this.sequence});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SizedBox.expand(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.linear,
            switchOutCurve: Curves.linear,
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  for (final child in previousChildren) Positioned.fill(child: child),
                  if (currentChild != null) Positioned.fill(child: currentChild),
                ],
              );
            },
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: MediaPlayer(
              key: ValueKey('${media.id}::$sequence'),
              media: media,
              onFinished: onMediaFinished,
            ),
          ),
        ),
      ),
    );
  }
}
