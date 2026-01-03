import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? name;
  final String email;
  final String? photoUrl;

  const UserEntity({
    required this.id,
    this.name,
    required this.email,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, name, email, photoUrl];

}
