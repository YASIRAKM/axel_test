part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final User user;
  final String? imagePath;

  const UpdateProfileEvent({required this.user, this.imagePath});

  @override
  List<Object?> get props => [user, imagePath];
}
