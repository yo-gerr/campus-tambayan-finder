class MoodCheckIn {
  const MoodCheckIn({
    required this.placeId,
    required this.mood,
    this.nickname,
    this.createdAt,
  });

  final String placeId;
  final String mood; // 'happy', 'relaxed', 'stressed', 'sad'
  final String? nickname;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'place_id': placeId,
      'mood': mood,
    };
    if (nickname != null && nickname!.trim().isNotEmpty) {
      map['nickname'] = nickname!.trim();
    }
    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }
    return map;
  }

  factory MoodCheckIn.fromJson(Map<String, dynamic> json) {
    return MoodCheckIn(
      placeId: json['place_id'] as String,
      mood: json['mood'] as String,
      nickname: json['nickname'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
