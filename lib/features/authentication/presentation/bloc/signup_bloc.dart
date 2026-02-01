import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/error_message_sanitizer.dart';
import '../../domain/usecases/signup.dart';
import 'events/signup_event.dart';
import 'states/signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final Signup signup;

  SignupBloc({required this.signup}) : super(const SignupState()) {
    on<SignupRequestEvent>(_onSignup);
  }

  Future<void> _onSignup(
    SignupRequestEvent event,
    Emitter<SignupState> emit,
  ) async {
    print('🔵 SignupBloc._onSignup called');
    print('   Event: ${event.runtimeType}');
    print('   Agency: ${event.agencyName}');
    print('   Email: ${event.email}');
    print('   Citizenship File: ${event.citizenshipFile.path}');
    print('   Photo File: ${event.photoFile.path}');
    
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');

    final result = await signup(
      type: event.type,
      agencyName: event.agencyName,
      ownerName: event.ownerName,
      name: event.name,
      address: event.address,
      districtProvince: event.districtProvince,
      primaryContact: event.primaryContact,
      email: event.email,
      officeLocation: event.officeLocation,
      officeOpenTime: event.officeOpenTime,
      officeCloseTime: event.officeCloseTime,
      numberOfEmployees: event.numberOfEmployees,
      hasDeviceAccess: event.hasDeviceAccess,
      hasInternetAccess: event.hasInternetAccess,
      preferredBookingMethod: event.preferredBookingMethod,
      password: event.password,
      citizenshipFile: event.citizenshipFile,
      photoFile: event.photoFile,
      nameMatchImage: event.nameMatchImage,
      panVatNumber: event.panVatNumber,
      alternateContact: event.alternateContact,
      whatsappViber: event.whatsappViber,
      panFile: event.panFile,
      registrationFile: event.registrationFile,
    );

    if (result is Error) {
      final error = result as Error;
      final failure = error.failure;
      print('   ❌ Signup Error:');
      print('   Failure Type: ${failure.runtimeType}');
      print('   Error Message: ${failure.message}');
      print('   Full Error: $error');
      
      // Use centralized error sanitizer to prevent exposing backend errors
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      ));
      print('   State emitted: isLoading=false, errorMessage=$errorMessage');
    } else if (result is Success) {
      print('   ✅ Signup Success');
      emit(state.copyWith(
        isSuccess: true,
        isLoading: false,
        errorMessage: null,
        successMessage: 'Registration successful! We will review your documents and contact you by email after verification.',
      ));
      print('   State emitted: isSuccess=true, isLoading=false');
    }
  }
}
