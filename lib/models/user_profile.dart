import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String? name;
  final String? email;
  final String? bio;
  final String? avatarUrl;
  final String? phoneNumber;
  final DateTime? birthDate;
  final List<String> interests;
  final bool isComplete;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    this.name,
    this.email,
    this.bio,
    this.avatarUrl,
    this.phoneNumber,
    this.birthDate,
    this.interests = const [],
    this.isComplete = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.empty(String id) {
    return UserProfile(
      id: id,
      createdAt: DateTime.now(),
      interests: const [],
      isComplete: false,
    );
  }

  bool get isPartial {
    return !isComplete &&
        (name != null ||
            email != null ||
            bio != null ||
            avatarUrl != null ||
            interests.isNotEmpty);
  }

  int get completionPercentage {
    int filledFields = 0;
    const int totalFields = 7;

    if (name != null && name!.isNotEmpty) filledFields++;
    if (email != null && email!.isNotEmpty) filledFields++;
    if (bio != null && bio!.isNotEmpty) filledFields++;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) filledFields++;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) filledFields++;
    if (birthDate != null) filledFields++;
    if (interests.isNotEmpty) filledFields++;

    return ((filledFields / totalFields) * 100).round();
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isComplete: json['isComplete'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate?.toIso8601String(),
      'interests': interests,
      'isComplete': isComplete,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? bio,
    String? avatarUrl,
    String? phoneNumber,
    DateTime? birthDate,
    List<String>? interests,
    bool? isComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthDate: birthDate ?? this.birthDate,
      interests: interests ?? this.interests,
      isComplete: isComplete ?? this.isComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        bio,
        avatarUrl,
        phoneNumber,
        birthDate,
        interests,
        isComplete,
        createdAt,
        updatedAt,
      ];
}