import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'mood_entry.dart';

class Meal {
  const Meal({
    required this.id,
    required this.name,
    required this.nameSi,
    required this.description,
    required this.descriptionSi,
    required this.emoji,
    required this.colors,
    required this.moods,
    required this.minutes,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
    required this.ingredientsSi,
    required this.mindfulPrompt,
    required this.mindfulPromptSi,
    required this.why,
    required this.whySi,
    this.isVegetarian = false,
    this.allergens = const [],
    this.avoidTags = const [],
    this.cuisine = 'cuisine.healthy',
  });

  final String id;
  final String name;
  final String nameSi;
  final String description;
  final String descriptionSi;
  final String emoji;
  final List<Color> colors;
  final List<Mood> moods;
  final int minutes;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final List<String> ingredients;
  final List<String> ingredientsSi;
  final String mindfulPrompt;
  final String mindfulPromptSi;
  final String why;
  final String whySi;
  final bool isVegetarian;
  final List<String> allergens;

  /// Preference keys from the "foods you prefer to avoid" list (`spicy`,
  /// `fried`, `oily`, `sugary`, `caffeine`, `redMeat`).
  final List<String> avoidTags;
  final String cuisine;

  LinearGradient get gradient => LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  String localizedName(bool isSi) => isSi ? nameSi : name;
  String localizedDescription(bool isSi) => isSi ? descriptionSi : description;
  String localizedWhy(bool isSi) => isSi ? whySi : why;
  String localizedPrompt(bool isSi) => isSi ? mindfulPromptSi : mindfulPrompt;
  List<String> localizedIngredients(bool isSi) =>
      isSi ? ingredientsSi : ingredients;

  bool worksFor(Mood mood) => moods.contains(mood);

  int matchScore(Mood mood) {
    if (moods.contains(mood)) return 86 + (id.hashCode % 13).abs();
    return 55 + (id.hashCode % 20).abs();
  }
}

class Tip {
  const Tip({
    required this.id,
    required this.emoji,
    required this.title,
    required this.titleSi,
    required this.body,
    required this.bodySi,
    required this.steps,
    required this.stepsSi,
    required this.tint,
    required this.minutes,
  });

  final String id;
  final String emoji;
  final String title;
  final String titleSi;
  final String body;
  final String bodySi;
  final List<String> steps;
  final List<String> stepsSi;
  final Color tint;
  final int minutes;

  String localizedTitle(bool isSi) => isSi ? titleSi : title;
  String localizedBody(bool isSi) => isSi ? bodySi : body;
  List<String> localizedSteps(bool isSi) => isSi ? stepsSi : steps;
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    this.avatar = '🌤️',
    this.photo = '',
    this.allergies = const [],
    this.conditions = const [],
    this.avoid = const [],
    this.language = 'en',
    this.reminderEnabled = true,
    this.reminderHour = 8,
    this.reminderMinute = 0,
    this.reminderDays = const [1, 2, 3, 4, 5, 6, 7],
  });

  final String name;
  final String email;
  final String avatar;

  /// Base64-encoded profile photo. Empty means the emoji [avatar] is shown.
  final String photo;
  final List<String> allergies;
  final List<String> conditions;
  final List<String> avoid;
  final String language;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final List<int> reminderDays;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'M';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  bool get hasPhoto => photo.isNotEmpty;

  String get reminderLabel {
    final h = reminderHour % 12 == 0 ? 12 : reminderHour % 12;
    final m = reminderMinute.toString().padLeft(2, '0');
    final suffix = reminderHour < 12 ? 'AM' : 'PM';
    return '$h:$m $suffix';
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? avatar,
    String? photo,
    List<String>? allergies,
    List<String>? conditions,
    List<String>? avoid,
    String? language,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    List<int>? reminderDays,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      photo: photo ?? this.photo,
      allergies: allergies ?? this.allergies,
      conditions: conditions ?? this.conditions,
      avoid: avoid ?? this.avoid,
      language: language ?? this.language,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      reminderDays: reminderDays ?? this.reminderDays,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'avatar': avatar,
        'photo': photo,
        'allergies': allergies,
        'conditions': conditions,
        'avoid': avoid,
        'language': language,
        'reminder_enabled': reminderEnabled,
        'reminder_hour': reminderHour,
        'reminder_minute': reminderMinute,
        'reminder_days': reminderDays,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String? ?? 'Friend',
        email: json['email'] as String? ?? '',
        avatar: json['avatar'] as String? ?? '🌤️',
        photo: json['photo'] as String? ?? '',
        allergies: (json['allergies'] as List?)?.cast<String>() ?? const [],
        conditions: (json['conditions'] as List?)?.cast<String>() ?? const [],
        avoid: (json['avoid'] as List?)?.cast<String>() ?? const [],
        language: json['language'] as String? ?? 'en',
        reminderEnabled: json['reminder_enabled'] as bool? ?? true,
        reminderHour: (json['reminder_hour'] as num?)?.toInt() ?? 8,
        reminderMinute: (json['reminder_minute'] as num?)?.toInt() ?? 0,
        reminderDays: (json['reminder_days'] as List?)
                ?.cast<num>()
                .map((e) => e.toInt())
                .toList() ??
            const [1, 2, 3, 4, 5, 6, 7],
      );
}

/// A small helper used by the UI for mood-tinted surfaces.
List<Color> moodGradient(Mood mood) => AppColors.moods[mood.name]!;

/// One ingredient line in a recipe, e.g. "80 g" + "rolled oats".
class RecipeIngredient {
  const RecipeIngredient({
    required this.quantity,
    required this.name,
    required this.nameSi,
  });

  final String quantity;
  final String name;
  final String nameSi;

  String localizedName(bool isSi) => isSi ? nameSi : name;
}

class RecipeStep {
  const RecipeStep({required this.text, required this.textSi});

  final String text;
  final String textSi;

  String localized(bool isSi) => isSi ? textSi : text;
}

/// Everything needed to actually cook a meal: quantities, ordered steps and a
/// cook's tip. Content is authored per meal so the app works fully offline.
class Recipe {
  const Recipe({
    required this.servings,
    required this.prepMinutes,
    required this.ingredients,
    required this.steps,
    this.tip,
    this.tipSi,
  });

  final int servings;
  final int prepMinutes;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;
  final String? tip;
  final String? tipSi;

  String? localizedTip(bool isSi) => isSi ? tipSi : tip;
}

/// A meal the user has actually cooked or eaten. Kept separate from moods so
/// the two can be correlated later without touching the check-in schema.
class MealLog {
  const MealLog({
    required this.id,
    required this.mealId,
    required this.createdAt,
  });

  final String id;
  final String mealId;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'meal_id': mealId,
        'created_at': createdAt.toIso8601String(),
      };

  factory MealLog.fromJson(Map<String, dynamic> json) => MealLog(
        id: json['id'] as String? ?? '',
        mealId: json['meal_id'] as String? ?? '',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
}

class MealVideo {
  const MealVideo({
    required this.id,
    required this.title,
    required this.channel,
    this.sinhala = false,
  });

  final String id;
  final String title;
  final String channel;

  /// True when the walkthrough is narrated in Sinhala.
  final bool sinhala;

  String get watchUrl => 'https://www.youtube.com/watch?v=$id';
  String get thumbnail => 'https://i.ytimg.com/vi/$id/hqdefault.jpg';

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'channel': channel,
        'sinhala': sinhala,
      };

  factory MealVideo.fromJson(Map<String, dynamic> json) => MealVideo(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        channel: json['channel'] as String? ?? '',
        sinhala: json['sinhala'] as bool? ?? false,
      );
}
