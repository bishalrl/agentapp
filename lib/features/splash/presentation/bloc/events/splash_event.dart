import '../../../../../core/bloc/base_bloc_event.dart';

abstract class SplashEvent extends BaseBlocEvent {
  const SplashEvent();
}

class CheckAuthEvent extends SplashEvent {
  const CheckAuthEvent();
}

