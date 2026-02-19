class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String role; // owner, admin, beautician
  final bool isActive;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    required this.role,
    this.isActive = true,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      role: json['role'] ?? 'beautician',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Check if user is owner
  bool get isOwner => role == 'owner';

  /// Check if user is admin
  bool get isAdmin => role == 'admin';

  /// Check if user is beautician
  bool get isBeautician => role == 'beautician';

  /// Check if user has admin access (owner or admin)
  bool get hasAdminAccess => isOwner || isAdmin;

  /// Get role display name
  String get roleDisplayName {
    switch (role) {
      case 'owner':
        return 'Pemilik';
      case 'admin':
        return 'Admin';
      case 'beautician':
        return 'Beautician';
      default:
        return role;
    }
  }

  /// Get initials for avatar
  String get initials {
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return words
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? role,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
