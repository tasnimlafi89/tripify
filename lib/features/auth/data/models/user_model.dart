import '../../domain/entities/User.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.name,
    required super.email,
    super.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['displayName'] as String? ?? json['name'] as String?,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}
