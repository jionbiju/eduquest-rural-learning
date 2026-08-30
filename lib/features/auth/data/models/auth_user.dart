/// User roles in the system
enum UserRole {
  student,
  teacher;

  String toJson() => name;
  
  static UserRole fromJson(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.student,
    );
  }
}

/// Represents an authenticated user in the system.
class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.role = UserRole.student,
    this.groupId,
  });

  /// Firebase UID
  final String uid;

  /// User's email
  final String email;

  /// User's display name
  final String displayName;

  /// Optional profile picture URL
  final String? photoUrl;

  /// Account creation timestamp
  final DateTime createdAt;

  /// User role (student or teacher)
  final UserRole role;

  /// Group/class ID for grouping students and teachers
  final String? groupId;

  AuthUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    UserRole? role,
    String? groupId,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      groupId: groupId ?? this.groupId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'role': role.toJson(),
      'groupId': groupId,
    };
  }

  static AuthUser fromJson(Map<String, dynamic> json) {
    return AuthUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      role: json['role'] != null 
          ? UserRole.fromJson(json['role'] as String)
          : UserRole.student,
      groupId: json['groupId'] as String?,
    );
  }
}
