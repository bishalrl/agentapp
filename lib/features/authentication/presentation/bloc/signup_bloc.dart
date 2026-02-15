import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/error_message_sanitizer.dart';
import '../../domain/usecases/signup.dart';
import '../../domain/usecases/send_otp.dart';
import 'events/signup_event.dart';
import 'states/signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final Signup signup;
  final SendOtp sendOtp;

  SignupBloc({
    required this.signup,
    required this.sendOtp,
  }) : super(const SignupState()) {
    on<SignupRequestEvent>(_onSignup);
    on<SignupSendOtpEvent>(_onSendOtp);
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
      agencyName: event.agencyName,
      ownerName: event.ownerName,
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
      panVatNumber: event.panVatNumber,
      alternateContact: event.alternateContact,
      whatsappViber: event.whatsappViber,
      panFile: event.panFile,
      registrationFile: event.registrationFile,
      otp: event.otp,
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

  Future<void> _onSendOtp(
    SignupSendOtpEvent event,
    Emitter<SignupState> emit,
  ) async {
    print('🔵 SignupBloc._onSendOtp called');
    emit(state.copyWith(isOtpSending: true, errorMessage: null));

    final result = await sendOtp(
      phone: event.phone,
      purpose: 'register',
      userType: 'Counter',
    );

    if (result is Error<void>) {
      final failure = result.failure;
      final errorMessage = ErrorMessageSanitizer.sanitize(failure);
      print('   ❌ Send OTP Error: ${failure.message}');
      emit(state.copyWith(
        isOtpSending: false,
        isOtpSent: false,
        errorMessage: errorMessage,
      ));
    } else if (result is Success<void>) {
      print('   ✅ OTP sent successfully from SignupBloc');
      emit(state.copyWith(
        isOtpSending: false,
        isOtpSent: true,
        errorMessage: null,
      ));
    }
  }
}
