import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
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
  StreamSubscription? _audioCompleteSubscription;
  bool _imageLoaded = false;
  ImageProvider? _imageProvider;
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;
  bool _timerStarted = false;
  Timer? _imageTimer;
  VoidCallback? _videoListener;
  bool _hasFinished = false; // Flag để đảm bảo onFinished chỉ gọi 1 lần

  @override
  void initState() {
    super.initState();
    print('📱 MediaPlayer initState - ID: ${widget.media.id}');
    _hasFinished = false;
    _playMedia();
  }

  @override
  void didUpdateWidget(covariant MediaPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update khi media thay đổi (id, type, hoặc url khác)
    if (oldWidget.media.id != widget.media.id ||
        oldWidget.media.type != widget.media.type ||
        oldWidget.media.url != widget.media.url) {
      // Dừng media cũ ngay lập tức trước khi dispose
      _stopMedia();
      _imageLoaded = false;
      _timerStarted = false;
      _hasFinished = false;
      _disposeMedia();
      _playMedia();
    }
  }

  void _stopMedia() {
    // Dừng video ngay lập tức
    if (_videoController != null && _videoController!.value.isInitialized) {
      try {
        // Remove listener trước khi pause
        if (_videoListener != null) {
          _videoController!.removeListener(_videoListener!);
          _videoListener = null;
        }
        _videoController!.pause();
      } catch (_) {
        // Ignore errors
      }
    }

    // Dừng audio ngay lập tức
    if (_audioPlayer != null) {
      try {
        _audioPlayer!.stop();
      } catch (_) {
        // Ignore errors
      }
    }

    // Cancel timer
    _imageTimer?.cancel();
    _imageTimer = null;
  }

  void _playMedia() {
    print(
      '🎬 Bắt đầu phát media: ${widget.media.type.name} - ID: ${widget.media.id}',
    );
    if (widget.media.type == MediaType.video) {
      // Hỗ trợ phát video local với prefix file://
      if (widget.media.url.startsWith('file://')) {
        _videoController =
            VideoPlayerController.file(
                File(Uri.parse(widget.media.url).toFilePath()),
              )
              ..initialize().then((_) {
                if (mounted) {
                  setState(() {});
                }
                _videoController!.play();
                _videoController!.setVolume(1);
                _videoController!.setLooping(false);
                _videoListener = () {
                  if (!_hasFinished &&
                      _videoController != null &&
                      _videoController!.value.isInitialized &&
                      _videoController!.value.position >=
                          _videoController!.value.duration &&
                      mounted &&
                      _videoController!.value.duration.inMilliseconds > 0) {
                    // Set flag để tránh gọi nhiều lần
                    _hasFinished = true;
                    // Video kết thúc, báo cho parent để chuyển media tiếp theo
                    widget.onFinished();
                  }
                };
                _videoController!.addListener(_videoListener!);
              });
      } else {
        _videoController = VideoPlayerController.network(widget.media.url)
          ..initialize().then((_) {
            if (mounted) {
              setState(() {});
            }
            _videoController!.play();
            _videoController!.setVolume(1);
            _videoController!.setLooping(false);
            _videoListener = () {
              if (!_hasFinished &&
                  _videoController != null &&
                  _videoController!.value.isInitialized &&
                  _videoController!.value.position >=
                      _videoController!.value.duration &&
                  mounted &&
                  _videoController!.value.duration.inMilliseconds > 0) {
                // Set flag để tránh gọi nhiều lần
                _hasFinished = true;
                // Video kết thúc, báo cho parent để chuyển media tiếp theo
                widget.onFinished();
              }
            };
            _videoController!.addListener(_videoListener!);
          });
      }
    } else if (widget.media.type == MediaType.audio) {
      _audioPlayer = AudioPlayer();
      _audioPlayer!.play(UrlSource(widget.media.url));
      // Lưu subscription để có thể cancel sau
      _audioCompleteSubscription = _audioPlayer!.onPlayerComplete.listen((
        event,
      ) {
        // Audio kết thúc, báo cho parent để chuyển media tiếp theo
        if (mounted && !_hasFinished) {
          _hasFinished = true;
          widget.onFinished();
        }
      });
    } else if (widget.media.type == MediaType.image) {
      _imageLoaded = false;
      _timerStarted = false;
      _imageTimer?.cancel();
      _imageTimer = null;
      // Preload image để tránh nháy
      _imageProvider = NetworkImage(widget.media.url);
      _imageStream = _imageProvider!.resolve(const ImageConfiguration());
      _imageStreamListener = ImageStreamListener((
        ImageInfo image,
        bool synchronousCall,
      ) {
        // Chỉ set flag, không gọi setState để tránh rebuild
        if (mounted && !_imageLoaded) {
          _imageLoaded = true;
          // Start timer ngay khi image preload xong
          _startImageTimer();
        }
      });
      _imageStream!.addListener(_imageStreamListener!);
    }
  }

  void _startImageTimer() {
    if (!_timerStarted && mounted) {
      _timerStarted = true;
      _imageTimer?.cancel();
      final duration = widget.media.duration ?? 3; // Giảm xuống 3s để test
      _imageTimer = Timer(Duration(seconds: duration), () {
        if (mounted && !_hasFinished) {
          _hasFinished = true;
          // Ảnh kết thúc, báo cho parent để chuyển media tiếp theo
          widget.onFinished();
        } else {}
      });
    } else {}
  }

  void _disposeMedia() {
    // Dừng video trước khi dispose
    if (_videoController != null) {
      try {
        _videoController!.pause();
        // Remove listener nếu có
        if (_videoListener != null) {
          _videoController!.removeListener(_videoListener!);
          _videoListener = null;
        }
      } catch (_) {
        // Ignore errors
      }
      _videoController!.dispose();
      _videoController = null;
    }

    // Dừng audio trước khi dispose
    _audioCompleteSubscription?.cancel();
    _audioCompleteSubscription = null;
    if (_audioPlayer != null) {
      try {
        _audioPlayer!.stop();
      } catch (_) {
        // Ignore errors
      }
      _audioPlayer!.dispose();
      _audioPlayer = null;
    }

    _imageTimer?.cancel();
    _imageTimer = null;
    if (_imageStream != null && _imageStreamListener != null) {
      try {
        _imageStream!.removeListener(_imageStreamListener!);
      } catch (_) {
        // Ignore errors khi dispose
      }
      _imageStream = null;
      _imageStreamListener = null;
    }
    _imageProvider = null;
    _timerStarted = false;
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
      return RepaintBoundary(
        child: SizedBox.expand(
          child: Image(
            image: _imageProvider ?? NetworkImage(widget.media.url),
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                // Ảnh đã load xong trong widget - start timer nếu chưa start
                // Không gọi setState để tránh rebuild
                if (!_imageLoaded && mounted) {
                  _imageLoaded = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      // Start timer khi image widget đã render xong
                      _startImageTimer();
                    }
                  });
                }
                return child;
              }
              return Container(
                color: Colors.black,
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              // Nếu lỗi thì chuyển sang media tiếp theo sau 2 giây
              if (!_timerStarted && mounted) {
                _timerStarted = true;
                _imageTimer?.cancel();
                _imageTimer = Timer(const Duration(seconds: 2), () {
                  if (mounted && !_hasFinished) {
                    _hasFinished = true;

                    widget.onFinished();
                  }
                });
              }
              return Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(Icons.error, color: Colors.red, size: 64),
                ),
              );
            },
          ),
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
