import 'package:tagarela/data/models/json.dart';

class User {
  const User({
    required this.name,
    required this.email,
    this.picture,
    this.country,
  });

  User.fromJson(Json json)
    : this(
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        picture: json['picture'] as String?,
        country: json['country'] as String?,
      );

  final String name;
  final String email;
  final String? picture;
  final String? country;

  Json toJson() => {
    'name': name,
    'email': email,
    'picture': ?picture,
    'country': ?country,
  };

  String get displayName => name.trim().isEmpty ? email : name.trim();

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  String get initials {
    final words = displayName.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final picked = words.length > 1 ? [words.first, words.last] : words;
    return picked.map((word) => word[0]).join().toUpperCase();
  }
}

class Stats {
  const Stats({required this.weekGain});

  Stats.fromJson(Json json) : this(weekGain: json['weekGain']! as int);

  final int weekGain;
}

class AuthTokens {
  const AuthTokens({required this.access, required this.refresh});

  AuthTokens.fromJson(Json json)
    : this(
        access: json['access_token']! as String,
        refresh: json['refresh_token']! as String,
      );

  final String access;
  final String refresh;
}
