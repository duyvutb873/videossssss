enum MediaType { image, video, audio, unknown }

MediaType mediaTypeFromString(String? s) {
  switch (s?.toLowerCase()) {
    case 'video':
      return MediaType.video;
    case 'audio':
      return MediaType.audio;
    case 'image':
      return MediaType.image;
    default:
      return MediaType.unknown;
  }
}

class Media {
  final String id;
  final String url;
  final MediaType type;
  final int? duration; // giây, áp dụng cho ảnh/audio
  final String? title;
  final String? name;

  Media({
    required this.id,
    required this.url,
    required this.type,
    this.duration,
    this.title,
    this.name,
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    id: (json['id'] ?? '').toString(),
    url: (json['url'] ?? '').toString(),
    type: mediaTypeFromString(json['type']?.toString()),
    duration: _parseNullableInt(json['duration']),
    name: json['name']?.toString(),
    title: json['title']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'type': type.name,
    'duration': duration,
    'name': name,
    'title': title,
  };
}

int? _parseNullableInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  final s = v.toString();
  return int.tryParse(s);
}

// Helpers để trích playlist từ response login
// Định dạng response từ API:
// {
//   "device": {
//     "id": "...",
//     "name": "...",
//     "type": "...",
//     "location": "...",
//     "user_id": "..."
//   },
//   "content": {
//     "campaignName": "...",
//     "campaignId": "...",
//     "playlist": [
//       {
//         "id": "...",
//         "url": "...",
//         "name": "...",
//         "type": "image|video|audio",
//         "duration": null hoặc số giây
//       },
//       ...
//     ]
//   }
// }

List<Media> parsePlaylistFromLoginResponse(Map<String, dynamic> response) {
  try {
    final content = response['content'];
    if (content is! Map<String, dynamic>) return const [];

    final playlist = content['playlist'];
    if (playlist is! List) return const [];

    return playlist
        .whereType<Map>()
        .map((item) {
          try {
            return Media.fromJson(item.cast<String, dynamic>());
          } catch (_) {
            // Bỏ qua item không hợp lệ
            return null;
          }
        })
        .whereType<Media>()
        .toList();
  } catch (_) {
    return const [];
  }
}
