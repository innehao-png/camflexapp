class UserProfile {
  final dynamic id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Support nested "data" wrapper (Laravel Resource style)
    final Map<String, dynamic> data =
        json.containsKey('data') && json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : json;

    return UserProfile(
      id: data['id'],
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString(),
      avatarUrl: data['avatar_url']?.toString() ??
          data['avatar']?.toString() ??
          data['profile_photo_url']?.toString(),
    );
  }

  UserProfile copyWith({
    dynamic id,
    String? name,
    String? email,
    String? phone,
    Object? avatarUrl = _sentinel,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl == _sentinel
          ? this.avatarUrl
          : avatarUrl as String?,
    );
  }

  /// Initials derived from the user's name (e.g. "John Doe" → "JD")
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// A private sentinel so `copyWith` can distinguish null from "not provided".
const Object _sentinel = Object();
