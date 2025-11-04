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
  int _sequence = 0; // tăng sau mỗi lần chuyển media để ép rebuild
  List<String> _lastMediaIds = []; // Track media IDs để detect khi API thay đổi

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaList = Provider.of<AppState>(context, listen: false).mediaList;

    // Lấy danh sách IDs hiện tại
    final currentIds = mediaList.map((m) => m.id).toList();

    // Nếu danh sách media thay đổi hoàn toàn (API mới), reset lại từ đầu
    if (_lastMediaIds.isNotEmpty &&
        (currentIds.length != _lastMediaIds.length ||
            !_listsEqual(currentIds, _lastMediaIds))) {
      setState(() {
        _currentIndex = 0;
        _sequence = 0;
      });
    }

    // Nếu index vượt quá length thì reset về 0
    if (_currentIndex >= mediaList.length && mediaList.isNotEmpty) {
      setState(() {
        _currentIndex = 0;
      });
    }

    _lastMediaIds = currentIds;
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void nextMedia(int total) {
    print('🔔 nextMedia được gọi - total: $total');
    if (total == 0) return;
    final nextIndex = (_currentIndex + 1) % total;
    print('🔄 Chuyển media: $_currentIndex → $nextIndex (Total: $total)');
    setState(() {
      // Tự động quay lại từ đầu khi phát hết
      _currentIndex = nextIndex;
      _sequence++;
    });
    print(
      '✔️ setState đã xong - new index: $_currentIndex, sequence: $_sequence',
    );
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
    print(
      '🏗️ MediaShowPage build - index: $_currentIndex, sequence: $_sequence, total: ${mediaList.length}',
    );
    return MediaShowTemplate(
      media: mediaList[_currentIndex],
      onMediaFinished: () {
        print('🎯 onMediaFinished được gọi từ template!');
        nextMedia(mediaList.length);
      },
      sequence: _sequence,
    );
  }
}
