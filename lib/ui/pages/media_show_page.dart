import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../states/app_state.dart';
import '../templates/media_show_template.dart';

class MediaShowPage extends StatefulWidget {
  const MediaShowPage({super.key});

  @override
  State<MediaShowPage> createState() => _MediaShowPageState();
}

class _MediaShowPageState extends State<MediaShowPage> {
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Nếu hết media hoặc chưa có media thì khởi tạo lại index
    final mediaList = Provider.of<AppState>(context, listen: false).mediaList;
    if (_currentIndex >= mediaList.length) {
      _currentIndex = 0;
    }
  }

  void nextMedia(int total) {
    setState(() {
      _currentIndex = (_currentIndex + 1) % total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final mediaList = appState.mediaList;
    if (mediaList.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return MediaShowTemplate(
      media: mediaList[_currentIndex],
      onMediaFinished: () => nextMedia(mediaList.length),
    );
  }
}
