import 'package:equatable/equatable.dart';

class ProfileFormState extends Equatable {
  final DateTime? dateOfBirth;
  final String? imagePath;
  final bool isDirty;

  const ProfileFormState({
    this.dateOfBirth,
    this.imagePath,
    this.isDirty = false,
  });

  ProfileFormState copyWith({
    DateTime? dateOfBirth,
    String? imagePath,
    bool? isDirty,
    bool setDateOfBirthNull = false,
    bool setImagePathNull = false,
  }) {
    return ProfileFormState(
      dateOfBirth: setDateOfBirthNull
          ? null
          : (dateOfBirth ?? this.dateOfBirth),
      imagePath: setImagePathNull ? null : (imagePath ?? this.imagePath),
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [dateOfBirth, imagePath, isDirty];
}
