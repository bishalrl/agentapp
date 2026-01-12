import '../../../../../core/bloc/base_bloc_event.dart';

abstract class ChangePasswordEvent extends BaseBlocEvent {
  const ChangePasswordEvent();
}

class ChangePasswordRequestEvent extends ChangePasswordEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequestEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

