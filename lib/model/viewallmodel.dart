class VideoData {
  final int id;
  final String name;
  final String thumbnail;
  final String landscape;
  final String description;

  VideoData({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.landscape,
    required this.description,
  });

  factory VideoData.fromJson(Map<String, dynamic> json) {
    return VideoData(
      id: json['id'],
      name: json['name'],
      thumbnail: json['thumbnail'],
      landscape: json['landscape'],
      description: json['description'],
    );
  }
}
