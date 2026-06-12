import 'package:flutter/foundation.dart';

@immutable
class AppUser {
  final int id;
  final String fullName;
  final String username;
  final String roleName;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.username,
    required this.roleName,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final role = json['Role'] as Map<String, dynamic>?;
    return AppUser(
      id: json['id'] as int,
      fullName: (json['full_name'] as String?) ?? '',
      username: json['username'] as String,
      roleName: (role?['role_name'] as String?) ?? 'kasir',
    );
  }
}
