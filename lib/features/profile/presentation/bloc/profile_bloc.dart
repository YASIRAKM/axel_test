import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/auth_usecases.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/update_profile.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetCurrentUser _getCurrentUser;
  final UpdateProfile _updateProfile;

  ProfileBloc({
    required GetCurrentUser getCurrentUser,
    required UpdateProfile updateProfile,
  }) : _getCurrentUser = getCurrentUser,
       _updateProfile = updateProfile,
       super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await _getCurrentUser(NoParams());
    result.fold((failure) => emit(ProfileError(message: failure.message)), (
      user,
    ) {
      if (user != null) {
        
        emit(
          ProfileLoaded(user: user,   message: null),
        );
      } else {
        emit(const ProfileError(message: 'No user logged in'));
      }
    });
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await _updateProfile(event.user, imagePath: event.imagePath);
    result.fold((failure) => emit(ProfileError(message: failure.message)), (
      user,
    ) {
      emit(
        ProfileLoaded(
          user: user,

          message: 'Profile Updated Successfully',
        ),
      );
    });
  }

}
