import 'package:flutter/material.dart';
import '../../models/media.dart';
import '../organisms/media_player.dart';

class MediaShowTemplate extends StatelessWidget {
  final Media media;
  final VoidCallback onMediaFinished;
  final int sequence;

  const MediaShowTemplate({
    super.key,
    required this.media,
    required this.onMediaFinished,
    required this.sequence,
  });

  @override
  Widget build(BuildContext context) {
    // Tạo key unique bằng cách kết hợp id, type và sequence để đảm bảo widget mới được tạo khi cần
    final uniqueKey = '${media.id}_${media.type.name}_$sequence';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SizedBox.expand(
          child: media.type == MediaType.image
              ? // Với ảnh, không dùng AnimatedSwitcher để tránh nháy
                MediaPlayer(
                  key: ValueKey(uniqueKey),
                  media: media,
                  onFinished: onMediaFinished,
                )
              : // Với video/audio, vẫn dùng AnimatedSwitcher
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: MediaPlayer(
                    key: ValueKey(uniqueKey),
                    media: media,
                    onFinished: onMediaFinished,
                  ),
                ),
        ),
      ),
    );
  }
}
