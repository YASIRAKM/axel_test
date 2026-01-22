import 'dart:io';
import 'package:bloc/bloc.dart';
import 'register_form_state.dart';

class RegisterFormCubit extends Cubit<RegisterFormState> {
  RegisterFormCubit() : super(const RegisterFormState());

  void imageChanged(File? image) {
    emit(state.copyWith(imageFile: image));
  }

  void dateOfBirthChanged(DateTime? date) {
    emit(state.copyWith(dateOfBirth: date));
  }
}
