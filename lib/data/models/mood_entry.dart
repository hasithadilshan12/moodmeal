import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum Mood { calm, happy, stressed, sad, tired, excited, angry, bored }

extension MoodX on Mood {
  String get key => name;

  String get emoji => switch (this) {
        Mood.calm => '😌',
        Mood.happy => '😊',
        Mood.stressed => '😰',
        Mood.sad => '😢',
        Mood.tired => '😴',
        Mood.excited => '🤩',
        Mood.angry => '😠',
        Mood.bored => '😐',
      };

  List<Color> get gradient => AppColors.moods[key]!;

  Color get color => gradient[1];

  String get labelKey => 'mood.$key';

  /// A gentle, non-clinical note used on the result screen.
  String get careKey => 'mood.$key';
}

List<Mood> moodValues() => Mood.values;

/// A single mood check-in.
class MoodEntry {
  const MoodEntry({
    required this.id,
    required this.mood,
    required this.intensity,
    required this.createdAt,
    this.note = '',
    this.tags = const [],
  });

  final String id;
  final Mood mood;
  final int intensity; // 1..5
  final DateTime createdAt;
  final String note;
  final List<String> tags;

  MoodEntry copyWith({
    String? id,
    Mood? mood,
    int? intensity,
    DateTime? createdAt,
    String? note,
    List<String>? tags,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      intensity: intensity ?? this.intensity,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'mood': mood.name,
        'intensity': intensity,
        'created_at': createdAt.toIso8601String(),
        'note': note,
        'tags': tags,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        id: json['id'] as String,
        mood: Mood.values.firstWhere(
          (m) => m.name == json['mood'],
          orElse: () => Mood.calm,
        ),
        intensity: (json['intensity'] as num?)?.toInt() ?? 3,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
        note: json['note'] as String? ?? '',
        tags: (json['tags'] as List?)?.cast<String>() ?? const [],
      );
}
