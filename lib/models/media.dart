enum MediaType { image, video, audio, unknown }

MediaType mediaTypeFromString(String? s) {
  switch (s) {
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
    id: json['id'] ?? '',
    url: json['url'],
    type: mediaTypeFromString(json['type']),
    duration: json['duration'],
    name: json['name'],
    title: json['title'],
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
