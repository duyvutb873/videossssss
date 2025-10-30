import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import '../../models/media.dart';

class MediaPlayer extends StatefulWidget {
  final Media media;
  final VoidCallback onFinished;
  const MediaPlayer({super.key, required this.media, required this.onFinished});

  @override
  State<MediaPlayer> createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _playMedia();
  }

  @override
  void didUpdateWidget(covariant MediaPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media.id != widget.media.id) {
      _disposeMedia();
      _playMedia();
    }
  }

  void _playMedia() {
    if (widget.media.type == MediaType.video) {
      // Hỗ trợ phát video local với prefix file://
      if (widget.media.url.startsWith('file://')) {
        _videoController =
            VideoPlayerController.file(
                File(Uri.parse(widget.media.url).toFilePath()),
              )
              ..initialize().then((_) {
                setState(() {
                  _loading = false;
                });
                _videoController!.play();
                _videoController!.setVolume(1);
                _videoController!.setLooping(false);
                _videoController!.addListener(() {
                  if (_videoController!.value.position >=
                          _videoController!.value.duration &&
                      mounted) {
                    widget.onFinished();
                  }
                });
              });
      } else {
        _videoController = VideoPlayerController.network(widget.media.url)
          ..initialize().then((_) {
            setState(() {
              _loading = false;
            });
            _videoController!.play();
            _videoController!.setVolume(1);
            _videoController!.setLooping(false);
            _videoController!.addListener(() {
              if (_videoController!.value.position >=
                      _videoController!.value.duration &&
                  mounted) {
                widget.onFinished();
              }
            });
          });
      }
    } else if (widget.media.type == MediaType.audio) {
      _audioPlayer = AudioPlayer();
      _audioPlayer!.play(UrlSource(widget.media.url));
      _audioPlayer!.onPlayerComplete.listen((event) {
        widget.onFinished();
      });
      if (widget.media.duration != null) {
        Future.delayed(
          Duration(seconds: widget.media.duration!),
          widget.onFinished,
        );
      }
    } else if (widget.media.type == MediaType.image) {
      Future.delayed(
        Duration(seconds: widget.media.duration ?? 5),
        widget.onFinished,
      );
    }
  }

  void _disposeMedia() {
    _videoController?.dispose();
    _videoController = null;
    _audioPlayer?.dispose();
    _audioPlayer = null;
  }

  @override
  void dispose() {
    _disposeMedia();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.media.type == MediaType.video &&
        _videoController != null &&
        _videoController!.value.isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
      );
    } else if (widget.media.type == MediaType.image) {
      return Center(
        child: Image.network(
          widget.media.url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (c, o, s) =>
              const Icon(Icons.error, color: Colors.red, size: 64),
        ),
      );
    } else if (widget.media.type == MediaType.audio) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.audiotrack, size: 100, color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              'Đang phát audio',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
