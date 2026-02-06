import 'package:agentapp/features/profile/presentation/bloc/events/profile_event.dart';
import 'package:agentapp/features/profile/presentation/bloc/states/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/error_message_sanitizer.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';


class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile getProfile;
  final UpdateProfile updateProfile;

  ProfileBloc({
    required this.getProfile,
    required this.updateProfile,
  }) : super(ProfileInitial()) {
    on<GetProfileEvent>(_onGetProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onGetProfile(
    GetProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await getProfile();
    if (result is Error<ProfileEntity>) {
      final failure = (result as Error<ProfileEntity>).failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(ProfileError(errorMessage));
    } else if (result is Success<ProfileEntity>) {
      final profile = result.data;
      emit(ProfileLoaded(profile));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await updateProfile(
      agencyName: event.agencyName,
      ownerName: event.ownerName,
      panVatNumber: event.panVatNumber,
      address: event.address,
      districtProvince: event.districtProvince,
      primaryContact: event.primaryContact,
      alternateContact: event.alternateContact,
      whatsappViber: event.whatsappViber,
      officeLocation: event.officeLocation,
      officeOpenTime: event.officeOpenTime,
      officeCloseTime: event.officeCloseTime,
      numberOfEmployees: event.numberOfEmployees,
      hasDeviceAccess: event.hasDeviceAccess,
      hasInternetAccess: event.hasInternetAccess,
      preferredBookingMethod: event.preferredBookingMethod,
      avatarPath: event.avatarPath,
    );
    if (result is Error<ProfileEntity>) {
      final failure = (result as Error<ProfileEntity>).failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      emit(ProfileError(errorMessage));
    } else if (result is Success<ProfileEntity>) {
      final profile = result.data;
      emit(ProfileUpdated(profile));
    }
  }
}
