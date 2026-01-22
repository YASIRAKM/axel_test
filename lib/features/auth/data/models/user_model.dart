import 'package:hive/hive.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends User {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String username;
  @HiveField(2)
  final String fullName;
  @HiveField(3)
  final String? profilePicturePath;
  @HiveField(4)
  final DateTime? dateOfBirth;
  @HiveField(5)
  final String password; 
  @HiveField(6)
  final int failedAttempts;
  @HiveField(7)
  final DateTime? lockoutUntil;

  const UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    this.profilePicturePath,
    this.dateOfBirth,
    required this.password,
    this.failedAttempts = 0,
    this.lockoutUntil,
  }) : super(
         id: id,
         username: username,
         fullName: fullName,
         profilePicturePath: profilePicturePath,
         dateOfBirth: dateOfBirth,
       );

  factory UserModel.fromEntity(User user, String password) {
    return UserModel(
      id: user.id,
      username: user.username,
      fullName: user.fullName,
      profilePicturePath: user.profilePicturePath,
      dateOfBirth: user.dateOfBirth,
      password: password,
      failedAttempts: 0,
      lockoutUntil: null,
    );
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? fullName,
    String? profilePicturePath,
    DateTime? dateOfBirth,
    String? password,
    int? failedAttempts,
    DateTime? lockoutUntil,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      password: password ?? this.password,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockoutUntil: lockoutUntil ?? this.lockoutUntil,
    );
  }
}
