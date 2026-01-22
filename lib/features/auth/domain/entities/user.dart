import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String fullName;
  final String? profilePicturePath;
  final DateTime? dateOfBirth;

  const User({
    required this.id,
    required this.username,
    required this.fullName,
    this.profilePicturePath,
    this.dateOfBirth,
  });

  @override
  List<Object?> get props =>
      [id, username, fullName, profilePicturePath, dateOfBirth];
}
