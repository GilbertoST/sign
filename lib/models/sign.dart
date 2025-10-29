class Sign {
  final int id;
  final String letter;
  final String? videoPath;
  final String? imagePath;
  final String? thumbnailUrl;  // URL miniature YouTube
  final String? description;
  final int difficulty;

  Sign({
    required this.id,
    required this.letter,
    this.videoPath,
    this.imagePath,
    this.thumbnailUrl,
    this.description,
    required this.difficulty,
  });

  factory Sign.fromJson(Map<String, dynamic> json) {
    return Sign(
      id: json['id'],
      letter: json['letter'],
      videoPath: json['video_path'],
      imagePath: json['image_path'],
      thumbnailUrl: json['thumbnail_url'],
      description: json['description'],
      difficulty: json['difficulty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'letter': letter,
      'video_path': videoPath,
      'image_path': imagePath,
      'thumbnail_url': thumbnailUrl,
      'description': description,
      'difficulty': difficulty,
    };
  }

  String get difficultyLabel {
    switch (difficulty) {
      case 1:
        return 'Facile';
      case 2:
        return 'Moyen';
      case 3:
        return 'Difficile';
      default:
        return 'Inconnu';
    }
  }
}

