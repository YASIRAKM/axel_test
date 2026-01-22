import 'dart:io';
import 'package:equatable/equatable.dart';

class RegisterFormState extends Equatable {
  final File? imageFile;
  final DateTime? dateOfBirth;

  const RegisterFormState({this.imageFile, this.dateOfBirth});

  RegisterFormState copyWith({File? imageFile, DateTime? dateOfBirth}) {
    return RegisterFormState(
      imageFile: imageFile ?? this.imageFile,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }

  @override
  List<Object?> get props => [imageFile, dateOfBirth];
}
