import 'package:bloc/bloc.dart';

import '../../../../auth/domain/entities/user.dart';
import 'profile_form_state.dart';

class ProfileFormCubit extends Cubit<ProfileFormState> {
  ProfileFormCubit() : super(const ProfileFormState());

  void initialize(User user) {
    emit(
      ProfileFormState(
        dateOfBirth: user.dateOfBirth,
        imagePath: user.profilePicturePath,
        isDirty: false,
      ),
    );
  }

  void dateChanged(DateTime date) {
    emit(state.copyWith(dateOfBirth: date, isDirty: true));
  }

  void imageChanged(String? path) {
    emit(
      state.copyWith(
        imagePath: path,
        isDirty: true,
        setImagePathNull: path == null,
      ),
    );
  }

  void markDirty() {
    if (!state.isDirty) {
      emit(state.copyWith(isDirty: true));
    }
  }

  void resetDirty() {
    emit(state.copyWith(isDirty: false));
  }
}
