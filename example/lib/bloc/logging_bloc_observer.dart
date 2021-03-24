import 'package:bloc/bloc.dart';

class LoggingBlocObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    print(
        '${bloc.runtimeType}:\t${transition.currentState} + ${transition.event} -> ${transition.nextState}');
    super.onTransition(bloc, transition);
  }

  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
    print('${cubit.runtimeType}:\t$error');
    super.onError(cubit, error, stackTrace);
  }
}
