import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('🔵 BLoC Created: ${bloc.runtimeType}');
  }

  @override
  void onEvent(BlocBase bloc, Object? event) {
    if (bloc is Bloc) {
      super.onEvent(bloc, event);
    }
    print('📤 Event: ${bloc.runtimeType} -> ${event.runtimeType}');
    print('   Event Data: $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('🔄 State Change: ${bloc.runtimeType}');
    print('   Current State: ${change.currentState}');
    print('   Next State: ${change.nextState}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    print('❌ Error in ${bloc.runtimeType}: $error');
    print('   StackTrace: $stackTrace');
  }

  @override
  void onTransition(Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);
    print('➡️ Transition: ${bloc.runtimeType}');
    print('   Event: ${transition.event}');
    print('   Current State: ${transition.currentState}');
    print('   Next State: ${transition.nextState}');
  }
}
